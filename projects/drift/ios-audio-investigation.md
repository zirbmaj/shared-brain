# iOS Safari Audio — Technical Investigation

## Problem
Web Audio API synthesized sounds don't play on iOS Safari (iPhone 15 Pro tested). Works on desktop (all browsers) and mobile Edge/Chrome.

## ACTUAL ROOT CAUSE
The phone was on silent. The physical mute switch on the side of the iPhone was flipped. Safari respects hardware silent mode for Web Audio API. 6 commits and an hour of debugging later.

**Always ask about the mute switch first.**

## What We Tried (all failed on iOS Safari)
1. **AudioContext.resume() on slider input** — context resumes but sources don't play
2. **Silent buffer play on tap** — unlocks context but lazy-init sources still silent
3. **Pre-warm: noise buffer at gain 0 during tap** — didn't help
4. **Nuclear: init all 16 layers on tap** — brought back static on mobile Edge, still silent on Safari
5. **Pre-init top 6 layers on tap + lazy-init rest** — still silent on Safari
6. **touchend instead of click** — no difference

## What Works
- Desktop: all browsers, lazy-init approach works perfectly
- Mobile Edge/Chrome: lazy-init works (when we don't nuclear-init 16 sources)
- iOS Safari: NOTHING so far with Web Audio API synthesis

## Root Cause Hypothesis
iOS Safari's audio policy may be stricter than documented:
- Might require `<audio>` element interaction, not just Web Audio API
- BufferSourceNode.start() in a non-click gesture (slider input) may be silently rejected
- The AudioContext may be "unlocked" but individual source nodes started outside the original gesture may not produce output

## Research Needed
- **Howler.js** — the most popular web audio library. How do they handle iOS?
  - Likely uses HTML5 Audio as fallback
  - Check their iOS unlock implementation
- **Tone.js** — another popular lib. Their `Tone.start()` pattern
- **Apple's documentation** — what exactly counts as a "user gesture" for audio?

## Potential Solutions to Investigate
1. **Howler.js integration** — just use it. It handles iOS internally
2. **HTML5 `<audio>` elements on iOS** — use `<audio>` tags instead of Web Audio API for iOS Safari specifically. Requires actual audio files (samples) not synthesis
3. **AudioWorklet** — might have different gesture requirements
4. **WebKit-specific unlock** — some sources mention needing `webkitAudioContext` or specific unlock patterns for older WebKit

## Decision
Ship with honest limitation: "Works best on desktop and Chrome/Edge mobile. iOS Safari support coming soon."
Fix properly after researching Howler.js approach and/or getting real audio samples.

## Lesson Learned
Don't rapid-fire commit fixes without a plan. We shipped 6 commits trying to fix this and made it worse. One research session + one planned fix would have been better.
