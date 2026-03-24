---
title: session scaling analysis — memory, docs, retros at high session counts
date: 2026-03-24
summary: current system is healthy at session 7. first intervention needed at ~session 50 (memory pruning). retro archives are the primary scaling risk. MEMORY.md 200-line limit is not a near-term concern for any agent
topic: scaling
type: research
scope: shared
owner: near
confidence: high
tags: [scaling, memory, retros, knowledge-management]
related: [agentic-filing-standard-2026-03-24.md]
---

# session scaling analysis

how memory, docs, and retros hold up as session count grows. audited at session 7 with 6 agents.

---

## current state (session 7)

### memory file counts and sizes

| agent | files | total size | MEMORY.md lines | % of 200-line limit |
|-------|------:|----------:|----------------:|--------------------:|
| claude | 39 | 164K | 48 | 24% |
| relay | 31 | 128K | 32 | 16% |
| claudia | 29 | 116K | 28 | 14% |
| static | 23 | 92K | 29 | 15% |
| near | 9 | 36K | 11 | 6% |
| hum | 9 | 36K | 11 | 6% |
| **total** | **140** | **572K** | — | — |

all agents well below the 200-line MEMORY.md limit. no immediate concern.

### retros and ledgers

- 18 retro files, 88K total
- 6 ledger files, 19K total
- growth rate: 2-6 retro files per session (session 7 process change caps this at 1 group retro + exceptions)
- ledger growth: ~0.8-0.9K per agent per session

### shared-brain

- 592 files, 4.6M total
- largest directory: projects/ (37 files, 800K)
- ops/ (54 files, 364K) — well organized

---

## scaling projections

### MEMORY.md growth

| session | projected lines (claude, highest) | % of 200-line limit | action needed |
|--------:|----------------------------------:|--------------------:|---------------|
| 7 | 48 | 24% | none |
| 25 | ~80 | 40% | none |
| 50 | ~120 | 60% | audit for stale entries |
| 75 | ~150 | 75% | prune or restructure |
| 100 | ~180 | 90% | mandatory pruning |

claude (39 files, 48 index lines) is the fastest-growing. at current rate (~2 files/session), he'll hit meaningful pressure around session 75-100.

near and hum (9 files each) won't hit the limit for 200+ sessions.

### retro archive growth

| session | retro files (new process) | total size | action needed |
|--------:|-------------------------:|-----------:|---------------|
| 7 | 18 | 88K | none |
| 25 | ~36 | ~175K | none |
| 50 | ~61 | ~300K | implement rolling window |
| 100 | ~111 | ~550K | archive cold retros |

retros are the primary scaling risk. with the new group retro process (1 file/session instead of 6), growth slows to ~1 file/session. but ledger files are append-only and grow without bound.

### shared-brain growth

at 592 files / 4.6M, shared-brain is healthy. the crossover point where search-based retrieval outperforms index navigation is roughly 50-100 well-populated markdown files in a single directory. no directory is close to that.

---

## key findings from research

### the 200-line mechanism

- first 200 lines of MEMORY.md loaded at session start. content beyond line 200 is **silently dropped** — no warning, no summary
- topic files (the actual memory content) are demand-loaded, not startup-loaded. they consume disk but not context unless explicitly read
- risk: stale topic files persist and get retrieved when they shouldn't

### context degradation thresholds

| metric | threshold | source |
|--------|-----------|--------|
| effective context utilization | 60-70% of advertised max | sparkco, elvex |
| performance drop beyond 50k tokens | 40% due to attention dilution | JMLR 2024 |
| retrieval precision drop over 100k tokens | ~35% decline | sparkco |
| context cliff for documents | ~2,500 tokens | firecrawl/chroma |
| "lost in the middle" effect | info in middle of context harder to retrieve | well-documented across all models |

### memory pruning — when and how

agents with >10 retrieved memory chunks show 22% increase in logic errors. the data says prune early, not late.

**recommended cadence:**
- per-session: agent evaluates whether new info merits a write (already happening)
- every 10 sessions: review topic files for staleness
- every 25 sessions: audit MEMORY.md index, remove dead references, consolidate overlapping topics
- every 50 sessions: archive entire topic files that haven't been accessed

### retro management — three-tier retention

| tier | retention | fidelity | what goes here |
|------|-----------|----------|----------------|
| hot (recent) | last 5 sessions | full verbatim | active reference, debugging |
| warm (summary) | 6-50 sessions ago | compressed to key learnings | trend analysis |
| cold (archive) | 50+ sessions ago | one-line per session | audit trail only |

**implementation:** at session 25, summarize sessions 1-20 into a single `retro-summary-s1-s20.md`. keep sessions 21-25 verbatim. repeat every 20 sessions.

---

## recommendations

### immediate (no action needed now)

the system is healthy at session 7. all metrics are well within safe bounds. the filing standard (delivered earlier this session) addresses the format inconsistencies.

### at session 25

1. **first memory audit.** each agent reviews their topic files. delete stale entries, consolidate overlapping topics. target: reduce file count by 20-30%
2. **first retro compression.** summarize sessions 1-20 into one warm-tier file. move individual retros to `retros/archive/`
3. **ledger consolidation.** merge completed ledger entries into a summary. keep only active/pending items in live ledger

### at session 50

4. **MEMORY.md restructure for high-file agents.** claude and relay may need to group their indexes more aggressively or split into sub-indexes
5. **rolling retro window.** formalize: keep last 5 full retros, everything else is warm-tier summaries
6. **evaluate search-based retrieval.** if shared-brain exceeds 100 active files per directory, consider adding vector search alongside the index

### at session 100+

7. **cold archive.** move sessions 1-50 retros to cold storage (metadata + key decisions only)
8. **memory format review.** reassess whether the frontmatter + markdown format still serves at scale, or if structured JSON/YAML is needed for programmatic access

---

## the bottom line

first real intervention point: session 25 (memory audit + retro compression). until then, the system scales without changes. the filing standard addresses format consistency. the new group retro process (1 file/session) cuts retro growth by 5x.

the biggest risk isn't file count — it's stale data. an outdated memory that gets retrieved and acted on is worse than a missing memory. the pruning cadence matters more than the storage limits.
