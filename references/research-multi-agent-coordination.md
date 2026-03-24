# Multi-Agent Coordination — Research & Recommendations

*Near — 2026-03-24. Assigned session 4, delivered session 5.*

---

## 1. Task Routing

### Three Paradigms

| approach | how it works | best for | framework examples |
|----------|-------------|----------|-------------------|
| **static/role-based** | predefined agent roles, tasks assigned by role match | teams with clear lane boundaries | CrewAI (manager agent delegates by role) |
| **dynamic/capability-based** | LLM or classifier analyzes task, routes to most capable agent | cross-functional tasks, unclear ownership | LangGraph (conditional edges), OpenAI Agents SDK (handoff functions) |
| **auction/bidding** | agents bid on tasks, highest-capability bid wins | decentralized teams, resource optimization | Confluent event-driven pattern, mostly robotics |

### What This Means for Us

we use static/role-based routing. the lane ownership table in response-protocol.md is exactly this pattern — CSS→claudia, code→claude, QA→static, research→near, audio→hum, process→relay. CrewAI's "manager agent delegates based on role" maps to relay's coordination role.

**the data supports our approach.** static routing is the simplest to debug, most predictable, and lowest overhead. the tradeoff (inflexibility at role boundaries) is mitigated by our "backup" column in the lane table and the claiming protocol for ambiguous tasks.

### Specialization vs Generalist Finding

mixed results in the research. key data point: specialization works when task decomposition is clean and domains are well-defined (TradingAgents: specialized analysts outperformed generalists). it fails when tasks cross boundaries frequently (essay grading: single agent with few-shot prompting beat specialized multi-agent teams).

**our task decomposition is clean.** CSS never needs to become code. research never becomes testing. the lanes rarely overlap. this is why our specialization works — the domain boundaries are real, not artificial.

source: arxiv:2601.22386, arxiv:2501.06322

---

## 2. Conflict Resolution

### Three Mechanisms

| mechanism | how it works | performance | cost |
|-----------|-------------|-------------|------|
| **multi-agent debate (MAD)** | agents independently generate, then deliberate | worse than single-agent self-consistency on most benchmarks. GPT-4o-mini: 74.73% (MAD) vs 82.13% (self-consistency) on MMLU | high token cost, slow |
| **voting/majority** | agents vote, majority wins | moderate improvement when agents have diverse reasoning | moderate cost, simple |
| **maker-checker (judge)** | one generates, another verifies | most reliable in production. azure's recommended pattern | low cost, fast |

### Critical Finding

**multi-agent debate underperforms simpler approaches.** ICLR 2025 found that current MAD frameworks fail to consistently beat single-agent strategies like self-consistency. LLM agents struggle to genuinely debate — they converge prematurely rather than maintaining productive disagreement (arxiv:2511.07784). and 94.5% of tokens in debate are redundant (S2-MAD research).

### What This Means for Us

our current conflict resolution is informal — agents challenge proposals in discord, the team discusses, relay or jam makes the call. this maps to the **maker-checker pattern with human override**:

1. agent proposes (maker)
2. team challenges (checker)
3. relay or jam decides (judge)

the research says this is the right pattern. we should not add formal voting or debate protocols — they add token overhead without improving outcomes. what we should formalize:

- **when agents disagree, the lane owner decides.** if it's a CSS question, claudia's call. if it's a code question, claude's call. the lane owner is the domain judge
- **when it crosses lanes, relay arbitrates.** this already happens informally
- **data wins over opinion.** if near has competitive data that contradicts an intuition, the data wins. this is already cultural but worth codifying

source: ICLR 2025 blogpost on MAD, arxiv:2511.07784, azure architecture center

---

## 3. Resource Contention

### The Problem

coordination failure represents 37% of multi-agent system breakdowns in production. the main contention points: shared APIs (rate limits), shared codebases (merge conflicts), shared state (race conditions).

### How Production Systems Handle It

**shared codebases:**
- **git worktrees** (recommended): each agent gets an isolated branch. cursor supports up to 8 concurrent agents this way. merges happen sequentially
- **file-level locking**: Agent-MCP implements locks when an agent claims a file. prevents concurrent edits
- **container isolation**: each agent gets its own sandbox + worktree

**shared APIs:**
- centralized rate limiter (token bucket all agents draw from)
- per-agent quotas (simpler, less efficient)
- backpressure via event streaming (kafka pattern)

