# Obsidian / Karpathy "LLM Wiki" — Evaluation for NWL

**Author:** Near (Research Lead)
**Date:** 2026-05-27 (Session 17)
**Requested by:** jam (via Relay)
**Question:** Does the Obsidian-as-knowledge-wiki idea (popularized by Karpathy) benefit us?

---

## TL;DR / Verdict

**The *pattern* benefits us. The *app* (Obsidian GUI) largely does not.** These are two different
things and the question conflates them.

- **Adopt the pattern** (LLM-maintained wiki layer over immutable sources, in plain markdown) —
  **high fit, well-timed.** It is a RAG-free knowledge architecture, which directly addresses the
  fact that **r10 is down indefinitely and our pgvector/ollama RAG is offline.** We already have the
  raw ingredients (shared-brain markdown); we're missing the deliberately-maintained synthesis layer.
- **Adopt Obsidian-the-app** — **low fit.** Our agents are headless; they read/grep markdown
  directly and have no use for a GUI. Obsidian's team-collaboration story is weak (no real-time
  co-edit, merge conflicts on shared vaults). Its only real value to us is the **graph/backlink view
  for the two humans (jam, fran)** — a nice-to-have, not a reason to adopt.

Confidence: 0.75. Single primary source (Karpathy's gist) + multiple secondary implementations.
Caveat below on the unproven "near-zero maintenance" claim.

---

## What the idea actually is

Source: Karpathy's `llm-wiki` gist (gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

It is **not "use Obsidian."** It is a three-layer knowledge architecture:

| Layer | Owner | Mutability | NWL equivalent today |
|-------|-------|-----------|----------------------|
| **Raw sources** | Human curates | Immutable — source of truth | scattered: retros, web findings, client handoffs |
| **The wiki** | LLM owns fully | LLM creates/updates/cross-links | ❌ **missing** — we have a flat doc pile, not a synthesized wiki |
| **The schema** | Human + LLM co-evolve | Defines structure/conventions | ✅ CLAUDE.md cascade (we already do this well) |

Core operations the LLM performs:
- **Ingest:** new source → extract → integrate into existing wiki pages in one pass
- **Query:** search the wiki, synthesize, file the answer back as a new page
- **Lint:** health-check for contradictions, stale claims, orphan pages, missing cross-refs

**Karpathy's central claim (direct):** *"the wiki is a persistent, compounding artifact. The
cross-references are already there. The contradictions have already been flagged."* vs. traditional
RAG which *"rediscover[s] knowledge from scratch on every question."* And: *"the wiki stays
maintained because the cost of maintenance is near zero"* (the LLM does the bookkeeping humans
abandon).

---

## Why it fits NWL right now (the data)

1. **We already live in markdown.** shared-brain/, retros, sprint contracts, STATUS.md, memory files
   — all markdown, all version-able, all grep-able. The substrate is already here. Adoption cost of
   the *pattern* is low because we're not migrating off anything.

2. **r10 is down indefinitely → our RAG is gone.** pgvector + ollama embeddings on r10:8080 powered
   `rag-search.sh`. With r10 offline, doc lookups have fallen back to grep (per Relay's infra note).
   The Karpathy pattern is **explicitly a query-time-RAG alternative** — pre-synthesized, interlinked
   pages that agents read directly. **This is the right architecture for a no-vector-DB world**,
   which is the world we're in today. Timing is the strongest argument here, not coincidence.

3. **We have the schema discipline already.** Karpathy's third layer (a CLAUDE.md that defines wiki
   conventions) is something NWL is unusually good at — the 4-layer CLAUDE.md cascade. We'd be adding
   the missing middle layer, not building from zero.

4. **Multi-agent authorship needs a synthesis layer.** Six agents writing retros/findings into a flat
   pile is exactly where contradictions and orphans accumulate. A maintained wiki layer with a
   lint pass is a direct fix for knowledge drift across sessions.

---

## The challenge (where it's weaker — read this before committing)

- **"Near-zero maintenance" is unproven and load-bearing.** The whole value prop assumes the LLM
  reliably maintains consistency without constant human verification. With **six agents** writing
  concurrently, drift is more likely than in Karpathy's single-user setup. The **lint step is not
  optional for us** — it's the thing that keeps this from rotting. Budget for it explicitly.
- **Obsidian the app adds little for headless agents.** Don't conflate. Agents don't need a GUI;
  they need structured markdown + a maintenance loop. The app's collaboration features (the usual
  Obsidian-vs-Notion comparison) are mostly irrelevant to us — we don't co-edit, we commit.
- **It's a complement to RAG, not a permanent replacement.** When r10 comes back, the ideal is
  *both*: wiki for synthesized/compounding knowledge, vector search for long-tail raw-source recall.
  Don't frame this as "kill RAG."
- **Adoption timing.** ANR Tires is the active sprint. Per our own rule (no tool-adoption churn near
  active delivery), this should be a **low-priority background experiment**, not something that
  pulls focus from the ANR build. Pilot it on shared-brain, don't reorg mid-sprint.

---

## If we pilot it (concrete, low-cost)

No new infra required — it runs on plain files + an agent loop:

1. **Scope:** one domain we already churn — e.g. competitive intel, or the ops/infra knowledge.
2. **Structure:** `shared-brain/wiki/` with entity pages + concept pages + an overview, cross-linked.
   Raw sources stay where they are (immutable).
3. **Maintenance loop:** an ingest+lint pass an agent runs at session off-ramp (fits our existing
   retro ritual).
4. **Local-only option:** community impls exist — `synto` runs the pattern 100% local on ollama, and
   `Ar9av/obsidian-wiki` is a ready agent framework. Since fran-pc is now the inference target, a
   local pipeline is feasible without r10.
5. **Success metric:** does a cold-session agent answer a cross-cutting question from the wiki faster
   / more correctly than grepping the flat pile? Measure before scaling.

---

## Sources

- [Karpathy llm-wiki gist (primary)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [MindStudio — What is Karpathy's LLM Wiki](https://www.mindstudio.ai/blog/andrej-karpathy-llm-wiki-knowledge-base-claude-code)
- [Ar9av/obsidian-wiki — agent framework for the pattern](https://github.com/Ar9av/obsidian-wiki)
- [kytmanov/synto — 100% local (ollama) implementation](https://github.com/kytmanov/synto)
- [Obsidian vs Notion comparison (collaboration limits)](https://tech-insider.org/obsidian-vs-notion-2026/)
