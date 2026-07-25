---
title: session 152 retro — claudia
date: 2026-05-21
type: retro
scope: shared
summary: Zombie recovery → Drift Re-Entry (P1 entry-path shipped) → widened to NWL Products brand/portfolio work.
---

# Session 152 Retro — Claudia

## What shipped
- **Drift entry-path rework (PR #38, live):** killed the "arrive twice" second splash, overlay
  now a blurred scrim over the live mixer; paired w/ Claude on the audio-unlock seam, which
  also fixed the Rain-60%/"nothing yet" state mismatch. Static QA'd 1440/768/375.
- **Brand-coherence + design-vitality reads** (cross-product) → fed the create/sunset board.
- **Joint "one studio" coherence artifact** w/ Hum (visual + sonic).
- voice.md "Two AIs"→"A team of AIs". Pulse nav-collision diagnosed (fix ready, held).

## What worked
- Clean pairing contract w/ Claude (overlay fires `Drift.unlockAndStart()`, zero file overlap).
- Didn't blindly re-fix Pulse nav — caught that the prior fix was mobile-only, root-caused the
  desktop issue (flex body shrinks shared nav), then HELD the PR once market read said merge.
- Held all pre-verdict polish on maybe-merged/sunset products instead of manufacturing work.
- In-lane discipline through very heavy cross-lane chatter; mostly stayed out of non-design threads.

## What didn't
- Burned ~12k tokens reading + resending the full 814-line style.css through MCP push_files,
  which 404'd anyway. Lesson: on a push 403, diagnose whether it's a team-wide auth issue
  BEFORE the heavy MCP file-content push. (Claude diagnosed the Zerimarx404→zirbmaj block.)
- Verified entry overlay at 1440+375 first, skipped 768 — only closed it after Static's gate
  surfaced the gap. My own rule says all three viewports first pass; do that.

## Token usage
High this session — justified spend on screenshot reads (visual work needs eyes) + 3 filed
design docs; avoidable spend on the full-file MCP push round-trip. Net: heavy but mostly
purposeful. Screenshot batching (multiple viewports per Playwright run) helped.

## Carries
- ⚖️ jam verdict pending: Pulse→merge into Dashboard, Letters→sunset/archive.
- Queued behind verdict + consensus: name-treatment unification (mono call-sign everywhere),
  audio-engine.js visual pairing (Hum sonic-brand co-owner), Pulse nav fix (only if kept).
- jam's hands: permanent git-cred fix, Supabase /mcp OAuth (gates live-usage validation),
  Spotify dashboard, r10 + xps13 down.

## Harness hygiene
No rules felt unnecessary this session.
