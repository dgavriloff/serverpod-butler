# Demo Setup Recommendations

Based on reviewing the current app state, here's my recommendation for demo setup.

## Current State

I observed:
- **Professor dashboard** (`/testdash`) — Empty prompt and transcript fields
- **Student room** (`/demotest/1`) — Empty workspace with a test drawing line, no transcript
- **Home screen** — Clean landing page ready for fresh start

## Recommendation: Pre-Loaded Demo

**For a 3-minute video, pre-load data.** Here's why:

| Approach | Pros | Cons |
|----------|------|------|
| **Fresh start** | Shows full flow | Takes 30+ seconds just to create session |
| **Pre-loaded** | Jump straight to features | Less "authentic" |
| **Hybrid** | Best of both | More complex to execute |

### Recommended: Hybrid Approach

1. **Quick fresh creation** (20 sec) — Show creating a session to prove it works
2. **Cut to pre-loaded session** — Switch to a session with transcript already populated
3. **Show AI features** — Butler Q&A, synthesis
4. **Brief live recording** (optional) — Show mic button works, but don't wait for transcription

---

## Pre-Demo Setup Checklist

### 1. Create Demo Session

```
Session Name: "Milgram Experiment Discussion"
Room Count: 3
URL Tag: "milgram" (or similar short tag)
```

### 2. Pre-Load Transcript

On the professor dashboard, paste this into the transcript field:

```
Today we're exploring the Milgram obedience experiments conducted at Yale in 1961. Stanley Milgram designed these experiments to understand how ordinary people could commit atrocities during the Holocaust.

In the experiment, participants believed they were administering electric shocks to a learner in another room. The shocks ranged from 15 volts labeled "slight shock" up to 450 volts labeled "danger: severe shock."

The shocking finding was that 65% of participants administered what they believed were lethal 450-volt shocks when instructed by an authority figure in a lab coat. Only 35% refused to continue.

For your breakout discussion, consider these questions: First, was this experiment ethical by today's standards? Second, what does it reveal about human nature and our relationship with authority? And third, could something like this happen today with social media algorithms and digital authority figures?

You have 15 minutes to discuss in your groups. Use the shared workspace to document your group's position. I'll synthesize insights across all groups when we come back together.
```

### 3. Set the Prompt

```
Discuss whether Milgram's obedience experiment was ethical. What does it reveal about authority and conformity? Consider modern parallels with social media and algorithmic influence.
```

### 4. Pre-Populate Room Content (Optional)

For Room 1, add some sample student discussion:

```
Our group's position:

ETHICAL CONCERNS:
- No true informed consent (participants didn't know the shocks were fake)
- Caused significant psychological distress
- Deception was central to the experiment

INSIGHTS ABOUT AUTHORITY:
- People defer to perceived experts (lab coat effect)
- Gradual escalation made it hard to stop
- Physical distance from victim reduced empathy

MODERN PARALLELS:
- Social media algorithms as "invisible authority"
- Content moderation as authority figures
- Influencer culture and parasocial authority
```

### 5. Browser Setup

**Window 1 (Professor):**
- Chrome browser
- URL: `https://serverpod-butler-dev.up.railway.app/[your-session-tag]dash`
- Position: Left side of screen

**Window 2 (Student):**
- Different browser (Safari, Firefox, or Chrome incognito)
- URL: `https://serverpod-butler-dev.up.railway.app/[your-session-tag]/1`
- Position: Right side of screen

---

## Pre-Demo Test Checklist

- [ ] Session loads without errors
- [ ] Transcript appears in student view
- [ ] Butler Q&A returns answers (test: "What percentage gave lethal shocks?")
- [ ] Real-time sync works (type in student, appears in professor)
- [ ] Synthesize button works and returns insights
- [ ] Recording button toggles (even if not actually recording for demo)
- [ ] Both windows fit nicely side-by-side at recording resolution

---

## Fallback Plans

**If Gemini API is slow:**
- Have pre-written Butler response ready to paste manually
- Or cut that part and mention "AI responds in seconds"

**If real-time sync breaks:**
- Refresh both browsers
- Worst case: show each view separately, mention "updates instantly"

**If transcript won't save:**
- Check browser console for errors
- Use `addTranscriptText` endpoint directly via API

**If session won't create:**
- Check for stale LiveSession rows (see CLAUDE.md for SQL fix)
- Use a different URL tag

---

## Recording Settings

**Resolution:** 1920x1080 or 1280x720
**Frame rate:** 30fps minimum
**Audio:** External mic recommended if showing voice
**Browser:** Hide bookmarks bar, extensions, use clean profile
**Screen:** Close all other apps, hide dock/taskbar if possible

---

## Quick Reference: Key URLs

| Purpose | URL Pattern |
|---------|-------------|
| Home | `/` |
| Create session | Click button on home |
| Professor dashboard | `/[tag]dash` |
| Student room | `/[tag]/[room#]` |

Replace `[tag]` with your session's URL tag (e.g., `milgram`).
Replace `[room#]` with room number (1, 2, 3...).
