---
title: Static FM — Self-Hosted Player UX
date: 2026-03-25
type: design spec
author: claudia
status: draft
---

# Static FM — Self-Hosted Player UI

## What Changes

### Before (Spotify dependency)
1. User arrives → sees "MUSIC" section with two buttons: "connect spotify" / "listen free"
2. Must choose before music plays
3. Free = 30-second clips that cut mid-song
4. Premium = full tracks but requires Spotify login + Premium account
5. Atmosphere plays immediately, music is gated

### After (Self-hosted)
1. User arrives → clicks anywhere to tune in → atmosphere AND music both start
2. No gate, no choice, no account
3. Full-length royalty-free tracks, continuous playback
4. Spotify Connect becomes an optional upgrade ("bring your own music")

## Simplified Player State

### The Connect Gate → Gone
The `player-connect` div with "connect spotify" / "listen free" disappears entirely. In its place, the `player-active` state shows immediately with the current track.

### Now Playing (always visible after tune-in)
```
┌─────────────────────────────────┐
│ ● NOW PLAYING                   │
│                                 │
│ [Album Art]  Track Title        │
│              Artist Name        │
│                                 │
│ ━━━━━━━━━━●━━━━━━━━━━  2:14/4:02│
│                                 │
│      ⏮     advancement auto     │
│           (no play/pause -      │
│            radio doesn't pause) │
└─────────────────────────────────┘
```

### Design Decisions

**No play/pause on music.** This is radio. You don't pause radio. The atmosphere controls (tune in/out) handle the overall experience. If you want silence, you adjust the music volume slider to 0.

**No skip (in live mode).** When we add live radio sync later, skip doesn't exist. For now with personal mode, a skip-forward button is acceptable but should be subtle — a small `>>` not a prominent control.

**Album art:** Self-hosted tracks may not have album art. Options:
1. Generate mood-colored abstract art per weather mode (a gradient square that matches the weather theme)
2. Use a generic vinyl/waveform placeholder
3. No art — just track info text

**Recommendation:** Option 1. Five simple gradient squares, one per weather mode:
- Rain: deep blue to slate (#1a2332 → #2d3748)
- Storm: dark purple to charcoal (#1a1428 → #2d2d3d)
- Fog: warm gray to silver (#282828 → #4a4a4a)
- Snow: ice blue to white (#1a2838 → #c8d8e8)
- Clear: midnight blue to warm gold (#0a1628 → #3d3520)

### The Spotify Upgrade Path
For users who WANT their own music:
```
┌─────────────────────────────────┐
│ ● SPOTIFY CONNECTED             │
│                                 │
│ [Real Art]  Track Title         │
│             Artist Name         │
│                                 │
│ ━━━━━━━━━━●━━━━━━━━━━  2:14/4:02│
│                                 │
│      ⏮    ▶/⏸    ⏭            │
│                                 │
│   disconnect · your playlists   │
└─────────────────────────────────┘
```

Spotify users get full controls (play/pause, skip, library access). This is the premium experience. The self-hosted radio is the default.

**How to access:** Small "connect spotify" link in the player footer, not a prominent button. It's there for power users, not the default path.

### Volume Controls (unchanged)
```
ATMOSPHERE ━━━━━●━━━━━━━━
MUSIC ♪    ━━━━━━━━●━━━━━
```

These stay exactly as they are (with the visibility fix from PR #16). The music slider now controls self-hosted audio volume instead of Spotify embed volume.

### Attribution Footer
Per near's licensing requirement, add a credits line below the player:
```
music: "Track Title" by Artist Name · CC0
```

Updates with each track change. Small, unobtrusive, Space Mono 8px. This is the attribution infrastructure that scales to CC-BY later.

## Up Next Section (existing)
The "UP NEXT" and "RECENTLY PLAYED" sections work exactly the same — they just reference self-hosted tracks instead of Spotify track IDs. Track metadata (title, artist, mood) stays in station.js.

## CSS Changes Needed
1. Remove `.player-connect` styles (or hide with display:none as fallback)
2. `.player-active` becomes the default visible state
3. Add weather-mode gradient backgrounds for album art placeholder
4. Add `.attribution-line` style (8px Space Mono, text-dim color)
5. Simplify `.player-controls` — remove play/pause, keep subtle skip-forward only

## What Stays the Same
- Vinyl record animation
- EQ bars
- DJ intro text display
- Weather mode switching
- Atmosphere synthesis + slider
- Chat widget
- Fullscreen mode
