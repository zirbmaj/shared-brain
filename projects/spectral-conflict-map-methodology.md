---
title: Spectral Conflict Map — Methodology
date: 2026-03-27
type: spec
scope: shared
owner: hum
status: ready to implement — blocked on R10 linux install
summary: How to measure frequency overlap across all 231 Drift layer pairs. Defines conflict thresholds, analysis bands, output format, and the batch pipeline.
---

# Spectral Conflict Map

## Purpose
When two ambient layers play simultaneously, their frequencies can mask each other — rain drowns out creek, deep drone muddies cafe noise, brown noise covers everything below 500Hz. The conflict map measures this objectively so the mixer can warn users or auto-suggest EQ adjustments.

This is tier 1b of the AI roadmap (post-PH). The map itself is a static dataset produced by batch analysis, not real-time computation.

## Layers (22 total)

### Sample-based (15)
1. rain
2. heavy-rain
3. thunder
4. fireplace
5. cafe
6. crickets
7. ocean-waves
8. train-cabin
9. forest-birds
10. leaves-rustling
11. keyboard-typing
12. creek
13. wind-chimes
14. gentle-thunder
15. distant-traffic

### Synthesis-based (7)
16. wind
17. vinyl-crackle
18. deep-drone
19. brown-noise
20. white-noise
21. snow-silence
22. focus-pulse

### Total pairs
C(22,2) = 231 unique pairs. Each pair gets one conflict score.

## Analysis Method

### Step 1: Generate spectral profiles (22 analyses)
For each layer, compute the average power spectral density (PSD) over its full duration.

**Sample-based layers:**
- Source: `/ambient-mixer/audio/seamless/*.mp3` (15 files, 60s each)
- Tool: `librosa.load()` → `librosa.feature.melspectrogram()` or raw FFT via `scipy.signal.welch()`
- Output: mean PSD across full duration, 1024-bin FFT, Hann window

**Synthesis-based layers:**
- These don't have audio files. Two options:
  - **Option A (preferred):** Render 60s of each synthesis layer to WAV using a headless Web Audio API capture (CDP protocol, same tooling from session 9). Analyze the WAV
  - **Option B (faster, less accurate):** Model the spectral profile from the synthesis parameters in engine.js. Brown noise = -6dB/octave slope, white noise = flat, deep drone = 140Hz fundamental + harmonics, etc. Skip the capture, compute mathematically
- Decision: Start with Option B for known-shape generators (brown/white noise, drone, focus pulse). Use Option A for complex ones (wind, vinyl crackle, snow silence) where the synthesis parameters don't fully describe the spectral content

### Step 2: Define frequency bands (8 bands)
Divide the audible range into perceptually meaningful bands:

| Band | Range | Character | Typical layers |
|------|-------|-----------|---------------|
| sub-bass | 20-60Hz | felt, not heard | deep drone, brown noise |
| bass | 60-250Hz | warmth, rumble | thunder, gentle-thunder, train |
| low-mid | 250-500Hz | body, muddiness danger zone | cafe, rain, wind |
| mid | 500-2000Hz | clarity, presence | keyboard, creek, birds |
| upper-mid | 2000-4000Hz | detail, articulation | crickets, wind-chimes |
| presence | 4000-8000Hz | brightness, air | vinyl crackle, leaves |
| brilliance | 8000-16000Hz | shimmer, sparkle | white noise, wind-chimes harmonics |
| ultra-high | 16000-20000Hz | air (mostly inaudible) | white noise tail |

### Step 3: Compute per-band energy (22 layers x 8 bands = 176 values)
For each layer, integrate the PSD within each frequency band. Normalize to dB relative to full-scale.

Output: 22x8 matrix. Each cell = average energy in dB for that layer in that band.

### Step 4: Compute pairwise conflict scores (231 pairs)
For each pair of layers (A, B), compute conflict per band:

```
band_conflict(A, B, band) = min(energy_A[band], energy_B[band])
```

The minimum represents the overlapping energy — the quieter layer's contribution in that band is what gets masked. If both layers are loud in the same band, that's a conflict.

**Overall conflict score:**
```
conflict(A, B) = weighted_sum(band_conflict across all 8 bands)
```

