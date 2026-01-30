# Demo Features Checklist

Use this checklist when recording your demo video. Features marked with stars are **must-show** for judges.

---

## Professor Features (Dashboard)

### Content Tab
- [ ] **Set assignment prompt** - Edit the "prompt" field that students see
- [ ] **Pull from transcript** - AI auto-generates assignment from lecture content
- [ ] **Live transcription** - Click record, speak, see real-time transcription
- [ ] Recording indicator (blinking red dot + "recording" badge)
- [ ] Manual transcript entry (paste/type content)

### Rooms Tab
- [ ] **Room activity grid** - See all rooms at a glance with content previews
- [ ] **Live occupant counts** - See how many students in each room
- [ ] **Synthesize all rooms** - AI generates cross-room insights (themes, contradictions, unique ideas)
- [ ] Click room card to expand/view details
- [ ] Close session button (ends for all participants)

### Dashboard Header
- [ ] Copy shareable link button
- [ ] Session name display

---

## Student Features (Breakout Room)

### Collaborative Editor
- [ ] **Real-time text editing** - Multiple users can type simultaneously
- [ ] **Freehand drawing canvas** - Draw diagrams, sketches, annotations
- [ ] **Write/Draw mode toggle** - Switch between text and drawing modes
- [ ] Undo/Clear functions for both text and drawing
- [ ] Auto-save indicator ("saving..." / "saved")

### Prompt Panel
- [ ] View professor's assignment/instructions
- [ ] Markdown formatting support
- [ ] Auto-refreshes when professor updates

### Transcript Panel (Scribe Tab)
- [ ] **View live lecture transcript** - See what professor said
- [ ] **Ask Butler questions** - "What did she say about X?" gets AI answer
- [ ] Full transcript history

### Room Info
- [ ] Room number in navigation breadcrumb
- [ ] Occupant count display

---

## Serverpod Features to Emphasize

Judges want to see how you used Serverpod. Call these out in your demo:

| Feature | What to Say | Where to Show |
|---------|-------------|---------------|
| **Streaming endpoints** | "Room updates stream via WebSocket" | Real-time text sync |
| **Redis pub/sub** | "Cross-client broadcasts via Redis" | Multi-browser sync |
| **ORM with relations** | "Sessions have many rooms, typed queries" | Room creation |
| **Code generation** | "Type-safe client generated from server" | Any API call |
| **Protocol classes** | "Shared models between server and client" | RoomUpdate, ButlerResponse |
| **Web server** | "Serverpod serves the Flutter web build" | Single deployment |
| **Config management** | "Multi-environment YAML configs" | Mention Railway deployment |

---

## AI Features (Gemini 2.0-Flash)

- [ ] **Live transcription** - Audio -> text in real-time
- [ ] **Contextual Q&A** - Answers grounded in transcript
- [ ] **Assignment extraction** - "Pull from transcript" generates prompt
- [ ] **Room summarization** - Summarize individual room content
- [ ] **Cross-room synthesis** - Identify themes across all groups

---

## Demo Flow Recommendation (3 min)

### Must-Hit Points:

1. **[0:00-0:20] Problem statement**
   - "Students in breakout rooms forget instructions"
   - "Professors can't see what groups are doing"

2. **[0:20-1:00] Professor creates session**
   - Create session (show it's easy)
   - Set prompt
   - Show/mention transcription works

3. **[1:00-1:45] Student joins room**
   - Join with just URL + room number (no account!)
   - Show collaborative text editor
   - **Show drawing canvas** (toggle to draw mode, scribble something)
   - Ask Butler a question, get answer

4. **[1:45-2:15] Real-time sync**
   - Type in student view
   - Show it appears in professor dashboard instantly
   - "This uses Serverpod streaming endpoints with Redis pub/sub"

5. **[2:15-2:45] Professor synthesis**
   - Click "synthesize all rooms"
   - Show AI-generated insights across groups
   - "Cross-room analysis powered by Gemini"

6. **[2:45-3:00] Closing**
   - "Breakout Butler: your AI teaching assistant"
   - "Built with Flutter and Serverpod"

---

## Judge-Pleasing Moments

Things that will impress judges:

1. **Zero-friction access** - "No accounts, no downloads, just a URL"
2. **Real-time everything** - Show two browsers syncing instantly
3. **AI integration** - Butler Q&A and synthesis are wow moments
4. **Drawing feature** - Visual collaboration, not just text
5. **Serverpod showcase** - Name-drop the features you used
6. **Genuine problem** - Every remote teacher has this pain point

---

## Pre-Demo Checklist

- [ ] Session created with pre-loaded transcript (saves demo time)
- [ ] Prompt already set
- [ ] Room 1 has some sample content
- [ ] Two browsers ready (Chrome + Safari/Firefox)
- [ ] Windows positioned side-by-side
- [ ] Mic permissions granted (if showing live recording)
- [ ] Test Butler Q&A works
- [ ] Test synthesize works
- [ ] Test drawing works
- [ ] Hide bookmarks bar, clean browser profile
