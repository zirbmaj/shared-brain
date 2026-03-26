---
title: PH Launch Day — Audio Verification Checklist
date: 2026-03-25
type: checklist
scope: shared
owner: hum
summary: Quick-verification checklist for audio quality during PH launch hour. Run within first 15 minutes of going live.
---

# PH Launch Day — Audio Verification Checklist

Run this within the first 15 minutes of PH listing going live. Total time: ~10 minutes.

## Pre-Launch (T-1 hour)

- [ ] Verify vercel deploy is current — all PRs landed (seamless audio #24, track.js #18, slider #16)
- [ ] Load drift.nowherelabs.dev/app.html in incognito — confirm cold start overlay appears
- [ ] Confirm PH UTM link loads correct mix: `?mix=eyJyYWluIjo2MCwiY2FmZSI6NDUsInZpbnlsIjoyMH0=`
- [ ] Verify "someone shared a room with you" tagline appears on shared link

## Preset Playback (first-touch experience)

Test each preset. User taps once → audio should play within 500ms.

| Preset | Layers | What to listen for |
|--------|--------|--------------------|
| rainy cafe | rain 60, cafe 45, vinyl 20 | rain + cafe balanced, vinyl subtle crackle underneath |
| deep focus | brown-noise 70, rain 25 | brown noise dominant, rain adds texture |
| midnight train | train 65, rain 30, drone 15 | train rhythm clear, drone barely perceptible |
| sunday morning | birds 50, leaves 30, wind 20 | birds dynamic but present, leaves as background rustle |
| winter cabin | fire 70, snow 40, wind 25 | fire crackle dominant, wind fills space |
| ocean at night | waves 75, crickets 30, drone 10 | wave rhythm clear, crickets fill gaps |

## Loop Points (seamless check)

For each preset, listen through at least one full loop cycle (60s). Check:

- [ ] rainy cafe — no audible restart bump at 60s mark
- [ ] winter cabin — fire loop clean, no volume drop/spike
- [ ] ocean at night — waves loop clean, no gap

If loop seam is audible: the seamless MP3s didn't deploy. Check if `/audio/seamless/` path is live or still pointing to `/audio/normalized/`.

## Mobile Audio Unlock

Test on actual phone (not emulator):

- [ ] iOS Safari: tap play → AudioContext unlocks, audio starts
- [ ] iOS Safari: switch tabs → come back → audio still playing (ambient layers use Web Audio, not Spotify)
- [ ] Android Chrome: same test
- [ ] Volume slider responds on mobile — drag master volume, hear change

## Volume Controls

- [ ] Master volume slider visible on mobile (should be order:1, above preset buttons)
- [ ] Master volume label readable (11px, primary text color)
- [ ] Per-layer sliders respond independently
- [ ] Sliding a layer to 0 → pauses (not destroys) the sample
- [ ] Sliding back up from 0 → resumes same sample (no synthesis fallback)

## Static FM (secondary product)

- [ ] Atmosphere slider visible and controllable
- [ ] Weather detection fires → correct playlist loads
- [ ] DJ intro plays on station start (30% chance per weather switch)
- [ ] DJ intro volume reasonable relative to atmosphere (check for ducking)

## Red Flags (stop and escalate)

- Silence on first tap → AudioContext not resuming. Bug in #bugs immediately
- Synthesis instead of sample audio → MP3 failed to load, fallback triggered. Check network tab for 404s
- Loud pop or click on any transition → crossfade not working or new artifact
- Volume spike when switching presets → master gain not resetting correctly

## Launch Hour Monitoring (0-4 hours post-launch)

- [ ] Monitor PH comments for audio complaints ("clicking," "glitch," "sounds weird," "too loud," "no sound")
- [ ] If audio issue reported: reproduce → diagnose → post fix spec in #dev within 15 minutes
- [ ] Check if any user reports synthesis fallback ("sounds fake/electronic") — indicates MP3 loading failure
- [ ] Monitor mobile-specific audio complaints (iOS autoplay, tab-switch pause)

## Post-Check

- [ ] Screenshot spectrogram of PH landing mix playing (visual proof for #dev)
- [ ] Post "audio verified clean" in #dev with timestamp
- [ ] Note any issues found with severity and product
