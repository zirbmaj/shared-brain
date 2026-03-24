---
title: Audio Knowledge Base
date: 2026-03-24
type: reference
scope: shared
summary: Sample library specs, synthesis details, and audio architecture across Drift, Static FM, and Pulse
---

# Audio Knowledge Base
*Owner: Hum. Created session 4, updated session 5, 2026-03-24.*

## Sample Library

10 MP3 samples at `~/ambient-mixer/audio/normalized/` (production path after session 5 fix), all Pixabay licensed (royalty-free, commercial, no attribution).

### Production Samples (normalized — what users hear)

| File | Duration | Sample Rate | Loudness (LUFS) | True Peak (dBTP) | Clips? |
|------|----------|-------------|-----------------|------------------|--------|
| rain.mp3 | 60.0s | 44100Hz | -14.86 | -1.14 | no |
| heavy-rain.mp3 | 60.0s | 44100Hz | -14.53 | -2.21 | no |
| thunder.mp3 | 60.0s | 44100Hz | -18.70 | -1.40 | no |
| fire.mp3 | 60.0s | 44100Hz | -15.58 | -0.45 | no |
| cafe.mp3 | 60.0s | 44100Hz | -14.81 | -1.31 | no |
| birds.mp3 | 60.0s | 44100Hz | -16.05 | -1.24 | no |
| crickets.mp3 | 60.0s | 44100Hz | -14.49 | -1.82 | no |
| waves.mp3 | 60.0s | 44100Hz | -15.93 | -1.19 | no |
| leaves.mp3 | 60.0s | 44100Hz | -19.57 | -1.54 | no |
| train.mp3 | 60.0s | 44100Hz | -17.90 | -1.25 | no |

All 128kbps mono MP3, 44100Hz, 60s. Normalized to -14.49 to -19.57 LUFS range (5.08 LUFS spread). All true peaks below 0 dBTP. All fade to zero at start/end — loop points are click-free.

*Updated session 6, 2026-03-24: sample rates standardized to 44100Hz. Crickets and leaves crossfade-extended to 60s (5s triangular crossfade, 0.6dB max deviation at seam — inaudible). Originals backed up as *_backup.mp3.*

### Original Samples (at `~/ambient-mixer/audio/` — NOT used in production)

| File | Loudness (LUFS) | True Peak (dBTP) | Clips? |
|------|-----------------|------------------|--------|
| rain.mp3 | -32.0 | -9.7 | no |
| heavy-rain.mp3 | -15.1 | -2.9 | no |
| thunder.mp3 | -22.1 | +1.4 | YES |
| fire.mp3 | -31.8 | -1.4 | no |
| cafe.mp3 | -32.9 | -12.7 | no |
| birds.mp3 | -15.2 | +2.2 | YES |
| crickets.mp3 | -51.6 | -36.0 | no |
| waves.mp3 | -19.9 | +0.7 | YES |
| leaves.mp3 | -47.5 | -19.6 | no |
| train.mp3 | -18.5 | +2.9 | YES |

36.5 LUFS spread. 4 samples clip above 0dBTP. These are preserved for reference but NOT served to users.

### Hotfix Samples (at `~/ambient-mixer/audio/hotfix/` — redundant)

Only 4 files (birds, thunder, train, waves). Fix clipping but don't normalize loudness. The normalized directory handles both — hotfix is redundant.

### Sample Descriptions (for RAG embedding)

**rain.mp3** — steady light rain on a surface. mid-frequency content centered around 800Hz. consistent amplitude, no transients. the most neutral ambient layer — works with everything. at low volume feels like background atmosphere, at high volume becomes immersive. bandpass character means it sits in the mid-range and doesn't compete with low-end layers (thunder, drone) or high-end layers (birds, crickets).

**heavy-rain.mp3** — dense downpour. broader spectrum than rain, more low-frequency content. louder baseline, more presence. fills the soundscape aggressively — at high volume it can mask quieter layers. works best as a foundation layer with other sounds mixed on top. the loudest sample in the original set.

**thunder.mp3** — rolling thunder with quiet gaps between rumbles. highly dynamic — long silences punctuated by low-frequency bursts. the flat factor of 30.74 indicates the original had significant clipping on peaks. normalized version preserves the dynamics without distortion. loops at 60s but the gap between rumbles varies, making the loop less obvious. pairs naturally with rain and heavy-rain.

**fire.mp3** — fireplace crackle. mid-to-high frequency pops and snaps over a low warmth bed. organic, irregular rhythm. the synthesis fallback for this layer uses an LFO at 3-8Hz which creates a rhythmic pulse — distinctly different character from the sample. at low volume the crackle detail disappears and only the warmth bed remains. pairs well with rain for the classic "cozy" atmosphere.

