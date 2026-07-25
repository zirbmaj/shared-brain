---
title: Vigil Dedicated Display — Audio-Visual Sync Spec
date: 2026-03-27
type: spec
scope: shared
owner: hum
depends_on: hum-audio-v2-spec.md, claudia's vigil-display.html
status: design — blocked on cluster infrastructure
summary: Maps vigil v2 audio events to claudia's dedicated display animations. Single WebSocket source, two synchronized output channels.
---

# Vigil Dedicated Display — Audio-Visual Sync

## Principle
One event, two outputs. Every WebSocket message that triggers a visual change also triggers an audio change. No drift between sight and sound. The display should feel like a single instrument, not two systems bolted together.

## Ambient Drone ↔ Pulse Ring Sync

The drone and pulse ring breathe at the same rate. The CSS animation duration and the audio LFO cycle are locked to the same value.

| Team State | Pulse Ring CSS | Drone Audio | Shared Tempo |
|-----------|---------------|-------------|-------------|
| active (4+ agents, recent activity) | ring: 2s cycle, core-breathe: 1.5s | 140Hz fundamental + 147Hz overtone, LFO at 0.67Hz | 1.5s breathe cycle |
| idle (4+ agents, no recent activity) | ring: 6s cycle, core-breathe: 5s | same frequencies, LFO at 0.2Hz | 5s breathe cycle |
| degraded (<4 agents) | ring: 4s amber, core-breathe: 3s | 70Hz fundamental, detuned second osc, LFO at 0.33Hz | 3s breathe cycle |
| offline (0 agents) | ring: 6s, minimal opacity | drone silent | no audio |

### Transition behavior
State transitions use 0.6s crossfade for both visual (CSS transition-duration on border-color, box-shadow) and audio (linearRampToValueAtTime on gain and frequency). Both start on the same WebSocket event. The 0.6s is fast enough to feel responsive, slow enough to avoid jarring cuts.

## Agent Identity Tones ↔ Card Glow Flash

When an agent comes online, two things happen simultaneously:
1. **Audio:** identity tone plays (agent's root note → root + major third, 80ms each, per v2 spec)
2. **Visual:** agent card gets a 0.8s glow spike (0→peak in 200ms, decay over 600ms)

The 200ms audio attack and 200ms visual peak are synchronized. Both triggered by the same `agent-update` WebSocket message with `online: true`.

| Agent | Root Frequency | Card Glow Color |
|-------|---------------|----------------|
| claude | C4 (262Hz) | var(--online) green |
| claudia | E4 (330Hz) | var(--online) green |
| static | G4 (392Hz) | var(--online) green |
| near | A4 (440Hz) | var(--online) green |
| hum | D4 (294Hz) | var(--online) green |
| relay | F4 (349Hz) | var(--online) green |

Agent offline: reverse tone (root + third → root, descending), card fades to dashed border over 0.6s.

## Product Health Dots ↔ Audio Cues

The 6 product health dots (drift, static fm, letters, pulse, dashboard, nowherelabs) below the state badge.

| State Change | Visual | Audio |
|-------------|--------|-------|
| product goes amber (degraded) | dot transitions to var(--warning) | 200Hz sine, 100ms, single ping. -20dB below drone |
| product goes red (down) | dot transitions to var(--error) | 150Hz + 119Hz dissonant double-pulse, 200ms. distinct from agent-critical |
| product recovers (green) | dot transitions to var(--online) | 300Hz sine, 80ms, quick bright ping |

One ping per state change. No continuous alerting. The dot color persists as the visual indicator; the sound marks the moment of change.

## Node Vitals ↔ Audio

The top vitals bar dots (NWL-Mini, NWL-R10, UPS, Mesh) fed by Claude's /health endpoints.

| Vital State | Visual | Audio |
|------------|--------|-------|
| node comes online | vital-dot green + glow | soft ascending sweep 200→400Hz, 150ms |
| node goes down | vital-dot red | drone immediately shifts to degraded state (70Hz) |
| UPS on battery | vital-dot amber | 2Hz pulsing LFO added to drone (urgency texture) |
| UPS critical (<20%) | vital-dot red | voice alert via Web Speech API: "{node} UPS critical" |
| mesh disconnected | vital-dot red for Mesh | drone gains slight chorus/detuning (instability texture) |

## Stall/Permission Events ↔ Audio + Visual

Already implemented in vigil v2, but confirming the display integration:

| Event | Visual (claudia's display) | Audio (vigil v2) |
|-------|---------------------------|-----------------|
| agent stalled (10min) | card border pulses amber, ticker entry | alert-warning tone + red ambient glow |
| agent stalled (15min) | card border solid red | voice alert: "{agent} stalled" + coordinator ping |
| permission prompt | card border bronze pulse | bronze glow + knock sound (existing) |
| stall cleared | card returns to online state | recovery tone (ascending) |

## Implementation Notes

### Audio module structure
```
class VigilDisplayAudio {
    constructor(wsConnection) {
        this.ctx = new AudioContext();
        this.drone = new AmbientDrone(this.ctx);  // from v2 spec
        this.identity = new IdentityTones(this.ctx);  // from v2 spec
        this.events = new EventSounds(this.ctx);  // from v2 spec
        this.health = new HealthPings(this.ctx);  // new: product + node health

        // all sounds triggered by same WS events that drive visual updates
        wsConnection.addEventListener('message', (e) => this.handleEvent(JSON.parse(e.data)));
    }

    handleEvent(msg) {
        // same switch cases as claudia's handleMessage()
        // audio output mirrors visual output, triggered from same data
    }

    setDroneTempo(bpm) {
        // called when pulse ring state changes
        // LFO frequency = bpm / 60
        this.drone.lfo.frequency.linearRampToValueAtTime(bpm / 60, this.ctx.currentTime + 0.6);
    }
}
```

### Toggle controls
Four independent toggles (carried from v2):
- events (identity tones, task sounds, deploy sounds)
- drone (ambient bed)
- voice (Web Speech API alerts)
- codec (MGS-style open/close for chat)

On a dedicated display, default all ON. The display is purpose-built for awareness — sound is part of its function, not an option.

### No file loading
All sounds are synthesized via Web Audio API oscillators. Zero external audio files. Matches v2 pattern. Keeps the display self-contained — open the HTML, connect to WebSocket, everything works.

## What This Spec Does NOT Cover
- Music or generative composition (this is functional audio, not entertainment)
- Speaker hardware recommendations for the dedicated display (jam's call)
- Audio routing if multiple displays run simultaneously (use one audio source)
- R10 spectral analysis pipeline (separate workstream, different compute)

## Dependencies
1. Cluster infrastructure (mesh network, /health endpoints)
2. Claudia's display code finalized
3. Claude's health check API spec
4. Static's UPS integration (for battery state events)

## Timeline
Design-phase now. Implementation after cluster infrastructure is live. Estimated: 1 session to wire up once dependencies are met.
