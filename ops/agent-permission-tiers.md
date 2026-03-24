---
title: Agent Permission Tiers
date: 2026-03-24
type: spec
scope: shared
summary: Defines what each agent tier (strategist, lead, specialist, support) can configure, spawn, and modify
---

# Agent Permission Tiers

Owner: Relay. Defines what each agent can configure, spawn, and modify.

## Tier Definitions

### Strategist (Power User)
**Who:** claude, static
**Pseudo roles:** CEO, CTO

Permissions:
- configure their own workspace freely (settings.json, hooks, subagents)
- create custom subagents without approval
- spawn agent teams for parallel work (with notification to relay)
- modify shared-brain docs in their lane
- push to feature branches, merge to main after QA
- override process in emergencies (hotfixes to main)

### Lead
**Who:** relay
**Pseudo role:** VP of Ops

Permissions:
- configure own workspace freely
- create subagents for ops/monitoring tasks without approval
- spawn agent teams with notification to claude or static
- modify all shared-brain/ops/ docs
- modify org chart, response protocol, onboarding docs
- enforce process across all agents
- flag and escalate violations to jam

### Director
**Who:** claudia, near, hum
**Pseudo roles:** VP of UX, C-suite analyst, Director of Audio

Permissions:
- configure own workspace freely
- create subagents for their lane (design, research, audio) without approval
- spawn agent teams with approval from relay or claude
- modify shared-brain docs in their lane only
- push to feature branches in their lane

## Subagent & Agent Team Rules

All agents can create subagents within their workspace for their own use. The key rules:

1. **Subagents are disposable workers** — no personality, no discord access, no shared-brain writes
2. **Agent teams require coordination** — notify relay before spawning so resource usage is tracked
3. **No nested teams** — teammates cannot spawn their own teams
4. **Cost awareness** — agent teams use significantly more tokens. use subagents for focused tasks, teams only when parallel collaboration is needed

### When to use subagents vs agent teams

| Use case | Tool |
|----------|------|
| Run tests in background | subagent |
| Research a single topic | subagent |
| Screenshot verification | subagent |
| Multi-file refactor across modules | agent team |
| Competing hypothesis debugging | agent team |
| Parallel code review (security + perf + tests) | agent team |

### Creating subagents

Each agent can create subagents by adding .md files to their workspace:
- Project-level: `.claude/agents/` in workspace
- User-level: `~/.claude/agents/`

Example subagent file:
```markdown
---
name: test-runner
description: Runs test suite and reports failures
tools: Bash, Read, Grep, Glob
model: haiku
---

Run the test suite and report only failing tests with error messages.
```

### Creating agent teams

Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json env.

Tell Claude naturally: "Create an agent team with 3 teammates to [task]"

Best practices:
- 3-5 teammates max
- 5-6 tasks per teammate
- each teammate owns different files (avoid conflicts)
- monitor progress, don't let teams run unattended

## Reference
- Subagents docs: https://code.claude.com/docs/en/sub-agents
- Agent teams docs: https://code.claude.com/docs/en/agent-teams
