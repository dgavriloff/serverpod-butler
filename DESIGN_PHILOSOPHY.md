# Scratchpad Design Philosophy

## Flutter Frontend Design System Guide

-----

## Core Identity

**Scratchpad** is a real-time classroom collaboration tool. The design language should feel like a thoughtful blend of **academic clarity** and **modern productivity software**—the visual equivalent of a well-organized notebook with just the right amount of digital intelligence.

### Design Pillars

1. **Quiet Confidence** — The UI never shouts. It earns trust through restraint.
1. **Contextual Intelligence** — AI features surface at the edges, not the center.
1. **Collaborative Awareness** — Always subtly communicate "you're not alone here."
1. **Focused Workspace** — Content is king; chrome is minimal.

-----

## Visual Language

### Color Palette

```
Background & Surfaces
├── Primary Background:    #FFFFFF (pure white)
├── Secondary Surface:     #FAFAFA (off-white for cards/panels)
├── Tertiary Surface:      #F5F5F5 (subtle distinction)
└── Border/Divider:        #E8E8E8 (barely there)

Text Hierarchy
├── Primary Text:          #1A1A1A (near-black, not pure)
├── Secondary Text:        #666666 (muted labels)
├── Tertiary Text:         #999999 (timestamps, hints)
└── Placeholder:           #CCCCCC (form hints)

Accent Colors (use sparingly)
├── Primary Action:        #2196F3 (calm blue for CTAs)
├── Live/Active:           #FF4444 (red dot, "live" badge)
├── Success/Online:        #4CAF50 (green status dots)
├── Warning/Attention:     #FFC107 (yellow, room 3 style)
└── AI Insight Accent:     #5B9BD5 (soft blue for AI-generated content)
```

#### Usage Rules

- **Never** use gradients for backgrounds or buttons
- Status colors appear **only** as small indicators (dots, badges)
- The blue CTA should be the **only** saturated element on any screen
- AI-generated content uses a subtle left-border accent, not background fills

### Typography

```
Font Family: System default with careful fallbacks
├── iOS:      SF Pro Text / SF Pro Display
├── Android:  Roboto
├── Web:      -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto

Type Scale (rem-based)
├── Display:       32px / 700 weight  (page titles like "scratchpad")
├── Page Title:    28px / 700 weight  (document titles like "untitled")
├── Section:       16px / 600 weight  (sidebar headers)
├── Body:          14px / 400 weight  (primary content)
├── Caption:       12px / 400 weight  (timestamps, metadata)
└── Overline:      11px / 500 weight  (labels like "AUDIO INPUT")
```

#### Typography Principles

- **Lowercase bias** — Headers use sentence case or lowercase ("breakout rooms" not "Breakout Rooms")
- **Weight over size** — Differentiate hierarchy through weight, not dramatic size jumps
- **Generous line-height** — 1.5 for body text, 1.3 for headings
- **Letter-spacing** — Slightly increased (+0.5px) for overlines and labels

### Spacing System

```
Base Unit: 4px

Spacing Scale
├── xs:    4px   (icon-to-text, tight groupings)
├── sm:    8px   (related elements)
├── md:    16px  (standard component padding)
├── lg:    24px  (section separation)
├── xl:    32px  (major content blocks)
└── 2xl:   48px  (page-level margins)
```

#### Whitespace Philosophy

The designs exhibit **aggressive whitespace**. When in doubt, add more space.

- Card content sits far from edges (24px+ padding)
- Sections breathe with 32px+ gaps
- The landing page demonstrates centered content with massive margins

-----

## Layout Patterns

### Three-Panel Architecture

The app uses a consistent mental model:

```
┌─────────────────────────────────────────────────────────┐
│  Navigation Bar (fixed)                                 │
├────────────────────────────────────┬────────────────────┤
│                                    │                    │
│                                    │   Contextual       │
│       Primary Content              │   Sidebar          │
│       (scrollable)                 │   (280-320px)      │
│                                    │                    │
│                                    │                    │
└────────────────────────────────────┴────────────────────┘
```

- **Navigation**: Breadcrumb-style with course/context hierarchy
- **Primary Content**: The workspace—documents, rooms, forms
- **Contextual Sidebar**: AI insights, transcripts, summaries (collapsible on mobile)

### Card System

Cards are the primary container for discrete content:

```dart
// Card styling constants
const cardRadius = 8.0;
const cardPadding = EdgeInsets.all(20);
const cardBorder = Border.all(color: Color(0xFFE8E8E8), width: 1);
// Note: NO shadows. Borders only.
```

#### Card Variants

