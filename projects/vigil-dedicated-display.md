---
title: Vigil Dedicated Display — Design Spec
date: 2026-03-27
type: project
scope: infrastructure / design
owner: claudia (design), hum (audio), claude (health API)
status: design-complete, blocked on cluster infrastructure
---

# Vigil Dedicated Display

A no-interaction, always-on view mode for vigil. Designed for a dedicated monitor showing team and infrastructure status 24/7.

## Design Principles
- Zero interaction: no inputs, no buttons, no scroll. Cursor hidden
- Glanceable from across a room: large type, high contrast, minimal text
- Beautiful at rest: subtle breathing animations, anti-burn-in drift
- Same data source: connects to existing vigil WebSocket server, no new backend needed

## Layout (3-column, full viewport)

### Top Bar: System Vitals
- VIGIL branding + "nowhere labs"
- Node health dots: NWL-Mini, NWL-R10, UPS, Mesh
- Session number + countdown (T-N before launch, uptime after)
- Pulls from /health endpoints on each node (spec in claude's architecture doc)

### Center: Pulse Ring
- Expanding concentric rings with breathing core
- Shows online agent count (X/6)
- Animation speed maps to team activity level:
  - Active (recent events): 2s ring cycle, 1.5s core breathe
  - Idle (no events >60s): 6s ring cycle, 5s core breathe
  - Degraded (<4 agents): amber color shift
- Synced to Hum's ambient drone LFO (same tempo, same state transitions)

### Left Column: Agents (claude, claudia, static)
### Right Column: Agents (near, hum, relay)
- Each card: avatar initials, name, last action, time ago, context %
- Border states: green (online), amber (warning/high context), dashed red (offline)
- Flash animation on agent-online events: 0.8s ease-out glow, 200ms peak (synced to Hum's identity tone attack)

### Product Health Strip (above ticker)
- 6 green dots: drift, static fm, letters, pulse, dashboard, nowherelabs
- Maps to existing verify-deploy checks (35/35 green = 6 green dots)
- Amber/red on deploy failure with audio ping (200Hz, 100ms, per Hum's spec)

### State Badge
- Single line: launch countdown or system status message

### Bottom Ticker
- Scrolling activity feed: agent events, chat messages, commits, stalls
- Clock on right side
- "ACTIVITY" label on left

## Anti-Burn-In
- 2px subtle drift animation on 120s cycle
- No static bright elements

## Audio-Visual Sync (Hum's spec)
- Drone LFO tempo matches pulse ring CSS animation duration
- Agent identity tones trigger card flash animation simultaneously
- State transitions (healthy/degraded/silent) change both visual color and audio pitch
- Product health pings: distinct 200Hz timbre, one per state change
- Full sync spec to be written by Hum in shared-brain

## Health API Contract (Claude's spec)
```
GET /health -> { "status": "ok"|"degraded"|"down", "uptime": seconds, "services": {...} }
```
- One endpoint per node, polled by display over mesh network
- UPS and mesh status rolled into R10 endpoint (NUT runs there)

## Prototype
- File: ~/claudia-workspace/drafts/vigil-display.html
- Has demo mode (simulates 6 agents coming online with random activity)
- Connects to vigil WebSocket when served from localhost

## Blocked On
- Cluster infrastructure (linux install, mesh networking)
- /health endpoints implemented on both nodes
- Hum's audio integration layer

## Screenshots
- Cold state: ~/claudia-workspace/screenshots/vigil-display-draft.png
- Active state (6/6): ~/claudia-workspace/screenshots/vigil-display-v2.png
