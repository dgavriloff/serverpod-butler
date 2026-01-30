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

/// Room state including content and occupant count.
class RoomState {
  const RoomState({this.content = '', this.occupantCount = 0});
  final String content;
  final int occupantCount;

  RoomState copyWith({String? content, int? occupantCount}) {
    return RoomState(
      content: content ?? this.content,
      occupantCount: occupantCount ?? this.occupantCount,
    );
  }
}

/// Maintains a map of room number → RoomState, merging stream updates.
/// Used by the professor dashboard to show all room content and occupants.
class RoomContentsNotifier extends StateNotifier<Map<int, RoomState>> {
  RoomContentsNotifier(this._ref, this._sessionId) : super({}) {
    _init();
  }

  final Ref _ref;
  final int _sessionId;
  StreamSubscription<RoomUpdate>? _sub;

  void _init() {
    // Load initial room contents
    _ref.read(allRoomsProvider(_sessionId).future).then((rooms) {
      final map = <int, RoomState>{};
      for (final room in rooms) {
        map[room.roomNumber] = RoomState(content: room.content, occupantCount: 0);
      }
      if (mounted) state = map;
    });

    // Subscribe to live updates
    _sub = client.room.allRoomUpdates(_sessionId).listen((update) {
      if (mounted) {
        state = {
          ...state,
          update.roomNumber: RoomState(
            content: update.content,
            occupantCount: update.occupantCount,
          ),
        };
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
    .family<RoomContentsNotifier, Map<int, RoomState>, int>(
  (ref, sessionId) => RoomContentsNotifier(ref, sessionId),
);

/// Manages local content + drawing editing with debounced save for a student room.
class RoomEditorNotifier extends StateNotifier<RoomEditorState> {
  RoomEditorNotifier(this._sessionId, this._roomNumber)
      : super(const RoomEditorState());

  final int _sessionId;
  final int _roomNumber;
  Timer? _contentDebounce;
  Timer? _drawingDebounce;
  Timer? _editingCooldown;
  StreamSubscription<RoomUpdate>? _sub;
  String _lastSavedContent = '';
  String _lastSavedDrawing = '';
  bool _hasJoined = false;
  bool _isLocallyEditingContent = false;
  bool _isLocallyEditingDrawing = false;

  Future<void> init() async {
    // Join the room (increment occupant count)
    try {
      final count = await client.room.joinRoom(_sessionId, _roomNumber);
      _hasJoined = true;
      if (mounted) state = state.copyWith(occupantCount: count);
    } catch (_) {
      // Ignore join errors - room updates will still work
    }

    // Load initial content
    final room = await client.room.getRoom(_sessionId, _roomNumber);
    if (room != null && mounted) {
      _lastSavedContent = room.content;
      _lastSavedDrawing = room.drawingData ?? '';
      state = state.copyWith(
        content: room.content,
        drawingData: room.drawingData ?? '',
        loaded: true,
      );
    } else if (mounted) {
      state = state.copyWith(content: '', drawingData: '', loaded: true);
    }

    // Subscribe to remote updates
    _sub = client.room
        .roomUpdates(_sessionId, _roomNumber)
        .listen((update) {
      if (!mounted) return;

      // Always update occupant count
      state = state.copyWith(occupantCount: update.occupantCount);

      // Only apply remote content if we're not actively editing
      if (!_isLocallyEditingContent && update.content != _lastSavedContent) {
        _lastSavedContent = update.content;
        state = state.copyWith(content: update.content);
      }

      // Only apply remote drawing if we're not actively editing
      final remoteDrawing = update.drawingData ?? '';
      if (!_isLocallyEditingDrawing && remoteDrawing != _lastSavedDrawing) {
        _lastSavedDrawing = remoteDrawing;
        state = state.copyWith(drawingData: remoteDrawing);
      }
    });
  }

  void updateContent(String content) {
    if (!mounted) return;
    _isLocallyEditingContent = true;
    state = state.copyWith(content: content);

    _contentDebounce?.cancel();
    _contentDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveContent(content);
    });

    // Reset editing flag after a longer cooldown to allow save + broadcast to complete
    _editingCooldown?.cancel();
    _editingCooldown = Timer(const Duration(milliseconds: 1500), () {
      _isLocallyEditingContent = false;
    });
  }

  void updateDrawing(String drawingData) {
    if (!mounted) return;
    _isLocallyEditingDrawing = true;
    state = state.copyWith(drawingData: drawingData);

    _drawingDebounce?.cancel();
    _drawingDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveDrawing(drawingData);
    });

    // Reset editing flag after cooldown
    _editingCooldown?.cancel();
    _editingCooldown = Timer(const Duration(milliseconds: 1500), () {
      _isLocallyEditingDrawing = false;
    });
  }

  Future<void> _saveContent(String content) async {
    if (!mounted) return;
    state = state.copyWith(isSaving: true);
    try {
      await client.room.updateRoomContent(_sessionId, _roomNumber, content);
      _lastSavedContent = content;
    } finally {
      if (mounted) state = state.copyWith(isSaving: false);
    }
  }

  Future<void> _saveDrawing(String drawingData) async {
    if (!mounted) return;
    state = state.copyWith(isSaving: true);
    try {
      await client.room
          .updateRoomDrawing(_sessionId, _roomNumber, drawingData);
      _lastSavedDrawing = drawingData;
    } finally {
      if (mounted) state = state.copyWith(isSaving: false);
    }
  }

  @override
  void dispose() {
    _contentDebounce?.cancel();
    _drawingDebounce?.cancel();
    _editingCooldown?.cancel();
    _sub?.cancel();
    // Leave the room (decrement occupant count)
    if (_hasJoined) {
      client.room.leaveRoom(_sessionId, _roomNumber).catchError((_) {});
    }
    super.dispose();
  }
}

class RoomEditorState {
  const RoomEditorState({
    this.content = '',
    this.drawingData = '',
    this.isSaving = false,
    this.loaded = false,
    this.occupantCount = 0,
  });

  final String content;
  final String drawingData;
  final bool isSaving;
  final bool loaded;
  final int occupantCount;

  RoomEditorState copyWith({
    String? content,
    String? drawingData,
    bool? isSaving,
    bool? loaded,
    int? occupantCount,
  }) {
    return RoomEditorState(
      content: content ?? this.content,
      drawingData: drawingData ?? this.drawingData,
      isSaving: isSaving ?? this.isSaving,
      loaded: loaded ?? this.loaded,
      occupantCount: occupantCount ?? this.occupantCount,
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
