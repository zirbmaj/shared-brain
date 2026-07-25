---
title: Session 14 Retro — Hum
date: 2026-03-28
session: 14
agent: hum
---

# Session 14 Retro — Hum

## What shipped

### Audio audit (T-3)
- Full sweep across Drift (15/15 seamless files, 4 resume points, compressor verified), Static FM (300ms crossfade, 105 intros, listen-free wired), Pulse (brown noise + rain bandpass correct)
- Zero regressions across all 3 products

### Vigil audio extensions
- vitals-audio.js: 407→851 lines
  - GPU inference tone (35Hz sawtooth, rises with tok/s)
  - GPU thermal alerts (E4 330Hz, distinct from system A4 440Hz)
  - VRAM pressure (gain escalation + noise layer)
  - Fran's PC expected-offline handling (silence vs half-gain static)
  - Stereo separation (infrastructure center, fran-pc +0.5 right)
  - Drone modulation from GPU state
- 30+ interaction sounds: search nav, preview open/close, tab switch, node expand/collapse, task toggle, Q&A response, card expand/collapse with agent identity tones
- Codec personality: per-agent static filtering (6 bandpass profiles), per-agent typewriter speed, identity drone (later removed per jam's feedback)

### Piper TTS
- Service deployed on R10:8091 (piper-tts-service.py)
- 64 common phrases pre-generated and cached (8ms retrieval)
- Web Speech API replaced with piper voice in vigil MCSound.voice()
- Loudness normalized to -22 LUFS
- Systemd unit spec posted (needs jam's hands)

### Infrastructure
- Health-server.py CPU/RAM patch applied on R10
- llama3:8b pulled and verified (correct answers vs mistral hallucinations)
- Piper TTS benchmarked: lessac-medium 3.4x RT, lessac-high 2.3x RT

### Specs and documentation
- GPU audio spec (mission-control-sounds/gpu-audio-spec.md)
- Piper endpoint spec (mission-control-sounds/piper-endpoint-spec.md)
- Joint codec chat spec with Claudia (shared-brain/projects/vigil-codec-chat.md)
- ML scouting context for Near's repo evaluation

## Lessons learned

1. **One sound source per interaction, not layered.** Jam tested the codec personality and wanted the drone removed — typing only. Multiple simultaneous audio layers during chat is distracting. The typing IS the sound. When in doubt, fewer sounds.

2. **"Felt, not heard" means lower than you think.** First codec deploy was too loud. Halving all gains (0.12→0.06, 0.02→0.01) was the right move. Start at half the gain you think is right, then adjust up.

3. **Spec before build saves time.** The GPU audio spec and piper endpoint spec meant Claude could wire things without back-and-forth. Clean interface contracts = parallel work.

4. **Verify agent findings before reporting.** The Pulse binaural beat "missing" finding from the explore agent was wrong — binaural lives in Drift, not Pulse. Always check before posting.

5. **SSH access is a force multiplier.** Having R10 SSH let me deploy piper, pull llama3, apply the health-server patch, and restart services. Without it, each task would have been blocked on Relay or jam.

## Carries for next session

- Spectral conflict detection: 231-pair matrix with librosa (greenlit, needs focused session)
- XTTS-v2 voice cloning test on fran's PC (when ROCm is ready)
- Piper systemd unit installation (needs jam's hands)
- Use rag-search.sh for doc lookups instead of grep
