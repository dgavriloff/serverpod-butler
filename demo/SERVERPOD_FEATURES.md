# Serverpod Features Used

This project showcases a wide range of Serverpod 3 capabilities. Here's what we used and why.

## 1. Real-Time Streaming (WebSocket)

**Feature:** `Stream<T>` return types on endpoints

**Where Used:**
- `RoomEndpoint.roomUpdates()` — Streams room content changes to students
- `RoomEndpoint.allRoomUpdates()` — Streams ALL room updates to professor dashboard
- `ButlerEndpoint.transcriptStream()` — Streams live transcription to all clients

**Why It Matters:**
Serverpod's streaming abstraction handles WebSocket lifecycle, reconnection, and multiplexing automatically. We didn't write a single line of WebSocket code — just `yield` statements.

```dart
Stream<RoomUpdate> roomUpdates(Session session, int sessionId, int roomNumber) async* {
  // Send current state first
  yield await _getCurrentRoomState(session, sessionId, roomNumber);

  // Then stream changes via Redis
  await for (var message in session.messages.stream(channelName)) {
    yield RoomUpdate.fromJson(message);
  }
}
```

---

## 2. Session Messaging (Redis Pub/Sub)

**Feature:** `session.messages.postMessage()` and `session.messages.stream()`

**Where Used:**
- Broadcasting room content updates to all connected clients
- Broadcasting transcript chunks to all rooms
- Notifying professor dashboard of occupancy changes

**Why It Matters:**
Redis-backed pub/sub enables horizontal scaling — multiple server instances can broadcast to each other's clients. Critical for real-time collaboration.

```dart
// Broadcast to specific room
session.messages.postMessage('room-$sessionId-$roomNumber', update);

// Broadcast to professor dashboard (all rooms)
session.messages.postMessage('all-rooms-$sessionId', update);
```

---

## 3. Database ORM with Relations

**Feature:** Serverpod's YAML-based model definitions with `relation` support

**Where Used:**
- `ClassSession` has many `Room` objects
- `ClassSession` has many `TranscriptChunk` objects
- `LiveSession` references `ClassSession` by ID

**Models:**
```yaml
# class_session.spy.yaml
class: ClassSession
table: class_session
fields:
  name: String
  roomCount: int
  createdAt: DateTime
  rooms: List<Room>?, relation(name=session_rooms)
```

```yaml
# room.spy.yaml
class: Room
table: room
fields:
  sessionId: int, relation(parent=class_session)
  roomNumber: int
  content: String
indexes:
  session_room_idx:
    fields: sessionId, roomNumber
    unique: true
```

---

## 4. Code Generation

**Feature:** `serverpod generate` creates client libraries automatically

**Where Used:**
- All endpoint methods are auto-exposed to Flutter client
- All protocol classes (models) are shared between server and client
- Type-safe RPC calls without manual serialization

**Flow:**
```
Server: lib/src/endpoints/butler_endpoint.dart
        ↓ serverpod generate
Client: lib/src/protocol/client.dart
        ↓
Flutter: client.butler.askButler(sessionId, question)
```

---

## 5. Protocol Classes (Shared Models)

**Feature:** `.spy.yaml` models compiled to Dart classes for both server and client

**Where Used:**
- `RoomUpdate` — Streamed from server, consumed by Flutter
- `TranscriptUpdate` — Real-time transcript chunks
- `ButlerResponse` — AI response wrapper with success/error states
- `ClassSession`, `Room`, `LiveSession` — Core domain models

**Why It Matters:**
No JSON parsing in Flutter code. Models are strongly typed end-to-end.

```dart
// Flutter receives typed objects
final Stream<RoomUpdate> updates = client.room.roomUpdates(sessionId, roomNumber);
await for (final update in updates) {
  setState(() => content = update.content);  // Type-safe!
}
```

---

## 6. Database Migrations

**Feature:** `serverpod create-migration` generates SQL migrations

**Where Used:**
- Initial schema creation for all tables
- Adding `creatorToken` to `LiveSession`
- Adding `prompt` field to `LiveSession`
- Creating indexes for performance

**Why It Matters:**
Schema changes are version-controlled and reproducible. No manual SQL editing.

---

## 7. Async/Await in Endpoints

**Feature:** Full async support in endpoint methods

**Where Used:**
- `processAudio()` — Awaits Gemini API transcription
- `askButler()` — Awaits Gemini Q&A response
- `synthesizeAllRooms()` — Fetches all rooms, then awaits AI synthesis

**Pattern:**
```dart
Future<ButlerResponse> askButler(Session session, int sessionId, String question) async {
  final liveSession = await _getLiveSession(session, sessionId);
  final answer = await GeminiService.instance.answerQuestion(question, liveSession.transcript);
  return ButlerResponse(answer: answer, success: true);
}
```

---

## 8. Configuration Management

**Feature:** YAML-based environment configs (`development.yaml`, `production.yaml`)

**Where Used:**
- Database connection strings per environment
- Redis connection per environment
- API server ports and hosts
- Web server static file paths

**Example:**
```yaml
# production.yaml
apiServer:
  port: 8080
  publicHost: serverpod-butler-dev.up.railway.app
  publicScheme: https

webServer:
  port: 8082
  publicHost: serverpod-butler-dev.up.railway.app

database:
  host: ${SERVERPOD_DATABASE_HOST}
  port: ${SERVERPOD_DATABASE_PORT}
  name: ${SERVERPOD_DATABASE_NAME}
  user: ${SERVERPOD_DATABASE_USER}
  password: ${SERVERPOD_DATABASE_PASSWORD}
```

---

## 9. Web Server for Static Files

**Feature:** Serverpod's built-in web server serves Flutter web builds

**Where Used:**
- Serves pre-built Flutter app from `web/app/`
- Single deployment artifact (server + frontend)
- SPA routing support

**Why It Matters:**
No separate CDN or static hosting needed. One Dockerfile, one Railway service.

---

## 10. Session Object for Request Context

**Feature:** `Session` parameter provides request context and services

**Where Used:**
- `session.db` — Database access
- `session.messages` — Redis pub/sub
- `session.log` — Structured logging

**Pattern:**
```dart
Future<Room?> getRoom(Session session, int sessionId, int roomNumber) async {
  return await Room.db.findFirstRow(
    session,
    where: (t) => (t.sessionId.equals(sessionId)) & (t.roomNumber.equals(roomNumber)),
  );
}
```

---

## Summary Table

| Feature | Serverpod API | Our Usage |
|---------|--------------|-----------|
| Real-time streaming | `Stream<T>` endpoints | Room updates, transcript |
| Pub/sub messaging | `session.messages` | Cross-client broadcasts |
| ORM with relations | `.spy.yaml` models | Session → Rooms hierarchy |
| Code generation | `serverpod generate` | Type-safe client |
| Shared models | Protocol classes | `RoomUpdate`, `ButlerResponse` |
| Migrations | `serverpod create-migration` | Schema versioning |
| Async endpoints | `Future<T>` methods | AI integration |
| Config management | YAML configs | Multi-environment |
| Static web server | WebServer config | Flutter hosting |
| Request context | `Session` object | DB, Redis, logging |

---

## What We Didn't Use (Yet)

- **Authentication module** — Used simple token-based auth instead
- **Serverpod Insights** — Available but not demoed
- **File uploads** — No file handling in MVP
- **Scheduled tasks** — No background jobs yet
- **Serverpod Cloud** — Deployed to Railway instead (but would use Cloud in production)
