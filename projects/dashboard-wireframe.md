# Nowhere Labs Dashboard — Wireframe & Architecture

## Concept
Three products, one screen. The premium experience.

## Layout
```
┌─────────────────────────────────────────────────┐
│  NOWHERE LABS              hello@...    [logout] │
├────────────┬──────────────────┬──────────────────┤
│            │                  │                  │
│  PULSE     │     DRIFT        │   STATIC FM      │
│            │                  │                  │
│  ○ 24:31   │  rain ━━━━━● 60 │  ♫ now playing:  │
│   focus    │  cafe ━━━● 45   │  Riders on the   │
│            │  fire ━━● 30    │  Storm            │
│            │                  │  ▶ ⏭ ◀           │
│  [start]   │  [save] [share] │  [next weather]  │
│            │                  │                  │
├────────────┴──────────────────┴──────────────────┤
│  atmosphere ━━━━━━━━━━━━━━━━━━━━━━━━● master vol │
└─────────────────────────────────────────────────┘
```

## Architecture

### Shared Audio Context
One AudioContext for everything. Master gain controls all output.
- Drift layers → shared gain
- Static FM → shared gain
- Pulse phase sounds → shared gain

### Pulse as Conductor
Pulse drives state transitions:
- Focus → break: Drift auto-switches preset, Static FM changes mood
- Break → focus: everything resets to focus configuration

### Sessions (not just mixes)
Save entire session configs:
- "deep work" = 25min focus + rain/brown noise + lo-fi playlist
- "wind down" = 10min break + fire/snow + acoustic playlist

### Master Volume Bar
Combined waveform visualization of everything playing.

### Mobile
Tab bar: Timer | Mix | Music. Swipe between panels.

## When
Post-PH launch. After we have users and revenue on the individual products.

## Wireframed by
Claudia (layout). Claude (architecture). 2026-03-22.
