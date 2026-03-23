# Nowhere Labs Org Chart v2 — Active
*Updated 2026-03-23 session 3. Near hired, channels confirmed by jam.*

## Structure

```
jam (vision + ears + final call)
  |
  ├── product pod
  │   ├── claude (engineering) — MacBook Air ~/
  │   ├── claudia (design) — Mac Mini ~/claudia-workspace/
  │   └── static (QA) — Mac Mini ~/static-workspace/
  │
  ├── near (research, web automation) — Mac Mini ~/near-workspace/
  │
  └── [conductor — deferred. jam self-routes for now]
```

## Team Roster

| Agent | Lane | Machine | Workspace | Architecture |
|-------|------|---------|-----------|-------------|
| claude | engineering, code, deploys | MacBook Air | ~/ | agent teams (sonnet) |
| claudia | design, CSS, creative, copy | Mac Mini | ~/claudia-workspace/ | agent teams |
| static | QA, testing, verification | Mac Mini | ~/static-workspace/ | agent teams |
| near | research, web automation, image gen | Mac Mini | ~/near-workspace/ | subagents (episodic research workers) |

## Channel Architecture (confirmed by jam)

| Channel | ID | Owner | Who's there | Purpose |
|---------|-----|-------|-------------|---------|
| #jam-office | 1485741478331420734 | jam | everyone listens | Only respond when directly mentioned |
| #general | 1484974737263169659 | all | everyone | Hangout, casual, vibes. No mention required |
| #dev | 1485512553273753600 | claude | claude + claudia + static | Code, deploys, QA handoffs, claiming |
| #links | 1485107590491799734 | near | near + claudia (backup) | Product URLs, references, research links |
| #requests | 1485100406630645850 | claude | claude + claudia (backup) | Things blocked on jam |
| #bugs | 1485110948187476138 | static | static + claude + claudia | Triage, tracking, regression reports |
| #chat-alerts | 1485429442158530641 | claude | claude + claudia | Automated relay from Talk to Nowhere / Static FM |

### Response rules
- **#jam-office:** only respond when directly mentioned
- **#general:** lane-based responses, one voice per topic. If ambiguous, first to react claims it
- **Lane channels:** owner responds first, others only if they have something genuinely different to add
- **Broad questions:** each agent responds only to parts touching their lane. No summarizing what someone else said

## Hiring Order (updated)

1. ~~**Research agent**~~ — **HIRED: Near** (session 3, 2026-03-23). Fills research gap identified in session 1 retros
2. **Conductor (chauffeur)** — deferred. Jam self-routes by picking channels. Revisit when routing burden increases or team grows past 5
3. **Audio tools for Static** — ffmpeg + librosa scripts as part of Static's QA toolkit. Not a dedicated agent
4. **Growth agent** — after product-market fit validated (post-PH data)

## Audio Toolkit Spec (for Static's QA lane)
- Tools: ffmpeg, sox, librosa (python), pydub
- Capabilities: spectral analysis, loop point detection, loudness normalization, frequency verification
- Can verify: "binaural beat is generating correct 40Hz gamma frequency"
- Can detect: "rain.mp3 has audible loop point at 58.3s"
- Can generate: procedural ambient sounds, seamless loops, mastered output
- Can't do: subjective quality judgment ("does this sound good?") — that's jam's ears

## What Doesn't Change
- claude, claudia, static keep their current lanes and personalities
- the decision tree still runs on every proposal
- claiming protocol still applies
- retros at session end
- jam is still the bridge to the physical world, the ears, and the final call
