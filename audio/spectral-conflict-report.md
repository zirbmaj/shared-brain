# Spectral Conflict Report — Drift Layer Pairs

**Date:** 2026-03-31 | **Author:** Hum | **Layers:** 22 (15 sample + 7 synthesis) | **Pairs:** 231

## Summary

| Severity | Count | Threshold |
|----------|-------|-----------|
| High conflict | 26 | >0.70 overlap |
| Medium conflict | 64 | 0.40–0.70 |
| Low conflict | 141 | <0.40 |

**Method:** Bhattacharyya coefficient on normalized power spectral densities. 0.0 = no spectral overlap, 1.0 = identical spectrum. Sample layers analyzed from MP3 files (seamless/), synthesis layers generated from known parameters.

## High Conflict Pairs (top 26)

These pairs compete for the same frequency bands. When both are at high volume, one will mask the other.

| # | Layer A | Layer B | Overlap | Frequency Band | Note |
|---|---------|---------|---------|----------------|------|
| 1 | vinyl | white-noise | 0.94 | broadband HF | expected — both are noise layers |
| 2 | waves | creek | 0.91 | 300–1800Hz mid | both water sounds, near-identical spectrum |
| 3 | heavy-rain | fire | 0.89 | 80–110Hz low-mid | fire's warmth bed sits on heavy-rain's body |
| 4 | fire | snow | 0.88 | 50–200Hz low | fire warmth + snow furnace hum overlap |
| 5 | distant-traffic | gentle-thunder | 0.86 | 20–65Hz sub-bass | both ultra-low rumble |
| 6 | thunder | train | 0.86 | 30–330Hz low | both dynamic low-frequency layers |
| 7 | leaves | gentle-thunder | 0.84 | 10–43Hz sub-bass | both concentrate energy below 50Hz |
| 8 | distant-traffic | snow | 0.83 | 50–180Hz low | traffic rumble + snow furnace |
| 9 | heavy-rain | cafe | 0.82 | 50–110Hz low-mid | rain body masks cafe murmur |
| 10 | thunder | cafe | 0.82 | 43–65Hz low | thunder rumble masks cafe low-end |
| 11 | birds | keyboard | 0.82 | 3000–4300Hz high | both peak in the 3–4kHz range |
| 12 | waves | wind | 0.81 | 200–1000Hz mid | wave spray + wind noise |
| 13 | heavy-rain | thunder | 0.81 | 43–150Hz low | classic pair but they fight |
| 14 | fire | cafe | 0.81 | 54–108Hz low-mid | fire warmth + cafe murmur |
| 15 | cafe | snow | 0.81 | 50–65Hz low | cafe murmur + furnace hum |
| 16 | thunder | snow | 0.80 | 43–183Hz low | thunder + furnace |
| 17 | train | snow | 0.79 | 32–183Hz low | train clicks + furnace |
| 18 | thunder | wind | 0.78 | 43–334Hz low-mid | thunder rumble + wind body |
| 19 | cafe | distant-traffic | 0.78 | 54–65Hz low | very similar bass profile |
| 20 | heavy-rain | snow | 0.77 | 54–108Hz low | rain body + furnace |
| 21 | heavy-rain | distant-traffic | 0.76 | 54–108Hz low | both low rumble |
| 22 | heavy-rain | train | 0.76 | 32–150Hz low | rain body + train clicks |
| 23 | fire | distant-traffic | 0.75 | 54–108Hz low-mid | fire warmth + traffic |
| 24 | fire | train | 0.74 | 32–108Hz low | fire + train low-end |
| 25 | train | wind | 0.72 | 32–301Hz low-mid | train rhythm + wind |
| 26 | train | distant-traffic | 0.71 | 32–65Hz low | both transportation sounds |

## Key Findings

### 1. The low-frequency pile-up (50–200Hz)
The biggest problem area. 8 layers concentrate energy in the 50–200Hz range: **heavy-rain, fire, cafe, thunder, train, snow, distant-traffic, gentle-thunder**. Any 3+ of these at high volume will create a muddy, boomy mix. This is the #1 actionable finding.

### 2. Safe combinations (low conflict)
These pairs have minimal spectral overlap and work well together:
- **crickets + drone** (0.05) — high-freq chirps vs sub-bass hum
- **birds + snow** (0.10) — 3kHz birdsong vs 50Hz furnace
- **binaural + vinyl** (0.06) — 200Hz tone vs 4kHz+ hiss
- **crickets + any low-freq layer** (<0.15) — crickets at 6.5kHz sit above everything
- **birds + any low-freq layer** (<0.20) — birds at 3.6kHz are well-separated

### 3. Expected conflicts (not actionable)
- vinyl × white-noise (0.94): both broadband noise, nobody would combine these
- waves × creek (0.91): both water — users choose one, not both

### 4. Surprising conflicts
- **birds × keyboard** (0.82): both peak at 3–4kHz. keyboard typing sounds occupy the same "presence" frequency as birdsong. A user mixing "cafe with birds and keyboard sounds" would get mud in the highs
- **fire × snow** (0.88): fire's warmth bed and snow's furnace hum are nearly identical spectrally. Both are "cozy indoor" sounds but they cancel each other out

## Recommendations

### For the product (Claude's lane)
1. **Mix recommendation engine** could use this data to warn users when they're combining high-conflict layers, or suggest complementary combinations
2. **Preset mixes** should avoid stacking 3+ layers from the 50–200Hz conflict zone
3. **Layer grouping in UI** could visually indicate which layers share frequency space

### For audio (my lane)
1. **EQ separation on the worst pairs** — if heavy-rain + fire are commonly combined, we could highpass fire at 120Hz to move it out of heavy-rain's body. Needs user behavior data first
2. **Spectral conflict map in knowledge base** — this report, kept updated as layers are added
3. **Per-layer frequency band labels** in the UI (e.g., "low rumble", "mid texture", "high detail") to help users self-serve better mixes

### Not recommended
- Automatic EQ ducking between layers — adds complexity, breaks the "invisible" principle
- Removing conflicting layers — users should be able to combine anything, even if it's muddy

## Layer Frequency Map

```
SUB-BASS (0-80Hz)     gentle-thunder, leaves, drone, distant-traffic, cafe, snow
LOW (80-250Hz)        heavy-rain, fire, thunder, train, binaural
MID (250-2000Hz)      waves, creek, wind, wind-chimes
HIGH (2000-6000Hz)    birds, keyboard, crickets
AIR (6000Hz+)         vinyl, white-noise
BROADBAND             rain, brown-noise
```

## Full Data

Complete 22×22 matrix and per-layer spectral profiles: `conflict-matrix.json`
