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

---

## Railway Deployment

### Project: `zoological-celebration`

Railway project has 3 services:
- **serverpod-butler** — the app (builds from GitHub `dgavriloff/serverpod-butler`, `main` branch)
- **Postgres** — `ghcr.io/railwayapp-templates/postgres-ssl:17` (with volume)
- **Redis** — `redis:8.2.1` (with volume)

Two environments: `production` and `dev` (both deploy from `main`).

### Architecture

```
Internet → Railway public domain (HTTPS :443)
         → Caddy (listens on $PORT, Railway-assigned)
              ├── POST requests      → Serverpod API (:8080)
              ├── WebSocket upgrades → Serverpod API (:8080)
              ├── /insights/*        → Serverpod Insights (:8081)
              └── everything else    → Serverpod Web (:8082, serves Flutter app)
```

**Why Caddy?** Railway only exposes one port per service. Serverpod runs API on 8080 and web on 8082. Caddy multiplexes both through a single Railway-assigned `$PORT`.

### Key Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Multi-stage: Flutter web build → Dart server compile → Debian runtime + Caddy |
| `Caddyfile.production` | Routes POST→API, WebSocket→API, else→web server |
| `railway.toml` | Tells Railway to use Dockerfile (not Railpack auto-detect) |
| `production.yaml` | Serverpod config; env vars override `localhost` defaults |
| `.dockerignore` | Excludes build artifacts, keeps generated code + migrations |

### Environment Variables (set in Railway dashboard or CLI)

**Auto-provided by Railway:**
- `PORT` — the port Railway routes traffic to (Caddy listens on this)
- `RAILWAY_PUBLIC_DOMAIN` — the `*.up.railway.app` domain

**Must be set manually for Serverpod:**

| Variable | Purpose |
|----------|---------|
| `GEMINI_API_KEY` | Gemini API for transcription |
| `SERVERPOD_DATABASE_HOST` | `postgres.railway.internal` |
| `SERVERPOD_DATABASE_PORT` | `5432` |
| `SERVERPOD_DATABASE_NAME` | `railway` |
| `SERVERPOD_DATABASE_USER` | `postgres` |
| `SERVERPOD_DATABASE_PASSWORD` | From Railway Postgres plugin |
| `SERVERPOD_REDIS_HOST` | `redis.railway.internal` |
| `SERVERPOD_REDIS_PORT` | `6379` |
| `SERVERPOD_REDIS_PASSWORD` | From Railway Redis plugin |
| `SERVERPOD_PASSWORD_database` | Same as `SERVERPOD_DATABASE_PASSWORD` |
| `SERVERPOD_PASSWORD_redis` | Same as `SERVERPOD_REDIS_PASSWORD` |
| `SERVERPOD_PASSWORD_serviceSecret` | Random secret for Insights auth |
| `SERVERPOD_PASSWORD_emailSecretHashPepper` | Random secret |
| `SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey` | Random secret |
| `SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper` | Random secret |

**Note:** Serverpod has TWO password systems:
1. `SERVERPOD_DATABASE_PASSWORD` — overrides `database.password` in the config directly
2. `SERVERPOD_PASSWORD_<key>` — maps to `passwords.yaml` entries (used by auth module for JWT, service secrets, etc.)

Both must be set. The `SERVERPOD_PASSWORD_database` and `SERVERPOD_PASSWORD_redis` entries are read from `passwords.yaml` for the DB/Redis connections. The `SERVERPOD_DATABASE_*` vars override the config file host/port/name/user/password.

### What Didn't Work / Lessons Learned

#### 1. Railpack can't build Dart/Flutter
Railway's default builder (Railpack) doesn't support Dart or Flutter. It saw the repo root (markdown files, no recognizable language) and failed. **Fix:** `railway.toml` with `dockerfilePath = "Dockerfile"`.

#### 2. Alpine doesn't work for Dart AOT binaries
Dart `compile exe` produces glibc-linked binaries. Alpine uses musl. The binary segfaults silently. **Fix:** Use `debian:bookworm-slim` as the runtime base.

#### 3. Original Dockerfile had `COPY --from=server-build /runtime/ /`
This path doesn't exist in the `dart:3.8.0` image. Dart AOT executables are fully self-contained — no separate runtime libraries needed. **Fix:** Just copy the compiled binary.

#### 4. Flutter Docker image version mismatch
`ghcr.io/cirruslabs/flutter:3.29.3` ships Dart SDK 3.7.2, but `pubspec.yaml` requires `^3.8.0`. **Fix:** Use `flutter:3.38.7` which has Dart 3.8.x.

#### 5. `**/generated/` in .gitignore blocked Docker builds
The root `.gitignore` had `**/generated/` and `**/migrations/` which:
- Prevented `git add` of server generated code (needed `git add -f`)
- Made `railway up` (CLI deploy) skip those files since it respects `.gitignore`
- GitHub-triggered deploys also didn't have these files

**Fix:** Changed `.gitignore` to use specific paths instead of globs:
```
breakout_butler/breakout_butler_client/lib/src/protocol/generated/
breakout_butler/breakout_butler_flutter/**/generated/
```
This ignores client/flutter generated code but tracks server generated code + migrations.

#### 6. `passwords.yaml` is gitignored → missing at runtime
Serverpod needs `passwords.yaml` for auth (JWT secrets, service secret, etc.). It's rightfully gitignored. **Fix:** Set `SERVERPOD_PASSWORD_<key>` environment variables in Railway for every key in the production section of `passwords.yaml`.

#### 7. `${VAR:default}` syntax doesn't work in Serverpod YAML
The original `production.yaml` used `${RAILWAY_PUBLIC_DOMAIN:api.examplepod.com}` but Serverpod's YAML parser doesn't support shell-style variable substitution with defaults. **Fix:** Use plain `localhost` defaults and rely on Serverpod's built-in env var override mechanism (`SERVERPOD_API_SERVER_PUBLIC_HOST`, etc.).

#### 8. DB password auth failure
Even with `SERVERPOD_DATABASE_PASSWORD` set, Serverpod may use `SERVERPOD_PASSWORD_database` for the actual DB connection (from the passwords map). Both need to be set to the same value from the Railway Postgres plugin.

**Current status:** Password vars found → DB `password authentication failed for user "postgres"`. This suggests `SERVERPOD_PASSWORD_database` may not be matching the actual Railway Postgres password, OR the `production.yaml` `database.name` is `serverpod` but Railway's DB name is `railway`.

### Still TODO

1. **Fix DB connection** — Verify `SERVERPOD_DATABASE_NAME=railway` overrides `database.name: serverpod` in production.yaml. Check which password Serverpod actually uses for the DB connection.
2. **Set `SERVERPOD_API_SERVER_PUBLIC_HOST`** — Needs to be the Railway public domain so the Flutter app's `config.json` gets the right API URL.
3. **Run migrations** — First successful boot needs `--apply-migrations` flag or manual migration.
4. **Generate a Railway domain** — Already created `serverpod-butler-dev.up.railway.app` for production env.
5. **Test the full flow** — Flutter app loads → API calls work → DB connected → Redis connected.

### Useful Railway CLI Commands

```bash
# Link project (already done)
railway link

# Switch environment
railway environment production

# Link service
railway service serverpod-butler

# Set env vars
railway variables set KEY=value

# View env vars
railway variables

# View logs
railway logs

# Deploy from local (uses .gitignore by default)
railway up --ci

# Deploy ignoring .gitignore
railway up --ci --no-gitignore

# Check project status
railway status --json
```
