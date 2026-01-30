import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../../core/utils/text_crdt.dart';
import '../../../main.dart';

/// Render CRDT JSON to plain text (for display in dashboard)
String _renderCrdtToText(String content) {
  if (!content.startsWith('[') || !content.contains('"id"')) {
    return content; // Not CRDT JSON, return as-is
  }
  try {
    final list = jsonDecode(content) as List<dynamic>;
    // Sort by position and filter out deleted chars
    final chars = list
        .map((item) => item as Map<String, dynamic>)
        .where((item) => item['deleted'] != true)
        .toList()
      ..sort((a, b) => (a['position'] as num).compareTo(b['position'] as num));
    return chars.map((c) => c['char'] as String).join();
  } catch (_) {
    return content;
  }
}

/// Generate a simple user ID
String _generateUserId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rng = Random();
  return List.generate(12, (_) => chars[rng.nextInt(chars.length)]).join();
}

/// Key for storing user ID in localStorage
const _userIdKey = 'breakout_butler_user_id';

/// Cached user ID (loaded from storage or generated)
String? _cachedUserId;

/// Get or create a persistent user ID using web localStorage
String _getOrCreateUserId() {
  if (_cachedUserId != null) return _cachedUserId!;

  try {
    final stored = web.window.localStorage.getItem(_userIdKey);
    if (stored != null && stored.isNotEmpty) {
      _cachedUserId = stored;
      return stored;
    }
  } catch (_) {
    // localStorage not available, generate new ID
  }

  final userId = _generateUserId();
  try {
    web.window.localStorage.setItem(_userIdKey, userId);
  } catch (_) {
    // Ignore storage errors
  }

  _cachedUserId = userId;
  return userId;
}

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
        map[room.roomNumber] = RoomState(
          content: _renderCrdtToText(room.content),
          occupantCount: 0,
        );
      }
      if (mounted) state = map;
    });

    // Subscribe to live updates
    _sub = client.room.allRoomUpdates(_sessionId).listen((update) {
      if (mounted) {
        state = {
          ...state,
          update.roomNumber: RoomState(
            content: _renderCrdtToText(update.content),
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
  TextCrdt? _textCrdt;
  String? _userId;
  Timer? _contentDebounce;
  Timer? _drawingDebounce;
  Timer? _editingCooldown;
  Timer? _presenceDebounce;
  Timer? _heartbeatTimer;
  StreamSubscription<RoomUpdate>? _sub;
  StreamSubscription<PresenceUpdate>? _presenceSub;
  String _lastSavedCrdtJson = '';
  String _lastSavedDrawing = '';
  bool _hasJoined = false;
  bool _isLocallyEditingDrawing = false;

  Future<void> init() async {
    try {
      // Get persistent user ID first (sync, uses localStorage)
      _userId = _getOrCreateUserId();
      _textCrdt = TextCrdt(nodeId: _userId);

      // Join the room with user ID
      try {
        final presence = await client.room.joinRoom(
          _sessionId,
          _roomNumber,
          _userId!,
          null, // Auto-generate display name
        );
        _hasJoined = true;
        if (mounted) {
          state = state.copyWith(myPresence: presence);
        }

        // Start heartbeat to keep presence alive (every 15 seconds)
        _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
          if (_hasJoined && mounted) {
            _sendHeartbeat();
          }
        });
      } catch (_) {
        // Ignore join errors - room updates will still work
      }

      // Load initial content - try to load as CRDT JSON, fallback to plain text
      final room = await client.room.getRoom(_sessionId, _roomNumber);
      if (room != null && mounted) {
        _lastSavedDrawing = room.drawingData ?? '';

        // Try to load as CRDT JSON, fallback to treating as plain text
        final content = room.content;
        if (content.startsWith('[') && content.contains('"id"')) {
          // Looks like CRDT JSON
          _textCrdt!.loadFromJson(content);
          _lastSavedCrdtJson = content;
          state = state.copyWith(
            content: _textCrdt!.text,
            crdtJson: _lastSavedCrdtJson,
            drawingData: room.drawingData ?? '',
            loaded: true,
          );
        } else if (content.length < 1000) {
          // Small plain text - convert to CRDT
          _textCrdt!.replaceAll(content);
          _lastSavedCrdtJson = _textCrdt!.toJson();
          state = state.copyWith(
            content: _textCrdt!.text,
            crdtJson: _lastSavedCrdtJson,
            drawingData: room.drawingData ?? '',
            loaded: true,
          );
        } else {
          // Large plain text - start fresh (legacy data, can't convert efficiently)
          _lastSavedCrdtJson = '[]';
          state = state.copyWith(
            content: '',
            crdtJson: '[]',
            drawingData: room.drawingData ?? '',
            loaded: true,
          );
        }
      } else if (mounted) {
        state = state.copyWith(content: '', crdtJson: '[]', drawingData: '', loaded: true);
      }
    } catch (e) {
      // If anything fails, at least mark as loaded so UI isn't stuck
      if (mounted) {
        state = state.copyWith(content: '', crdtJson: '[]', drawingData: '', loaded: true);
      }
    }

    // Subscribe to remote updates
    _sub = client.room
        .roomUpdates(_sessionId, _roomNumber)
        .listen((update) {
      if (!mounted) return;

      // Always update occupant count and presence
      state = state.copyWith(
        occupantCount: update.occupantCount,
        presence: update.presence ?? [],
      );

      // Merge remote CRDT content
      final remoteContent = update.content;
      if (remoteContent != _lastSavedCrdtJson && _textCrdt != null) {
        if (remoteContent.startsWith('[') && remoteContent.contains('"id"')) {
          // Remote is CRDT JSON - merge it
          _textCrdt!.merge(remoteContent);
          _lastSavedCrdtJson = _textCrdt!.toJson();
          state = state.copyWith(
            content: _textCrdt!.text,
            crdtJson: _lastSavedCrdtJson,
          );
        }
        // If remote is plain text, ignore it (we're using CRDT now)
      }

      // Only apply remote drawing if we're not actively editing
      final remoteDrawing = update.drawingData ?? '';
      if (!_isLocallyEditingDrawing && remoteDrawing != _lastSavedDrawing) {
        _lastSavedDrawing = remoteDrawing;
        state = state.copyWith(drawingData: remoteDrawing);
      }
    });

    // Subscribe to presence updates for real-time cursor tracking
    _presenceSub = client.room
        .presenceUpdates(_sessionId, _roomNumber)
        .listen((update) {
      if (!mounted) return;

      final currentPresence = Map<String, UserPresence>.fromIterable(
        state.presence,
        key: (p) => (p as UserPresence).userId,
        value: (p) => p as UserPresence,
      );

      if (update.joined == false) {
        // User left
        currentPresence.remove(update.user.userId);
      } else {
        // User joined or updated
        currentPresence[update.user.userId] = update.user;
      }

      state = state.copyWith(
        presence: currentPresence.values.toList(),
        occupantCount: currentPresence.length,
      );
    });
  }

  void updateContent(String newText, {int cursorPosition = -1}) {
    if (!mounted || _textCrdt == null) return;

    // Apply change to CRDT
    final oldText = _textCrdt!.text;
    _textCrdt!.applyChange(oldText, newText);

    final crdtJson = _textCrdt!.toJson();
    state = state.copyWith(
      content: _textCrdt!.text,
      crdtJson: crdtJson,
    );

    _contentDebounce?.cancel();
    _contentDebounce = Timer(const Duration(milliseconds: 300), () {
      _saveContent(crdtJson);
    });

    // Send presence update (typing state + cursor position)
    _sendPresenceUpdate(
      isTyping: true,
      textCursor: cursorPosition,
    );

    // Reset typing indicator after cooldown
    _editingCooldown?.cancel();
    _editingCooldown = Timer(const Duration(milliseconds: 1500), () {
      _sendPresenceUpdate(isTyping: false);
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
      // Also mark as not drawing
      _sendPresenceUpdate(isDrawing: false);
    });
  }

  /// Update drawing cursor position (called on pointer move)
  void updateDrawingCursor(double x, double y) {
    _sendPresenceUpdate(
      isDrawing: true,
      drawingX: x,
      drawingY: y,
    );
  }

  /// Send presence update to server (debounced)
  void _sendPresenceUpdate({
    bool? isTyping,
    int? textCursor,
    bool? isDrawing,
    double? drawingX,
    double? drawingY,
  }) {
    if (!_hasJoined || state.myPresence == null) return;

    // Debounce presence updates to avoid flooding
    _presenceDebounce?.cancel();
    _presenceDebounce = Timer(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      final updated = UserPresence(
        userId: state.myPresence!.userId,
        displayName: state.myPresence!.displayName,
        color: state.myPresence!.color,
        textCursor: textCursor ?? state.myPresence!.textCursor,
        isTyping: isTyping ?? state.myPresence!.isTyping,
        drawingX: drawingX ?? state.myPresence!.drawingX,
        drawingY: drawingY ?? state.myPresence!.drawingY,
        isDrawing: isDrawing ?? state.myPresence!.isDrawing,
        lastActive: DateTime.now(),
      );

      state = state.copyWith(myPresence: updated);
      client.room.updatePresence(_sessionId, _roomNumber, updated);
    });
  }

  /// Send a heartbeat to keep presence alive
  void _sendHeartbeat() {
    if (!_hasJoined || state.myPresence == null || !mounted) return;

    final updated = UserPresence(
      userId: state.myPresence!.userId,
      displayName: state.myPresence!.displayName,
      color: state.myPresence!.color,
      textCursor: state.myPresence!.textCursor,
      isTyping: false,
      drawingX: state.myPresence!.drawingX,
      drawingY: state.myPresence!.drawingY,
      isDrawing: false,
      lastActive: DateTime.now(),
    );

    state = state.copyWith(myPresence: updated);
    client.room.updatePresence(_sessionId, _roomNumber, updated);
  }

  Future<void> _saveContent(String crdtJson) async {
    if (!mounted) return;
    state = state.copyWith(isSaving: true);
    try {
      await client.room.updateRoomContent(_sessionId, _roomNumber, crdtJson);
      _lastSavedCrdtJson = crdtJson;
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
    _presenceDebounce?.cancel();
    _heartbeatTimer?.cancel();
    _sub?.cancel();
    _presenceSub?.cancel();
    // Leave the room
    if (_hasJoined && _userId != null) {
      client.room.leaveRoom(_sessionId, _roomNumber, _userId!).catchError((_) {});
    }
    super.dispose();
  }
}

class RoomEditorState {
  const RoomEditorState({
    this.content = '',
    this.crdtJson = '[]',
    this.drawingData = '',
    this.isSaving = false,
    this.loaded = false,
    this.occupantCount = 0,
    this.presence = const [],
    this.myPresence,
  });

  /// Rendered text content (for display)
  final String content;

  /// CRDT JSON data (for sync)
  final String crdtJson;

  final String drawingData;
  final bool isSaving;
  final bool loaded;
  final int occupantCount;
  final List<UserPresence> presence;
  final UserPresence? myPresence;

  /// Get other users' presence (excluding self)
  List<UserPresence> get otherUsers =>
      presence.where((p) => p.userId != myPresence?.userId).toList();

  RoomEditorState copyWith({
    String? content,
    String? crdtJson,
    String? drawingData,
    bool? isSaving,
    bool? loaded,
    int? occupantCount,
    List<UserPresence>? presence,
    UserPresence? myPresence,
  }) {
    return RoomEditorState(
      content: content ?? this.content,
      crdtJson: crdtJson ?? this.crdtJson,
      drawingData: drawingData ?? this.drawingData,
      isSaving: isSaving ?? this.isSaving,
      loaded: loaded ?? this.loaded,
      occupantCount: occupantCount ?? this.occupantCount,
      presence: presence ?? this.presence,
      myPresence: myPresence ?? this.myPresence,
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
