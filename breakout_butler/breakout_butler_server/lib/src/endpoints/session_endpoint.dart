import 'dart:math';
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

    final token = _generateToken();
    final liveSession = LiveSession(
      sessionId: sessionId,
      urlTag: urlTag,
      isActive: true,
      transcript: '',
      prompt: '',
      startedAt: DateTime.now(),
      creatorToken: token,
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

  /// End a live session and delete all associated data
  Future<void> endLiveSession(Session session, String urlTag) async {
    final liveSession = await getLiveSessionByTag(session, urlTag);
    if (liveSession != null) {
      final sessionId = liveSession.sessionId;

      // Delete rooms first (foreign key constraint)
      await Room.db.deleteWhere(
        session,
        where: (t) => t.sessionId.equals(sessionId),
      );

      // Delete the live session
      await LiveSession.db.deleteRow(session, liveSession);

      // Delete the class session
      await ClassSession.db.deleteWhere(
        session,
        where: (t) => t.id.equals(sessionId),
      );
    }
  }

  /// Validate a creator token for a live session.
  /// Returns true if the token matches the session's creator token.
  Future<bool> validateCreatorToken(
    Session session,
    String urlTag,
    String token,
  ) async {
    final liveSession = await LiveSession.db.findFirstRow(
      session,
      where: (t) =>
          t.urlTag.equals(urlTag) &
          t.isActive.equals(true) &
          t.creatorToken.equals(token),
    );
    return liveSession != null;
  }

  /// Get all rooms for a session
  Future<List<Room>> getRooms(Session session, int sessionId) async {
    return await Room.db.find(
      session,
      where: (t) => t.sessionId.equals(sessionId),
      orderBy: (t) => t.roomNumber,
    );
  }

  /// Generate a random URL-safe token.
  static String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return List.generate(32, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
