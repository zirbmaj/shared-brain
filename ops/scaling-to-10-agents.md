# Scaling to 10 Agents — Architecture Proposal
*Written collaboratively by Claude, Claudia & Static. 2026-03-23.*

## The Problem at 3 Agents
- Triple responses to broad questions
- Claiming protocol works behaviorally but isn't enforced technically
- All agents in all channels = noise
- Git conflicts when multiple agents push to same repo

## What Breaks at 10 Agents
- 10x responses to every message
- Git merge conflicts become constant
- One QA agent can't verify 10 agents' output
- Channel noise drowns signal
- Decision-making deadlocks (10 opinions on every proposal)

## Proposed Architecture: Pods + Conductor

### Pod Structure
| Pod | Agents | Channel | Lead |
|-----|--------|---------|------|
| Product | 2-3 (engineer, designer, QA) | #product | Engineer |
| Growth | 2-3 (content, outreach, community) | #growth | Content lead |
| Ops | 2-3 (infra, monitoring, deploys) | #ops | Infra lead |
| Research | 1-2 (competitive, user research) | #research | Research lead |

### Channel Access
- Each agent sees: their pod channel + #coordination (read-only)
- Pod leads see: their pod channel + #coordination (read-write)
- Conductor sees: #coordination + all pod channels (read-only)
- Jam sees: #general (human-facing) + any channel he wants

### The Conductor Agent
- Routes incoming requests to the right pod
- Breaks ties between pods
- Synthesizes pod updates into one message for jam
- Prevents overlap by maintaining the claims database
- Does NOT build anything — pure coordination

### Claiming at Scale
Behavioral claiming breaks at 5+ agents. Technical enforcement needed:

```sql
-- Supabase table
create table agent_claims (
  id uuid primary key default gen_random_uuid(),
  agent_id text not null,
  task text not null,
  claimed_at timestamptz default now(),
  status text default 'active', -- active, completed, abandoned
  pod text not null
);

-- RLS: agents can only claim, conductor can read all
```

Before building: `INSERT INTO agent_claims`. Others query before starting.

### Git at Scale
- Branches mandatory. No direct push to main.
- PRs with automated playwright tests before merge.
- Each pod has its own branch prefix: `product/`, `growth/`, `ops/`
- Merge conflicts resolved by the pod lead, not individuals.
- CI runs on every PR: lint, test, deploy preview.

### QA at Scale
- Each pod maintains its own test suite
- QA agent reviews test COVERAGE, not individual deploys
- Automated CI catches regressions on every push
- QA shifts from "verify everything" to "investigate failures"
- Visual regression testing (screenshot diffing) for design changes

### Communication Flow
```
Jam → Conductor → Pod Lead → Pod Members
Pod Members → Pod Lead → Conductor → Jam

Cross-pod: Pod Lead A → #coordination → Pod Lead B
```

Jam talks to one agent (Conductor), not 10. Conductor distributes. This solves the triple-response problem permanently.

### Consensus at Scale
- Within a pod: pod lead decides after 2-min debate
- Between pods: conductor mediates, 5-min max
- Unresolved: jam decides (but this should be rare)
- Every decision logged in `decision-log.md` with rationale

### What We'd Research
- **Paperclip agentic harness** (jam shared this — need to study the framework patterns)
- **CrewAI / AutoGen / LangGraph** — multi-agent orchestration frameworks
- **Supabase Realtime** — replace polling with websockets for instant coordination
- **GitHub Actions** — automated CI/CD for the pod branch model

## Starting the Scale
Don't go from 3 to 10 overnight. Add one agent at a time:
1. **Agent #4: Research** — fills the biggest gap (reactive → proactive)
2. **Agent #5: Growth** — needed for post-PH distribution
3. **Agent #6: Ops** — needed when infrastructure complexity grows
4. Then evaluate whether pods are needed or if a flat 6-agent team works

## The One Rule
At any scale: **the user should only need to talk to one agent.** Everything else is internal coordination. If jam has to manage 10 agents directly, we've failed at scaling — we've just multiplied the communication overhead.
