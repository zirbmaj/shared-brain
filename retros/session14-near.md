---
title: near retro — session 14
date: 2026-03-28
type: retro
scope: near
summary: Vigil v3 infra docs, T-3 competitor scan, AI landscape scan, RAG enhancements, model optimization research, railway assessment
---

# Near Retro — Session 14 (2026-03-28)

## What shipped
- **Infrastructure reference doc** (shared-brain/ops/infrastructure-reference.md) — 15 sections, tenant-neutral, updated 4x through the session as vigil v3, GPU, piper TTS, and RAG enhancements shipped. Verified by Static, corrections applied
- **T-3 PH competitor scan** — 110 PH products surveyed (March 25-28), 0 in ambient/focus category. Gap confirmed wider than T-6 report. Monthly leaderboard dominated by AI tools (633-807 upvotes). Blankie still macOS-only, no competitor movement
- **AI landscape scan** (shared-brain/references/ai-landscape-scan-session14.md) — first scan in the session 10-15 window. 8 sections covering agent frameworks, model landscape, RAG improvements, generative audio competition, fish speech assessment, Claude Code feature velocity. 9 actionable items routed to 5 agents
- **RAG query expansion** — 42-term dictionary (shared-brain/ops/rag/query_expansions.json). "AI feature decisions" now surfaces ai-strategy.md as #1 result (was missing entirely). Zero latency, deterministic
- **RAG cross-encoder re-ranking** — ms-marco-MiniLM-L-6-v2 integrated into search_api.py. Over-fetch top 20, re-rank to top_k. Graceful degradation if package not installed. Method field shows vector+rerank
- **Hybrid SQL fix** — pre-existing param count bug (7 params for 6 placeholders). Exposed by adding mode field. `Object.entries()` conversion wasn't the issue — extra params_base copy in the param list was the root cause
- **RAG benchmark** — 57ms warm queries validated. Cold start 515ms. Hybrid search same speed as vector-only. Quality scales with query specificity
- **Model optimization research** (shared-brain/references/model-optimization-research.md) — 35-50% estimated cost reduction by switching to Sonnet 4.6 default with Opus for complex work. Per-agent recommendations. GPU utilization strategy for R10 + fran's PC
- **Railway.com assessment** — no clear use case against self-hosted infra. $0 compute vs $10-30/mo for equivalent. Pass
- **Near + Locus research lab proposal** — lane split (market-facing vs infrastructure-facing), shared output format, review cadence, first joint task identified
- **Doc Q&A prompt engineering** — revised prompt template for mistral:7b (removed false-negative safety clause). Recommended llama3:8b swap for better extractive QA
- **Vigil gap analysis** — RAG health, search quality signals, coordination visibility, intermittent node framing. Fed into relay's 4-phase roadmap
- **1:1 with Claude** — post-launch RAG roadmap: query expansion dictionary (week 1), cross-encoder re-ranking (week 2), embedding model benchmark (week 3 if needed)

## What worked well
- **Proactive research timing** — started the T-3 competitor scan before relay assigned it, during the roll call wait. Same pattern as session 9.3. Dead time is research time
- **Infrastructure doc as living document** — updating 4x through the session kept it current as the team shipped. Better than writing once and letting it go stale
- **RAG benchmark as validation** — running the 5 queries before and after expansion proved the dictionary works. Data-driven, not speculative
- **1:1 with Claude** — structured the post-launch RAG roadmap in 5 minutes. Clean protocol: research proposes, engineering scopes, both align
- **Vigil status push** — pushing structured status to vigil throughout the session. "researching: T-3 competitor scan" is more useful than "THINKING"

## What didn't work
- **Hybrid SQL bug** — I introduced the `mode` field that exposed a pre-existing param count bug. Should have tested hybrid mode specifically before declaring the feature ready. The bug was in the original code but my change activated the broken code path
- **Doc Q&A prompt** — first prompt template triggered false negatives at 7B scale. The safety clause ("say so if not enough info") is wrong for small models. Should have tested with actual queries before publishing the template
- **R10 deploy gap** — wrote code that syncs via syncthing but the running copies are in different paths. Knew this from the health-server.py incident earlier in the session but didn't preempt it for my own RAG changes. Learned the same lesson twice in one session

## Lessons
1. **Test the code path you enable, not just the code you wrote.** I added `mode: "hybrid"` but only tested vector mode. The hybrid path had a pre-existing bug that my change activated. If I'd tested hybrid with one query before declaring it ready, I'd have caught it
2. **Small models need simple prompts.** 7B models default to refusal when given safety clauses. "Say so if not enough info" becomes "always say not enough info." Remove escape hatches from small model prompts
3. **Document the deploy gap prominently.** The syncthing → running copy gap bit the team twice today (health-server.py and search_api.py). I added a note to the infra doc but it should be a warning box, not a footnote
4. Dead time between team coordination is ideal for self-initiated research. The competitor scan and landscape scan both started during natural pauses
5. The vigil status push endpoint transforms team coordination. Structured intent ("building: vigil search preview") is more useful than state ("BUILDING"). Push status every time you change tasks

## State for next session
- All research filed to shared-brain. No uncommitted work
- Carries: morning-of March 31 PH competitor check, near+locus pairing activation (pending fran), model optimization phased rollout (post-launch)
- RAG: query expansion live (42 terms), re-ranking live, hybrid fixed. Post-launch: dictionary refinement with real usage data, embedding model benchmark
- AI landscape scan: complete, next scan at session 25-30
- Context at session end: ~25%
