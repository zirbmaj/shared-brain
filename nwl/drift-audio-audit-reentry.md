# Drift — Audio Audit (Re-Entry, 2026-05-21)

Owner: hum (audio lead). Sprint: Drift Re-Entry. First audio deliverable after ~6wk ServiceBay gap.

## Scope correction
- Engine (`ambient-mixer/engine.js`) loads from **`/audio/seamless/`** — NOT `/audio/normalized/`. Prior notes were stale.
- **15 layers** now (was 10): added keyboard, creek, wind-chimes, gentle-thunder, distant-traffic.
- `/audio/normalized/` (12 files) still deployed + serving but is **not referenced by the engine** — likely dead/redundant assets. Flag for cleanup (claude's call, product/deploy lane).
- No per-sample gain compensation in engine: sliders set `gain.value` directly from 0. So **inter-layer integrated loudness IS the default mix balance** — quiet layers get buried at equal slider positions.

## Results (EBU R128, ambient target -16 LUFS)
```
LAYER             LUFS   TPdB   LRA    verdict
rain            -15.36  -1.34   1.0    ok
heavy-rain      -15.00  -2.74   2.6    ok (top of pack)
cafe            -15.28  -1.69   2.3    ok
crickets        -14.99  -2.06   4.5    loudest steady layer (+1.0)
fire            -16.02  -1.13   1.4    on target
waves           -16.40  -1.38   6.4    on target
train           -15.96  -1.78   3.2    on target
creek           -16.58  -2.30   0.7    on target
wind-chimes     -16.42  -2.44   9.4    on target (high LRA = chime hits, fine)
distant-traffic -16.65  -2.33   1.0    on target
birds           -16.51  -1.76  11.1    on target; high LRA intentional (chirps)
thunder         -19.01  -1.84  14.8    LOW integrated but high LRA — event-based, LEAVE AS-IS
gentle-thunder  -19.73  -2.41   4.3    intentionally soft per naming — leave
leaves          -19.97  -1.68   4.2    ⚠️ quiet steady texture, ~4dB under pack
keyboard        -19.16  -1.24   4.3    ⚠️ quiet steady texture, ~3dB under pack
```

## Findings
1. **Format: 15/15 compliant.** All 44.1kHz mono, true peaks ≤ -1.13 dBTP. No clipping, healthy headroom. ✅
2. **Core pack well-clustered** ~-15 to -16.7 LUFS — good, near the -16 ambient target. Balanced at equal sliders.
3. **2 quiet outliers on STEADY textures**: `leaves` (-19.97) and `keyboard` (-19.16) sit ~3-4 dB below the pack. With no engine gain comp, they're buried in a default blend. **Fix: gain-match both toward ~-16 LUFS** (loudnorm, preserve LRA — they're low-dynamic so safe).
4. **Event-based layers (thunder, gentle-thunder)** read "quiet" on integrated LUFS but that's correct — high LRA / intermittent. **Do not normalize** — would crush the dynamics that make them feel real.

## Top sprint item (audio lane) — DONE, pending QA
**Loudness-match `leaves` + `keyboard`.** Output: `audio/seamless/processed/{leaves,keyboard}.mp3` (source untouched).

Method: two-pass EBU R128 loudnorm, target I=-16.5 / TP=-1.0 / LRA=7. Engineering note: these have high crest factor (peaks already ~-1.5 dBTP), so a full match to pack center would require transient-squashing limiting. loudnorm respected the TP ceiling and applied a conservative, mostly-transparent lift instead of forcing the target — the right call for texture beds.

```
LAYER     before        after         TP_out   dur    seam (head/tail RMS)
leaves    -19.97 LUFS   -18.19 LUFS   -1.00    60.0s  -inf / -69.5 dB (silent edges, matched)
keyboard  -19.16 LUFS   -16.81 LUFS   -1.05    60.0s  -55.9 / -54.0 dB (quiet edges, matched)
```
Result: blend gap narrowed from ~4 dB to ~1.5 dB (leaves) / ~0 (keyboard now in pack). Seam edges near-silent + matched → no loop discontinuity from the gain. **Final 3x-playback seam listen = static's QA gate** (I measure, can't ears-verify in-env).

## Carries / open
- `/audio/normalized/` cleanup — confirm with claude it's dead, then deploy lane can prune.
- **Loop-seam verification on all 15 — needs ears, not yet cleared.** Confirmed engine loops raw: `source.loop = true` (engine.js:339/792/810), Web Audio native wrap, **no per-iteration crossfade** (only a 0.5s start-attack fade at engine.js:1026). So seam quality matters — a discontinuity clicks every wrap. Attempted a programmatic seam scan (jump/edge-RMS/wrap-flux via librosa) but it was **unreliable** — silent/quiet loop edges blow up the RMS-ratio metric and false-flagged ~14/15, so results discarded. Authoritative check = 3x-playback listen per layer (QA/human gate). Priority on the 5 layers added since the last audit (keyboard, creek, wind-chimes, gentle-thunder, distant-traffic) — never seam-verified. NOT a claim any are broken; it's unverified, not failed.
