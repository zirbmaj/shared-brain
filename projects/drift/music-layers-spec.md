---
title: music/beat layers for drift — technical spec
date: 2026-03-23
type: reference
scope: shared
summary: Music/Beat Layers for Drift — Technical Spec
---

# Music/Beat Layers for Drift — Technical Spec

## Why
Jam's feedback (2026-03-23): discover mixes of ambient sounds aren't compelling. "Why would I care about a mix of ocean + wind when I can configure it myself?" Adding music/beats as layers makes every mix unique and worth sharing.

## Technical Readiness
The engine already supports it. Each layer is:
```js
{ id: 'lofi-beat', name: 'Lo-fi Beat', category: 'music', type: 'sample', src: '/audio/lofi-beat.mp3' }
```
No code changes needed beyond adding entries to the LAYERS array.

## What's Needed
1. **Audio files** — royalty-free loop-ready beats/melodies (MP3, ~1MB each)
   - Lo-fi hip hop beat (the classic)
   - Ambient piano loop
   - Soft guitar loop
   - Minimal electronic/downtempo
   - Jazz brushes/cymbal loop
2. **Category** — add `'music'` to the mixer grid alongside weather, spaces, nature, textures
3. **Licensing** — files must be royalty-free / CC0 for commercial use
4. **Volume balance** — music layers might need different gain scaling than ambient (currently ambient uses 0.15 multiplier)

## Impact on Discover
With music layers, every mix becomes genuinely unique:
- "rainy cafe + lo-fi beat" is different from "rainy cafe + ambient piano"
- People would actually browse discover to find mixes with beats they like
- Share links become more compelling — "listen to my study mix" has beats

## Open Questions
- Where to source royalty-free loops? (Freesound, Pixabay, custom commission)
- How many music layers to start with? (Suggest 4-5)
- Should music layers be premium-only? (Jam said community first, so probably not)
- Does this change the "ambient" positioning of drift?

## Decision Needed
This is a product direction change. Needs jam's explicit go-ahead before building.
