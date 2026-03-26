---
title: Drift — First-Time Onboarding for PH Launch
date: 2026-03-25
type: design spec
author: claudia
status: draft
---

# Drift — Onboarding Flow for PH Visitors

## The Problem

Current flow:
1. Start overlay: "DRIFT / ambient sound mixer / tap to begin" → dead screen, no preview
2. Tap → full mixer with 18 layers, no guidance
3. User has to find a slider and drag it to hear anything

A PH visitor has ~5 seconds to decide if this is worth their time. The current start screen wastes those seconds on a logo and a tap prompt. After tapping, they face 18 unlabeled sliders and no guidance.

## The Fix: Sound-First Onboarding

### Principle
Don't make them build. Let them hear, then invite them to change it.

### Step 1: Enhanced Start Overlay (before tap)

Current:
```
DRIFT
ambient sound mixer
tap to begin
```

Proposed:
```
DRIFT

[rain 60 · cafe 45 · vinyl 20]     ← visual preview of what they're about to hear
━━━━━━━ ━━━━━ ━━━                   ← three small level bars, animated subtly

tap to begin mixing

18 layers · infinite combinations · free forever
```

The level bars show the default mix visually before any sound plays. It hints at what's inside without explaining it. The "tap to begin mixing" changes the verb from passive ("begin") to active ("begin mixing").

For shared links, this already works: the start overlay shows the shared mix layers. For organic visitors, it shows the default cold-start mix.

### Step 2: Instant Sound on Tap (first 3 seconds)

Current: tap → silent mixer, user must find and slide a layer.

Proposed: tap → the default mix fades in over 1.5 seconds. Rain at 60, cafe at 45, vinyl at 20. The user immediately hears a complete soundscape.

This is actually already how the cold start works (there's a default mix). The change is making it more prominent — the sliders should animate to their positions as the sound fades in, so the user sees the connection between slider position and sound.

### Step 3: Guided First Interaction (first 30 seconds)

After the mix is playing, a subtle hint appears near the most interesting inactive layer:

```
                                        try adding fireplace →
[🔥 Fireplace     ━━━━━━━━━━━━━━━━━━━━━━━  0]
```

One hint. One layer. Not a tutorial, not a tooltip tour. Just a gentle nudge toward the first interaction that teaches them the product.

**Why fireplace:** It's the most viscerally satisfying add to the rainy cafe mix. The crackle is immediately recognizable and transforms the soundscape. It teaches "oh, I can add layers" in the most rewarding way possible.

The hint disappears after:
- They interact with any layer (mission accomplished)
- 15 seconds pass (they're exploring on their own)
- They scroll (they're looking around)

### Step 4: Discovery Nudge (after 60 seconds)

If the user has been listening for 60+ seconds and hasn't saved or shared:

```
                                            ↓ share this mix
[controls bar: ▶ ━━━━━━━● MASTER   save  share  discover]
```

Subtle glow on the share button (we already have this animation: `shareNudge`). Not a popup, not a modal. Just the existing share nudge activating after engagement.

## What This Doesn't Change

- The start overlay is still required (AudioContext needs user gesture)
- The cold-start default mix is already built
- Save/share/discover flows are unchanged
- Mobile flow is the same concept, just different layout

## Implementation Notes

### Start Overlay Changes (CSS + HTML)
- Add three small level bars below the subtitle (CSS-only, using the `.smp-bar` / `.smp-fill` pattern from the shared mix preview)
- Change "tap to begin" → "tap to begin mixing"
- Add "18 layers · infinite combinations · free forever" below the tap prompt

### Guided Hint (JS + CSS)
- New element: `.onboard-hint` — absolutely positioned near the fireplace layer
- Shows 3 seconds after overlay dismissal IF no layers have been interacted with
- Disappears on any slider interaction, scroll, or after 15 seconds
- CSS: `opacity` transition, small arrow pointing at the fireplace slider
- Only shows once per session (sessionStorage flag)

### Slider Animation on Entry
- When overlay dismisses and cold-start mix loads, animate sliders from 0 to their target positions over 1.5 seconds
- CSS `transition: width 1.5s ease-out` on the slider fill
- Synced with audio fade-in

## Mobile Considerations

Same flow, but the hint should point to a layer that's visible without scrolling. On mobile with the collapsed grid, fireplace might be below the fold. Check which layers are visible on 375px after overlay dismiss — the hint should point to whatever's the most rewarding visible layer.

## Metrics

- Time to first interaction (slider touch) — should decrease
- Session duration — should increase (more engagement with mixing)
- Share rate — should increase (nudge activates earlier)
- Bounce rate from app.html — should decrease (instant sound reduces "what do I do?" exits)
