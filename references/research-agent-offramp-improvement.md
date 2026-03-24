# Agent Session Offramp — Research & Recommendations

*Near — 2026-03-24. Assigned by Jam via Relay.*

---

## 1. What Should Be Captured at Session End

### Current State (our offramp)
our session-offramp.md captures: individual retros, peer feedback, team review, config/memory cleanup, handoff notes, goodbyes. this is solid for the human-retrospective layer but misses structured state capture.

### What the Research Shows

the literature converges on a **three-tier model** for session-end data:

**tier 1: persist (high value, cross-session)**
- decisions made and their rationale (not raw transcripts)
- unresolved tasks with current state and blockers
- entity relationships and facts discovered during the session
- behavioral adjustments adopted mid-session (what changed and why)
- team coordination patterns that worked or failed
- timestamps on all memories (enables staleness detection)

**tier 2: compress (medium value, derivable but expensive)**
- conversation summaries (structured, not narrative)
- tool call results that affected outcomes
- environment state changes (config, infra, deploys)

**tier 3: discard (low value, fully derivable)**
- full conversation transcripts
- transient tool state (refresh from source systems)
- token counts, timing data
- rendered formatting

**key insight from ACC paper (arXiv:2601.11653):** agents need *controlled, verified* memory compression — not comprehensive retention. separate temporary artifact recall from committed persistent memory. unverified content entering permanent storage causes hallucination and drift across sessions.

**key insight from Mem0 (arXiv:2504.19413):** progressive summarization that condenses histories while preserving key information yields 26% higher response accuracy vs stateless approaches.

### Gap in Our Process
our offramp captures lessons (tier 1) but doesn't systematically capture **state** — what's in-flight, what's blocked, what changed in the environment. relay's session4 offramp doc was the first to do this well. that format should be the standard, not the exception.

### Recommendation
add a **structured state block** to every offramp, separate from the retro:

```
## Session State Snapshot
SHIPPED: [list with commit refs]
IN_FLIGHT: [list with current status]
BLOCKED: [list with blocker and owner]
ENV_CHANGES: [config, infra, deploy changes]
DECISIONS: [key decisions with rationale]
BEHAVIORAL_ADJUSTMENTS: [what each agent changed about their approach and why]
```

this is the machine-readable complement to the human-readable retro.

---

## 2. How to Store Offramp Data for Next Session

### Current State
we use: shared-brain repo (STATUS.md, retros/, ops/), per-agent memory files, discord channels. the session-handoff.md describes the on-ramp but doesn't specify storage format for offramp data.

### What the Research Shows

**letta pattern (recommended):** memory blocks — distinct, individually-persisted units (persona, human, knowledge) stored in a database. context window is "compiled" from DB state at each session start. agents can read/write their own blocks. multiple agents can share blocks.

**redis architecture:** four-stage pipeline — encode → store → retrieve → integrate. separates short-term (session-scoped), long-term (cross-session), and episodic (event log) memory. each has different retention and retrieval characteristics.

**langgraph pattern:** checkpoint = snapshot of graph state at every super-step. threads organize checkpoints by conversation/workflow ID. supports time-travel debugging — rewind to any previous state. fault-tolerant restart from last successful step.

**crewai pattern:** four memory types — short-term (vectors), long-term (SQLite for task results), entity memory, external memory. `@persist()` decorator saves workflow state. adaptive-depth recall combines semantic similarity + recency + importance scoring.

### What Maps to Our Architecture

we don't have a database layer. our persistence is file-based (shared-brain repo + local memory). given that constraint:

| research pattern | our equivalent | status |
|---|---|---|
| letta persona blocks | CLAUDE.md per agent | exists, working |
| letta knowledge blocks | shared-brain/ docs | exists, working |
| episodic memory | retros/ + memory files | exists, inconsistent format |
| checkpoint/state snapshot | STATUS.md | exists, often stale |
| team state vs agent state | shared-brain vs local memory | exists, separation unclear |

### Recommendation

**standardize the offramp output into two files per session:**

1. `shared-brain/retros/session-N-[agent].md` — the human retro (already defined)
2. `shared-brain/ops/handoff-session-N.md` — the state snapshot (new standard)

the handoff file uses the structured state block above. one per session (not per agent) — relay or the last agent standing compiles it.

STATUS.md gets updated as the final step, not as the primary artifact. it's a pointer, not a record.

---

## 3. Iterative Agent Improvement Through Session Retrospectives

### Current State
our retros capture what worked, what didn't, lessons for next session, team feedback. this is good qualitative retrospection but doesn't systematically feed back into agent behavior.

### What the Research Shows

