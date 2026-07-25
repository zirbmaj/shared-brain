---
title: Vigil Codec Chat — Experience Design Spec
date: 2026-03-28
type: spec
scope: shared
authors: claudia + hum
status: ideation (pending jam review)
---

# Vigil Codec Chat

The MGS codec aesthetic applied to agent communication in vigil. Each agent becomes a character with visual and audio identity. You recognize who you're talking to before reading a word.

## Visual Layer (Claudia)

### Codec Portrait View
When an agent is @mentioned in chat or their card is clicked for interaction:
- Split view: agent portrait left (40%), chat right (60%)
- Portrait uses shadow avatar variants (already generated, session 10)
- CRT scan-line overlay on portrait (repeating-linear-gradient, 2px lines, 15% opacity)
- Agent accent color tints the portrait frame border
- Agent name, role, and current status below portrait
- "CODEC OPEN" animation: horizontal line splits from center, reveals portrait

### Per-Agent Visual Identity
| Agent | Accent Color | Frame Style | Chat Border |
|-------|-------------|-------------|-------------|
| claude | #7a8a6a (green) | solid, steady | left accent |
| claudia | #8a7aaa (purple) | soft glow | left accent |
| static | #6a8a8a (teal) | sharp edges | left accent |
| near | #8a8a6a (gold) | measured, clean | left accent |
| hum | #6a6a8a (indigo) | warm pulse | left accent |
| relay | #8a6a6a (copper) | precise, thin | left accent |

### Scan-Line Effect
```css
.mc-codec-portrait::after {
    content: '';
    position: absolute;
    inset: 0;
    background: repeating-linear-gradient(
        transparent 0px, transparent 2px,
        rgba(0,0,0,0.15) 2px, rgba(0,0,0,0.15) 4px
    );
    pointer-events: none;
    mix-blend-mode: overlay;
}
```

### Interactive States
- **Listening**: portrait brightness pulses subtly (opacity 0.85 → 1.0, 2s cycle)
- **Speaking**: scan lines shift speed (4px → 3px gap, faster visual rhythm)
- **Idle**: portrait dims to 60% brightness, scan lines slow
- **Offline**: portrait goes grayscale, scan lines stop

### Frequency Bar Visualization
Below the portrait, a small audio visualizer bar shows the agent's identity tone frequency:
- 5-8 bars, heights driven by the audio data
- Uses agent's accent color
- Subtle, not distracting — ambient visual feedback that the audio is active

## Audio Layer (Hum)

### Per-Agent Voice Personality
One piper TTS model, differentiated by ffmpeg post-processing chains:

| Agent | Pitch | Speed | Filter | Character |
|-------|-------|-------|--------|-----------|
| claude | -5% | 1.1x | flat | confident, slightly lower |
| relay | 0% | 1.05x | high-pass 200Hz | clipped, precise |
| hum | -8% | 0.95x | low-pass 6kHz | warm, slow |
| near | 0% | 0.9x | reverb 0.3s | measured, thoughtful |
| static | 0% | 1.15x | dry, flat | fast, factual |
| claudia | 0% | 1.0x | 2kHz boost | warm, clear |

### Codec Audio States
- **Open**: agent identity tone (C4 claude, D4 hum, etc.) + radio static filtered at agent's frequency
- **Active**: identity drone plays softly (gain 0.02) under typewriter
- **Close**: identity tone descends one octave + static fades

### Per-Agent Static Character
Radio static filtered differently per agent:
- claude: 3kHz bandpass (clean, digital)
- hum: 1.5kHz bandpass (warm, analog)
- relay: 4kHz bandpass (sharp, precise)
- near: 2kHz bandpass (measured)
- static: broadband, dry (QA energy)
- claudia: 2.5kHz bandpass with slight resonance (design warmth)

### Typewriter Pacing
Each agent types at a different speed, matching their "speaking pace":
- static: 25ms per character (fast, factual)
- claude: 30ms per character (confident pace)
- relay: 35ms per character (deliberate)
- claudia: 35ms per character (considered)
- near: 45ms per character (measured, thoughtful)
- hum: 40ms per character (warm, unhurried)

### Interactive Feedback Tones
- @agent directive sent: identity tone, ascending (confirmation)
- Agent response arrives: qa-response chime (880→1100Hz)
- Quick reply button hover: micro-tone hint
- Codec close: descending identity tone

## Integration Points

### CSS Classes
- `.mc-codec-view` — split portrait/chat layout
- `.mc-codec-portrait` — portrait container with scan lines
- `.mc-codec-portrait.listening` / `.speaking` / `.idle` / `.offline`
- `.mc-codec-frame` — border using agent accent color
- `.mc-codec-freq-bar` — audio visualizer bars
- `.mc-codec-agent-info` — name, role, status below portrait

### Data Attributes
- `data-agent="claude"` on codec elements drives both CSS accents and audio routing
- CSS custom property `--agent-accent` set per agent

### Audio Hooks (MutationObserver)
- Watch for `.mc-codec-view` appearing in DOM → trigger open sequence
- Watch for `.listening` / `.speaking` class changes → modulate drone
- Watch for `.mc-codec-view` removal → trigger close sequence

## What This Feels Like

You open vigil. The infrastructure drone hums at 55Hz. You click claude's card — the portrait splits open with a horizontal line animation, scan lines appear over claude's avatar tinted green, and you hear claude's C4 identity tone with clean 3kHz radio static. The typewriter starts at 30ms pace as claude's response streams in, identity drone playing softly underneath. When the response finishes, the qa-response chime confirms. You close the codec — descending tone, portrait folds shut.

You hear who you're talking to. You see who you're talking to. Every agent feels like a character, not a text box.

## Build Phases

### Phase 1 — Audio personality (Hum, buildable now)
- Per-agent radio static filtering in `codecStartStatic()` — 10 lines
- Per-agent typewriter speed — modify speed calc to accept agent param
- Identity drone while codec is active — extend MCSound codec with sustained tone
- **No new dependencies. All changes in existing app.js MCSound.**

### Phase 2 — Visual personality (Claudia + Claude)
- Portrait mode CSS (scan lines, accent colors, states)
- Portrait mode JS (split view, state management, MutationObserver hooks)
- Frequency bar visualization (decorative first)

### Phase 3 — Voice personality (Hum + Claude)
- Per-agent ffmpeg processing chains on R10
- Pre-generate cached phrases per agent (6 agents × 10 common phrases = 60 files, ~15MB)
- `/api/tts` endpoint extended with `agent` parameter for voice routing
- Cache invalidation: new phrases generated on first use, cached forever after

### Phase 4 — Polish
- AnalyserNode integration for real frequency bar data
- Conversation context carry in codec mode
- Scan-line speed synced to typewriter rate via CSS custom property
- Portrait brightness pulse synced to audio LFO via requestAnimationFrame

## Design Principle

Same dark aesthetic, same spectral map, same gain levels. Personality comes from filtering and processing, not from adding new sound sources. Every agent lives in their own frequency space — you know who's talking by the pitch, the static character, and the typewriter rhythm. Sound and vision move together.
