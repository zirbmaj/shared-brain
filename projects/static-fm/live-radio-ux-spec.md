---
title: Static FM — Live Radio vs Personal Mode UX
date: 2026-03-25
type: design spec
author: claudia
status: draft
---

# Static FM — Live Radio vs Personal Mode

## The Core Question
Does the user know they're hearing what everyone else hears? And how do they switch to their own experience?

## Two Modes

### Live Radio (default)
Everyone tuned to the same weather mode hears the same track at the same position. Like a real radio station. You tune in mid-song, not from the beginning.

**Why default:** It's a radio station. The whole brand is "tune in." Personal playlists are what Spotify does. The magic of radio is that someone else picked this song and you happened to hear it at the right moment.

**UX signals:**
- Listener count is real: "4 listening" means 4 people hearing this exact moment
- DJ intros play at natural intervals (every 3-4 tracks), everyone hears them simultaneously
- "LIVE" indicator next to the frequency (103.7)
- Track progress bar shows position but isn't scrubbable (you can't rewind radio)

### Personal Mode
Your own shuffled playlist. Skip tracks, no shared state. The "personal broadcast" experience.

**When you'd want this:**
- You don't like the current track and want to skip
- You want to go back to a song you heard
- You want control

**UX signals:**
- Listener count changes to "solo broadcast"
- Skip/back controls appear
- Track progress bar becomes scrubbable
- No "LIVE" badge
- DJ intros still play (they're part of the character, not the sync)

## The Switch

**Location:** Small toggle near the frequency display. Not a settings page, not a modal.

```
| 103.7 |  LIVE  [personal]
```

Tapping "personal" switches to personal mode. The frequency stays, the LIVE badge disappears, skip controls fade in.

Tapping "LIVE" switches back. Current personal track fades out, live stream fades in mid-song. Seamless audio crossfade (1s).

**First-time behavior:** Default is LIVE. No explanation needed. The toggle is discoverable but not pushed. Most users should experience the communal radio feeling without thinking about it.

## Visual Treatment

### Live Mode
- `LIVE` badge: small pill, accent color, subtle pulse animation (like the existing breathing animations)
- No transport controls (no skip, no back, no scrub)
- Listener count: real number, updates in real-time
- Track info shows as normal

### Personal Mode
- No badge, frequency only
- Transport controls fade in: skip forward, skip back (minimal, icon-only)
- "solo broadcast" replaces listener count
- Track progress becomes interactive (scrub on click/drag)

### The Transition
- Switching modes: 1s audio crossfade, UI elements animate (controls slide in/out, badge fades)
- No page reload, no modal, no confirmation
- If you're in personal mode and switch back to live, you join wherever the live stream currently is

## Weather Mode Interaction
- Switching weather mode in LIVE always syncs to the live stream for that weather
- Switching weather mode in PERSONAL starts a fresh shuffle for that weather
- The live stream runs independently per weather mode (rain has its own timeline, storm has its own)

## Technical Notes (for claude)
- Live sync needs a shared clock — simplest implementation is a deterministic shuffle based on UTC date + weather mode, with track position calculated from elapsed time
- No actual streaming server needed — each client calculates what should be playing right now and starts the audio at the correct offset
- This means "live" is simulated, not truly server-streamed. But the effect is identical: everyone hears the same thing at the same time
- Personal mode is the current implementation (random shuffle per user)

## What This Doesn't Change
- Atmosphere layer (rain, wind, etc.) — always personal, always independent
- DJ intros — play in both modes, timed by the mode they're in
- Chat — stays as-is, not affected by mode
- Volume controls — same in both modes
