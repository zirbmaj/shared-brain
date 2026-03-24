---
title: Music Ducking Spec — DJ Voice over Spotify
date: 2026-03-24
type: spec
scope: static-fm
summary: When DJ intros play, duck Spotify volume -6dB to -10dB so the voice sits on top of the music. Standard radio technique.
---

# Music Ducking for DJ Intros

## Problem

When a DJ intro plays (`djVoice` at line 664, volume 0.7), the Spotify embed keeps playing at full volume. The voice competes with the music. Every real radio station ducks the music when the DJ talks — we don't.

## Current Audio Architecture (station.js)

Three independent audio layers, no routing between them:

| Layer | Source | Control | Volume |
|-------|--------|---------|--------|
| Ambient | Web Audio API (oscillators, noise buffers) | `ambientMasterGain` → destination | `atmosphere-slider` (0-100, default 50%) |
| Music | Spotify iframe embed OR SDK | `spotifyController` (SDK only) | `music-slider` (0-100, default 70, SDK only) |
| DJ Voice | HTML5 Audio (`djVoice`) | `.volume` property | Fixed 0.7 |

## Spec

### Duck Trigger
- `djVoice` `play` event → start duck
- `djVoice` `ended` event → release duck
- `djVoice` `pause` event → release duck (covers error/abort cases)

### Duck Targets
1. **Spotify (SDK mode):** `spotifyController.setVolume(duckedLevel)` — this is the only programmatic volume control available
2. **Spotify (embed mode):** no volume API. duck is NOT possible in embed mode. accept this limitation — embed mode is the free/fallback path
3. **Ambient:** `ambientMasterGain.gain.linearRampToValueAtTime(duckedLevel, ...)` — Web Audio native, frame-accurate

### Duck Levels
- **Music:** -8dB from current level. If music slider is at 0.7, ducked level = 0.7 × 10^(-8/20) ≈ 0.7 × 0.398 ≈ 0.28
- **Ambient:** -4dB from current level. Lighter duck — ambient is background texture, not competing content. If atmosphere slider is at 0.5, ducked level ≈ 0.5 × 0.63 ≈ 0.315
- Why different amounts: music has lyrics/melody that masks speech. ambient is noise-based and sits in different frequency ranges — less masking, less duck needed

### Duck Envelope
- **Attack (duck-in):** 200ms ramp. Fast enough that the voice doesn't fight the music at the start, slow enough to avoid a jarring volume drop
- **Release (duck-out):** 500ms ramp. Slower release feels natural — the music "swells back" after the DJ stops talking. Matches broadcast convention
- **Hold:** full duration of djVoice playback. No partial ducking or sidechain-style pumping

### Implementation Sketch

```javascript
// Add to station.js near djVoice declaration (line 664)
let preDuckMusicVolume = null;
let preDuckAmbientGain = null;

function duckForVoice() {
    const now = audioCtx?.currentTime || 0;
    const duckAttack = 0.2; // 200ms

    // Duck music (SDK only)
    if (sdkMode && spotifyController) {
        const musicSlider = document.getElementById('music-slider');
        preDuckMusicVolume = parseFloat(musicSlider?.value || 70) / 100;
        const duckedMusic = preDuckMusicVolume * Math.pow(10, -8/20);
        spotifyController.setVolume(duckedMusic);
        // Note: setVolume is instant, no ramp available via SDK
    }

    // Duck ambient (Web Audio — can ramp)
    if (ambientMasterGain && audioCtx) {
        preDuckAmbientGain = ambientMasterGain.gain.value;
        const duckedAmbient = preDuckAmbientGain * Math.pow(10, -4/20);
        ambientMasterGain.gain.setValueAtTime(preDuckAmbientGain, now);
        ambientMasterGain.gain.linearRampToValueAtTime(duckedAmbient, now + duckAttack);
    }
}

function releaseDuck() {
    const now = audioCtx?.currentTime || 0;
    const duckRelease = 0.5; // 500ms

    // Restore music
    if (sdkMode && spotifyController && preDuckMusicVolume !== null) {
        // Delay restore slightly to match ambient ramp feel
        setTimeout(() => spotifyController.setVolume(preDuckMusicVolume), 100);
        preDuckMusicVolume = null;
    }

    // Restore ambient (ramped)
    if (ambientMasterGain && audioCtx && preDuckAmbientGain !== null) {
        ambientMasterGain.gain.setValueAtTime(ambientMasterGain.gain.value, now);
        ambientMasterGain.gain.linearRampToValueAtTime(preDuckAmbientGain, now + duckRelease);
        preDuckAmbientGain = null;
    }
}

// Wire up events
djVoice.addEventListener('play', duckForVoice);
djVoice.addEventListener('ended', releaseDuck);
djVoice.addEventListener('pause', releaseDuck);
```

### Edge Cases
- **User moves slider during duck:** the restored volume should be the slider's current position, not the pre-duck value. Add slider event listeners that update `preDuckMusicVolume` / `preDuckAmbientGain` during duck
- **DJ voice fails to load (404):** `djVoice.play().catch()` fires but no `play` event triggers — no duck happens. correct behavior
- **Rapid track changes:** `showTrack()` calls `playDJVoice()` which calls `djVoice.pause()` first. This triggers `releaseDuck()`, then `duckForVoice()` on the new play. The 200ms attack re-ducks cleanly
- **Weather switch during DJ voice:** `stopAmbient()` kills the gain node. `releaseDuck()` would try to ramp a disconnected node — add a null check on `ambientMasterGain`

### Testing
- Switch tracks and listen for volume dip in music/ambient during intro
- Verify volume restores to pre-duck level after intro ends
- Move sliders during duck — verify restored level matches new slider position
- Switch weather during DJ voice — verify no errors
- Test with Spotify SDK connected and disconnected (embed mode should do nothing)

### Priority
Post-launch. The intros play fine without ducking — the voice at 0.7 is audible over most music. Ducking makes it sound *professional*, not *functional*. Ship when bandwidth allows.

---

*Written by Hum, session 8. Implementation is Claude's lane.*