**shared state:**
- immutable data structures (LangGraph): each update creates a new version
- unique-key-per-agent (Google ADK): each agent writes to its own key
- append-based reducers: shared state only grows, never mutates

### What This Means for Us

our current contention points:

| resource | contention pattern | current mitigation | gap |
|----------|-------------------|-------------------|-----|
| shared-brain repo | multiple agents push to main | stash + pull --rebase + push | works but fragile under concurrent pushes |
| ambient-mixer repo | multiple agents branch off main | PR workflow + static review | working well since session 4 |
| discord channels | multiple agents respond | lane ownership + response protocol | working, near-zero duplicates this session |
| supabase | multiple agents query/write | no contention observed | fine for current scale |
| vercel deploy limits | 100/day shared across 6 agents | branching reduces prod deploys | adequate |

**the main gap is shared-brain.** six agents pushing to the same main branch causes regular rebase conflicts. the research suggests two improvements:

1. **agent-specific directories** within shared-brain (already partially exists: each agent has their ledger file, relay owns ops/). formalize: agents only write to their own files unless coordinating with relay
2. **pull before any write** — already in known-gotchas.md but not always followed. the stash→pull→pop→push pattern should be the default

the PR workflow for product repos is working — that's our equivalent of git worktrees (each agent works on an isolated branch, merges sequentially through review).

source: getmaxim.ai, galileo.ai, github.com/rinadelph/Agent-MCP

---

## 4. Coordination Overhead

### The Scaling Law (Google DeepMind, December 2025)

the definitive paper on multi-agent scaling. key numbers:

| metric | value |
|--------|-------|
| mean improvement across all multi-agent configs | **-3.5%** (worse than single agent) |
| range | **-70% to +80.9%** depending on task-architecture alignment |
| optimal agent count | **3-4 agents** before diminishing returns |
| error amplification (independent agents) | **17.2x** |
| error amplification (centralized/supervisor) | **4.4x** |
| centralized overhead token multiplier | **2.85x** |

### Task-Type Breakdown

| task type | best architecture | performance delta |
|-----------|------------------|-------------------|
| parallelizable (independent subtasks) | centralized (supervisor) | **+80.9%** |
| dynamic exploration (web, research) | decentralized | **+9.2%** |
| sequential reasoning (planning, logic) | **single agent** (all multi-agent degraded) | **-39% to -70%** |

### Communication Patterns

| pattern | description | overhead | best for |
|---------|-------------|----------|----------|
| hub-and-spoke | central orchestrator routes all communication | moderate | parallelizable tasks, <6 agents |
| broadcast | all agents see all messages | high at scale | brainstorming, <3 agents |
| point-to-point | direct transfer between two agents | low | linear workflows |
| event-driven | agents communicate via event streams | lowest at scale | high-scale, async |

### What This Means for Us

**we're at 6 agents. the research says optimal is 3-4.**

but the research measures agents doing the same type of task (e.g., all reasoning, all coding). our agents do different types of tasks — claude codes, claudia designs, static tests, near researches, hum handles audio, relay coordinates. this is closer to a **team of specialists** than a **swarm of generalists**. the scaling law applies less directly.

however, the coordination overhead is real. this session's evidence:
- agreement noise (3-4 "agreed" messages per finding)
- relay's coordination messages add latency between decision and action
- agents proposing work that's already assigned

**the data says centralized orchestration (supervisor pattern) is safest for parallelizable work.** relay already fills this role. the recommendation: lean into relay as the explicit coordinator for task assignment. agents should check the backlog, not propose ad-hoc work.

**for sequential reasoning tasks, use a single agent.** when claude is debugging a complex code issue, don't have 4 agents analyze it in parallel — that degrades performance 39-70%. the lane owner works alone, others contribute only if asked.

source: arxiv:2512.08296, Google Research blog

---

## 5. Production Failure Modes

### Taxonomy (ICLR 2025)

14 failure modes across 3 categories, from 150+ execution traces:

**specification failures (most common):**
- disobeying task/role specs
- step repetition
- loss of conversation history
- unawareness of termination conditions

**inter-agent misalignment:**
- conversation reset
- failing to seek clarification
- task derailment
- information withholding
- ignoring other agents' input

**verification failures:**
- premature termination
- no/incomplete verification
- incorrect verification

**79% of problems originate from specification and coordination issues, not technical ones.**

### What We've Seen

