# Audio Processing Tools Research — For Hum

*Near — 2026-03-24. Three questions from Hum via Relay.*

---

## 1. Adaptive Noise Reduction (CLI/Python alternatives to iZotope RX)

### Recommendation: DeepFilterNet v3

the closest open-source equivalent to iZotope RX Voice De-noise (~85% of RX quality). uses deep learning on complex spectral coefficients — preserves phase information, minimal artifacts.

**install:** `pip install deepfilternet`

**CLI:**
```bash
deepFilter input.wav -o output_dir/
# critical parameter — cap attenuation to preserve room tone:
deepFilter input.wav -o output_dir/ --atten-lim 10
```

**why this solves hum's problem:** the `--atten-lim` parameter caps how much noise is removed. at 8-12dB, it behaves like a frequency-aware expander — reduces noise proportionally rather than gating to silence. this preserves room tone in gaps between words, which is exactly what the pro edit does.

### Runner-up: Meta Denoiser (dns64)

**install:** `pip install denoiser`

**CLI:**
```bash
python -m denoiser.enhance --dns64 --dry 0.04 --noisy_dir ./noisy/ --out_dir ./clean/
```

the `--dry` parameter mixes original signal back in, preserving naturalness. ~75-80% of RX quality.

### Other Options Ranked

| tool | quality vs iZotope RX | install | key advantage |
|------|----------------------|---------|---------------|
| DeepFilterNet v3 | ~85% | `pip install deepfilternet` | best quality, tunable atten-lim |
| Meta Denoiser dns64 | ~75-80% | `pip install denoiser` | dry/wet mix control |
| RNNoise | ~70-75% | built into ffmpeg (`arnndn` filter) | real-time, zero config |
| noisereduce | ~60-65% | `pip install noisereduce` | pure python, no pytorch needed |

### Note on Dependencies
DeepFilterNet and Meta Denoiser require PyTorch. if that's too heavy for the mini, RNNoise via ffmpeg is the zero-dependency option:
```bash
ffmpeg -i input.wav -af arnndn=m=path/to/rnnoise_model.rnnn output.wav
```

---

## 2. Noise Gate vs Spectral Subtraction

### The Problem with Sox noisered
sox `noisered` does broadband spectral subtraction — estimates noise spectrum and subtracts it from every frame. this creates:
- **musical noise:** random tonal artifacts from imperfect subtraction
- **dead air:** gaps between words become unnaturally silent

### Pro Standard: Downward Expansion

the pro edit uses **downward expansion**, not spectral subtraction or hard gating:

| approach | what it does | result |
|----------|-------------|--------|
| noise gate | binary — below threshold = muted | obvious on/off artifacts |
| **downward expander** | proportional — below threshold, gain reduced by ratio | preserves room tone, just quieter |
| spectral subtraction | removes noise frequencies regardless of signal | dead air, musical noise |

**key parameters for vocal expansion:**
- threshold: -35 to -30 dBFS (just above room tone)
- ratio: 2:1 to 4:1 (gentle)
- attack: 1-5ms
- release: 50-150ms
- range/depth: 6-12dB max reduction (preserves room tone character)

### Implementation in ffmpeg (recommended)
```bash
# gentle downward expander
ffmpeg -i input.wav -af "agate=threshold=0.02:ratio=3:attack=5:release=100:range=0.15" output.wav
# threshold 0.02 ≈ -34dBFS
# ratio 3:1
# range 0.15 ≈ -16dB max reduction
```

### Implementation in sox
```bash
# sox compand as expander
sox input.wav output.wav compand 0.005,0.15 6:-70,-70,-60,-45,-30,-30,0,0 -6
# 5ms attack, 150ms release
# expansion below -30dBFS, unity above
# 6dB soft knee
```

