# Breakout Room Butler - Hackathon Project

## Concept
A Zoom companion app for professors using breakout rooms. Provides collaborative workspaces that eliminate the "what did she want us to do?" problem.

## Core Problem
- Professor sends students to Zoom breakout rooms
- Each room needs to collaborate (notes, ideas, diagrams)
- Currently: messy chat, separate Google Docs, disorganized
- Professor has no visibility into what rooms are producing

## Solution
1. **Professor creates/opens session** with a prompt and context
2. **Students join via simple URL** matching their Zoom room number
3. **Each room gets a workspace** (whiteboard + text doc hybrid)
4. **Professor sees all rooms live** from their dashboard

---

## URL Structure

```
/[url-tag]        → Professor dashboard (sees all rooms)
/[url-tag]/1      → Room 1 workspace
/[url-tag]/2      → Room 2 workspace
...
```

- Professor sets the URL tag (e.g., `psych101`)
- Easy to say out loud: "go to butler.app/psych101/your-room-number"
- Mirrors Zoom room numbers directly

---

## Session Model

| Concept | What it is | Lifespan |
|---------|-----------|----------|
| **Session** | The live "room is open" state + URL tag | Ephemeral (class period) |
| **Workspace Data** | Notes, drawings, content per room | Persistent (forever) |

### Professor Flow

```
[Dashboard]
    ├── [+ New Session]
    │       → Enter URL tag
    │       → Enter prompt
    │       → Set room count
    │       → Session is live
    │
    └── [Open Existing]
            → List of past sessions:
                • "Milgram Discussion" - Jan 20
                • "Research Methods Brainstorm" - Jan 15
                • "Ethics Case Study" - Jan 8
            → Pick one
            → Enter URL tag (can reuse or pick new)
            → Session is live with existing data
```

---

## Data Model

```
Session (persistent)
  - id
  - name (optional, or auto from prompt)
  - prompt
  - created_at
  - room_count

Room (persistent, belongs to session)
  - id
  - session_id
  - room_number
  - content (text doc data)
  - whiteboard_data (drawing data)

LiveSession (ephemeral, in-memory or short-lived DB row)
  - session_id
  - url_tag (e.g., "psych101")
  - is_active
  - expires_at
```

---

## MVP Features (Final Scope)

| Feature | Complexity | In MVP |
|---------|-----------|--------|
| Professor creates session with URL tag | Low | ✅ |
| Students join room via URL | Low | ✅ |
| Shared text doc per room | Medium | ✅ |
| Professor streams audio (mic capture) | Medium | ✅ |
| Butler transcribes via Gemini | Medium | ✅ |
| Students ask butler "what did she say?" | Medium | ✅ |
| Professor sees all rooms live | Medium | ✅ |
| Real-time sync across users | Medium | ✅ |
| Whiteboard/drawing | - | ❌ V2 |
| Cross-room synthesis | - | ❌ V2 |
| Open existing session with history | - | ❌ V2 |

### V2 Features (Post-MVP)
- Whiteboard/drawing canvas
- Cross-room AI synthesis ("themes across all rooms")
- Session history and reopening
- Export to PDF
- Student identity/names

---

## Tech Stack

- **Frontend:** Flutter (web primary, mobile possible)
- **Backend:** Serverpod 3
  - Real-time WebSocket sync for collaborative editing
  - New auth module for professor accounts
  - Relic web server for clean routing
- **AI:** Gemini API (for butler features - TBD)
- **Hosting:** Serverpod Cloud (free credits from hackathon)

---

## Butler Features (Live Transcription)

### Architecture

```
[Professor's Browser]
        │
        │ Audio stream (WebSocket)
        ▼
[Serverpod Backend]
        │
        │ Audio chunks
        ▼
[Gemini Transcription]
        │
        │ Text stream
        ▼
[Butler Context]  ──→  Stored + broadcast to rooms
        │
        ▼
[Student Workspaces]  ──→  See live context / ask butler questions
```

### Butler Capabilities (MVP)