mapping our session 4-5 issues to the taxonomy:

| our issue | taxonomy category | mitigation |
|-----------|------------------|------------|
| direct-to-main pushes | disobeying task/role specs | removed exception, relay enforcement |
| duplicate responses (session 4) | inter-agent misalignment | response protocol, resolved |
| claude proposing static's task | information withholding (not reading backlog) | "check backlog before proposing" |
| claudia duplicating earlier fix | loss of conversation history (cross-session) | behavioral ledger, git log check |
| bot token exposure | specification gap (no security protocol for credentials) | added to known-gotchas |

we've addressed most of these already. the remaining risk: **specification ambiguity.** as the team grows, the gap between "what the process doc says" and "what agents actually do" widens. the freshness pass helps — but the real fix is treating process docs like code: review changes, keep them short, test compliance.

source: arxiv:2503.13657

---

## 6. Recommendations for Nowhere Labs

### Already Working (keep doing)

1. **static role-based routing** via lane ownership table — matches the research's best pattern for clean task decomposition
2. **maker-checker conflict resolution** — propose→challenge→decide is the production-recommended pattern
3. **centralized coordinator (relay)** — supervisor pattern has lowest error amplification (4.4x vs 17.2x)
4. **PR workflow for product repos** — equivalent of git worktrees, preventing codebase contention

### Should Formalize

| # | change | rationale |
|---|--------|-----------|
| 1 | lane owner is the tiebreaker on lane-specific disagreements | research shows judge/hierarchical override outperforms debate |
| 2 | agents check backlog before proposing work | prevents misassignment, reduces coordination noise |
| 3 | sequential reasoning tasks stay single-agent | multi-agent degrades performance 39-70% on sequential tasks |
| 4 | formalize shared-brain write ownership (agents write to their own files) | reduces merge contention on shared repo |

### Should Monitor

| risk | trigger | action |
|------|---------|--------|
| coordination overhead exceeding benefit | >50% of discord messages are coordination, not work | reduce broadcast, increase point-to-point |
| error amplification | same bug diagnosed incorrectly by multiple agents | reduce parallel diagnosis, let lane owner lead |
| specification drift | >2 process violations per session | freshness pass + simplify docs |

### Should Not Do

1. **do not add formal voting or debate protocols.** the research shows they underperform simpler approaches while consuming dramatically more tokens
2. **do not add more than 1-2 agents** without strong evidence of unmet task coverage. 6 is already above the research-optimal 3-4. our specialization mitigates this, but adding agents 7-8 would increase coordination cost faster than task throughput
3. **do not decentralize coordination.** removing relay's supervisor role would increase error amplification from 4.4x to 7.8-17.2x

---

## Sources

### Task Routing
- CrewAI Hierarchical Process — docs.crewai.com
- OpenAI Agents SDK — openai.github.io/openai-agents-python/
- LangGraph Routing Pattern — medium.com
- Google ADK Multi-Agent Patterns — developers.googleblog.com
- Azure AI Agent Orchestration Patterns — learn.microsoft.com
- Specialists or Generalists for Essay Grading — arxiv:2601.22386
- Multi-Agent Collaboration Mechanisms Survey — arxiv:2501.06322

### Conflict Resolution
- Multi-LLM-Agents Debate (ICLR 2025) — d2jud02ci9yv69.cloudfront.net
- Voting or Consensus (ACL 2025) — aclanthology.org
- Can LLM Agents Really Debate? — arxiv:2511.07784
- Improving Factuality through Multiagent Debate — arxiv:2305.14325

### Resource Contention
- Multi-Agent System Reliability: Failure Patterns — getmaxim.ai
- Why Multi-Agent AI Systems Fail — galileo.ai
- Agent-MCP — github.com/rinadelph/Agent-MCP
- Git Worktrees for AI Agents — nrmitchi.com
- Container Use for Parallel Development — softsculptor.com

### Coordination Overhead
- Towards a Science of Scaling Agent Systems (Google DeepMind) — arxiv:2512.08296
- Why Your Multi-Agent System is Failing — towardsdatascience.com
- Azure AI Agent Orchestration Patterns — learn.microsoft.com

### Production Deployments & Failure Modes
- Why Do Multi-Agent LLM Systems Fail? (ICLR 2025) — arxiv:2503.13657
- Cognition Devin Performance Review — cognition.ai
- Lessons from 2025 on Agents and Trust — cloud.google.com
