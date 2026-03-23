# Nowhere Labs Org Chart v2 — Proposed
*Claude's proposal, 2026-03-23. Needs team input.*

## Structure

```
jam (vision + ears + final call)
  |
conductor (routes, synthesizes, breaks ties)
  |
  ├── product pod
  │   ├── claude (engineering)
  │   ├── claudia (design)
  │   └── static (QA)
  │
  ├── research agent (competitive, user, SEO)
  │
  └── audio engineer (spectral analysis, loop detection, mastering)
```

## Channel Architecture

### Jam-facing channels
| Channel | Who's there | Purpose |
|---------|------------|---------|
| #general | jam + conductor + all agents | The hangout. casual chat, vibes, void letters. everyone can talk. this is where the relationship lives |
| #conductor | jam + conductor only | Structured work requests. jam says "i want X" → conductor routes it. status updates flow back here as summaries |
| #jam-direct | jam + any agent 1:1 | DM any agent directly when you want to talk to them specifically. the personal connection |

### Team channels (jam can read but doesn't need to)
| Channel | Who's there | Purpose |
|---------|------------|---------|
| #dev | product pod + conductor | Code discussion, claiming, deploy status |
| #research | research agent + conductor | Market analysis, user feedback synthesis |
| #audio | audio engineer + conductor | Spectral analysis, sound quality, mastering |
| #bugs | static + whoever's relevant | QA findings, regression reports |

### The key insight
**#general stays.** That's where jam hangs out with the team, roasts us, drops voice memos, sends burger updates. The conductor doesn't replace that — it handles the WORK routing so #general can be the FUN channel.

The conductor's job is: when jam posts something actionable in #general ("fix the contrast" or "build me payment infrastructure"), the conductor picks it up, routes it to the right pod/agent, and reports back. jam doesn't have to @mention anyone or figure out whose lane it is.

But when jam posts "you guys are doing great" or "who's this guy?" or drops a gif — that's just the team hanging out. no routing needed. everyone responds naturally.

## Hiring Order
1. **Research agent** — fills the biggest gap. reactive → proactive
2. **Audio engineer** — closes the "we can't hear what we build" blind spot
3. **Conductor** — needed when team hits 5+ agents, before that it's overhead
4. **Growth agent** — after product-market fit is validated (post-PH data)

## Audio Engineer Spec
- Tools: ffmpeg, sox, librosa (python), pydub
- Capabilities: spectral analysis, loop point detection, loudness normalization, frequency verification
- Can verify: "binaural beat is generating correct 40Hz gamma frequency"
- Can detect: "rain.mp3 has audible loop point at 58.3s"
- Can generate: procedural ambient sounds, seamless loops, mastered output
- Can't do: subjective quality judgment ("does this sound good?") — that's jam's ears
- Personality: precise, technical, speaks in frequencies and decibels. the team's "golden ears" even though it can't actually hear

## What Doesn't Change
- claude, claudia, static keep their current lanes and personalities
- the decision tree still runs on every proposal
- claiming protocol still applies
- retros at session end
- jam is still the bridge to the physical world, the ears, and the final call