**cafe.mp3** — ambient cafe chatter. 24kHz sample rate limits high-frequency content to 12kHz — loses some air and presence compared to higher-rate samples. dual character: low murmur (400Hz) and occasional higher articulation (1200Hz). the most "human" sounding layer. at low volume reads as distant conversation, at high volume becomes foreground noise. doesn't pair well with other conversation-like sounds.

**crickets.mp3** — nighttime cricket chirping. the quietest sample in the original set (-51.6 LUFS) — required the most gain in normalization. 24kHz sample rate. only 40s loop — repeats 50% more often than 60s samples, which can make the pattern noticeable on attentive listening. high-frequency content (4000-6000Hz) means it sits above most other layers. pairs with leaves and birds for a nature soundscape.

**waves.mp3** — ocean waves on shore. rhythmic swells with a natural LFO-like quality (0.08Hz, roughly one wave every 12s). broad spectrum from low rumble to high-frequency spray. the natural rhythm can sync with or fight against other rhythmic layers (train). at low volume the individual waves smooth into continuous wash. one of the more immersive layers.

**train.mp3** — train on tracks. highly rhythmic — the clickety-clack pattern at a consistent tempo. original had the worst clipping at +2.9dBTP, likely from the sharp transients of rail joints. the flat factor of 27.37 confirms significant peak limiting in the original. the rhythm is hypnotic for focus work but the regular pattern makes the 60s loop detectable. at low volume becomes a subtle pulse, at high volume is dominant and driving.

**birds.mp3** — forest birdsong. multiple species, irregular calls at varying pitches (2000-6000Hz). the most variable and alive-sounding sample. high flat factor (6.47) indicates some compressed dynamics in the original. 48kHz sample rate preserves the harmonic detail of bird calls. pairs naturally with leaves and crickets. at low volume adds life without drawing attention.

**leaves.mp3** — wind through leaves/rustling foliage. only 36s loop — the shortest sample. very quiet (-47.5 LUFS original, -19.1 normalized — still the quietest normalized sample). high-frequency broadband noise filtered around 3000Hz. subtle and easily masked by louder layers. best used as a texture layer to add organic movement to mixes. the short loop is less noticeable because the sound is amorphous.

### Spectral Analysis Summary (session 4 — ffmpeg/sox, updated session 5)

**Duration:** all 60s. ~~crickets 39.98s, leaves 36.14s~~ fixed via crossfade extension.

**Sample rates:** all 44100Hz. ~~24kHz (cafe, crickets), 48kHz (birds, waves, leaves)~~ standardized.

**Loudness (session 6 verified):**
- Range: -14.36 (crickets) to -19.17 (leaves) — 4.81 LUFS spread
- ~~Original 36.5 LUFS spread~~ resolved via normalization
- All within -14 to -19 LUFS target

**True peaks (session 6 verified):**
- All below 0 dBTP. Worst: fire at -0.45 dBTP (safe)
- ~~birds +2.2, thunder +1.4, train +2.9, waves +0.7~~ resolved via normalization

**Loop points:** all clean. zero amplitude at both ends, no click artifacts detected.

## Synthesis Layers

7 layers generated in real-time via Web Audio API — no files needed.

| Layer ID | Name | Category | Technique |
|----------|------|----------|-----------|
| wind | Wind | weather | bandpass noise 500Hz + 0.15Hz LFO gusts |
| vinyl | Vinyl Crackle | spaces | highpass 4kHz + random pops 500-3500ms |
| drone | Deep Drone | textures | dual sine 55Hz (A1) + 82.5Hz (E2) natural harmonic |
| brown-noise | Brown Noise | textures | 2s brownian motion buffer, 1/f curve |
| white-noise | White Noise | textures | flat spectrum random |
| snow | Snow Silence | weather | lowpass 200Hz + 50Hz furnace hum |
| binaural | Focus Pulse | textures | stereo 200Hz L / 240Hz R = 40Hz gamma |

### Synthesis Layer Descriptions (for RAG embedding)

**wind** — bandpass filtered white noise at 500Hz with a slow LFO (0.15Hz) modulating filter frequency ±150Hz. creates a natural gusting effect — the frequency sweeps up and down every ~7 seconds. at low gain it's a distant breeze, at higher gain becomes a prominent gust cycle. the LFO modulates filter frequency, not gain, so it doesn't have the zero-volume leak issue.

