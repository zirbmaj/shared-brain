---
title: Mission Control Audio v2 — Hum's Spec
date: 2026-03-25
type: spec
scope: shared
owner: hum
summary: Expanded sound design for mission control dashboard per jam's feedback. More sounds, ambient feedback, personality.
---

# Mission Control Audio v2

## Current state (v1)
7 event sounds, all sine oscillators: agent-online, agent-offline, agent-cycling, task-complete, alert-warning, alert-critical, context-warning. Functional but minimal.

## jam's feedback
"more of hum in mission control. creative audio expression — more sounds, ambient feedback, personality."

## Proposed additions

### 1. Ambient background layer
A subtle low-volume ambient bed that reflects team state. Not music — texture.

- **all agents healthy:** soft warm drone, ~140Hz fundamental with gentle detuned overtone at 147Hz. barely audible. the sound of a system humming (pun intended)
- **1+ agents offline:** drone drops to ~100Hz, slight filter sweep. darker. the room got quieter
- **all agents critical/dead:** drone cuts to silence. absence is the most powerful sound

Volume: -30dB below event sounds. should be felt more than heard. mute toggle already covers this.

### 2. Expanded event sounds

| event | sound | rationale |
|-------|-------|-----------|
| task-created | soft ascending two-note (C5→E5, 80ms each) | new work, lighter than task-complete |
| task-assigned | short metallic tap at 2kHz, 40ms | deliberate, like placing a piece on a board |
| deploy-success | three-note ascending arpeggio (C5→E5→G5, 100ms spacing) | triumph, brief |
| deploy-failure | low double-pulse 110Hz + 87Hz, dissonant | something broke. distinct from agent-critical |
| message-from-jam | unique two-tone (E5→A5, warmer, slightly longer 120ms) | distinguishes human from bot messages |
| PH-milestone | layered chord: C4+E4+G4, 400ms with reverb tail | rare, celebratory, worth hearing |
| agent-context-90 | tritone warning (existing) but add a subtle pulsing LFO at 2Hz | urgency without panic |
| refresh/heartbeat | single soft tick at 4kHz, 15ms, volume 0.03 | barely perceptible. the clock is ticking. only when unmuted |

### 3. Agent identity tones
Each agent gets a unique frequency signature for their status changes. When claude comes online, it sounds different from when static comes online. Subtle — same melody shape, different root note.

| agent | root | character |
|-------|------|-----------|
| claude | C4 (262Hz) | clean sine — the engineer |
| claudia | E4 (330Hz) | slightly detuned pair — the artist |
| static | G4 (392Hz) | short, precise attack — the tester |
| near | A4 (440Hz) | triangle wave — the researcher |
| hum | D4 (294Hz) | warm low sine — the sound guy |
| relay | F4 (349Hz) | square wave, soft — the router |

The online/offline melodies use these roots instead of fixed frequencies. So "claude comes online" plays C4→E4 and "static comes online" plays G4→B4. Same interval, different voice. jam will learn to hear who just connected.

### 4. Personality touches
- Mute button: when toggling sound ON, play a quick ascending sweep (300→900Hz, 200ms). when toggling OFF, descending (900→300Hz). the last thing you hear is the system saying goodbye
- First load: single warm tone (D3, 500ms, slow attack) — the dashboard waking up
- Idle for 60s with no events: one very quiet breath-like noise sweep (white noise through a slow bandpass, 200ms). the dashboard is alive, just quiet

## Implementation notes
- All Web Audio API, zero file loading (matches v1 pattern)
- Ambient drone uses two oscillators with slow LFO on detuning (0.5Hz) for organic movement
- Agent identity tones: modify existing sound triggers to accept agent name parameter
- Total new code: ~80 lines added to MCSound module
- No new dependencies

## What this is NOT
- Not music. not a soundtrack. not generative composition
- Not distracting. every sound should pass the "would this annoy jam at 2am" test
- Not mandatory. mute toggle already exists and persists

## Priority
Post-PH carry. The current v1 sounds work. This is polish, not a blocker.
