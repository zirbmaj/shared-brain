---
title: Static FM — First-Time Onboarding
date: 2026-03-25
type: design spec
author: claudia
status: draft
---

# Static FM — Onboarding Flow

## The Problem

Current flow:
1. User arrives → sees "STATIC FM / late night weather radio / click anywhere to tune in"
2. Clicks → atmosphere starts, but music is gated behind "connect spotify" / "listen free"
3. Two-column layout: vinyl + track info on left, weather buttons + playlist on right
4. The "MUSIC" section with connect buttons is the first thing that demands a decision

A first-time visitor hits a decision wall before they've experienced anything. They don't know what "connect spotify" means in this context. They don't know what "listen free" gives them. They have to choose before they understand the product.

## The Fix: Tune In, Then Explore

### Principle
Radio doesn't ask you to sign up. You just tune in and it's playing.

### Step 1: Landing (before click)

Current landing is good — "click anywhere to tune in" is clear and simple. No changes needed here.

One small addition: show the current weather mode and a hint of what's playing.

```
| 103.7 |
STATIC FM
late night weather radio

🌧 rain mode · 4 listening

click anywhere to tune in
```

The listener count and weather mode give social proof and context before the click. "4 listening" says "other people are here" which makes clicking feel less like entering an empty room.

### Step 2: Instant Everything on Click (first 3 seconds)

Current: click → atmosphere plays, music section shows connect buttons.

With self-hosted music (claude's PR #17): click → atmosphere AND music both play immediately. No gate, no decision.

The experience should be:
1. Click anywhere
2. Rain atmosphere fades in (0.5s)
3. Music track fades in underneath (1s delay, 1.5s fade)
4. DJ intro plays after first track settles (~5s delay)
5. Vinyl record starts spinning
6. Track info populates

The user goes from silence to a full radio station experience in 3 seconds. No choices required.

### Step 3: Weather Mode Discovery (first 30 seconds)

The weather buttons (Rain, Storm, Fog, Snow, Clear Night) are already visible on the right. But a first-time visitor might not realize they change the entire experience — atmosphere, music, and DJ personality all shift.

Subtle hint after 10 seconds of listening:

```
🌧 RAIN  ⛈ STORM  🌫 FOG  🌨 SNOW  🌙 CLEAR NIGHT
                                    ↑
                          try a different weather
```

Same pattern as drift: one hint, disappears on interaction or after 15 seconds, never shows again (sessionStorage).

### Step 4: Volume Discovery

The ATMOSPHERE and MUSIC sliders are below the player. Most users won't touch them — which is fine, the defaults are good. But for users who want more atmosphere and less music (or vice versa), the sliders should be visible without scrolling on desktop.

No change needed — they're already in the viewport on desktop. On mobile they're below the fold but that's acceptable since mobile users interact more vertically.

## The Spotify Connect Path (Post Self-Hosted)

With self-hosted music as the default, Spotify Connect becomes a power-user upgrade:

```
┌─────────────────────────┐
│ ♪ currently playing      │
│   "Memory Shores"        │
│   John Bartmann · CC0    │
│                          │
│ ━━━━━━━●━━━━━━━  2:14    │
│                          │
│   connect spotify ›      │  ← small text link, not a button
└─────────────────────────┘
```

"connect spotify" is a small link at the bottom of the now-playing section. Not a prominent button, not a gate. Tapping it opens the Spotify OAuth flow for users who want their own music. Everyone else just listens to the curated radio.

## What This Doesn't Change

- Weather button layout and behavior
- Chat widget
- Atmosphere synthesis
- Fullscreen mode
- DJ intro timing and content

## Implementation Notes

### Landing Enhancement (HTML + CSS)
- Add weather mode + listener count to the landing overlay
- Reuse existing `.broadcast-time` pattern for the weather indicator
- Listener count from existing supabase `chat_presence` or a simple counter

### Auto-Play Music on Tune-In (JS)
- Depends on claude's PR #17 (self-hosted playback)
- On overlay dismiss: start atmosphere (existing), then start music with 1s delay
- Remove the `player-connect` gate from the default flow
- Music player goes directly to `player-active` state

### Weather Hint (JS + CSS)
- Same pattern as drift onboarding: `.onboard-hint`, sessionStorage flag
- Position near the weather buttons
- 10s delay after tune-in, disappears on weather change or 15s timeout

## Mobile Considerations

On 375px, the two-column layout stacks vertically. The weather buttons are below the vinyl/player section. The hint should appear above the weather buttons when they're in viewport (use IntersectionObserver to only show when visible).

## Metrics

- Time to weather switch — should decrease (hint prompts exploration)
- Session duration — should increase (immediate music removes the connect-wall dropout)
- Weather mode diversity — currently most users stay on rain. hint should increase storm/fog/snow/clear usage
