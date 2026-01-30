import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// In-memory tracking of room occupants and presence.
/// Key: 'sessionId-roomNumber', Value: map of userId -> UserPresence
final Map<String, Map<String, UserPresence>> _roomPresence = {};

String _presenceKey(int sessionId, int roomNumber) => '$sessionId-$roomNumber';

/// Get presence map for a room, creating if needed
Map<String, UserPresence> _getPresenceMap(int sessionId, int roomNumber) {
  final key = _presenceKey(sessionId, roomNumber);
  return _roomPresence.putIfAbsent(key, () => {});
}

/// Stale timeout - users inactive for this long are removed
const _staleTimeout = Duration(seconds: 30);

/// Clean up stale users from a room (called periodically)
List<String> _cleanupStaleUsers(int sessionId, int roomNumber) {
  final presenceMap = _getPresenceMap(sessionId, roomNumber);
  final now = DateTime.now();
  final staleUserIds = <String>[];

  presenceMap.removeWhere((userId, presence) {
    final isStale = now.difference(presence.lastActive) > _staleTimeout;
    if (isStale) staleUserIds.add(userId);
    return isStale;
  });

  return staleUserIds;
}

/// Available colors for users (assigned round-robin)
const _userColors = [
  '#FF6B6B', // red
  '#4ECDC4', // teal
  '#45B7D1', // blue
  '#96CEB4', // green
  '#FFEAA7', // yellow
  '#DDA0DD', // plum
  '#98D8C8', // mint
  '#F7DC6F', // gold
];

/// Endpoint for managing breakout room workspaces with real-time collaboration
class RoomEndpoint extends Endpoint {
  // Channel for all room updates in a session (professor dashboard)
  static String _allRoomsChannel(int sessionId) => 'all-rooms-$sessionId';

  // Channel for a specific room
  static String _roomChannel(int sessionId, int roomNumber) =>
      'room-$sessionId-$roomNumber';

  // Channel for presence updates (separate from content for efficiency)
  static String _presenceChannel(int sessionId, int roomNumber) =>
      'presence-$sessionId-$roomNumber';

  /// Get current occupant count for a room
  int _getOccupantCount(int sessionId, int roomNumber) {
    return _getPresenceMap(sessionId, roomNumber).length;
  }

  /// Get list of current user presences for a room
  List<UserPresence> _getPresenceList(int sessionId, int roomNumber) {
    return _getPresenceMap(sessionId, roomNumber).values.toList();
  }

  /// Called when a student enters a room
  Future<UserPresence> joinRoom(
    Session session,
    int sessionId,
    int roomNumber,
    String odtuserId,
    String? displayName,
  ) async {
    // Clean up stale users first
    final staleUsers = _cleanupStaleUsers(sessionId, roomNumber);
    for (final staleUserId in staleUsers) {
      session.messages.postMessage(
        _presenceChannel(sessionId, roomNumber),
        PresenceUpdate(roomNumber: roomNumber, user: UserPresence(
          userId: staleUserId, displayName: '', color: '',
          textCursor: -1, isTyping: false, drawingX: -1, drawingY: -1,
          isDrawing: false, lastActive: DateTime.now(),
        ), joined: false),
      );
    }

    final presenceMap = _getPresenceMap(sessionId, roomNumber);
    final colorIndex = presenceMap.length % _userColors.length;

    final presence = UserPresence(
      userId: odtuserId,
      displayName: displayName ?? 'User ${presenceMap.length + 1}',
      color: _userColors[colorIndex],
      textCursor: -1,
      isTyping: false,
      drawingX: -1,
      drawingY: -1,
      isDrawing: false,
      lastActive: DateTime.now(),
    );

    presenceMap[odtuserId] = presence;

    // Broadcast presence join
    final presenceUpdate = PresenceUpdate(
      roomNumber: roomNumber,
      user: presence,
      joined: true,
    );
    session.messages.postMessage(_presenceChannel(sessionId, roomNumber), presenceUpdate);

    // Broadcast full room update
    await _broadcastRoomUpdate(session, sessionId, roomNumber);

    return presence;
  }