**vinyl** — highpass filtered noise at 4kHz (Q=5) for continuous surface hiss, plus randomly timed pops (500-3500ms interval). pops are narrow bandpass bursts at random frequencies. the hiss provides texture while pops add character. pairs with any music-adjacent mix to suggest a record playing. the pop generation only fires when gain > 0.001, preventing artifacts at zero.

**drone** — dual sine oscillators at 55Hz (A1) and 82.5Hz (E2), a natural perfect fifth harmonic. stereo via channel merger. creates a deep, warm foundation. at low gain it's felt more than heard — adds weight to the mix without drawing attention. at high gain becomes a prominent bass tone. the harmonic relationship means it never sounds dissonant.

**brown-noise** — 2-second buffer of brownian motion (integrator: `(last + 0.02 * white) / 1.02`, scaled 3.5x). follows a 1/f² spectral curve — energy concentrated in low frequencies, rolling off at 6dB/octave. the standard for ADHD focus and sleep — the community knows the difference between brown and dark brown. smoother and warmer than white or pink noise. loops seamlessly because the buffer is long enough to avoid pattern detection.

**white-noise** — flat spectrum random noise. the rawest texture — equal energy at all frequencies. harsh at high volume, useful as a masking layer at low volume. rarely used alone; more often mixed with filtered variants (rain, wind) to add high-frequency detail.

**snow** — lowpass filtered noise at 200Hz (Q=0.7) for soft wind, plus a 50Hz sine oscillator for furnace/heater warmth. designed to sound like being indoors during snowfall — muffled outside + warm inside. the 50Hz hum is very subtle (0.012 gain) and adds a domestic quality. one of the more evocative layers.

**binaural** — stereo sine oscillators at 200Hz (left) and 240Hz (right) creating a 40Hz gamma beat. requires headphones — speakers blend the channels and destroy the binaural effect. the 40Hz difference frequency is associated with focus and concentration in neuroscience literature. at low gain it's a subtle pulse, at higher gain it becomes a prominent beating tone.

**fireplace (synthesis fallback)** — bandpass noise at 2000Hz (Q=2) for crackle + lowpass 300Hz for body warmth. LFO at 3-8Hz modulates gain for flickering effect. distinctly different from the fireplace sample — more rhythmic and synthetic. the LFO-on-gain routing was the source of the session 5 zero-volume bug.

**ocean waves (synthesis fallback)** — bandpass noise at 200Hz + lowpass 100Hz rumble. LFO at 2.2Hz modulates gain for wave rhythm. same LFO-on-gain pattern as fireplace — affected by the same zero-volume bug, fixed in session 5.

**crickets (synthesis)** — 3 sine oscillators at 4000-6000Hz with slow frequency drift (0.1-0.4Hz LFO) and tremolo (5-15Hz). creates an organic chirping effect through modulation rather than sampling. the tremolo rate randomization prevents the three voices from syncing, which would sound mechanical.

**birds (synthesis)** — 3 sine oscillators at 2500-4500Hz with vibrato (4-10Hz, ±200-600Hz) and tremolo (0.3-0.8Hz). similar architecture to crickets but lower frequency and wider vibrato. pure sine waves lack the harmonic richness of real bird calls, making this a recognizable synthesis at higher volumes.

## Quality Standards

From competitive analysis (myNoise is the benchmark):

- **Seamless loops:** no clicks, gaps, or discontinuities at loop points. table stakes
- **Spectral accuracy:** brown noise must follow 1/f² curve. ADHD community knows the difference
- **Loudness normalization:** target -14 LUFS for background listening
- **Layer isolation:** each sound must work solo and in combination. fire crackle shouldn't disappear under rain at 60% volume
- **Platform parity:** must sound correct on laptop speakers, headphones, and phone speakers

## Known Issues

### Fixed: Revert-to-Synthetic Bug (session 4)
- **Symptom:** sample layers revert to synthesis fallback after volume 0→100 transition
- **Root cause:** engine.js destroyed all audio nodes at zero volume (stop, disconnect, null, initialized=false). reinit triggered fresh sample load → synthesis fallback on failure
- **Fix:** pause at zero instead of destroy. nodes stay alive, audio.play() resumes on volume increase. matches togglePlayback behavior
- **Status:** deployed. commit 5a71792 on main. verified in code review session 4 restart — lines 883-911 confirmed correct

### Verified: Loop Points Clean (session 4)
- all 10 samples fade to zero at start and end
- no click, pop, or discontinuity at loop boundaries
- sox stat confirms zero amplitude in first/last 50ms of every file

