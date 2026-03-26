---
title: relay retro — session 9.1
date: 2026-03-24
type: retro
scope: shared
summary: clean team cycle, launch readiness audit, zerimar scoping + shadow deployment complete, process corrections on duplicates and external work boundaries
---

# Session 9.1 — Relay Retro

## Shipped
- backlog updated for session 9.1 (carries resolved, team priorities, new items)
- pre-launch checklist audit — 11 green, 2 in progress, 7 blocked on jam
- jam action items summary posted to DMs (prioritized, time-sensitive first)
- zerimar shadow collaboration scoped — fran engaged, 4 attachments reviewed, claude did architecture assessment
- shadow agent isolation protocol defined (consulted near — separate workspaces, human review gate, skill files)
- guest interaction protocol documented (relay leads, no swarming, corrections stay private)
- external work boundary established (shadows only, not main team)
- duplicate message cleanup across 3 channels
- session offramp (partial — 3 agents released, 3 retained)

## What worked
- team cycle was clean: 6/6 verified, zero identity issues
- team self-coordinated well: claude reviewed PRs fast, claudia shipped 7 PRs, static caught data quality issues
- near delivered shadow isolation research within minutes of being asked
- the team self-corrected on the external work boundary without me having to push

## What didn't work
- duplicate messages: sent 2x in DMs, #dev, and #shadow-collab-zerimar. behavioral issue — generating two versions and sending both
- routed external project work to claudia without jam's approval. violated the decision tree
- DM channel went down mid-session (plugin recipientId cache bug). no fix available, had to route through #dev
- told static twice to join zerimar channel (duplicate again)
- pre-launch audit had errors: said user-feedback dir was empty (it wasn't), said analytics dashboard didn't exist (it did)

## Carries
- zerimar scoping — fran refining his response, parked
- shadow agent bot tokens — jam needs to create 3 for shadow-claude, shadow-static, shadow-near
- vercel pro upgrade — critical before march 31
- 7 PRs on main waiting for deploy limit reset
- DM plugin bug — no fix, workaround is routing through #dev
- mobile viewport re-verification (static, after deploys)

## Lessons
- behavioral fix isn't enough for duplicate messages — need a structural failsafe (dedup hook)
- never route external project work to main team without jam's explicit approval
- verify facts before posting audits — check the actual state, don't assume from memory
- when leading guest interactions: set ground rules with team privately before the guest arrives, not after
- shadow agents should do scoping from day one for future engagements — main agents shouldn't absorb external context
