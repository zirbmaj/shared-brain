---
title: claudia retro — session 12
date: 2026-03-26
type: retro
scope: claudia
summary: Stall/permission CSS for both vigils, state badge positioning fix, app.js badge wiring
---

# Claudia Retro — Session 12 (2026-03-26)

## What shipped

### Vigil - stall + permission visual states
- **Stalled**: breathing red glow (4s cycle), matches Hum's 0.3Hz LFO wobble
- **Permission**: steady bronze/amber glow, informational not alarming
- Status badge element added to app.js card template
- JS wiring for badge text ("stalled" / "awaiting input") + recovery clear
- Test event handlers updated with badge text

### Vigil - state badge positioning
- Moved `.mc-state-badge` outside `.mc-agent-header` flex container
- Changed to `display: block` with `margin-top: 4px` underneath agent name
- Fixed jam's complaint about tags covering agent names

### Both vigils kept in sync
- All CSS and JS changes shipped to mission-control/ and vigil-meridian/ simultaneously

## What worked well
- **Parallel build**: 4 agents (claude, claudia, hum, static) on detection/css/audio/qa simultaneously
- **Fast diagnosis**: verified served files vs disk files to rule out caching issues
- **Staying in lane**: correctly identified 90% of the issues as not-my-territory and stayed quiet

## What didn't work
- **Badge HTML missing**: wrote CSS for an element that didn't exist in the DOM yet. Should have checked the HTML template first
- **Single-vigil edit**: initially only wrote to mission-control/, had to copy to meridian after jam called it out
- **Too many messages during crisis**: team was noisy when jam was frustrated. Relay had to silence everyone
- **Copied app.js blindly to meridian**: got lucky that agent config was in server.js not app.js

## Lessons
1. **Check the DOM before writing CSS** - no point styling elements that don't exist
2. **Always edit both vigil directories** - standing rule from jam, saved to memory
3. **When jam is frustrated, shut up** - fewer messages, more fixes
4. **Verify what's served, not what's on disk** - curl the endpoint to confirm

## State for next session
- Budget resets Friday noon
- PH launch T-5 (March 31)
- All vigil features shipped and verified
- Carries: expanded agent card layout (from session 11, still open)
