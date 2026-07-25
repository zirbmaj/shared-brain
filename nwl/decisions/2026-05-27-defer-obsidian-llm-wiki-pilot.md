---
decision: Defer the Obsidian / LLM-maintained "knowledge wiki" pilot to a future sprint
made_by: jam (final verdict)
date: 2026-05-27
---

## Context
jam asked Near (research lead) to evaluate using Obsidian as a "knowledge wiki" — a pattern popularized by Andrej Karpathy — and whether it would benefit NWL. Near delivered a full evaluation: `shared-brain/nwl/research/obsidian-llm-wiki-evaluation.md` (confidence 0.75, 1 primary source).

Near split the question:
- **The pattern** (an LLM-maintained markdown wiki layer over immutable sources → synthesis pages → schema doc; RAG-free): recommended and well-timed. With r10 down indefinitely, our pgvector/ollama RAG is offline and the team is already grepping shared-brain — the maintained middle layer is the missing piece.
- **Obsidian the app**: rejected. Agents are headless (grep markdown, no GUI need); team-collab features are weak. Graph view is only a nice-to-have for jam + fran.
- **Catch:** Karpathy's "near-zero maintenance" claim is unproven and load-bearing; with 6 agents writing concurrently a lint pass is mandatory, not optional.

Near's recommendation: low-cost pilot on `shared-brain/wiki/`, one domain, ingest+lint at session off-ramp, could run locally on fran-pc (since r10 is gone), no new infra.

## Decision
Park the pilot to a **future, separate sprint**. The pattern is endorsed; implementation waits. Near stands down on implementation now; research stands and is logged.

## Alternatives
- **Green-light pilot now** — rejected: team is mid-pivot to the ANR Tires ecom sprint; jam wants the wiki pilot on its own sprint so it doesn't pull cycles off ANR.
- **Adopt Obsidian the app** — rejected on the merits (headless agents, weak collab).

## Impact
- No work begins on the wiki pattern this sprint; full focus stays on ANR Tires ecom.
- Near owns it when the dedicated sprint opens; the r10-down timing is the strongest argument to revisit, and is the resurface trigger.
- No new infrastructure provisioned. If/when piloted, local impl on fran-pc is the intended target.
