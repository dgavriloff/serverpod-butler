import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for managing classroom sessions
class SessionEndpoint extends Endpoint {
  /// Create a new classroom session
  Future<ClassSession> createSession(
    Session session,
    String name,
    int roomCount,
  ) async {
    final classSession = ClassSession(
      name: name,
      roomCount: roomCount,
      createdAt: DateTime.now(),
    );

    final createdSession = await ClassSession.db.insertRow(session, classSession);

    // Create rooms for this session
    for (var i = 1; i <= roomCount; i++) {
      await Room.db.insertRow(
        session,
        Room(
          sessionId: createdSession.id!,
          roomNumber: i,
          content: '',
          updatedAt: DateTime.now(),
        ),
      );
    }

    return createdSession;
  }

  /// Start a live session with a URL tag
  Future<LiveSession> startLiveSession(
    Session session,
    int sessionId,
    String urlTag,
  ) async {
    // Check if URL tag is already in use
    final existing = await LiveSession.db.findFirstRow(
      session,
      where: (t) => t.urlTag.equals(urlTag) & t.isActive.equals(true),
    );

    if (existing != null) {
      throw Exception('URL tag "$urlTag" is already in use');
    }

    final liveSession = LiveSession(
      sessionId: sessionId,
      urlTag: urlTag,
      isActive: true,
      transcript: '',
      startedAt: DateTime.now(),
    );

    return await LiveSession.db.insertRow(session, liveSession);
  }

  /// Get a live session by URL tag
  Future<LiveSession?> getLiveSessionByTag(
    Session session,
    String urlTag,
  ) async {
    return await LiveSession.db.findFirstRow(
      session,
      where: (t) => t.urlTag.equals(urlTag) & t.isActive.equals(true),
    );
  }

  /// Get session details including rooms
  Future<ClassSession?> getSession(Session session, int sessionId) async {
    return await ClassSession.db.findById(
      session,
      sessionId,
      include: ClassSession.include(
        rooms: Room.includeList(),
      ),
    );
  }

  /// End a live session
  Future<void> endLiveSession(Session session, String urlTag) async {
    final liveSession = await getLiveSessionByTag(session, urlTag);
    if (liveSession != null) {
      liveSession.isActive = false;
      liveSession.expiresAt = DateTime.now();
      await LiveSession.db.updateRow(session, liveSession);
    }
  }

  /// Get all rooms for a session
  Future<List<Room>> getRooms(Session session, int sessionId) async {
    return await Room.db.find(
      session,
      where: (t) => t.sessionId.equals(sessionId),
      orderBy: (t) => t.roomNumber,
    );
  }
}
