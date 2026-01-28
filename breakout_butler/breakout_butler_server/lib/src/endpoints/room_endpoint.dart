import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for managing breakout room workspaces with real-time collaboration
class RoomEndpoint extends Endpoint {
  // Channel for all room updates in a session (professor dashboard)
  static String _allRoomsChannel(int sessionId) => 'all-rooms-$sessionId';

  // Channel for a specific room
  static String _roomChannel(int sessionId, int roomNumber) =>
      'room-$sessionId-$roomNumber';

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

    room.content = content;
    room.updatedAt = DateTime.now();
    await Room.db.updateRow(session, room);

    // Broadcast update to room-specific listeners
    final update = RoomUpdate(
      roomNumber: roomNumber,
      content: content,
      drawingData: room.drawingData,
      timestamp: DateTime.now(),
    );
    session.messages.postMessage(_roomChannel(sessionId, roomNumber), update);

    // Also broadcast to all-rooms channel for professor dashboard
    session.messages.postMessage(_allRoomsChannel(sessionId), update);

    return room;
  }

  /// Update room drawing data
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

    // Broadcast update to room-specific listeners
    final update = RoomUpdate(
      roomNumber: roomNumber,
      content: room.content,
      drawingData: drawingData,
      timestamp: DateTime.now(),
    );
    session.messages.postMessage(_roomChannel(sessionId, roomNumber), update);

    // Also broadcast to all-rooms channel for professor dashboard
    session.messages.postMessage(_allRoomsChannel(sessionId), update);

    return room;
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
