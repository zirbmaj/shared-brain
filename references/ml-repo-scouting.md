---
title: ML Opportunities — Open-Source Repo Scouting
date: 2026-03-28
type: research
scope: shared
author: near
summary: Open-source repos for ambient audio gen, music recommendation, spectral analysis, anomaly detection, voice cloning — evaluated against our GPU mesh
---

# ML Repo Scouting — Open Source for Our GPU Mesh

Repos evaluated against our hardware constraints:
- **R10:** 8GB VRAM (RX 5700 XT, Vulkan only — no CUDA, no ROCm for PyTorch)
- **Fran's PC:** 16GB VRAM (RX 7900 GRE, ROCm works for PyTorch)
- **Both:** 32GB RAM, CPU-capable for non-GPU workloads

Key filter: **does it need CUDA specifically, or can it run on ROCm/CPU?**

---

## 1. Ambient Audio Generation

Goal: generate non-repeating soundscapes ("rain on a tin roof") instead of looping 60s samples.

### AudioLDM2 — Text-to-Audio Diffusion
- **Repo:** [haoheliu/AudioLDM2](https://github.com/haoheliu/AudioLDM2)
- **What it does:** Text prompt → audio. "gentle rain with distant thunder" → 10-47s audio clip
- **VRAM:** ~8GB with CPU offloading (DiT uses 5.9GB, decoder spikes to 14.5GB but can be offloaded)
- **R10 viable?** Marginal — 8GB VRAM is tight. CPU offloading would work but slow. Not Vulkan-compatible (needs PyTorch CUDA/ROCm)
- **Fran viable?** Yes — 16GB VRAM with ROCm should handle it
- **Quality:** Good for sound effects and ambient. Not music-quality
- **Verdict:** **Fran's PC only.** Can't run on R10 (PyTorch needs CUDA/ROCm, not Vulkan)

### Stable Audio Open 1.0 — Text-to-Audio (Stability AI)
- **Repo:** [Stability-AI/stable-audio-tools](https://github.com/Stability-AI/stable-audio-tools)
- **What it does:** Text → up to 47s stereo audio at 44.1kHz. 1.21B parameters
- **VRAM:** 16GB recommended (5.9GB for diffusion, 14.5GB for decoding)
- **R10 viable?** No — needs 16GB and PyTorch (no Vulkan)
- **Fran viable?** Yes — fits 16GB with ROCm
- **Quality:** Higher quality than AudioLDM2. Stereo output
- **Verdict:** **Fran's PC only.** Best quality option for ambient generation

### MusicGen (Meta) — Music Generation
- **Repo:** [facebookresearch/audiocraft](https://github.com/facebookresearch/audiocraft)
- **What it does:** Text → music. "ambient electronic with rain sounds" → 30s clip
- **VRAM:** Small model (300M) ~2GB, Medium (1.5B) ~6GB, Large (3.3B) ~12GB
- **R10 viable?** Small model only (via CPU, no PyTorch GPU on Vulkan)
- **Fran viable?** Yes — medium model fits easily on 16GB ROCm
- **Quality:** Excellent for music. Overkill for ambient sounds
- **Verdict:** **Small on R10 CPU, Medium on Fran.** Good for Static FM auto-generated background tracks

### Recommendation
**Start with Stable Audio Open on fran's PC.** Highest quality, stereo output, designed for ambient/effects. Test: "60 seconds of rain on a tin roof" — if generation time < 60s, it's viable for live use. If not, pre-generate a library of non-repeating variations.

---

## 2. Music Recommendation / Auto-DJ Sequencing

Goal: Static FM auto-selects next track based on weather mood + listener history.

### Lightweight Collaborative Filtering
- **Repo:** [ABSounds/MusicRecommenderCF](https://github.com/ABSounds/MusicRecommenderCF)
- **What it does:** Collaborative filtering using ALS algorithm on sparse user-artist interaction matrix
- **VRAM:** None — runs on CPU. NumPy/SciPy based
- **R10 viable?** Yes — CPU only, lightweight
- **Our use case:** Map drift layers/mixes to listener sessions. Recommend next mix based on similar listeners

### Audio Feature-Based Similarity
- **Repo:** [rollingstorms/Sound-Content-Music-Recommendation-System](https://github.com/rollingstorms/Sound-Content-Music-Recommendation-System)
- **What it does:** Content-based recommendations using audio features (MFCCs, spectral contrast, tempo)
- **VRAM:** None — librosa + sklearn, CPU only
- **R10 viable?** Yes
- **Our use case:** Compare audio features of drift layers to find complementary sounds. "Users who like rain+cafe tend to also like wind+keyboard"

### Custom Approach (Most Practical)
For our scale (22 layers, ~40 discover mixes, ~100 user sessions), a full ML recommendation system is overkill. A simpler approach:
1. Extract audio features per layer (librosa, already on R10)
2. Build a similarity matrix (cosine distance on feature vectors)
3. Track co-occurrence: which layers are mixed together most often (SQL query on Supabase)
4. Recommend: "people who mixed rain + cafe also added wind"

**No repo needed.** This is 50 lines of Python + a SQL query. The AI roadmap tier 1 (collaborative filtering, SQL, $0) already specifies this.

### Recommendation
**Don't clone a repo — build the 50-line custom solution.** Our scale doesn't justify a framework. Extract features with librosa, build co-occurrence matrix from Supabase, serve recommendations via a simple endpoint on R10.

---

## 3. Spectral Analysis / Audio Conflict Detection

Goal: detect when two drift layers mask each other at the same frequency.

### Demucs — Source Separation (Meta)
- **Repo:** [facebookresearch/demucs](https://github.com/facebookresearch/demucs)
- **What it does:** Separates mixed audio into stems (vocals, drums, bass, other)
- **VRAM:** 4-6GB minimum, 8GB recommended
- **R10 viable?** CPU only (PyTorch, no Vulkan). Slower but functional
- **Fran viable?** Yes — ROCm supported explicitly
- **Our use case:** Analyze what frequency bands each drift layer occupies. If two layers share the same band, flag as conflicting
- **Verdict:** **Useful but heavy for our use case.** Demucs separates full songs into stems — we just need frequency analysis

### Librosa + Custom Analysis (Best Fit)
- **Repo:** [librosa/librosa](https://github.com/librosa/librosa) (already on R10)
- **What it does:** Spectral analysis, MFCC extraction, chromagrams, spectral contrast
- **VRAM:** None — pure CPU/NumPy
- **R10 viable?** Yes — already installed
- **Our use case:** Hum's 231-pair conflict map. For each pair of layers:
  1. Compute mel spectrogram for both
  2. Find overlapping frequency bands
  3. Score the conflict (overlap area / total energy)
  4. Build a lookup table: "rain + thunder: low conflict (different bands). rain + creek: high conflict (both 800Hz-2kHz)"

### Essentia 2.0 — Audio Analysis Library
- **Repo:** [MTG/essentia](https://github.com/MTG/essentia)
- **What it does:** C++ library with Python bindings. Extensive spectral, temporal, tonal descriptors
- **VRAM:** None — CPU
- **R10 viable?** Yes
- **Our use case:** More feature extractors than librosa. Could detect tonal conflict (two layers in clashing keys), rhythmic conflict (different tempos creating beats)

### Recommendation
**Librosa is sufficient.** Already installed on R10. Hum's methodology (shared-brain/projects/spectral-conflict-map-methodology.md) uses librosa for the 231-pair analysis. No additional repo needed. If we need more advanced tonal analysis later, add Essentia.

---

## 4. Anomaly Detection for Agent Behavior

Goal: detect when an agent is behaving unusually (stalled, looping, context burning too fast).

### ADTK — Anomaly Detection Toolkit
- **Repo:** [arundo/adtk](https://github.com/arundo/adtk)
- **What it does:** Unsupervised rule-based time series anomaly detection. Detectors + transformers + aggregators
- **VRAM:** None — pure Python, lightweight
- **R10 viable?** Yes — CPU, minimal resources
- **Our use case:** Monitor agent context burn rate, response times, tool call frequency. Flag anomalies: "claude's context burn rate doubled in the last 30 minutes" or "static hasn't made a tool call in 45 minutes"

### Luminol — Lightweight Anomaly Detection
- **Repo:** [linkedin/luminol](https://github.com/linkedin/luminol)
- **What it does:** Lightweight time series anomaly detection + correlation
- **VRAM:** None — Python, very lightweight
- **R10 viable?** Yes
- **Our use case:** Detect anomalies in service health metrics (CPU spikes, response time degradation) and correlate with agent behavior

### dtaianomaly — Academic-Quality Detection
- **Repo:** [ML-KULeuven/dtaianomaly](https://github.com/ML-KULeuven/dtaianomaly)
- **What it does:** Broad range of anomaly detectors with preprocessing and visual analysis
- **VRAM:** None — CPU
- **Our use case:** More sophisticated detection patterns than ADTK. Good for detecting slow drift anomalies (agent gradually degrading over hours)

### Custom Threshold + Vigil (Most Practical)
For our 10-agent setup, a simple approach works:
1. Track metrics per agent: context %, tool calls/min, response latency, time in state
2. Compute rolling averages (10-minute window)
3. Alert when current value > 2x rolling average
4. Vigil already has state duration tracking — extend to burn rate

**No ML needed for 10 agents.** Simple statistical thresholds catch 90% of anomalies. Add ADTK later if we need pattern detection beyond thresholds.

### Recommendation
**Start with custom thresholds in vigil (no repo).** If we need more sophisticated detection, **ADTK** is the cleanest lightweight option. Luminol for service metric correlation.

---

## 5. Voice Cloning / TTS Fine-Tuning

Goal: clone jam's voice for DJ intros. Replace generic ElevenLabs with a recognizable voice.

### XTTS-v2 (Coqui TTS)
- **Repo:** [coqui-ai/TTS](https://github.com/coqui-ai/TTS)
- **What it does:** Voice cloning from 6-second audio clip. 16 languages. <150ms streaming latency
- **VRAM:** 8GB for inference, 16-24GB for fine-tuning
- **R10 viable?** Inference on CPU (slow, ~5x real-time). No GPU (PyTorch, not Vulkan)
- **Fran viable?** Yes — 16GB ROCm for inference, tight for fine-tuning
- **Quality:** Good. Not ElevenLabs quality but recognizable voice clone
- **License:** Open source (community-maintained after Coqui shutdown)
- **Verdict:** **Best option for voice cloning.** Inference on fran's PC, CPU fallback on R10

### OpenVoice
- **Repo:** [myshell-ai/OpenVoice](https://github.com/myshell-ai/OpenVoice)
- **What it does:** Instant voice cloning with fine-grained style control (emotion, accent, rhythm, pitch)
- **VRAM:** ~4GB for inference
- **R10 viable?** CPU only (PyTorch). Fran for GPU
- **Quality:** Good style control but lower base quality than XTTS-v2
- **Verdict:** **Interesting for style control** but XTTS-v2 is better for straight voice cloning

### Fish Speech S2
- **Repo:** [fishaudio/fish-speech](https://github.com/fishaudio/fish-speech)
- **What it does:** SOTA TTS with voice cloning from 10s reference. Streaming via SGLang
- **VRAM:** 24GB recommended (NVIDIA)
- **R10 viable?** No — needs CUDA/ROCm, and 8GB too small
- **Fran viable?** Marginal — 16GB ROCm, needs quantization. ZLUDA fork exists for AMD Windows
- **Quality:** Highest quality in open source
- **Verdict:** **Stretch for our hardware.** Test on fran's PC with quantization if XTTS-v2 quality isn't sufficient

### Piper (Already Deployed)
- Already running on R10:8091
- No voice cloning — uses pre-trained voices
- 3.4x real-time on CPU. Quality gap vs ElevenLabs is audible
- Good for system alerts, not for brand voice DJ intros

### Recommendation
**XTTS-v2 on fran's PC for voice cloning.** Record 6 seconds of jam's voice, clone it, generate DJ intros locally. Fall back to ElevenLabs for the highest-quality brand intros. Test XTTS-v2 quality against ElevenLabs — if it's close enough, we can drop the $5/mo ElevenLabs subscription entirely.

---

## 6. Summary Matrix

| Category | Best Repo | Runs On | GPU Needed? | Complexity | Priority |
|----------|-----------|---------|-------------|-----------|----------|
| Ambient audio gen | Stable Audio Open | Fran's PC (ROCm) | Yes (16GB) | Medium | Post-launch |
| Music recommendation | Custom (50 lines) | R10 CPU | No | Low | Post-launch week 1 |
| Spectral conflict | Librosa (already installed) | R10 CPU | No | Low | Post-launch (Hum's spec ready) |
| Anomaly detection | Custom thresholds → ADTK | R10 CPU | No | Low | Post-launch |
| Voice cloning | XTTS-v2 (Coqui) | Fran's PC (ROCm) | Yes (8-16GB) | Medium | Post-launch |

**3 of 5 categories don't need a repo — custom solutions on existing tools are more practical at our scale.** The two that need repos (ambient audio gen, voice cloning) both run on fran's PC, not R10.

---

## 7. Hardware Utilization Map

| Node | Current Load | Can Add |
|------|-------------|---------|
| R10 GPU (8GB Vulkan) | Ollama models (5.7GB) | Nothing ML — Vulkan doesn't support PyTorch. Ollama-only |
| R10 CPU (99% idle) | Burst inference | Librosa spectral analysis, ADTK anomaly detection, collaborative filtering |
| Fran GPU (16GB ROCm) | Idle | Stable Audio Open, XTTS-v2, AudioLDM2, Demucs, Fish Speech (stretch) |
| Fran CPU | Idle | CPU fallback for any model |

**R10's Vulkan GPU is an ollama-only accelerator.** PyTorch ML models need CUDA or ROCm — they can't use Vulkan. All ML inference beyond ollama goes to fran's PC or R10 CPU.

This is the key architectural constraint: R10 runs ollama fast (65 tok/s) but can't run arbitrary PyTorch models on GPU. Fran's PC is the real ML node.

---

*Near, session 14, 2026-03-28. Research only — ideate, don't build. Claude evaluates feasibility.*
