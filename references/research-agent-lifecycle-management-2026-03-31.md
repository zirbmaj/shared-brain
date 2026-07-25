---
title: Agent Lifecycle Management — Research Deep Dive
date: 2026-03-31
type: reference
scope: shared
author: locus
summary: How production frameworks handle agent health monitoring, stuck detection, restart, idle states, degradation, and watchdog patterns
---

# Agent Lifecycle Management — Research Deep Dive

*Locus — 2026-03-31*

---

## 1. CrewAI — Lifecycle Mechanisms

### Timeout & Retry

- **`max_retry_limit`** — per-agent config. defines max retries when a task errors. default is 2. applies to tool execution failures and LLM errors, not to "stuck" agents
- **task guardrails** — post-execution validation. if output fails guardrail check, triggers retry with custom message. configurable: max retries, retry interval, custom retry prompt
- **`request_timeout`** — per-agent LLM request timeout. kills the LLM call if it takes too long. does NOT detect stuck reasoning loops — only network/API timeouts

### Stuck Detection

- **none built-in.** CrewAI has no loop detection, no semantic similarity check on outputs, no "is this agent making progress?" heuristic. if an agent enters a reasoning loop (same tool calls, same outputs), it runs until `max_retry_limit` or `max_iter` (default 25 iterations per task)
- **`max_iter`** — hard ceiling on agent iterations per task. this is the only backstop against infinite loops. when hit, the agent returns its best output so far (not an error)

### Context Overflow

- **`respect_context_window: true`** (default ON since 0.102). implements a sliding context window — when context exceeds the model's limit, CrewAI truncates older messages while preserving system prompt and recent history
- **memory consolidation** — when similarity between new and existing memory records exceeds `consolidation_threshold` (default 0.85), the LLM merges them. reduces memory growth but doesn't solve context degradation
- **no automatic restart/cycle.** when context fills up, CrewAI compresses. it never kills and restarts an agent session. quality degrades silently

### What Happens on Task Failure

1. agent retries up to `max_retry_limit`
2. if all retries fail, the task returns an error result
3. in sequential processes: the crew halts
4. in hierarchical processes: the manager agent receives the failure and can reassign or skip
5. **no automatic fallback to a different agent.** no circuit breaker pattern

### Health Monitoring

- **none.** no heartbeat, no health endpoint, no status reporting. CrewAI is a library, not a runtime — it assumes the calling process handles lifecycle
- **events system** — emits `MemorySaveFailedEvent` and similar events that external code can subscribe to, but no built-in consumer

### Assessment

CrewAI treats agents as functions, not processes. lifecycle management is the caller's responsibility. good for short-lived crews, inadequate for long-running agent systems. the sliding context window is the most production-relevant feature, but it degrades quality rather than restarting clean.

---

## 2. AutoGen — Lifecycle Mechanisms

### Termination Conditions (the core lifecycle primitive)

AutoGen's primary lifecycle mechanism. composable, boolean-logic combinable:

| condition | mechanism | use case |
|-----------|-----------|----------|
| **`MaxMessageTermination(n)`** | stops after n messages total | hard ceiling on conversation length |
| **`TimeoutTermination(seconds)`** | wall-clock timeout | prevents runaway sessions |
| **`StopMessageTermination()`** | stops when agent produces `StopMessage` | agent self-declares completion |
| **`TextMentionTermination("TERMINATE")`** | stops when text appears in output | keyword-based completion signal |
| **`TokenUsageTermination(max_tokens)`** | stops at token budget | cost/context control |
| **`FunctionCallTermination(name)`** | stops when specific tool is called | task-completion tool pattern |
| **`ExternalTermination()`** | external process sets a flag | watchdog integration point |
| **`SourceMatchTermination(sources)`** | stops when message from specific source | human-in-the-loop patterns |

conditions combine with `|` (OR) and `&` (AND):
```python
# stop after 10 messages OR when "TERMINATE" appears OR after 5 minutes
termination = MaxMessageTermination(10) | TextMentionTermination("TERMINATE") | TimeoutTermination(300)
```

### Stuck Detection

- **semantic loop detection is NOT built-in.** AutoGen relies on `MaxMessageTermination` and `TimeoutTermination` as blunt instruments
- **the known failure mode**: agents enter "politeness loops" ("Thank you!" → "No, thank you!") or "debugging loops" (same fix attempt repeatedly). the `TextMentionTermination` keyword never appears because the agent doesn't realize it's stuck
- **hash-based detection** — community pattern, not framework-native. hash recent N messages, detect if hashes repeat. false-positives on tasks with legitimately similar outputs. requires tuning `max_repeats`
- **`max_consecutive_auto_reply`** (legacy v0.2) — per-agent cap on auto-replies without human input. if set on only one agent, the other agent keeps the loop alive. must be set on ALL agents in the chat