1. **Live transcription** - Professor's mic → Gemini → text
2. **Context awareness** - Butler knows what's been said in class
3. **Student Q&A** - "What did she say about the deadline?" → searches transcript
4. **Auto-extract prompt** - Detects when professor gives breakout task
5. **Room summarization** - Professor can ask "summarize Room 3"

### Why This Wins

- Real user, real problem (your professor)
- Butler is central, not bolted on
- Shows off Serverpod 3 (real-time WebSockets, streaming, multi-user sync)
- Demo writes itself: Professor talks → Butler captures → Students see context → Rooms collaborate

---

## Data Model (Updated)

```
Session (persistent)
  - id
  - name
  - prompt
  - created_at
  - room_count

Room (persistent, belongs to session)
  - id
  - session_id
  - room_number
  - content (text doc data)

LiveSession (ephemeral)
  - session_id
  - url_tag (e.g., "psych101")
  - is_active
  - transcript (accumulated text from butler)

TranscriptChunk (persistent, for searchability)
  - id
  - session_id
  - timestamp
  - text
```

---

## Tech Stack (Final)

- **Frontend:** Flutter Web
- **Backend:** Serverpod 3
  - Real-time WebSocket sync for collaborative editing
  - Audio streaming endpoint
  - Transcript broadcast
- **AI:** Gemini API
  - Live transcription
  - Q&A over transcript
  - Room summarization
- **Hosting:** Serverpod Cloud (hackathon credits)
- **Audio Capture:** Browser MediaRecorder API (mic capture)

---

## Development Setup

### Prerequisites
- Flutter SDK (3.7+)
- Dart SDK (3.0+)
- Docker Desktop (for Postgres/Redis)

### Installation Commands
```bash
# Install Flutter via Homebrew
brew install --cask flutter

# Add Flutter to PATH and verify
flutter doctor

# Install Serverpod CLI
dart pub global activate serverpod_cli

# Verify Serverpod
serverpod

# Start Docker Desktop, then create project
serverpod create breakout_butler
```

### Project Structure (after `serverpod create`)
```
breakout_butler/
├── breakout_butler_server/     # Serverpod backend
│   ├── lib/
│   │   └── src/
│   │       ├── endpoints/      # API endpoints
│   │       └── models/         # Data models (YAML → Dart)
│   └── config/
├── breakout_butler_client/     # Generated client library
└── breakout_butler_flutter/    # Flutter app
```

### Running Locally
```bash
# Start Docker containers (Postgres + Redis)
cd breakout_butler_server
docker compose up -d

# Generate code from models
serverpod generate

# Run server
dart run bin/main.dart

# Run Flutter web app (in another terminal)
cd ../breakout_butler_flutter
flutter run -d chrome
```

---

## Serverpod Streaming (Real-time)

### Server-side Stream Endpoint
```dart
class TranscriptEndpoint extends Endpoint {
  // Streaming method - returns Stream
  Stream<TranscriptUpdate> transcriptStream(Session session, String sessionId) async* {
    // Subscribe to transcript updates for this session
    await for (var update in transcriptService.getUpdates(sessionId)) {
      yield update;
    }
  }

  // Receive audio chunks from professor
  Future<void> sendAudioChunk(Session session, String sessionId, ByteData audio) async {
    // Process audio → transcribe → broadcast
  }
}
```

### Client-side Stream Subscription
```dart
// Open WebSocket connection
await client.openStreamingConnection();

// Listen to transcript updates
await for (var update in client.transcript.transcriptStream(sessionId)) {
  setState(() => transcript.add(update));
}
```

---

## Gemini API Integration

### Audio Transcription
```dart
// Using google_generative_ai package
final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

Future<String> transcribeAudio(Uint8List audioData) async {
  final response = await model.generateContent([
    Content.multi([
      DataPart('audio/webm', audioData),
      TextPart('Transcribe this audio accurately.')
    ])
  ]);
  return response.text ?? '';
}
```

### Q&A Over Transcript
```dart
Future<String> askButler(String question, String transcript) async {
  final response = await model.generateContent([
    Content.text('''
    You are a helpful classroom assistant. Based on the lecture transcript below,
    answer the student's question.

    TRANSCRIPT:
    $transcript

    QUESTION: $question
    ''')
  ]);
  return response.text ?? '';
}
```