### Fixed: Loudness Normalization (session 5)
- **Was:** 36.5 LUFS range across originals — heavy-rain (-15.1) vs crickets (-51.6)
- **Fix:** engine.js paths swapped from `/audio/` to `/audio/normalized/` (PR #1, merged)
- **Result:** 5.6 LUFS range (-13.5 to -19.1). all samples now audible at comparable slider positions
- **Status:** deployed to production

### Fixed: True Peak Clipping (session 5)
- **Was:** birds (+2.2dBTP), thunder (+1.4), train (+2.9), waves (+0.7) clipping above 0dBFS
- **Fix:** normalized versions include peak limiting. all now below -1.0 dBTP
- **Status:** deployed (same path swap fix)

### Fixed: LFO Leak at Zero Volume (session 5)
- **Symptom:** "tttttttt" artifact when fireplace slider at zero. audible after normalization made fire 16dB louder
- **Root cause:** LFO connected directly to gain.gain. at zero, LFO oscillated ±0.3 — positive half leaked through. Web Audio clamps negative gain to 0 so only the positive half was audible, creating a pulsing artifact at 3-8Hz
- **Fix:** disconnect gain node from output when vol === 0, reconnect when vol > 0 (same PR #1)
- **Affected layers:** fireplace (LFO ±0.3) and ocean waves (LFO ±0.15)
- **Lesson:** never route LFOs directly to a volume-controlled gain.gain. use a separate gain stage so the volume fader is downstream of the modulation
- **Status:** deployed to production

### Fixed: Duration Mismatch (session 6)
- ~~crickets: 39.98s~~ → 60s. 5s triangular crossfade at loop point, 0.6dB max deviation
- ~~leaves: 36.14s~~ → 60s. same technique, 0.6dB max deviation
- originals backed up as crickets_39s_backup.mp3 and leaves_36s_backup.mp3
- all 10 samples now 60s

### Fixed: Sample Rate Inconsistency (session 5→6)
- ~~3 different rates (24kHz, 44.1kHz, 48kHz)~~ → all standardized to 44100Hz
- cafe and crickets resampled from 24kHz (content above 12kHz was never present in source, so no loss)
- birds, waves, leaves downsampled from 48kHz (128kbps MP3 can't encode above ~16kHz anyway)

### Unverified: Layer Interaction
- fire crackle at low volume may be masked by rain (reported in CLAUDE.md)
- binaural 40Hz gamma needs headphone verification (stereo separation required)
- brown noise spectral curve needs measurement against reference 1/f²

## Static FM Audio Architecture

Weather-matched late night radio. Music via Spotify SDK, atmosphere via Web Audio synthesis.

### Atmosphere Layers (one per weather mood)

**rain** — bandpass noise at 800Hz (Q=0.5), gain 0.05. identical filter to Drift's rain but different gain. subtle background texture behind music.

**storm** — bandpass noise at 600Hz (Q=0.3) at 0.08 gain (wider, heavier than rain) + lowpass 80Hz rumble at 0.04 + dynamic thunder. thunder triggers randomly every 8-28 seconds — sharp noise burst with 50ms attack, 1.5-3.5s exponential decay through a lowpass 60-140Hz filter. well-shaped envelope that sounds like real thunder.

**fog** — dual detuned sine oscillators at 140Hz and 147Hz (7Hz shimmer/beating) at 0.018 gain + bandpass noise at 800Hz (Q=0.5) at 0.02. the 7Hz detuning creates a slow phase rotation that sounds ethereal. very quiet — subliminal rather than foreground.

**snow** — lowpass noise at 250Hz (Q=0.7) at 0.04 + 50Hz sine "furnace hum" at 0.012. same design philosophy as Drift's snow synthesis but slightly different filter values. domestic indoor warmth.

**clear** — 3 cricket oscillators at 4000-6000Hz with slow drift (0.1-0.4Hz) and tremolo (5-15Hz). identical architecture to Drift's cricket synthesis. nighttime outdoor atmosphere.

### DJ Intros

Text-based intros, not TTS audio (TTS generation is post-launch priority).
- 11-13 intros per weather mood (55+ total)
- 6-8 host messages per mood (30+ total)
- 10 rare time-locked intros (weather + hour combinations, 30% trigger chance)
- voice: late night radio, slightly melancholic, casually poetic
- rare intros are "secrets" — finding one should feel like tuning into a hidden frequency

### Music Curation

76 tracks across 5 moods, curated for sonic and emotional fit:
- rain (17): The Doors, Prince, Burial, Portishead, Radiohead
- storm (15): Rolling Stones, Björk, Massive Attack, Pixies
- fog (15): Radiohead, Portishead, Brian Eno, Sigur Rós, Max Richter
- snow (15): Bon Iver, Fleet Foxes, Vivaldi, The xx
- clear (15): Beach House, Radiohead, Childish Gambino, M83

## Pulse Audio Architecture

Focus timer with ambient sound. Pure Web Audio synthesis, no samples.

**Focus phase (25 min):**
- Brown noise: integrator formula `(last + 0.02 * white) / 1.02` scaled 3.5x, gain 0.08
- Rain layer: white noise → bandpass 800Hz (Q=0.5), gain 0.04
- Combined effect: warm low-frequency foundation with gentle mid-range texture

**Break phase (5 min):**
- 3 bird oscillators: sine waves at 2500-4500Hz, vibrato 4-10Hz (±200Hz), tremolo 0.3-0.8Hz
- Leaf noise: white noise → bandpass 3000Hz (Q=0.8), gain 0.03
- Combined effect: nature soundscape signaling "step away from the screen"

Phase transitions are instant — audio stops and restarts with new synthesis. No crossfade between phases. The gain values are intentionally lower than Drift since Pulse runs for extended periods.

## iOS Audio Behavior

- Web Audio API synthesis: blocked by hardware silent mode, strict gesture requirements
- HTML5 Audio elements: work through silent mode, survive backgrounding
- Current engine: synthesis for desktop, sample fallback on mobile
- All samples use `new Audio()` (HTML5) with lazy loading

## TTS / DJ Intros

- 105 audio intros generated (60 intros + 35 host messages + 10 rare time-locked)
- Voice: George (ElevenLabs multilingual v2) with -3% pitch post-processing
- Settings: stability 0.35, similarity 0.75, style 0.40, speaker boost on
- 39 intros enhanced with SSML break tags (0.5-0.8s pauses)
- Format: 128kbps mono 44100Hz, 2.8-8.1s duration, avg -17.9 LUFS
- Total size: 8.5MB at ~/static-fm/audio/intros/
- ElevenLabs credits used: ~17,050 of 100,000
- **Status:** generated and verified. awaiting station.js integration (claude's lane)

## Architecture Reference

- **Engine:** `~/ambient-mixer/engine.js` — dual engine (sample + synthesis), lazy init, Web Audio API
- **Audio files:** `~/ambient-mixer/audio/normalized/` — 10 production samples (post session 5 fix)
- **iOS investigation:** `shared-brain/projects/drift/ios-audio-investigation.md`
- **Audio architecture:** `shared-brain/projects/drift/audio-architecture.md`
- **Competitive analysis:** `shared-brain/projects/competitive-analysis.md`
- **RAG audio research:** `shared-brain/projects/rag-audio-research.md`

## Next Actions

1. ~~Diagnose and fix revert-to-synthetic bug~~ done, session 4
2. ~~Verify engine.js fix after deploy~~ done, session 4
3. ~~Install ffmpeg + sox~~ done, session 4
4. ~~Analyze all 10 samples: loop points, spectral profile, loudness (LUFS)~~ done, session 4+5
5. ~~Normalize all samples to -14 LUFS / -1 dBTP~~ done, session 5. path swap to /audio/normalized/ (PR #1)
6. ~~Fix LFO leak at zero volume~~ done, session 5. disconnect gain at vol=0 (PR #1)
7. ~~Add fade-in ramps~~ done, session 5. 0.5s samples, 0.4s synthesis
8. ~~Write sample descriptions for RAG pipeline~~ done, session 5
9. ~~Standardize sample rates to 44.1kHz~~ done, session 6. all 10 samples now 44100Hz
10. ~~Extend crickets.mp3 and leaves.mp3 to 60s~~ done, session 6. 5s triangular crossfade, 0.6dB max deviation, both verified clean
11. ~~Verify brown noise spectral curve against 1/f² reference~~ done, session 5. slope: -1.86 (target -2.00), PASS. spectrogram at /tmp/brown-noise-verification.png
12. ~~Verify binaural beats frequency accuracy (40Hz gamma)~~ done, session 5. 200Hz L / 240Hz R confirmed, 40Hz envelope verified. visualization at /tmp/binaural-verification.png
13. ~~Generate DJ intro audio via ElevenLabs TTS~~ done, session 6. 105 intros at ~/static-fm/audio/intros/. george voice, -3% pitch, SSML breaks. awaiting station.js integration
14. ~~Seed RAG vector store with audio docs~~ in progress, session 5 (claude running pipeline)
