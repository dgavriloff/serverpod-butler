import 'dart:async';

import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';

/// Stream of updates for a single room.
final roomUpdatesProvider =
    StreamProvider.autoDispose.family<RoomUpdate, ({int sessionId, int roomNumber})>(
  (ref, args) => client.room.roomUpdates(args.sessionId, args.roomNumber),
);

/// Stream of updates for all rooms in a session (professor dashboard).
final allRoomUpdatesProvider =
    StreamProvider.autoDispose.family<RoomUpdate, int>(
  (ref, sessionId) => client.room.allRoomUpdates(sessionId),
);

/// Fetch all rooms for a session.
final allRoomsProvider =
    FutureProvider.autoDispose.family<List<Room>, int>(
  (ref, sessionId) => client.room.getAllRooms(sessionId),
);

/// Maintains a map of room number → content, merging stream updates.
/// Used by the professor dashboard to show all room content.
class RoomContentsNotifier extends StateNotifier<Map<int, String>> {
  RoomContentsNotifier(this._ref, this._sessionId) : super({}) {
    _init();
  }

  final Ref _ref;
  final int _sessionId;
  StreamSubscription<RoomUpdate>? _sub;

  void _init() {
    // Load initial room contents
    _ref.read(allRoomsProvider(_sessionId).future).then((rooms) {
      final map = <int, String>{};
      for (final room in rooms) {
        map[room.roomNumber] = room.content;
      }
      if (mounted) state = map;
    });

    // Subscribe to live updates
    _sub = client.room.allRoomUpdates(_sessionId).listen((update) {
      if (mounted) {
        state = {...state, update.roomNumber: update.content};
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final roomContentsProvider = StateNotifierProvider.autoDispose
    .family<RoomContentsNotifier, Map<int, String>, int>(
  (ref, sessionId) => RoomContentsNotifier(ref, sessionId),
);

/// Manages local content editing + debounced save for a student room.
class RoomEditorNotifier extends StateNotifier<RoomEditorState> {
  RoomEditorNotifier(this._sessionId, this._roomNumber)
      : super(const RoomEditorState());

  final int _sessionId;
  final int _roomNumber;
  Timer? _saveDebounce;
  StreamSubscription<RoomUpdate>? _sub;
  String _lastSavedContent = '';

  Future<void> init() async {
    // Load initial content
    final room = await client.room.getRoom(_sessionId, _roomNumber);
    if (room != null && mounted) {
      _lastSavedContent = room.content;
      state = state.copyWith(content: room.content, loaded: true);
    } else if (mounted) {
      state = state.copyWith(content: '', loaded: true);
    }

    // Subscribe to remote updates
    _sub = client.room
        .roomUpdates(_sessionId, _roomNumber)
        .listen((update) {
      if (mounted && update.content != _lastSavedContent) {
        state = state.copyWith(content: update.content);
      }
    });
  }

  void updateContent(String content) {
    if (!mounted) return;
    state = state.copyWith(content: content);

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _save(content);
    });
  }

  Future<void> _save(String content) async {
    if (!mounted) return;
    state = state.copyWith(isSaving: true);
    try {
      await client.room.updateRoomContent(_sessionId, _roomNumber, content);
      _lastSavedContent = content;
    } finally {
      if (mounted) state = state.copyWith(isSaving: false);
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}

class RoomEditorState {
  const RoomEditorState({
    this.content = '',
    this.isSaving = false,
    this.loaded = false,
  });

  final String content;
  final bool isSaving;
  final bool loaded;

  RoomEditorState copyWith({
    String? content,
    bool? isSaving,
    bool? loaded,
  }) {
    return RoomEditorState(
      content: content ?? this.content,
      isSaving: isSaving ?? this.isSaving,
      loaded: loaded ?? this.loaded,
    );
  }
}

final roomEditorProvider = StateNotifierProvider.autoDispose
    .family<RoomEditorNotifier, RoomEditorState, ({int sessionId, int roomNumber})>(
  (ref, args) {
    final notifier = RoomEditorNotifier(args.sessionId, args.roomNumber);
    notifier.init();
    return notifier;
  },
);
