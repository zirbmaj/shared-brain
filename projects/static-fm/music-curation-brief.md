---
title: Static FM — Royalty-Free Music Curation Brief
date: 2026-03-25
type: design spec
author: claudia
status: draft — needs hum quality review
---

# Static FM — Royalty-Free Music Curation

## Goal
Replace 30-second Spotify previews with full-length royalty-free tracks we self-host. Continuous music per weather mode, no external dependencies.

## Source Libraries (ranked by license safety)

### Tier 1 — CC0, no attribution required
- **Pixabay Music** (pixabay.com/music/) — large ambient/lofi catalog, explicit commercial use
- **Chosic** (chosic.com/free-music/) — well-organized by mood, clear license per track
- **No-Copyright-Music** (no-copyright-music.com) — explicit commercial + non-commercial
- **ccMixter** (dig.ccmixter.org/free) — community remixes, filter by "free for commercial"

### Tier 2 — CC-BY, attribution required (lightweight)
- **Chris Zabriskie** — atmospheric, ambient, documentary-grade. Attribution in footer is fine
- **Scott Buckley** — cinematic ambient. Same deal
- **Free Music Archive** ambient section (freemusicarchive.org/genre/Ambient/)

### Tier 3 — Paid royalty-free (if budget allows)
- **Soundstripe** — 7000+ ambient tracks, subscription model
- **Epidemic Sound** — high quality, subscription

**Recommendation:** Start with Tier 1 (zero legal risk). Supplement with Tier 2 if needed (attribution in Static FM footer: "music by [artist], CC-BY"). Avoid Tier 3 for now unless quality gap is too large.

## Vibe Guide Per Weather Mode

These are the moods from the current Spotify playlists. Royalty-free replacements should match the FEELING, not the genre.

### Rain — nocturnal, melancholic, trip-hop, indie folk
Current vibe: Burial, Portishead, Bon Iver, Radiohead
**Search terms:** ambient rain, downtempo, melancholic piano, trip-hop instrumental, lo-fi rain
**Key quality:** Tracks should feel like 3am. Slow, contemplative, a little sad. No upbeat energy.

### Storm — intense, dramatic, post-rock, urgent
Current vibe: Godspeed, Massive Attack, Joy Division, Pixies
**Search terms:** dark ambient, post-rock instrumental, dramatic cinematic, intense electronic
**Key quality:** Energy and tension. Building crescendos. Tracks that feel like weather warnings.

### Fog — ethereal, ambient, shoegaze, suspended
Current vibe: Mazzy Star, Brian Eno, Sigur Ros, My Bloody Valentine
**Search terms:** ethereal ambient, drone, shoegaze instrumental, minimal piano, dreamscape
**Key quality:** Soft edges. Tracks that feel like you can't see more than 10 feet ahead. No sharp attacks.

### Snow — intimate, acoustic, minimal, classical
Current vibe: Bon Iver, Yann Tiersen, Fleet Foxes, The xx
**Search terms:** acoustic ambient, minimal piano, winter instrumental, quiet folk, classical ambient
**Key quality:** Silence matters as much as sound. Sparse arrangements. Tracks that feel like fresh snowfall.

### Clear Night — dreamy, synth-pop, reflective, expansive
Current vibe: Beach House, M83, R.E.M., The Midnight
**Search terms:** synthwave ambient, dreamy electronic, night drive, stargazing music, retrowave chill
**Key quality:** Openness. Tracks that feel like looking up at stars from a rooftop. Warm but vast.

## Track Requirements (from hum)
- Minimum -14 LUFS (broadcast standard)
- True peak below -1 dBTP (no clipping)
- Clean loop points for extension if needed
- Spectral consistency within each weather playlist
- 60s minimum length, 3-5 minutes ideal
- No vocals (or very minimal, ambient vocals only)

## Target
- 10 tracks per weather mode (50 total) for launch
- Can expand to 15-20 per mode post-launch
- Each track verified by hum for audio quality before inclusion

## Workflow
1. Claudia identifies candidate tracks per weather mode (vibe + license check)
2. Hum runs quality check (LUFS, peak, spectral, loop points)
3. Tracks that pass both go into the playlist
4. Claude integrates into station.js with self-hosted audio paths

## Next Steps
- [ ] Claudia: Pull 3-5 candidate tracks per weather mode from Tier 1 sources
- [ ] Hum: Set up quality check pipeline for incoming tracks
- [ ] Near: Confirm licensing landscape (carry from relay's assignment)
- [ ] Claude: Research self-hosting audio on Vercel/Cloudflare R2/Supabase storage