  /// Called when a student leaves a room
  Future<void> leaveRoom(
    Session session,
    int sessionId,
    int roomNumber,
    String userId,
  ) async {
    final presenceMap = _getPresenceMap(sessionId, roomNumber);
    final presence = presenceMap.remove(userId);

    if (presence != null) {
      // Broadcast presence leave
      final presenceUpdate = PresenceUpdate(
        roomNumber: roomNumber,
        user: presence,
        joined: false,
      );
      session.messages.postMessage(_presenceChannel(sessionId, roomNumber), presenceUpdate);
    }

    // Broadcast full room update
    await _broadcastRoomUpdate(session, sessionId, roomNumber);
  }

  /// Update a user's presence (cursor position, typing state, etc.)
  Future<void> updatePresence(
    Session session,
    int sessionId,
    int roomNumber,
    UserPresence presence,
  ) async {
    final presenceMap = _getPresenceMap(sessionId, roomNumber);
    presenceMap[presence.userId] = presence.copyWith(lastActive: DateTime.now());

    // Broadcast presence update
    final presenceUpdate = PresenceUpdate(
      roomNumber: roomNumber,
      user: presence,
      joined: null,
    );
    session.messages.postMessage(_presenceChannel(sessionId, roomNumber), presenceUpdate);
  }

  /// Stream presence updates for a room
  Stream<PresenceUpdate> presenceUpdates(
    Session session,
    int sessionId,
    int roomNumber,
  ) async* {
    // First, send current presence for all users
    for (final presence in _getPresenceList(sessionId, roomNumber)) {
      yield PresenceUpdate(
        roomNumber: roomNumber,
        user: presence,
        joined: true,
      );
    }

    // Then stream updates
    final updateStream = session.messages.createStream<PresenceUpdate>(
      _presenceChannel(sessionId, roomNumber),
    );

    await for (var update in updateStream) {
      yield update;
    }
  }

  /// Broadcast a full room update (content + presence)
  Future<void> _broadcastRoomUpdate(
    Session session,
    int sessionId,
    int roomNumber,
  ) async {
    final room = await getRoom(session, sessionId, roomNumber);
    final update = RoomUpdate(
      roomNumber: roomNumber,
      content: room?.content ?? '',
      drawingData: room?.drawingData,
      occupantCount: _getOccupantCount(sessionId, roomNumber),
      presence: _getPresenceList(sessionId, roomNumber),
      timestamp: DateTime.now(),
    );

    session.messages.postMessage(_roomChannel(sessionId, roomNumber), update);
    session.messages.postMessage(_allRoomsChannel(sessionId), update);
  }

  /// Get a specific room by session ID and room number
  Future<Room?> getRoom(
    Session session,
    int sessionId,
    int roomNumber,
  ) async {
    return await Room.db.findFirstRow(
      session,
      where: (t) =>
          t.sessionId.equals(sessionId) & t.roomNumber.equals(roomNumber),
    );
  }

  /// Update room content
  Future<Room> updateRoomContent(
    Session session,
    int sessionId,
    int roomNumber,
    String content,
  ) async {
    final room = await getRoom(session, sessionId, roomNumber);
    if (room == null) {
      throw Exception('Room not found');
    }

    // Debug logging for CRDT content
    session.log('updateRoomContent: sessionId=$sessionId, roomNumber=$roomNumber');
    session.log('Content length: ${content.length}, preview: ${content.substring(0, content.length > 200 ? 200 : content.length)}');

    room.content = content;
    room.updatedAt = DateTime.now();
    await Room.db.updateRow(session, room);

    // Broadcast update
    await _broadcastRoomUpdate(session, sessionId, roomNumber);

    return room;
  }

  /// Update room drawing data (full replacement - for backwards compatibility)
  Future<Room> updateRoomDrawing(
    Session session,
    int sessionId,
    int roomNumber,
    String drawingData,
  ) async {
    final room = await getRoom(session, sessionId, roomNumber);
    if (room == null) {
      throw Exception('Room not found');
    }

    room.drawingData = drawingData;
    room.updatedAt = DateTime.now();
    await Room.db.updateRow(session, room);

    // Broadcast update
    await _broadcastRoomUpdate(session, sessionId, roomNumber);

    return room;
  }

