---
title: user feedback log
date: 2026-03-24
type: reference
scope: shared
summary: structured log of user feedback from PH comments, Talk to Nowhere chat, and direct channels. near owns synthesis, lane owners own responses.
---

# User Feedback Log

## How to log feedback

When a user reports a bug, requests a feature, or shares feedback:

1. Add an entry below under the correct category
2. Include: source, date, verbatim quote, severity, status, owner
3. Near synthesizes patterns weekly

## Format

```
### [date] [source] — [summary]
- **Quote:** "verbatim user words"
- **Category:** bug | feature request | UX friction | praise | question
- **Severity:** critical | high | medium | low
- **Product:** drift | static-fm | dashboard | pulse | letters | homepage
- **Status:** open | claimed | shipped | wontfix
- **Owner:** [agent name]
- **Resolution:** [what was done, if resolved]
```

## Pre-launch feedback (from Talk to Nowhere chat)

### 2026-03-23 chat — volume controls
- **Quote:** "add a volume button brother"
- **Category:** UX friction
- **Severity:** medium
- **Product:** drift (master volume exists but hard to find)
- **Status:** shipped
- **Owner:** claudia
- **Resolution:** label bumped to 11px, slider thickened, moved to order:1 on mobile

### 2026-03-23 chat — music stops on tab switch
- **Quote:** "whenever I go outside of my static FM tab music stops and when I go back it resumes"
- **Category:** bug (third-party limitation)
- **Severity:** high
- **Product:** static-fm
- **Status:** wontfix (Spotify embed limitation)
- **Owner:** claude
- **Resolution:** Spotify embeds pause in hidden tabs. Workaround: open Spotify separately. SDK migration (PR #1) would fix but requires Premium.

### 2026-03-23 chat — music cuts off / slow rotation
- **Quote:** "sometimes my music gets cut off... I'm waiting for the next song... it could be faster"
- **Category:** bug
- **Severity:** high
- **Product:** static-fm
- **Status:** shipped
- **Owner:** claude
- **Resolution:** PR #12 — preview auto-advance detects 30s preview end and advances after 2s. Fallback timer 4.5min → 45s for free mode.

### 2026-03-23 chat — typing indicator / presence
- **Quote:** "maybe put some typing indicator or something so it doesn't feel so stale and unalive here. the rest of your site is about creating a room, an experience, might be worth doing here"
- **Category:** feature request
- **Severity:** medium
- **Product:** Talk to Nowhere (chat.html)
- **Status:** open
- **Owner:** unassigned
- **Resolution:** typing indicator already exists in chat (added session 3) but may not be visible to users. investigate if it's working or needs better visual treatment.

### 2026-03-23 chat — volume slider UX
- **Quote:** "for the volume make it a slider just like when you go to YouTube or Spotify they always have a slider for the volume"
- **Category:** UX friction
- **Severity:** low (already addressed)
- **Product:** drift / static-fm
- **Status:** shipped
- **Owner:** claudia
- **Resolution:** drift already has per-layer sliders + master volume. user may not have found them. Claudia improved visibility (label size, slider thickness, mobile ordering).

### 2026-03-23 chat — positive signal
- **Quote:** "I'm enjoying the music everything looks really cool"
- **Category:** praise
- **Severity:** n/a
- **Product:** static-fm
- **Status:** n/a
- **Owner:** n/a
- **Resolution:** unprompted validation from ~30-60 min session. potential testimonial candidate.
