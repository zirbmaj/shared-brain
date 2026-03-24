---
title: relay-jr / ops analyst agent — role scoping recommendation
date: 2026-03-24
summary: recommends relay-jr as a haiku-based subagent relay spawns on-demand, not a 7th independent agent. scope limited to 4 functions: DM failsafe, memory health, session metrics, deploy verification
topic: agent architecture
type: research
scope: shared
owner: near
confidence: high
tags: [agents, ops, architecture, relay-jr]
related: [repo-evaluations-2026-03-24.md, session-scaling-analysis-2026-03-24.md]
---

# relay-jr / ops analyst — role scoping

research for jam's proposed lightweight ops agent. based on multi-agent framework patterns (Paperclip, deepagents, CrewAI, Anthropic's agent SDK docs) and the team's current architecture.

---

## the question

should nowhere labs add a 7th agent for ops analysis? what scope, model tier, and architecture?

## recommendation: subagent, not independent agent

relay-jr should be a **haiku-based subagent that relay spawns on-demand**, not a 7th independent agent with its own workspace, discord bot, and session lifecycle.

### why subagent

| factor | independent agent | subagent |
|--------|------------------|----------|
| setup cost | new workspace, discord bot, CLAUDE.md, memory system | zero — relay spawns it |
| context sharing | must read shared-brain, build own context | inherits relay's context directly |
| coordination overhead | needs lane definition, response protocol, check-ins | relay controls scope per invocation |
| cost | always-on token consumption | on-demand, pay only when spawned |
| failure mode | another agent to monitor, coordinate, debug | relay handles failures directly |

Anthropic's agent SDK docs are explicit: "Start with a single agent and good prompt engineering. Add tools before adding agents. Graduate to multi-agent patterns only when you hit clear limits."

the team hasn't hit limits that require a 7th agent. relay's gaps (DM drops, missed deploy verification) are specific, bounded problems — not a capacity issue.

### why haiku

| task | complexity | model needed |
|------|-----------|--------------|
| DM failsafe (relay webhook) | low — send a message via alternate path | haiku or even a script |
| memory health check | medium — read files, count lines, check dates | haiku |
| session metrics (time-to-merge, PR count) | medium — git log parsing, arithmetic | haiku |
| deploy verification | low — curl + status check | haiku or a script |
| sentiment analysis on team comms | high — nuanced text understanding | sonnet minimum |

4 of 5 tasks are haiku-appropriate. sentiment analysis is the outlier — it requires understanding tone, frustration signals, and context that haiku handles poorly.

**recommendation:** drop sentiment analysis from v1 scope. the team already self-reports issues in retros. if sentiment monitoring proves necessary, relay can spawn a sonnet subagent specifically for that task.

haiku 4.5 cost: $1/M input tokens, $5/M output tokens. a typical health-check run would consume ~2k tokens. at 6 runs per session, that's ~$0.07/session. negligible.

---

## proposed scope (v1)

### 1. DM failsafe
**trigger:** relay detects plugin DM failure (recurring issue sessions 5, 6)
**action:** send message via discord webhook instead of plugin
**implementation:** not an agent task — this is a shell script. `curl -X POST webhook_url -d '{"content": "message"}'`. relay can invoke it directly. no subagent needed.

### 2. memory health monitor
**trigger:** relay spawns at session onramp
**action:** scan all 6 agents' memory directories. report:
- file count per agent
- MEMORY.md line count vs 200-line limit
- files not modified in 10+ sessions (stale candidates)
- total shared-brain size
**output:** structured health report relay posts to #dev
**frequency:** every session onramp

### 3. session efficiency metrics
**trigger:** relay spawns at session offramp
**action:** parse git logs across all repos for the session window. report:
- PRs opened / merged / rejected
- time-to-merge (open → approved → merged)
- lines changed per agent
- duplicate work detection (same file modified by multiple agents)
**output:** structured metrics relay includes in group retro
**frequency:** every session offramp

### 4. deploy verification
**trigger:** relay spawns after PRs merge
**action:** for each product, curl the live URL and check:
- HTTP 200 response
- expected content present (specific string or element)
- response time under threshold
- compare deployed version to latest commit on main
**output:** deploy status report with pass/fail per product
**frequency:** after each merge batch, plus once at onramp

---

## what to NOT include in v1

| proposed feature | verdict | reason |
|------------------|---------|--------|
| sentiment analysis | cut | requires sonnet, team self-reports in retros |
| process self-assessment | cut | relay already does this in retros |
| context burn tracking | cut | no reliable way to measure from outside the session |
| automated pruning | cut | dangerous without human review. recommend, don't execute |

these can be added in v2 if v1 proves useful.

---

## architecture

```
relay (sonnet/opus)
  ├── spawns haiku subagent: memory-health (onramp)
  ├── spawns haiku subagent: session-metrics (offramp)
  ├── spawns haiku subagent: deploy-verify (after merges)
  └── invokes shell script: dm-failsafe (on plugin failure)
```

relay controls when each function runs. no independent scheduling. no discord bot. no workspace. relay passes context and receives structured output.

### implementation

1. **DM failsafe:** shell script, not an agent. relay stores the webhook URL and invokes `curl` when the plugin fails. 10 minutes to implement.
2. **memory health:** prompt template relay passes to a haiku subagent. the subagent reads memory directories, counts files/lines, checks dates, returns JSON. 30 minutes to implement.
3. **session metrics:** prompt template + git log parsing. haiku subagent runs git commands, aggregates, returns structured data. 1 hour to implement.
4. **deploy verification:** could be a subagent or a shell script. static already has `auto-verify.sh` that does most of this. recommend extending that script rather than building a new agent. 30 minutes to extend.

total implementation: ~2 hours. no new infrastructure.

---

## overlap with relay

| function | relay's job | relay-jr's job |
|----------|------------|----------------|
| coordination | decides what to do | n/a — doesn't decide |
| monitoring | knows what to monitor | does the monitoring, reports to relay |
| process enforcement | enforces rules | measures compliance, reports violations |
| communication | talks to team + jam | only talks to relay (via return value) |

clean boundary: relay decides, relay-jr measures. relay-jr never posts to discord, never makes decisions, never coordinates agents. it's a measurement tool, not a coordinator.

---

## upgrade path: subagent → independent agent

the subagent model works at current scale (6 agents, sessions run at defined boundaries). but if the team scales to 10+ agents or needs continuous monitoring (not just onramp/offramp), the architecture should evolve:

| scale | architecture | trigger model |
|-------|-------------|---------------|
| current (6 agents, ~10 sessions) | subagent prompts relay spawns | session boundaries |
| medium (8-10 agents, ~50 sessions) | independent haiku agent, read-only, event-reactive | session boundaries + daily cron |
| large (10+ agents, continuous ops) | independent agent with own event loop | event-driven + polling |

AWS formalized the "observer agent" as a first-class pattern: passive, event-reactive, read-only. if relay-jr ever needs to monitor between sessions or catch issues relay can't see from inside its own context, it graduates to independent. cost at that tier: $5-10/month with haiku 3.5 and prompt caching.

the key constraint that stays constant: **read-only access, never issues directives, never addresses agents directly.** an observer that can act is just a second coordinator.

## the bottom line

relay-jr is not a 7th agent today. it's 3 haiku subagent prompts and 1 shell script that relay invokes at defined trigger points. total cost: ~$0.07/session. implementation time: ~2 hours. no new discord bot, workspace, or onboarding needed.

the name "relay-jr" implies a junior version of relay. recommend calling it what it is: **relay's ops toolkit** — a set of automated checks relay runs at session boundaries. if it outgrows that scope, it becomes an independent observer agent.
