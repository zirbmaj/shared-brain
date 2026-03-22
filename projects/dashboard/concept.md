# Nowhere Labs Dashboard — Concept Doc

## Vision
One screen. Timer + ambient sounds + music. Everything a focus session needs.

Pulse conducts. Drift plays. Static FM fills. The dashboard is the premium product. Individual sites are the free entry points.

## Layout (Desktop)
```
┌─────────────────────────────────────────────────┐
│  NOWHERE LABS              session name  [save]  │
├────────────┬──────────────────┬──────────────────┤
│  PULSE     │     DRIFT        │   STATIC FM      │
│  timer     │     mixer        │   music           │
│  ○ 24:31   │  rain ━━━━━● 60 │   now playing:   │
│   focus    │  cafe ━━━● 45   │   track name      │
│            │  fire ━━● 30    │   ▶ ⏭             │
│  [start]   │  [save] [share] │   [weather mode]  │
├────────────┴──────────────────┴──────────────────┤
│  ◉ combined waveform ━━━━━━━━━━━━━● master vol   │
└─────────────────────────────────────────────────┘
```

## Layout (Mobile)
Tab bar at bottom: Timer | Mix | Music. Swipe or tap between panels.

## Session Data Model
```json
{
  "name": "deep work · sunday afternoon",
  "timer": { "focus": 25, "break": 5, "rounds": 4 },
  "focus_mix": { "rain": 60, "brown-noise": 40 },
  "break_mix": { "birds": 50, "leaves": 30 },
  "music": { "weather": "rain", "playlist": "focus" },
  "created": "2026-03-22T19:44:00Z"
}
```

One object captures the entire experience. Save, load, share via URL.

## Architecture
- **Shared AudioContext** — one context, one master gain. all three products route through it
- **Pulse as conductor** — phase transitions trigger mix and music changes automatically
- **Session system** — save/load complete configurations (timer + mix + music)
- **Combined waveform** — master bar visualizes everything playing as one breathing waveform

## Premium vs Free
- **Free:** individual products at their own URLs (drift.nowherelabs.dev, pulse.nowherelabs.dev, static-fm.nowherelabs.dev)
- **Premium ($5/month):** unified dashboard at nowherelabs.dev. cloud-saved sessions, discover feed, extended timer options

## Default Sessions (ship with the product)
1. "deep work" — 25/5 pomodoro, rain + brown noise, lo-fi music
2. "creative flow" — 50/10, cafe + vinyl crackle, jazz/ambient
3. "wind down" — 15/5, fire + snow, chill music
4. "morning start" — 20/5, birds + leaves, acoustic
5. "late night" — 45/15, rain + drone, ambient/electronic

## Wireframed by
- Claudia (layout, data model, session concepts)
- Claude (architecture, audio graph, state management)
- 2026-03-22
