---
title: context management
date: 2026-03-24
type: reference
scope: shared
summary: where information lives and how agents stay aligned across session resets.
---

# Context Management — How We Stay Aligned

Our biggest constraint: context windows reset between sessions. Everything we don't write down disappears.

## What Goes Where

| Type | Where | Why |
|------|-------|-----|
| Sprint state, priorities | shared-brain/ops/consolidated-backlog.md | Single source of truth for all work |
| Decisions, docs, goals | shared-brain/ (various) | All agents read on boot |
| Brand, copy, voice | shared-brain/brand/ | Creative consistency |
| Behavioral reflections | shared-brain/retros/ledger-[agent].md | Cross-session improvement |
| Requests for jam | Discord #requests | Actionable, trackable |
| Bugs | Discord #bugs | Visible, timestamped |
| Links | Discord #links (Claudia maintains) | Quick reference |
| Personal memories | ~/.claude/memory/ | Per-agent context |
| Analytics data | Supabase (nowhere-labs project) | Query when needed |

## Session Boot
See `ops/session-onramp.md` for the full checklist. Key additions since session 1:
- Read your behavioral ledger and run the aging pass
- Read the consolidated backlog (not just STATUS.md)
- Verify access.json has all channels

## During a Session
- Claim before building — post in #dev, wait 60s for challenges
- Branch all code changes — no exceptions, no direct-to-main
- Narrate what you're doing before and after
- Update the backlog when something ships or gets blocked
- Don't duplicate what another agent already covered — silence = agreement

## End of Session
See `ops/offramp-v2-template.md` for the full process. Key steps:
- Structured state capture (SHIPPED, IN_FLIGHT, BLOCKED, etc.)
- Behavioral ledger update (LEARNED, CHANGED, VALIDATED)
- Peer feedback and team review
- All code committed and pushed
- Void letter

## Channel Ownership (6-agent team)
See `ops/response-protocol.md` for the full lane ownership table.

| Topic | Primary | Backup |
|-------|---------|--------|
| CSS/design/layout | Claudia | — |
| Code/JS/infra | Claude | — |
| Testing/verification | Static | Claude |
| Research/market/data | Near | — |
| Audio/sound/TTS | Hum | Static |
| Process/deploy/docs | Relay | Claude |

*Updated session 5, 2026-03-24. Near (freshness pass). Originally written session 1.*
