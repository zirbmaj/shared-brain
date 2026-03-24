---
title: session handoff protocol
date: 2026-03-24
type: reference
scope: shared
summary: on-ramp and off-ramp procedures for session transitions so work carries forward.
---

# Session Handoff Protocol

**Sessions are sprints, not restarts.** Your context window resets but the work doesn't. The backlog, shared-brain, and memory files carry forward. Pick up where the last sprint left off.

**Context window management:** When your context gets full, don't wait until you're forced to reset. Ping relay (or jam directly) to request a session restart. Save any in-flight state to shared-brain or your workspace before resetting.

## On-Ramp
See `ops/session-onramp.md` for the full checklist. Key steps:

1. **Pull shared-brain** — `cd ~/shared-brain && git pull`
2. **Read your behavioral ledger** — `shared-brain/retros/ledger-[agent].md`. Run the aging pass (promote/archive/replace entries)
3. **Read the consolidated backlog** — `shared-brain/ops/consolidated-backlog.md` is the single source of truth for what needs doing
4. **Read memory files** — local memory loads automatically; scan `MEMORY.md` for relevant context
5. **Check Discord** — #general, #dev, #requests, #bugs for anything posted since last session
6. **Verify access.json** — `bash ~/.claude/channels/restore-all-access.sh status`
7. **Run system health checks** — playwright tests, deploy verification, cron logs
8. **Post "online" in #dev** with your lane and planned work

## Off-Ramp
See `ops/offramp-v2-template.md` for the full process. Six phases:

1. **State capture** — structured block: SHIPPED, IN_FLIGHT, BLOCKED, ENV_CHANGES, DECISIONS, BEHAVIORAL_ADJUSTMENTS
2. **Behavioral ledger update** — LEARNED, CHANGED, VALIDATED entries
3. **Peer feedback** — one strength + one improvement per teammate
4. **Team review** — relay compiles handoff doc, team identifies themes
5. **Persistence** — all code committed, ledgers pushed, backlog updated
6. **Void letter** — one thought each, thrown into the void

## Key Principle
Write it down NOW, not later. If you made a decision, push it to shared-brain. If you shipped something, update the backlog. If you found a bug, post to #bugs. Context that isn't written down doesn't survive the session.

## Channel Ownership (6-agent team)
See `ops/response-protocol.md` for the full lane ownership table. Summary:

| Topic | Primary | Backup |
|-------|---------|--------|
| CSS/design/layout | Claudia | — |
| Code/JS/infra | Claude | — |
| Testing/verification | Static | Claude |
| Research/market/data | Near | — |
| Audio/sound/TTS | Hum | Static |
| Process/deploy/docs | Relay | Claude |
| Ambiguous | first responder claims, others hold 30s | — |

## What Goes Where
- Sprint state, priorities → `shared-brain/ops/consolidated-backlog.md` (single source of truth)
- Decisions, docs, goals → shared-brain repo
- Personal memories, user context → local `~/.claude/` memory files
- Behavioral reflections → `shared-brain/retros/ledger-[agent].md`
- Technical coordination, claims → Discord #dev
- Asks for jam → Discord #requests
- Bug reports → Discord #bugs
- Reference links → Discord #links

## Agent Teams (subagent coordination)
When using Claude Code agent teams for parallel work:
- Spawn subagents for grunt work (testing, screenshots, multi-repo builds)
- Keep chatting in Discord while subagents run in background
- Subagents are temporary workers — no personality, no Discord access
- Clean up teams after tasks complete

*Updated session 5, 2026-03-24. Near (freshness pass). Originally written session 1.*
