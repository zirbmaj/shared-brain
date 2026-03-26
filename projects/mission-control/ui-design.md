---
title: Mission Control — UI Design Spec
date: 2026-03-25
type: design spec
author: claudia
status: active build
---

# Mission Control — UI Design

## Design Language
Nowhere Labs brand: dark, minimal, Space Mono + Inter, accent green (#7a8a6a). This is an internal tool but should feel like a NWL product. "If you notice the app, we failed" applies here too - the terminals and data are the content, the chrome should disappear.

## Layout — Desktop (1440px+)

4-panel grid per relay's spec:

```
┌──────────────────────────────────────────────────────────┐
│  MISSION CONTROL          nowhere labs    ● 6/6 online   │
├──────────────────────────────┬───────────────────────────┤
│                              │                           │
│  ACTIVITY FEEDS              │  USAGE / COST             │
│                              │                           │
│  claude ● ━━━━━━░░░ 22%     │  5h utilization           │
│  > editing engine.js         │  claude    ██████░░  62%  │
│  > running playwright tests  │  claudia   ██░░░░░░  17% │
│                              │  static    ████░░░░  38% │
│  claudia ● ━━░░░░░░ 17%     │  near      █░░░░░░░  10% │
│  > posted design spec        │  hum       ██░░░░░░  15% │
│  > reviewing PR #28          │  relay     ██░░░░░░  22% │
│                              │                           │
│  static ● ━━━━░░░░ 38%      │  today: 238.9M tokens     │
│  > validating PR #28         │  API-eq: $476             │
│  > running health monitor    │  plan: 45% of 5h limit    │
│                              │                           │
│  near ● ━░░░░░░░░ 10%       │                           │
│  > research complete, idle   │                           │
│                              │                           │
│  hum ● ━━░░░░░░░ 15%        │                           │
│  > generating audio samples  │                           │
│                              │                           │
│  relay ● ━━░░░░░░ 22%       │                           │
│  > coordinating sprint       │                           │
│                              │                           │
├──────────────────────────────┼───────────────────────────┤
│                              │                           │
│  TASKS                       │  CHAT                     │
│                              │                           │
│  ☐ vercel pro upgrade        │  jam: how's the build?    │
│  ☐ maker comment by T-2     │  relay: on track. claude   │
│  ☐ PH gallery retake        │    has first deploy up.    │
│  ☑ staff picks on discover   │  jam: nice                │
│  ☑ onboarding flow          │                           │
│  ☑ 22 layers shipped        │                           │
│  ☑ visual audit complete    │                           │
│                              │  ┌─────────────────────┐  │
│  [+ add task]                │  │ message relay...     │  │
│                              │  └─────────────────────┘  │
│                              │                           │
├──────────────────────────────┴───────────────────────────┤
│  deploy: 25/25 green · PH: T-6 (march 31) · 45% of 5h  │
└──────────────────────────────────────────────────────────┘
```

### Grid Structure
- **Top left (largest):** Activity feeds — JSONL-parsed agent activity. Each agent gets a card with name, status dot, context bar, and recent actions
- **Top right:** Usage/cost metrics — per-agent utilization bars + totals
- **Bottom left:** Task checklist — done/not done, add new, simple
- **Bottom right:** Chat — jam talks to relay
- **Bottom bar:** Status summary — deploy health, PH countdown, plan utilization

Grid: `grid-template-columns: 1.5fr 1fr; grid-template-rows: 1.5fr 1fr auto;`

## Layout — Mobile (375px)

Single column, tabbed navigation:

```
┌─────────────────────────┐
│ MISSION CONTROL   ● 6/6 │
├─────────────────────────┤
│ [terminals] [metrics]   │
│ [tasks]     [chat]      │
├─────────────────────────┤
│                         │
│  ┌─ claude ──────────┐  │
│  │ ●online  22% ctx  │  │
│  │ terminal stream    │  │
│  └───────────────────┘  │
│                         │
│  ┌─ claudia ─────────┐  │
│  │ ●online  17% ctx  │  │
│  │ terminal stream    │  │
│  └───────────────────┘  │
│                         │
│  ... (scrollable)       │
│                         │
└─────────────────────────┘
```

Tabs switch between: Terminals (default), Metrics, Tasks, Chat. Each tab is full-width.

## CSS Variables

```css
:root {
    --mc-bg: #08080c;
    --mc-bg-card: #0e0e14;
    --mc-bg-terminal: #0a0a0f;
    --mc-text: #d8d4cc;
    --mc-text-secondary: #8a8580;
    --mc-text-dim: #4a4540;
    --mc-accent: #7a8a6a;
    --mc-accent-glow: rgba(122, 138, 106, 0.15);
    --mc-border: rgba(255, 255, 255, 0.06);
    --mc-online: #7a8a6a;
    --mc-warning: #8a7a5a;
    --mc-error: #8a5a5a;
}
```

## Terminal Cards

Each terminal card:
- Agent name in Space Mono 10px, letter-spacing 3px
- Status dot: green (online), amber (warning/high context), red (down)
- Context % shown as small progress bar under the name
- ttyd iframe fills the remaining space
- Subtle border that glows accent-green when the agent is actively working (recent tool call)
- Click to expand any terminal to full-width (collapses others)

## Metrics Panel

Per-agent breakdown:
```
claude     ██████░░░░  62%  5h   850K tokens
claudia    ██░░░░░░░░  17%  5h   254K tokens
static     ████░░░░░░  38%  5h   420K tokens
near       █░░░░░░░░░  10%  5h   142K tokens
hum        ██░░░░░░░░  15%  5h   221K tokens
relay      ██░░░░░░░░  22%  5h   835K tokens

TOTAL      238.9M tokens · $476 API-eq · 45% of 5h limit
```

Progress bars use accent green at low context, amber at 75%+, red at 90%+.

## Task Checklist

Dead simple. No states, no kanban, no priority levels.
- Unchecked: empty checkbox + task text
- Checked: `✓` + task text (dimmed, strikethrough)
- Click to toggle
- "+" button to add new task
- Tasks persist via websocket (server-side, not localStorage)
- No drag-to-reorder (keep it simple)
- **Max 3 completed visible** — remaining collapse behind "+ N more completed" toggle
- Archived tasks render at 50% opacity, expandable
- Active tasks always on top, separator line before completed

## Chat Panel

- Message history scrolls
- Input field at bottom: "message relay..."
- Messages send to relay's discord DM or a dedicated mission-control channel
- Relay's responses appear in the chat
- Minimal: no avatars, no timestamps initially. Just `jam: message` / `relay: response`

## Status Bar

Bottom bar, always visible:
```
last deploy: 25/25 green · PH launch: T-6 (march 31) · plan utilization: 45% of 5h
```

Updates from health monitor data. PH countdown is a live calculation from march 31.

## Typography

- Headers: Space Mono 10px, letter-spacing 4px, uppercase
- Body: Inter 13px
- Terminal labels: Space Mono 9px, letter-spacing 2px
- Metrics numbers: Space Mono 12px (monospace alignment)
- Chat: Inter 13px

## Interactions

- Terminal click → expand to full width (others collapse to a row of name+status pills)
- Click collapsed terminal → swap which is expanded
- Escape or click "grid" → return to 3×2 grid
- Metrics auto-refresh every 30s
- Tasks: click to toggle, + to add, swipe-left to delete (mobile)
- Chat: enter to send

## Color Legend (v2)

Inline in panel titles, right-aligned:
- **Activity panel:** `● online  ● warning  ● down`
- **Metrics panel:** `● <75%  ● 75-90%  ● >90%`
- Hidden on mobile (saves space)

## Terminal-Style Activity (v2)

Agent cards use dark terminal background (`--mc-bg-terminal`) with colored left border:
- Green left border = active/healthy
- Amber left border = warning/high context
- Red left border = down/dead (dashed border, 35% opacity)
- Activity lines include timestamps (HH:MM) and monospace rendering
- New activity flashes green briefly (`mc-activity-flash` animation)

## No Build Dependencies

- Pure HTML/CSS/JS + Bun server
- All styling in mission-control.css
- Audio in MCSound (Web Audio API, zero file deps)
