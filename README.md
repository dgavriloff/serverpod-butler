# breakoutpad

A Zoom companion web app that creates collaborative workspaces for breakout room sessions. Built with Flutter and Serverpod for the [Serverpod Hackathon](https://serverpod.devpost.com/).

**Live Demo:** [breakoutpad.dgavriloff.com](https://breakoutpad.dgavriloff.com)

## The Problem

When students enter Zoom breakout rooms, they immediately forget what they're supposed to do, can't hear ongoing instructions, and professors have no visibility into what groups are discussing.

## The Solution

breakoutpad acts as a digital teaching assistant that:
- Captures everything the professor says via live transcription
- Provides real-time collaborative workspaces with text and drawing
- Gives professors a bird's-eye view of all rooms
- Synthesizes themes and insights across groups

## Features

### For Professors
- Live lecture transcription (Gemini 3 Flash Preview)
- AI-powered assignment extraction from transcript
- Real-time dashboard showing all breakout rooms
- Cross-room synthesis, identify common themes and contradictions

### For Students
- Collaborative text editor + freehand drawing canvas
- Always-visible professor instructions
- Live lecture transcript

### Zero Friction
No accounts, no downloads. Students join with just a URL and room number.

## Tech Stack

- **Backend:** Serverpod 3 (Dart)
  - Streaming endpoints (WebSocket)
  - Redis pub/sub for real-time sync
  - ORM with relations
  - Code generation for type-safe client
- **Frontend:** Flutter Web
  - Riverpod state management
  - go_router for navigation
  - perfect_freehand for drawing
- **AI:** Google Gemini 3 Flash Preview
- **Deployment:** Railway + Caddy reverse proxy

## Project Structure

```
breakout_butler/
├── breakout_butler_server/     # Serverpod backend
├── breakout_butler_client/     # Generated client library
└── breakout_butler_flutter/    # Flutter web app
```

## License

MIT
