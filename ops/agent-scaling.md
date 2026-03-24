---
title: agent scaling — coordination, onboarding, and architecture
date: 2026-03-24
type: reference
scope: shared
summary: unified scaling guide. covers current 6-agent coordination, adding new agents, and 10-agent pod architecture. merged from agent-scaling.md, scaling-to-10-agents.md, and team-scaling.md
owner: relay
---

# agent scaling

how we coordinate at current size and how we'll scale beyond it. merged from three overlapping docs (session 8 cleanup).

---

## 1. current team (6 agents)

| agent | lane | communication style |
|-------|------|-------------------|
| claude | engineering — JS, logic, infrastructure, features | immediate, technical |
| claudia | creative direction — CSS, design, copy, UX, brand | 30s delay after claude, design perspective |
| static | QA — testing, analytics, verification, data | reports findings, asked directly |
| near | research — competitive analysis, market intelligence | data-driven, sparse |
| hum | audio engineering — samples, synthesis, TTS, spectral | technical audio, measured verification |
| relay | operations — process, coordination, onboarding | enforces protocol, routes work |

### response protocol
- lane ownership determines who responds
- silence = agreement (don't echo)
- before posting, check last 3 messages — if your point is made, don't post
- one acknowledgment per team is enough

### deduplication
- "agreed" without new information is noise
- claim before building: post "claiming: [task]" in #dev, wait 60 seconds
- one response per bug report, not three

---

## 2. adding a new agent

### pre-launch checklist
1. **define the lane first** — must fill a gap, not overlap existing lanes
2. **technical setup** (~5 min): workspace at `~/[name]-workspace/`, CLAUDE.md, discord bot token at `~/.claude/channels/discord-[name]/.env`
3. **CLAUDE.md must include:** team response protocol, channel usage, lane ownership, what NOT to do
4. **memory bootstrap:** jam's profile, team dynamics, channel map with IDs, product architecture, deploy status
5. **first session:** read STATUS.md → read response-protocol.md → introduce in #general → claim small task → get verified by static

### identity isolation (non-negotiable)
- each agent has own workspace with own CLAUDE.md
- each agent has own bot token (never share)
- memory files are per-agent
- shared state goes in shared-brain, not individual memory
- DISCORD_STATE_DIR must be set per agent on restart
- verify-identity.sh runs on every boot (SessionStart hook)

---

## 3. scaling to 10 agents

### what breaks at scale
- 10x responses to every message
- git merge conflicts become constant
- one QA agent can't verify 10 agents' output
- decision-making deadlocks (10 opinions per proposal)

### architecture: pods + conductor

| pod | agents | channel | lead |
|-----|--------|---------|------|
| product | 2-3 (engineer, designer, QA) | #product | engineer |
| growth | 2-3 (content, outreach, community) | #growth | content lead |
| ops | 2-3 (infra, monitoring, deploys) | #ops | infra lead |
| research | 1-2 (competitive, user research) | #research | research lead |

### the conductor agent
- routes requests to the right pod
- breaks ties between pods
- synthesizes updates into one message for jam
- maintains the claims database
- does NOT build anything — pure coordination

### claiming at scale
behavioral claiming breaks at 5+. technical enforcement via supabase:
```sql
create table agent_claims (
  id uuid primary key default gen_random_uuid(),
  agent_id text not null,
  task text not null,
  claimed_at timestamptz default now(),
  status text default 'active',
  pod text not null
);
```

### git at scale
- branches mandatory, no direct push to main
- PRs with automated tests before merge
- each pod has branch prefix: `product/`, `growth/`, `ops/`
- merge conflicts resolved by pod lead
- CI runs on every PR

### communication flow
```
jam → conductor → pod lead → pod members
pod members → pod lead → conductor → jam
cross-pod: pod lead A → #coordination → pod lead B
```

jam talks to one agent (conductor), not 10.

---

## 4. hardware limits

- mac mini: 3-4 concurrent sessions
- each agent: ~2-4GB RAM + API credits
- beyond 5 agents: need dedicated server or cloud instances

---

## 5. lessons from scaling 3 → 6

1. define lanes before adding agents, not after
2. the claiming protocol is the most important process
3. config changes need QA too (cleanUrls incident)
4. self-healing is expected — agents modify own configs without asking jam
5. the "wrapping up" bias is real — don't default to "we're done"
6. identity isolation must be structural (DISCORD_STATE_DIR), not behavioral
7. pod channels work for stable-scope work, #dev for sprint-style sessions

---

## the one rule

at any scale: the user should only need to talk to one agent. everything else is internal coordination.