  /// Add a stroke to the drawing (CRDT-style merge by ID)
  Future<void> addStroke(
    Session session,
    int sessionId,
    int roomNumber,
    DrawingStroke stroke,
  ) async {
    final room = await getRoom(session, sessionId, roomNumber);
    if (room == null) {
      throw Exception('Room not found');
    }

    // Parse existing strokes
    Map<String, dynamic> strokes = {};
    if (room.drawingData != null && room.drawingData!.isNotEmpty) {
      try {
        strokes = Map<String, dynamic>.from(jsonDecode(room.drawingData!));
      } catch (_) {
        // Corrupt data, start fresh
      }
    }

    // Add/update stroke by ID
    strokes[stroke.id] = {
      'userId': stroke.userId,
      'points': stroke.points,
      'color': stroke.color,
      'width': stroke.width,
      'createdAt': stroke.createdAt.toIso8601String(),
      'deleted': stroke.deleted,
    };

    room.drawingData = jsonEncode(strokes);
    room.updatedAt = DateTime.now();
    await Room.db.updateRow(session, room);

    // Broadcast update
    await _broadcastRoomUpdate(session, sessionId, roomNumber);
  }

  /// Remove a stroke (soft delete for CRDT consistency)
  Future<void> removeStroke(
    Session session,
    int sessionId,
    int roomNumber,
    String strokeId,
  ) async {
    final room = await getRoom(session, sessionId, roomNumber);
    if (room == null) {
      throw Exception('Room not found');
    }

    // Parse existing strokes
    Map<String, dynamic> strokes = {};
    if (room.drawingData != null && room.drawingData!.isNotEmpty) {
      try {
        strokes = Map<String, dynamic>.from(jsonDecode(room.drawingData!));
      } catch (_) {
        return; // Nothing to remove
      }
    }

    // Mark stroke as deleted
    if (strokes.containsKey(strokeId)) {
      strokes[strokeId]['deleted'] = true;
    }

    room.drawingData = jsonEncode(strokes);
    room.updatedAt = DateTime.now();
    await Room.db.updateRow(session, room);

    // Broadcast update
    await _broadcastRoomUpdate(session, sessionId, roomNumber);
  }

  /// Stream real-time room updates for a specific room
  Stream<RoomUpdate> roomUpdates(
    Session session,
    int sessionId,
    int roomNumber,
  ) async* {
    // First, send current state
    final room = await getRoom(session, sessionId, roomNumber);
    if (room != null) {
      yield RoomUpdate(
        roomNumber: roomNumber,
        content: room.content,
        drawingData: room.drawingData,
        occupantCount: _getOccupantCount(sessionId, roomNumber),
        presence: _getPresenceList(sessionId, roomNumber),
        timestamp: room.updatedAt,
      );
    }

    // Then stream updates
    final updateStream = session.messages.createStream<RoomUpdate>(
      _roomChannel(sessionId, roomNumber),
    );

    await for (var update in updateStream) {
      yield update;
    }
  }

  /// Stream updates for ALL rooms in a session (for professor dashboard)
  Stream<RoomUpdate> allRoomUpdates(
    Session session,
    int sessionId,
  ) async* {
    // First, send current state of all rooms
    final rooms = await Room.db.find(
      session,
      where: (t) => t.sessionId.equals(sessionId),
      orderBy: (t) => t.roomNumber,
    );

    for (var room in rooms) {
      yield RoomUpdate(
        roomNumber: room.roomNumber,
        content: room.content,
        drawingData: room.drawingData,
        occupantCount: _getOccupantCount(sessionId, room.roomNumber),
        presence: _getPresenceList(sessionId, room.roomNumber),
        timestamp: room.updatedAt,
      );
    }

    // Then stream all updates via the all-rooms channel
    final updateStream = session.messages.createStream<RoomUpdate>(
      _allRoomsChannel(sessionId),
    );

    await for (var update in updateStream) {
      yield update;
    }
  }

  /// Get all rooms for a session (snapshot, not streaming)
  Future<List<Room>> getAllRooms(Session session, int sessionId) async {
    return await Room.db.find(
      session,
      where: (t) => t.sessionId.equals(sessionId),
      orderBy: (t) => t.roomNumber,
    );
  }
}
