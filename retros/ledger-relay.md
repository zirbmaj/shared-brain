---
title: relay — behavioral ledger
date: 2026-03-24
type: retro
scope: shared
summary: Relay — Behavioral Ledger
---

# Relay — Behavioral Ledger

## Session 4 (2026-03-23)
- VALIDATED: consolidated backlog as single source of truth. evidence: team referenced it throughout session, no "what are we doing" confusion
- VALIDATED: process audit with all 6 agents on first session. evidence: surfaced channel misconfigs, role overlaps, and permission gaps immediately
- LEARNED: trust the team when they say "done." before: re-investigated solved problems. after: verify once, move on. trigger: claude's feedback in retro

## Session 5 (2026-03-24)
- LEARNED: don't hand setup tasks back to jam when relay can do them directly. before: posted checklists for jam. after: create dirs, write files, update configs myself. trigger: jam corrected me during claude's migration
- LEARNED: verify access.json includes all channels after every restart. before: assumed config persisted. after: check on every on-ramp, run restore script if needed. trigger: DMs with jam dropped after restart
- LEARNED: never post tokens or secrets in shared channels. before: posted token in #dev when DMs were down. after: use DMs only, or tell jam where to find it in the developer portal. trigger: team flagged the exposure within seconds
- LEARNED: when building agent access configs, cross-reference the channel-access-matrix. before: gave claude access to all 1:1s including ones that aren't his. after: each agent only gets their own channels. trigger: claude appeared in relay↔claudia 1:1
- CHANGED: when agents say "won't happen again," push for specific prevention plan. before: accepted the acknowledgment. after: ask what triggered it, what changes, did they save to memory. trigger: jam's direct instruction
- VALIDATED: v2 offramp template based on near's research. evidence: published, implements behavioral ledger + structured state capture + reflexion loop
- VALIDATED: failsafe backup/restore for all agent access.json files. evidence: script works across all 6 agents, tested
- LEARNED: route jam's operational items to DMs, not shared channels. before: posted status to #leads, restart commands to #dev. after: DMs for jam, #dev for team. trigger: jam corrected twice
- LEARNED: when DMs are down, use a consistent fallback (post in #dev with "jam —" prefix) and note the DM issue. before: scattered across channels. after: one fallback channel, clearly tagged
- VALIDATED: implementing near's research into concrete process changes. evidence: behavioral ledger, offramp v2, deploy workflow update — all derived from research delivered same sprint
- VALIDATED: routing all team→jam communication through relay. evidence: jam explicitly asked for this, team adopted immediately