Weights per band (perceptual importance):
- sub-bass: 0.5 (less perceptible)
- bass: 1.0
- low-mid: 1.5 (muddiness is the #1 mixing problem)
- mid: 1.5
- upper-mid: 1.2
- presence: 1.0
- brilliance: 0.8
- ultra-high: 0.3

Normalize final score to 0-100 scale.

### Step 5: Classify conflicts

| Score | Label | Meaning |
|-------|-------|---------|
| 0-20 | clean | layers occupy different frequency space. safe to combine |
| 20-40 | mild | some overlap, but perceptually distinct. most users won't notice |
| 40-60 | moderate | noticeable masking. one layer partially drowns the other |
| 60-80 | heavy | significant overlap. one layer dominates. EQ or volume adjustment recommended |
| 80-100 | conflict | nearly identical frequency range. don't recommend combining without EQ |

## Output Format

### Primary: JSON conflict matrix
```json
{
  "version": 1,
  "date": "2026-XX-XX",
  "layers": ["rain", "heavy-rain", ...],
  "band_energies": {
    "rain": { "sub_bass": -42.1, "bass": -18.3, ... },
    ...
  },
  "conflicts": {
    "rain+heavy-rain": { "score": 87, "label": "conflict", "bands": { "low_mid": 72, "mid": 65, ... }},
    "rain+cafe": { "score": 34, "label": "mild", "bands": { ... }},
    ...
  }
}
```

### Secondary: Markdown report
Human-readable summary sorted by conflict severity. Top 10 conflicts, top 10 cleanest pairs, per-layer "plays well with" and "conflicts with" lists. Written to `shared-brain/reports/spectral-conflict-map.md`.

### Tertiary: Spectrogram overlays (optional)
For the top 20 highest-conflict pairs, generate overlay spectrograms showing where the two layers collide. PNG files in `shared-brain/reports/spectrograms/`. Visual proof for the team.

## Pipeline (R10 batch job)

```bash
#!/bin/bash
# spectral-conflict-map.sh — runs on NWL-R10
# prereqs: python3, librosa, scipy, numpy, matplotlib

# 1. Copy sample files from shared-brain (syncthing has them)
# 2. Render synthesis layers to WAV (option A/B per layer)
# 3. Compute spectral profiles
# 4. Compute conflict matrix
# 5. Generate report + optional spectrograms
# 6. Write results to shared-brain/reports/ (syncthing propagates to mini)

python3 /path/to/spectral_conflict_analysis.py \
    --samples-dir /shared-brain/audio/seamless/ \
    --synthesis-params /shared-brain/audio/synthesis-profiles.json \
    --output-json /shared-brain/reports/spectral-conflict-matrix.json \
    --output-md /shared-brain/reports/spectral-conflict-map.md \
    --spectrograms /shared-brain/reports/spectrograms/
```

Estimated compute time on R10 (32GB RAM, CPU-only):
- 15 sample FFTs: ~5 seconds
- 7 synthesis renders + FFTs: ~30 seconds (if using Option A with headless capture)
- 231 pair comparisons: <1 second
- 20 spectrogram overlays: ~10 seconds
- **Total: under 1 minute**

## How the Map Gets Used

### Phase 1 (post-PH, static data)
- Conflict matrix loaded into engine.js as a lookup table
- When user adjusts a layer, show subtle visual hint if it conflicts with another active layer
- "these layers overlap in the low-mid range" tooltip or border color shift
- No automatic intervention — inform, don't restrict

### Phase 2 (future, with local LLM)
- Ollama on R10 generates mix recommendations that avoid high-conflict pairs
- "you like rain + cafe (score 34). try rain + keyboard (score 12) for cleaner separation"
- Spectral-aware auto-EQ: when two layers conflict, apply complementary shelf filters to separate them

## Dependencies
- R10 running Ubuntu with python3, librosa, scipy, numpy, matplotlib
- Syncthing sharing audio assets between nodes
- 15 seamless MP3 files (already in git, verified on production)
- Synthesis parameter extraction from engine.js (manual, one-time)

## Not in Scope
- Real-time spectral analysis (Web Audio API AnalyserNode handles this client-side)
- Per-user mix analysis (this is a global layer-pair reference)
- Loudness normalization (already done — all samples at -14 to -16.5 LUFS)
- Static FM or Pulse layer analysis (different products, different audio architecture)