1. **Room Card** (breakout rooms view)
- Large number as visual anchor (light gray, ~48px)
- Status dot in top-right
- Title + subtitle at bottom
- Hover: subtle background shift to #F8F8F8
1. **Content Card** (sidebar summaries)
- Cream/warm background (#FDF8F4) for AI context
- No border, background differentiation only
1. **Action Card** (landing page sections)
- Dashed or light border
- Form elements contained within

-----

## Component Specifications

### Buttons

```
Primary Button (CTA)
├── Background:    #2196F3
├── Text:          #FFFFFF, 14px, 500 weight
├── Padding:       12px 24px
├── Radius:        6px
├── Full-width:    Yes (in forms)
└── Icon:          Optional left-aligned (+ symbol)

Secondary Button
├── Background:    Transparent
├── Border:        1px solid #E0E0E0
├── Text:          #333333
└── Hover:         Background #F5F5F5
```

### Form Inputs

```
Text Field
├── Height:        48px
├── Border:        1px solid #E0E0E0
├── Radius:        6px
├── Padding:       0 16px
├── Label:         Above field, 12px, #666666
├── Placeholder:   #CCCCCC, same size as input
└── Focus:         Border color → #2196F3
```

### Status Indicators

```
Online/Active Dot
├── Size:          8px diameter
├── Color:         #4CAF50 (green)
├── Position:      Top-right of room cards

Live Badge
├── Background:    Transparent
├── Border:        1px solid #FF4444
├── Text:          #FF4444, 11px
├── Dot:           6px filled #FF4444, left of text
├── Padding:       4px 8px
└── Radius:        12px (pill shape)

Timestamp
├── Color:         #999999
├── Size:          12px
└── Format:        "2 mins ago" or "10:02"
```

### Navigation

```
Breadcrumb
├── Separator:     " / " with spaces
├── Active:        #333333
├── Inactive:      #666666, clickable
├── Icon:          Course/room icon at start
└── Size:          14px
```

-----

## AI Feature Presentation

### Design Principle: Intelligence at the Periphery

AI features should feel like a helpful assistant sitting beside you, not an overlay demanding attention.

### Visual Treatment

1. **Live Insights Panel**

   ```
   ┌─ ✨ live insights ────────────────────────┐
   │                                           │
   │  ○  Insight text here with natural        │
   │     language summary of detected topic.   │
   │     2 mins ago                            │
   │                                           │
   │  ○  Another insight follows the same      │
   │     pattern with timestamp below.         │
   │     5 mins ago                            │
   │                                           │
   └───────────────────────────────────────────┘
   ```
- Small circle bullet (○) with accent color
- Text wraps naturally, no truncation
- Timestamps right-aligned or below
1. **Context Cards**
- Warm cream background (#FDF8F4 or similar)
- "Topic:" label in bold, content in regular weight
- Contained, doesn't bleed into interface
1. **Action Items**
- Checkbox style, not AI-fancy
- Feels like a normal todo list
- AI origin indicated by section header, not item styling

### AI Iconography

- Use subtle sparkle (✨) or abstract icon for "AI-powered" sections
- Never use robot faces, brains, or chat bubble icons
- The magic should be in the content, not the decoration

-----

## Motion & Interaction

### Principles

- **Functional, not decorative** — Every animation serves a purpose
- **Quick and light** — 150-250ms for most transitions
- **Ease-out curves** — `Curves.easeOut` for entering elements

### Specific Animations

```dart
// Panel slide-in (sidebar, transcript)
duration: 200ms
curve: Curves.easeOutCubic

// Card hover/tap feedback
scale: 0.98 → 1.0
duration: 100ms

// Live content appearing (new insight)
opacity: 0 → 1
translateY: 8px → 0
duration: 250ms
curve: Curves.easeOut

// Status dot pulse (live indicator)
scale: 1.0 → 1.2 → 1.0
duration: 1500ms
repeat: infinite
```

### Loading States

- Skeleton screens with subtle shimmer (left-to-right)
- "Updating automatically…" text for live content
- Never spinners; prefer progressive content loading

-----

## Responsive Behavior

### Breakpoints

```
Mobile:    < 600px   — Single column, bottom nav, sidebar as modal
Tablet:    600-1024px — Primary + collapsible sidebar
Desktop:   > 1024px  — Full three-panel layout
```

### Mobile Adaptations

- Sidebar becomes bottom sheet or separate screen
- Room cards stack 2-across, then 1-across
- Navigation collapses to hamburger + current context
- "Live" features show condensed banner at top

-----

## Accessibility Requirements

### Color Contrast

- All text meets WCAG AA (4.5:1 for body, 3:1 for large text)
- Status indicators have text labels, not color alone
- Focus states clearly visible (blue outline, not just color change)

### Touch Targets

- Minimum 44x44px for all interactive elements
- Cards and list items: full-width tap target
- Adequate spacing between adjacent targets

### Screen Readers

- Semantic heading hierarchy (h1 → h2 → h3)
- Live regions for real-time updates (`aria-live="polite"`)
- Descriptive labels for all icons and status indicators

-----

## Implementation Notes for Flutter

### Theme Configuration

```dart
final scratchpadTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Color(0xFF2196F3),
    onSurface: Color(0xFF1A1A1A),
  ),
  fontFamily: null, // Use platform default
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: Color(0xFFE8E8E8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
);
```

### Key Packages to Consider

- `flutter_animate` — For the subtle motion design
- `shimmer` — Skeleton loading states
- `intl` — Relative time formatting ("2 mins ago")

### File Structure Suggestion

```
lib/
├── core/
│   ├── theme/
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── spacing.dart
│   └── widgets/
│       ├── sp_card.dart
│       ├── sp_button.dart
│       ├── sp_input.dart
│       └── sp_status_indicator.dart
├── features/
│   ├── room/
│   ├── document/
│   └── live_panel/
```

-----

## Design Review Checklist

Before shipping any screen, verify:

- [ ] No pure black (#000000) anywhere
- [ ] Whitespace feels generous, not cramped
- [ ] Only one blue CTA visible at a time
- [ ] AI features are subtle, peripheral
- [ ] Text hierarchy uses weight, not just size
- [ ] Cards have borders OR backgrounds, not both
- [ ] Interactive elements have clear tap feedback
- [ ] Live content has appropriate animation
- [ ] Empty states are friendly and actionable

-----

## Summary

Scratchpad's design succeeds through **restraint**. It's a tool that gets out of the way, letting students and instructors focus on what matters: learning and collaboration. The AI features—while powerful—present as quiet helpers in the margins, not the main event.

When implementing, ask: "Does this feel calm? Does it feel trustworthy? Would I want to stare at this for a 90-minute lecture?"

If yes, ship it.