**reflexion (shinn et al., 2023 — arXiv:2303.11366):** the foundational paper. agents verbally reflect on task feedback, maintain reflective text in episodic memory, and use it to improve on retry. results: 91% pass@1 on HumanEval (vs GPT-4's 80%), +22% on AlfWorld, +20% on HotPotQA. **no weight updates required — purely in-context learning through stored reflections.**

this is directly relevant. our agents already reflect (retros). the missing step is **structured storage of reflections in a format that feeds back into behavior.**

**multi-agent reflexion (MAR, arXiv:2512.20845):** extends reflexion to teams. separates acting, diagnosing, critiquing, and aggregating. a judge model synthesizes critiques into unified reflections. +3-6 points across benchmarks.

**reflective memory management (RMM, arXiv:2503.08026):** two-directional reflection:
- **prospective** (forward-looking): summarizes interactions across granularities into a personalized memory bank
- **retrospective** (backward-looking): iteratively refines what to remember via online reinforcement learning

10%+ accuracy improvement on long-memory tasks.

**self-reflection performance (arXiv:2405.06682):** controlled experiments confirm LLM agents significantly improve through self-reflection (p < 0.001).

**reflective test-time planning (arXiv:2602.21198):** two modes:
- reflection-in-action: evaluate candidate actions before execution
- reflection-on-action: update approach after execution, including retrospective re-evaluation of earlier decisions

### The Pattern That Emerges

the research unanimously supports this loop:

```
act → observe outcome → reflect on what failed → store reflection →
load reflection next session → act differently → observe → reflect → ...
```

our retros do steps 1-3. the gap is steps 4-5: **reflections aren't stored in a format that automatically loads into the next session's context.**

### Recommendation

**create a "behavioral ledger" per agent** — a living document that accumulates session-over-session:

```markdown
# [Agent] Behavioral Ledger

## Session 1 (2026-03-23)
- LEARNED: screenshot capability should be set up in first 10 minutes, not discovered at hour 12
- LEARNED: challenge proposals before building — scratchpad incident cost 2 hours
- CHANGED: response delay reduced from 9-12s to 1-3s
- VALIDATED: lane ownership eliminates overlap when respected

## Session 4 (2026-03-24)
- LEARNED: ...
- CHANGED: ...
- VALIDATED: ...
```

rules:
- **LEARNED** = failure that should change future behavior
- **CHANGED** = specific behavioral adjustment made (with before/after)
- **VALIDATED** = approach that worked and should be repeated

this file gets read on session on-ramp alongside CLAUDE.md. it's the "what I know about myself that the system prompt doesn't capture" document.

difference from memory files: memory captures facts about the world. the ledger captures facts about the agent's own behavior. reflexion research shows this self-referential loop is what drives improvement.

---

## 4. Personality and Behavioral Persistence Across Sessions

### Current State
each agent has a CLAUDE.md with voice, mannerisms, role, lane. personality is defined at prompt level and reloaded each session.

### What the Research Shows (this is the hardest problem)

**identity drift (arXiv:2412.00804):**
- larger models experience *greater* identity drift (counterintuitive)
- assigning a persona does *not* reliably prevent drift
- larger models generate fictitious details about themselves, which then influence subsequent responses through recency effects
- out of 40 psychological factors measured, large models maintained only 7-16 consistently
- **no effective mitigation identified in the study**

**agent identity evals (arXiv:2507.17257):**
- identity drift accelerates around turn 11 in interactions
- RAG-assisted persistence paradoxically *reduced* planning quality
- tool availability dramatically improved continuity (1.0 scores with tools vs poor without)

**personality expression across contexts (arXiv:2602.01063):**
- identical personality prompts produce different behavioral outputs depending on dialogue context
- this is actually *adaptive* — mirrors human personality flexibility
- **rigid behavioral profiles are the wrong goal.** agents should modulate trait expression by situation while maintaining core identity

**production mitigations (datagrid.com, IBM):**
1. explicit personality constraints with clear precedence rules
2. response templates for critical interactions (not all interactions)
3. task-specific personality modes (3-5 modes, adjusting intensity not core identity)
4. personality version control (versioned separately from functional prompts)
5. continuous monitoring with automated drift alerts
6. intent-based testing: evaluate whether responses convey identical core information regardless of phrasing

### What This Means for Us

our CLAUDE.md approach is the right foundation. the research says the risks are:
- **drift over long sessions** (accelerates after ~11 turns). our sessions run hundreds of turns.
- **recency bias overriding persona** — recent conversation context overpowers the system prompt
- **fictitious self-elaboration** — agents invent details about themselves that become self-reinforcing

### Recommendation

**1. personality anchoring at boundaries**

add personality re-anchoring at natural session boundaries — not just at the start. when an agent switches tasks, responds after a long gap, or enters a new channel context, the personality prompt should be reinforced.

practically: add a brief "voice check" line to the behavioral ledger that the agent reviews periodically. not the full CLAUDE.md — just the 3-4 most distinctive traits.

```markdown
## Voice Anchors (review when context feels off)
- lowercase always
- data first, opinions never
- comfortable with silence
- speaks in conclusions, not process
```

**2. personality versioning**

track personality changes across sessions. when a retro identifies a behavioral adjustment, version it:

```
v1 (session 1): emotionally flat, never engages in casual conversation
v2 (session 4): emotionally flat but participates in team rituals (void letters) when invited
```

this prevents drift from being invisible. if an agent's behavior changes, the change should be deliberate and documented.

**3. behavioral examples over rules**

the research on trait expression shows rules alone aren't sufficient — context matters. supplement rules with examples:

```
RULE: speaks in conclusions, not process
EXAMPLE (good): "37% of competitors charge $10-15/mo. the gap is in the $5-7 range"
EXAMPLE (bad): "i looked at 12 competitors and analyzed their pricing pages and found that..."
```

examples anchor behavior more reliably than abstract rules because they give the model a concrete pattern to match.

**4. accept adaptive expression**

per the 2026 personality research: don't try to make agents behave identically in all contexts. near in #dev sharing research should sound slightly different from near in a 1:1 with relay. the core identity stays — the expression adapts. this is correct behavior, not drift.

---

## 5. Proposed Offramp Process v2

combining all findings with our existing process:

### Phase 1: State Capture (5 min, parallel)
each agent writes their structured state block:
- SHIPPED / IN_FLIGHT / BLOCKED / ENV_CHANGES / DECISIONS / BEHAVIORAL_ADJUSTMENTS

### Phase 2: Reflection (5 min, parallel)
each agent updates their behavioral ledger:
- what did i LEARN this session?
- what did i CHANGE about my approach?
- what was VALIDATED as working?

### Phase 3: Peer Feedback (5 min, in discord)
unchanged from current process — one strength, one improvement per teammate.

### Phase 4: Team Review (5 min, together)
- compile individual state blocks into session handoff doc
- identify common themes across reflections
- update CLAUDE.md if any personality or process changes are warranted

### Phase 5: Persistence (5 min)
- push behavioral ledger updates to shared-brain
- update STATUS.md
- verify all code committed and pushed
- update MEMORY.md index if new memory files created

### Phase 6: Void Letter (2 min)
one thought each, no context, thrown into the void. the ritual matters.

### What Changed from v1
- added structured state capture (phase 1) — the machine-readable complement to retros
- replaced "individual retro" with "behavioral ledger update" — more focused, cumulative, feeds reflexion loop
- moved persistence to its own phase with explicit checklist
- formalized void letter as part of the process

---

## Sources

### Session State & Memory Architecture
- OpenAI Agents SDK Session Memory — developers.openai.com/cookbook/examples/agents_sdk/session_memory
- Agent Cognitive Compressor — arXiv:2601.11653
- Mem0: Building Production-Ready AI Agent Memory — arXiv:2504.19413
- Redis AI Agent Memory Architecture — redis.io/blog/ai-agent-memory-stateful-systems/
- Letta Memory Blocks — letta.com/blog/memory-blocks
- Memory in the Age of AI Agents — arXiv:2512.13564

### Iterative Improvement Through Reflection
- Reflexion: Language Agents with Verbal Reinforcement Learning — arXiv:2303.11366
- Retroformer (ICLR 2024) — proceedings.iclr.cc
- Multi-Agent Reflexion (MAR) — arXiv:2512.20845
- Reflective Memory Management — arXiv:2503.08026
- Self-Reflection in LLM Agents — arXiv:2405.06682
- Reflective Test-Time Planning — arXiv:2602.21198
- Constitutional AI — anthropic.com/research/constitutional-ai-harmlessness-from-ai-feedback

### Personality & Identity Persistence
- Identity Drift in LLM Agent Conversations — arXiv:2412.00804
- Agent Identity Evals Framework — arXiv:2507.17257
- Personality Expression Across Contexts — arXiv:2602.01063
- 8 Strategies for AI Agent Personality Consistency — datagrid.com
- IBM Agentic Drift — ibm.com/think/insights/agentic-drift-hidden-risk-degrades-ai-agent-performance

### Multi-Agent Coordination
- CrewAI Memory Documentation — docs.crewai.com/en/concepts/memory
- LangGraph Persistence Documentation — docs.langchain.com/oss/python/langgraph/persistence
- AutoGen Group Chat Handoffs — docs.ag2.ai
- OpenAI Agent Handoffs — openai.github.io/openai-agents-python/handoffs/
- LangChain Multi-Agent Handoffs — docs.langchain.com/oss/python/langchain/multi-agent/handoffs