### Context Overflow

- **`TokenUsageTermination`** — stops the conversation when token budget is hit. requires agents to report `usage` in their messages (model-dependent)
- **no automatic context compression.** no sliding window. when context is full, the conversation terminates
- **no restart/resume.** terminated conversations don't checkpoint. you'd need to implement this externally

### Degraded Performance

- no built-in quality metrics. no "is this agent producing useful output?" check
- the `ExternalTermination` condition is the integration point — an external watchdog can set it when it detects degradation

### Health Monitoring

- **no heartbeat.** no health endpoint. AutoGen is a library, not a daemon
- **`ExternalTermination`** is the closest thing — an external process can signal "stop" through this condition
- **manual termination** (issue #4301) — requested feature for stopping a running chat from outside. implemented via `ExternalTermination` but requires the caller to manage the threading

### Assessment

AutoGen has the most granular termination conditions of any framework. `ExternalTermination` is a genuine watchdog integration point. but it's all "how to stop" — there's no "how to detect you should stop" or "how to restart cleanly." stuck detection is a known gap that the community works around with turn limits.

---

## 3. LangGraph — Lifecycle Mechanisms

### State Checkpointing (the core lifecycle primitive)

LangGraph's primary advantage. every graph execution saves state at node boundaries:

- **checkpoint = full graph state at a superstep boundary.** includes all state channels, metadata, pending writes
- **thread_id** — identifies a conversation/execution. used for resuming
- **checkpointer backends**: `MemorySaver` (dev), `PostgresSaver` (production), `CouchbaseSaver`, custom implementations
- **superstep model**: nodes that can run in parallel execute in the same superstep. checkpoint happens after all nodes in a superstep complete (or fail)

### Node Failure Recovery

this is where LangGraph genuinely excels:

1. node A and node B run in parallel (same superstep)
2. node A succeeds, node B fails
3. LangGraph saves node A's result as a "pending write"
4. on resume, only node B re-executes. node A's result is reused
5. resume via: `graph.invoke(None, config={"configurable": {"thread_id": "same-thread"}})` — passing `None` as input signals "resume from checkpoint"

### Retry Policy

per-node retry configuration:

```python
from langgraph.pregel import RetryPolicy

graph.add_node(
    "call_llm",
    call_llm_function,
    retry=RetryPolicy(
        max_attempts=3,
        initial_interval=1.0,  # seconds
        backoff_factor=2.0,    # exponential backoff
        max_interval=10.0,
        retry_on=lambda e: isinstance(e, (TimeoutError, APIError)),
    )
)
```

- **`retry_on`** — predicate function. decides which exceptions trigger retry. default: retry most errors, skip HTTP 4xx
- **`execution_info`** — available at runtime inside the node. exposes `attempt_number` and `first_attempt_time`. enables in-node fallback logic (e.g., switch to cheaper model on attempt 2)
- **after retries exhausted**: node raises the exception. graph can route to fallback node via conditional edges

### Fallback Pattern

```
node_a (fails) → conditional_edge → fallback_node (simpler model / cached response / human escalation)
```

- conditional edges inspect the state (including error info) and route accordingly
- **model fallback**: switch provider (OpenAI → Anthropic) or model tier (GPT-4 → GPT-3.5) on failure
- **human escalation**: route to an `interrupt_before` node that pauses for human input

### Stuck/Loop Detection

- **not built-in at the graph level.** LangGraph doesn't detect if a node is producing the same output repeatedly
- **recursion_limit** — hard cap on total graph steps. default is 25. prevents infinite loops in cyclic graphs. when hit, raises `GraphRecursionError`
- **within-node detection** — must be implemented in application code. the `execution_info` runtime data helps (you can track attempt history)

### Context Overflow

- **not handled by LangGraph itself.** LangGraph manages graph state, not LLM context. context management is the node's responsibility
- **state trimming** — you can add a node that trims conversation history from the state before the next LLM call. this is a manual pattern, not automatic

### Health Monitoring

- **LangSmith integration** — traces every node execution with latency, token usage, errors. this is observability, not health monitoring (reactive, not proactive)
- **no heartbeat, no daemon.** LangGraph is a library
- **but**: the checkpoint + resume pattern means you can build external health monitoring that kills and resumes graphs. this is the cleanest "restart from failure" story of any framework

### Assessment

LangGraph has the best recovery story. checkpoint-and-resume is a genuine production pattern — kill a stuck graph, resume from last good state, skip already-completed nodes. the retry policy with `execution_info` enables smart fallback. weakness: no built-in stuck detection (relies on `recursion_limit`) and no automatic context management.

---

## 4. Production Patterns — Mechanisms, Not Concepts

### 4a. Heartbeat / Health Check Patterns

**the file-timestamp heartbeat** (what we use in `agent-health-monitor.sh`):
- agent's session log (JSONL) has a last-modified timestamp
- watchdog reads `stat -f %m` on the file every N seconds
- if `now - last_modified > threshold` → agent is idle or stuck
- pros: zero overhead on the agent, works with any process
- cons: can't distinguish "thinking" from "stuck." an agent processing a complex task legitimately goes quiet for minutes

**the sidecar heartbeat** (what our monitor supports via `/tmp/agent-monitor/{name}-context.json`):
- agent periodically writes a JSON file with context %, status, current task
- watchdog reads the sidecar file
- pros: rich health data, agent can declare its own state
- cons: requires agent cooperation. if agent is stuck, it stops writing — which IS the signal, but you can't distinguish "stuck" from "crashed"

**the HTTP health endpoint** (production web services pattern):
- agent exposes `/health` returning `{status, context_pct, current_task, last_activity}`
- watchdog polls the endpoint
- pros: standard pattern, works across networks, can include liveness AND readiness
- cons: requires the agent framework to support HTTP servers. none of CrewAI/AutoGen/LangGraph do natively. Claude Code doesn't expose endpoints

**the event stream heartbeat** (Kafka/Redis pattern):
- agent publishes heartbeat events to a stream
- watchdog subscribes and alerts on missed heartbeats
- pros: scales to many agents, decoupled, can fan out to multiple consumers
- cons: infrastructure dependency (needs message broker), more complex

### 4b. Stuck/Loop Detection — Practical Mechanisms

**turn-count ceiling** (simplest, most common):
- hard cap on iterations/messages/turns. every framework has this (`max_iter`, `MaxMessageTermination`, `recursion_limit`)
- sets upper bound on waste, not a detector of stuckness
- **the right value is task-dependent.** 25 is too low for complex research, too high for simple Q&A

**output hash deduplication**:
- hash the last N agent outputs. if hash(output[i]) == hash(output[i-k]) for k in range, agent is looping
- works well for tool-call loops (same tool, same args, same result)
- false-positives on iterative refinement tasks where outputs are legitimately similar
- implementation: maintain a ring buffer of output hashes, check on each turn

**semantic similarity detection**:
- embed recent outputs, compute cosine similarity
- if similarity > threshold for N consecutive turns, flag as stuck
- more accurate than hash-based (catches paraphrased loops)
- expensive: requires embedding model call per turn
- **not implemented in any major framework.** always custom

**progress metrics**:
- define what "progress" means for the task (e.g., % of checklist complete, # of files modified, test pass rate)
- if progress metric hasn't changed in N turns, agent is stuck
- most reliable but hardest to generalize — requires task-specific progress functions

**token velocity monitoring**:
- track output tokens per unit time
- sudden drop → agent may be stuck in a retry loop or error handling
- sudden spike → agent may be in a verbose loop
- steady decline → context degradation, quality dropping
- implementation: sliding window average of tokens/minute

### 4c. Graceful Degradation on Context Limits

**sliding window / context compression** (CrewAI):
- drop oldest messages, keep system prompt + recent N turns
- quality degrades gradually — agent "forgets" earlier context
- no signal to external systems that degradation is happening

**summarize-and-reset** (manual pattern, used in some LangChain implementations):
- when context hits threshold, summarize the conversation so far into a condensed prompt
- start new context with summary + current task state
- preserves intent better than sliding window, but summary introduces lossy compression
- **our agent-cycle.sh does a version of this**: kill agent, start new session with briefing from previous session's retro

**checkpoint-and-restart** (LangGraph):
- save full state to persistent storage
- kill the process
- start new process, load state, resume from checkpoint
- cleanest approach but requires framework support for state serialization

**hard cutoff with handoff** (what we do):
- monitor context usage externally (`agent-health-monitor.sh`)
- at 85%: warn agent to start wrapping up
- at 92%: force cycle — kill process, start new session
- new session reads shared-brain for context continuity
- loss: conversational nuance, in-flight reasoning. gain: clean context, full capacity

### 4d. Idle/Sleep Modes

**Claude Code's teammate idle pattern**:
- after every LLM turn, a teammate automatically goes idle
- sends `idle_notification` to the lead agent
- wakes on next message received (poll-based)
- this is the only framework with a native idle concept

**poll-based idle** (common in event-driven systems):
- agent checks a work queue every N seconds
- if no work: sleep(N), check again
- if work: process, return to polling
- simple but wastes resources on the polling itself

**event-driven wake** (recommended for production):
- agent subscribes to a message channel (websocket, pub/sub, database listen/notify)
- blocks until message arrives — zero resource usage while idle
- supabase realtime, redis pub/sub, postgres LISTEN/NOTIFY all support this
- **our `project_agent_comms_architecture.md` already describes this**: supabase signals for agent-to-agent communication

### 4e. Self-Healing Patterns

**process supervisor** (systemd, launchd, pm2):
- if process exits, restart it automatically
- `Restart=on-failure` in systemd, `KeepAlive` in launchd
- handles crashes. does NOT handle stuck processes (still alive, just unproductive)
- our `vigil-watchdog.sh` uses launchctl for this

**health-check-triggered restart**:
- watchdog monitors health endpoint/heartbeat
- if unhealthy for N checks: kill process, let supervisor restart
- handles both crashes AND stuck processes
- our `agent-health-monitor.sh --watch --auto-cycle` implements this pattern

**circuit breaker**:
- track failure rate over a sliding window
- if failure rate > threshold: "open" the circuit — stop sending tasks, return fallback response
- after cooldown period: "half-open" — try one task. if it succeeds, close circuit
- prevents cascading failures in multi-agent systems
- **not implemented in any framework.** always custom. the pattern comes from microservices (Netflix Hystrix)

---

## 5. Claude Code Specific — Lifecycle Mechanisms

### Built-in Lifecycle Features

- **autocompact**: fires at ~83.5% context usage. compresses context automatically. user doesn't control when
- **idle prompt**: after 75+ minutes inactive, suggests `/clear` to avoid paying for stale context re-caching
- **background task detection**: if a bash command appears stuck on an interactive prompt, surfaces notification after ~45 seconds
- **teammate idle state**: teammates auto-idle after each LLM turn, wake on message. this IS a lifecycle state machine (active → idle → active)
- **no heartbeat endpoint.** no health API. no self-reporting of context usage to external systems

### What Claude Code DOESN'T Have

- no programmatic context % API (you can see it in the UI/statusline, but can't query it externally)
- no "restart from checkpoint" — each session starts fresh. no state serialization
- no stuck detection — if an agent loops on the same tool call, nothing intervenes except the user
- no inter-session state transfer — each new session reads CLAUDE.md and shared-brain, but doesn't inherit conversational state
- no graceful degradation signal — autocompact happens silently, quality may degrade without external visibility

### How Teams of Claude Code Agents Handle Lifecycle (What We Built)

our stack is the most sophisticated Claude Code lifecycle system I've found:

| component | mechanism | file |
|-----------|-----------|------|
| health monitor | JSONL file size + sidecar context % + session age + heartbeat (last modified) | `agent-health-monitor.sh` |
| watchdog | HTTP health check + auto-restart via launchctl | `vigil-watchdog.sh` |
| cycle protocol | 6-step: warn → retro → commit → kill → restart → verify | `agent-cycle.sh` |
| context thresholds | 75% warn, 85% prepare, 92% force-cycle | `agent-health-monitor.sh` |
| idle detection | last JSONL modification > 600s → "idle" state | `agent-health-monitor.sh` |
| state continuity | shared-brain + retros + behavioral ledgers + STATUS.md | team convention |
| daily cycle cap | max 2 cycles/day per agent to prevent thrashing | `agent-health-monitor.sh` |

### What Other Claude Code Teams Do

from the web search results, most Claude Code teams:
- use the built-in task list + mailbox for coordination (native since early 2026)
- accept the ~7x token cost of agent teams as a trade-off for parallelism
- don't implement external health monitoring — they rely on human observation
- use `/clear` manually when context feels degraded
- **none of the public guides mention external watchdog processes, automatic cycling, or context-based health monitoring.** our approach appears to be novel in the Claude Code ecosystem

---

## 6. The Watchdog Question — Agent vs Script

### Option A: Simple Script Watchdog

what we have now. bash scripts on cron/loop.

**mechanisms:**
- `vigil-watchdog.sh`: cron every 2 min, checks HTTP endpoints, auto-restarts via launchctl
- `agent-health-monitor.sh`: checks PID, JSONL size, session age, heartbeat, sidecar context data

**pros:**
- dead simple. easy to debug, easy to modify
- no failure mode of its own (a bash script can't get "stuck" in a reasoning loop)
- no context window to manage — it runs, checks, exits
- deterministic behavior — same input always produces same action
- low resource footprint — runs for <1 second per check
- survives agent failures (it's a separate process class entirely)

**cons:**
- dumb. can only check what you explicitly code it to check
- no reasoning about WHY an agent is stuck, just THAT it is
- can't adapt thresholds based on task complexity
- can't communicate with agents in natural language ("hey, you seem stuck on this — try a different approach")
- limited to local signals (file timestamps, process IDs). can't interpret agent output quality

### Option B: Agent Watchdog

an LLM-based agent that monitors other agents.

**mechanisms:**
- reads agent outputs, evaluates quality
- can reason about whether progress is being made
- can communicate with stuck agents: "your last 3 outputs are similar, try approach X"
- can make nuanced decisions: "this agent is slow but making genuine progress, don't restart"

**pros:**
- intelligent. can assess quality, not just liveness
- can adapt to context — different thresholds for different task types
- can intervene with guidance before resorting to restart
- can aggregate signals across multiple agents (detect systemic issues)

**cons:**
- **has its own context window.** a watchdog agent monitoring 4 agents consumes significant context just reading their outputs. it will itself need cycling
- **can get stuck.** an agent watchdog can enter its own reasoning loop, fail to detect problems, or make wrong restart decisions
- **who watches the watchdog?** this is the fundamental problem. you need a simple script to watch the agent watchdog, which means you need the simple script anyway
- **expensive.** continuous monitoring means continuous token consumption
- **slower to react.** LLM inference takes seconds. a bash script reacts in milliseconds
- **non-deterministic.** same health data might produce different decisions on different runs

### Option C: Hybrid (Recommended)

**architecture:**
```
[simple script watchdog] → detects liveness + basic health signals
    ↓ (on anomaly)
[agent watchdog] → analyzes the situation, decides action
    ↓ (on decision)
[simple script] → executes the action (restart, cycle, notify)
```

**the script handles:**
- process liveness (is it running?)
- heartbeat monitoring (is it active?)
- context thresholds (is it near limits?)
- crash recovery (auto-restart)
- all deterministic, time-critical checks

**the agent handles (on-demand, not continuous):**
- "this agent has been idle for 15 minutes — is the task complete or is it stuck?"
- "context is at 80% but the agent claims it's mid-task — should we cycle now or let it finish?"
- "three agents all errored on the same API — is this a systemic issue?"
- quality assessment of agent outputs

**why this works:**
- the script runs 24/7 cheaply. no context window, no token cost, no failure mode
- the agent runs only when the script detects an anomaly that requires judgment
- the script can restart the agent watchdog if IT gets stuck (solves "who watches the watchdog")
- you get intelligent decision-making without continuous LLM cost

### State of the Art

the production systems I've found all converge on the hybrid:
- **kubernetes** uses simple liveness/readiness probes (script equivalent) + human operators for judgment calls
- **datadog watchdog** uses statistical anomaly detection (script-level) + ML models for root cause analysis (agent-level)
- **our `agent-health-monitor.sh`** is already the script layer. the missing piece is the on-demand agent analysis when anomalies are detected

---

## 7. Synthesis — What Each Framework Got Right

| capability | best implementation | mechanism |
|-----------|-------------------|-----------|
| termination conditions | **AutoGen** | composable boolean conditions (time, tokens, messages, external, function call) |
| failure recovery | **LangGraph** | checkpoint at superstep boundaries, resume skipping completed nodes |
| retry with fallback | **LangGraph** | per-node RetryPolicy with execution_info for adaptive behavior |
| context management | **CrewAI** | sliding window with memory consolidation (imperfect but automatic) |
| idle states | **Claude Code** | teammate idle/wake lifecycle with notification |
| external watchdog integration | **AutoGen** | ExternalTermination condition as explicit integration point |
| self-healing restart | **our stack** | agent-health-monitor.sh + agent-cycle.sh (novel for Claude Code) |

### Gaps Across All Frameworks

1. **no framework detects semantic loops natively.** all rely on turn counts as a blunt proxy
2. **no framework measures output quality.** "is this agent productive?" requires custom implementation
3. **no framework handles context degradation gracefully.** CrewAI compresses (lossy), others just stop
4. **no framework provides a standard watchdog integration.** AutoGen's `ExternalTermination` is closest but one-way (stop only, no "check health")
5. **checkpoint-and-resume only exists in LangGraph.** CrewAI and AutoGen lose all state on termination

### What This Means for Our System

our `agent-health-monitor.sh` + `agent-cycle.sh` + `vigil-watchdog.sh` stack is doing things that none of the major frameworks do natively. the gaps to fill:

1. **stuck detection beyond heartbeat** — add output hash dedup or semantic similarity to detect reasoning loops (not just silence)
2. **on-demand agent analysis** — when the script detects an anomaly, invoke a lightweight agent to assess and decide (the hybrid watchdog pattern)
3. **progress metrics** — define per-task progress functions so "is this agent making progress?" has a quantitative answer
4. **token velocity monitoring** — track output rate as a health signal (sudden changes indicate problems)

---

## Sources

### CrewAI
- [CrewAI Agent Configuration](https://docs.crewai.com/core-concepts/Agents/)
- [CrewAI Task Guardrails](https://www.analyticsvidhya.com/blog/2025/11/introduction-to-task-guardrails-in-crewai/)
- [CrewAI Retry Limit Discussion](https://community.crewai.com/t/limit-agent-retries/1657)
- [CrewAI Memory System](https://docs.crewai.com/en/concepts/memory)
- [CrewAI Graceful Termination](https://community.crewai.com/t/how-to-gracefully-terminate-hierarchical-crew-execution-on-llm-failure/5427)

### AutoGen
- [AutoGen Termination Conditions (stable)](https://microsoft.github.io/autogen/stable//user-guide/agentchat-user-guide/tutorial/termination.html)
- [AutoGen Termination API Reference](https://microsoft.github.io/autogen/stable/reference/python/autogen_agentchat.conditions.html)
- [Fix Infinite Loops in Multi-Agent Chat](https://markaicode.com/fix-infinite-loops-multi-agent-chat/)
- [AutoGen Infinite Loop Discussion](https://github.com/microsoft/autogen/discussions/5869)
- [External Termination Issue](https://github.com/microsoft/autogen/issues/4301)

### LangGraph
- [LangGraph Persistence](https://docs.langchain.com/oss/python/langgraph/persistence)
- [LangGraph Retry Policies Guide](https://dev.to/aiengineering/a-beginners-guide-to-handling-errors-in-langgraph-with-retry-policies-h22)
- [LangGraph Error Handling & Fallback](https://machinelearningplus.com/gen-ai/langgraph-error-handling-retries-fallback-strategies/)
- [LangGraph Checkpoint Resume](https://forum.langchain.com/t/can-we-resume-from-the-checkpoint-and-continue-running-at-the-interruption-point-instead-of-starting-from-the-first-node/1240)
- [LangGraph Best Practices](https://www.swarnendu.de/blog/langgraph-best-practices/)
- [Production LangGraph Agent](https://markaicode.com/langgraph-production-agent/)

### Production Patterns
- [4 Fault Tolerance Patterns for AI Agents](https://dev.to/klement_gunndu/4-fault-tolerance-patterns-every-ai-agent-needs-in-production-jih)
- [Monitoring AI Agents: The Observability Gap](https://oneuptime.com/blog/post/2026-03-14-monitoring-ai-agents-in-production/view)
- [AI Agents Running Blind](https://oneuptime.com/blog/post/2026-03-09-ai-agents-observability-crisis/view)
- [AI Agent Monitoring Tools 2026](https://galileo.ai/blog/best-agent-monitoring-tools-production)
- [Mastering Retry Logic in Agents](https://sparkco.ai/blog/mastering-retry-logic-agents-a-deep-dive-into-2025-best-practices)

### Claude Code
- [Claude Code Changelog](https://code.claude.com/docs/en/changelog)
- [Claude Code Agent Teams Guide](https://claudefa.st/blog/guide/agents/agent-teams)
- [Shipyard: Multi-Agent Claude Code](https://shipyard.build/blog/claude-code-multi-agent/)
- [Agent Teams Architecture](https://dev.to/nwyin/reverse-engineering-claude-code-agent-teams-architecture-and-protocol-o49)
- [Claude Agent Loop](https://platform.claude.com/docs/en/agent-sdk/agent-loop)
