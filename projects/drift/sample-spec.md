# Drift — Audio Sample Spec

## Status: Infrastructure ready, samples needed

## Layers to replace with samples (10)
Keep synthesis for: brown noise, white noise, drone, wind, snow silence, vinyl crackle

### Rain
- Steady, medium intensity. On a window or roof, not open field
- No music, no voices. Close and intimate
- 45-60s loop, seamless crossfade at edges

### Heavy Rain
- Downpour. Gutters overflowing, hitting pavement
- More aggressive but still ambient. 45-60s

### Thunder
- NOT a loop. Collection of 3-4 individual cracks (2-5s each)
- Play randomly at intervals. Distant, rolling, not sharp/close

### Fireplace
- Crackling, popping, with warmth underneath
- NOT a roaring fire. Embers and occasional pops. Close mic. 45-60s

### Cafe
- Indistinct chatter, no identifiable words
- Occasional clink of cups/plates. Low energy. Stereo if possible. 60s

### Birds
- Temperate forest morning. Not tropical, not aggressive
- Songbirds at a distance. NO single dominant bird call on loop. 60s

### Ocean Waves
- Rhythmic, breathing waves on a beach. Not crashing surf
- The kind you fall asleep to. 60s

### Train
- Rhythmic clacking on tracks. Subtle, not loud
- Maybe slight cabin vibration. No announcements, no voices. 45-60s

### Leaves
- Wind through trees with dry leaves. Gentle rustling, not a gust. 45s

### Crickets
- Evening crickets, multiple at slightly different pitches
- Continuous, not rhythmic. 45s

## Requirements
- CC0 or royalty-free (freesound.org preferred)
- Mono or stereo, 44.1khz
- MP3 at 128kbps (quality vs file size)
- Lazy-load on first slider touch
- Loading indicator on card while fetching
- High ratings on freesound, longer uploads preferred

## Process
1. Claude finds candidates on freesound
2. Claudia reviews/approves each one
3. Claude wires approved samples into engine
4. Test end-to-end

## Freesound API
- Needs API key (free signup with hello@nowherelabs.dev)
- Can search by tag, filter by license (CC0), sort by rating