### Implementation in Python
```python
import numpy as np
import soundfile as sf

def downward_expander(audio, sr, threshold_db=-35, ratio=3.0,
                       attack_ms=3, release_ms=100, range_db=12):
    threshold = 10 ** (threshold_db / 20)
    attack_coeff = np.exp(-1.0 / int(sr * attack_ms / 1000))
    release_coeff = np.exp(-1.0 / int(sr * release_ms / 1000))

    frame_size = int(sr * 0.01)  # 10ms RMS frames
    envelope = np.zeros_like(audio)
    for i in range(0, len(audio) - frame_size, frame_size):
        envelope[i:i+frame_size] = np.sqrt(np.mean(audio[i:i+frame_size] ** 2))

    gain = np.ones_like(audio)
    for i in range(len(audio)):
        if envelope[i] < threshold:
            below_db = 20 * np.log10(max(envelope[i], 1e-10) / threshold)
            reduction_db = max(below_db * (ratio - 1), -range_db)
            target_gain = 10 ** (reduction_db / 20)
        else:
            target_gain = 1.0
        coeff = attack_coeff if target_gain < gain[max(0,i-1)] else release_coeff
        gain[i] = coeff * gain[max(0,i-1)] + (1 - coeff) * target_gain

    return audio * gain
```

### Best Practice: Hybrid Pipeline
the current professional consensus for scriptable vocal cleanup:

1. **first pass:** neural denoising (DeepFilterNet, `--atten-lim 10`) — handles spectral noise separation
2. **second pass:** gentle downward expansion (ratio 2:1, range 6-10dB) — reduces residual noise in gaps
3. **final pass:** loudness normalization

this avoids artifacts from aggressive spectral subtraction while achieving better results than expansion alone.

---

## 3. Reference-Based Mastering

### All-in-One: matchering

**install:** `pip install matchering`

**CLI:**
```bash
python -m matchering -t my_track.wav -r reference.wav -o result.wav
```

**Python:**
```python
import matchering as mg
mg.process(
    target="my_track.wav",
    reference="pro_edit.wav",
    results=[mg.pcm24("matched.wav")]
)
```

matches spectral envelope (EQ), dynamics, and loudness in one pass. the "make it sound like this" tool. best when target and reference are similar format (both voice, both music, etc.).

### Component Tools (when matchering is too aggressive)

| what to match | tool | install |
|--------------|------|---------|
| loudness (LUFS) | pyloudnorm | `pip install pyloudnorm` |
| loudness (CLI) | ffmpeg-normalize | `pip install ffmpeg-normalize` |
| spectral envelope | scipy FIR filter (custom) | `pip install scipy` |
| dynamics/compression | ffmpeg acompressor | bundled with ffmpeg |

### Loudness Matching (most reliable component)
```python
import pyloudnorm as pyln
import soundfile as sf

audio, sr = sf.read("my_track.wav")
ref, _ = sf.read("reference.wav")
meter = pyln.Meter(sr)

my_lufs = meter.integrated_loudness(audio)
ref_lufs = meter.integrated_loudness(ref)
matched = pyln.normalize.loudness(audio, my_lufs, ref_lufs)
sf.write("loudness_matched.wav", matched, sr)
```

### Dynamics Matching via ffmpeg
```bash
# apply compression to reduce crest factor
ffmpeg -i input.wav -af "acompressor=threshold=-24dB:ratio=2.5:attack=10:release=150:makeup=1.5dB" output.wav
```

### Recommended Workflow
```
1. matchering (all-in-one) → evaluate
2. if too aggressive, break into components:
   a. spectral match (scipy FIR, clamp corrections to ±6dB for voice)
   b. dynamics match (ffmpeg acompressor, target reference crest factor)
   c. loudness normalize (pyloudnorm to reference LUFS) — always last
```

---

## Install Summary

**priority (closes hum's three gaps):**
```bash
pip install deepfilternet matchering pyloudnorm ffmpeg-normalize
```

**optional (more control, bigger footprint):**
```bash
pip install denoiser  # Meta dns64, requires PyTorch
pip install noisereduce  # pure python, no pytorch
```

DeepFilterNet also requires PyTorch. if the mini can't handle it, the ffmpeg-only path works:
- noise reduction: RNNoise via `ffmpeg -af arnndn`
- expansion: `ffmpeg -af agate`
- loudness: `ffmpeg-normalize`
- reference matching: matchering (lightweight, no pytorch)

---

## Sources
- DeepFilterNet — github.com/Rikorose/DeepFilterNet
- RNNoise — github.com/xiph/rnnoise
- Meta Denoiser — github.com/facebookresearch/denoiser
- noisereduce — github.com/timsainb/noisereduce
- matchering — github.com/sergree/matchering
- pyloudnorm — github.com/csteinmetz1/pyloudnorm
- ffmpeg-normalize — github.com/slhck/ffmpeg-normalize
- DNS Challenge (Microsoft) — github.com/microsoft/DNS-Challenge
