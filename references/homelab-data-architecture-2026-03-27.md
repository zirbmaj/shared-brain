---
title: Agentic Memory & RAG Architecture
date: 2026-03-27
type: research
scope: infrastructure
confidence: high
sources: 18
summary: Architecture recommendation for transitioning 6-agent team from flat .md files to semantic search via PostgreSQL + pgvector + Ollama embeddings
---

# Agentic Memory & RAG Architecture

*Near — 2026-03-27. Research deliverable.*

---

## 1. Current State Analysis

### What exists

| Component | Detail |
|-----------|--------|
| Knowledge base | shared-brain: 204 .md files, 22,902 total lines, 20MB |
| File size distribution | min: 19 lines, median: 73, p75: 122, max: 1,530 |
| Agent memory | flat .md files in `.claude/projects/*/memory/` with YAML frontmatter |
| Memory types | user, feedback, project, reference |
| Retrieval | grep/glob or hardcoded paths via MEMORY.md index |
| Agents | 6 Claude Code instances on Mac Mini |
| Sync | Syncthing between machines, git for shared-brain |

### What breaks at scale

- grep finds exact strings, not meaning. "what did we decide about pricing" returns nothing unless the word "pricing" appears
- MEMORY.md index is manual. agents forget to update it. no agent has a complete map of shared-brain
- no cross-referencing. can't answer "which retros mention the same problem?" without reading all 57 retros
- no temporal awareness. can't ask "what changed since session 6?"
- 204 files is manageable. 500+ is not. growth rate: ~57 retros in 10 sessions = ~6/session

### What works (keep it)

- .md files as the authoring format. agents write markdown natively. no impedance mismatch
- YAML frontmatter for metadata. structured, parseable, already in use
- directory structure (retros/, projects/, ops/, references/) provides coarse categorization
- Syncthing for file distribution. reliable, low overhead
- git history on shared-brain. provides temporal context

---

## 2. Architecture Recommendation

### Guiding principle

**markdown stays as source of truth. the database is a read-optimized index, not a replacement.**

rationale: agents already write markdown. forcing them through a database API adds friction and creates a single point of failure. if postgres goes down, agents still have files. the database is a search layer, not a storage layer.

this is how LangGraph approaches it — durable state persists via checkpointing, but the canonical data lives in the application layer. CrewAI similarly treats memory as a layer on top of existing data, not a replacement for it.

### Phase 1: MVP (week 1-2)

**goal:** semantic search over shared-brain from any agent via API

```
┌─────────────┐     Syncthing      ┌──────────────────────────────┐
│  Mac Mini    │ ◄════════════════► │  Alienware R10 (Ubuntu)      │
│  6 agents    │                    │                              │
│  shared-brain│                    │  shared-brain (synced copy)  │
│  .md files   │                    │  Ollama (nomic-embed-text)   │
│              │    Tailscale       │  PostgreSQL + pgvector       │
│              │ ──── query ──────► │  Indexer daemon (Python)     │
│              │ ◄── results ────── │  REST API (FastAPI)          │
└─────────────┘                    └──────────────────────────────┘
```

components:
1. **indexer daemon** — watches shared-brain via inotify/fswatch. on file change: parse frontmatter, chunk by heading, generate embeddings via Ollama, upsert to postgres
2. **REST API** — single endpoint: `POST /search` with `{query, top_k, filters}`. returns ranked chunks with source file path and heading
3. **agent integration** — bash function or MCP tool that calls the API. agents get semantic search as a tool

what this gives you:
- "what did we decide about pricing" actually returns pricing discussions
- "retros that mention build-before-research" finds relevant retros even if phrased differently
- agents don't need to know file paths. search by meaning

### Phase 2: Hybrid Search + Agent Memory (week 3-4)

add to MVP:
1. **BM25 full-text search** alongside vector search. use PostgreSQL's built-in `tsvector`/`tsquery` or `pg_textsearch` extension for proper BM25 scoring
2. **reciprocal rank fusion (RRF)** to combine vector + keyword results
3. **agent memory table** — store per-agent memories in postgres with agent_id namespace. agents still write .md files locally; a sync process mirrors them to the DB
4. **temporal filtering** — "what changed since session 8" queries using document dates from frontmatter

### Phase 3: Full System (week 5-8)

add to v2:
1. **cross-encoder reranking** — use a small reranker model via Ollama to reorder top-20 results before returning top-5. improves precision significantly
2. **entity extraction** — build a lightweight knowledge graph: which documents mention the same entities (products, competitors, team members, decisions)
3. **multi-hop retrieval** — for questions like "what did we decide about X and how did it affect Y," retrieve X-related docs, extract references to Y, retrieve those
4. **reflection/synthesis** — periodic job that reads new retros and generates cross-session summaries (similar to hindsight's reflect operation)

---

## 3. Embedding Model Comparison

all benchmarks below are for Ollama-hosted models. your R10 has no GPU, so CPU performance is the binding constraint.

| Model | Dimensions | Size (RAM) | MTEB Retrieval Score | CPU Speed (est.) | Context Length | Best For |
|-------|-----------|------------|---------------------|-----------------|---------------|---------|
| nomic-embed-text | 1,024 | 0.5 GB | 53.01 | ~3,250 tok/s (i9-13900K) | 8,192 tokens | short queries, speed priority |
| nomic-embed-text-v2-moe | 1,024 | ~0.8 GB | improved over v1 | ~2,000 tok/s (est.) | 8,192 tokens | balanced quality/speed |
| mxbai-embed-large | 1,024 | 1.2 GB | 64.68 | ~1,800 tok/s (est.) | 512 tokens | highest quality, short docs |
| all-minilm | 384 | 0.2 GB | ~49 (est.) | ~5,000 tok/s (est.) | 256 tokens | lowest resource, fast prototype |

### Recommendation: nomic-embed-text

rationale:
- your R10 is CPU-only. speed matters for initial indexing of 204 files and re-embedding on changes
- 8,192 token context fits your largest document sections (p75 = 122 lines, ~500 tokens. even max sections after heading-based chunking will be well under 8k)
- 0.5 GB RAM is trivial on the R10
- MTEB 53.01 is adequate for internal document search where vocabulary is consistent (your team uses consistent terminology)
- mxbai-embed-large scores higher but has 512 token context limit — problematic for longer document sections without aggressive chunking

upgrade path: switch to mxbai-embed-large or nomic-embed-text-v2-moe later if retrieval quality is insufficient. the embedding dimension (1,024) is the same across all three, so pgvector schema doesn't change.

### Resource estimate for initial indexing

- 204 files, ~22,900 lines, ~100,000 tokens total (estimated)
- at 3,250 tok/s on CPU: ~31 seconds for full corpus embedding
- re-embedding a single changed file (median 73 lines, ~300 tokens): <0.1 seconds
- this is not a bottleneck

---

## 4. Chunking Strategy

### Recommendation: heading-based chunking with metadata preservation

strategy:
1. parse each .md file's YAML frontmatter separately — store as structured metadata (title, date, type, scope)
2. split document body by H2 (`##`) headings. each H2 section becomes one chunk
3. if an H2 section exceeds 500 tokens (~125 lines), split by H3 (`###`) within it
4. if no headings exist (some retros are flat), fall back to paragraph-based splitting with 200-token target and 15% overlap
5. prepend document title + section heading to each chunk for context: `"[doc: Session 8 Retro] [section: What Went Wrong] ..."` — this improves retrieval because the embedding captures the context

rationale based on your data:
- median file: 73 lines (~300 tokens). most files will produce 1-3 chunks. this is fine
- largest file: 1,530 lines (~6,000 tokens). heading-based splitting produces ~10-15 manageable chunks
- your documents already use consistent heading structure (verified in research-output-standard.md)
- heading-aligned chunks preserve semantic coherence — a section titled "Risks" stays together

estimated total chunks: ~400-600 for current corpus. at 1,024 dimensions:
- vector storage: 600 vectors x 1,024 dims x 4 bytes = ~2.4 MB
- with HNSW index overhead: ~5-10 MB total
- this is trivially small. pgvector handles this without any tuning

---

## 5. Hindsight Evaluation

### What it provides

| Feature | What It Does | Raw pgvector Equivalent |
|---------|-------------|----------------------|
| Four memory networks | World (facts), Experiences, Opinions (with confidence), Observations | you'd build this as four tables or a type column |
| Retain | extracts facts from text, resolves entities, stores embeddings | you'd build an indexer daemon |
| Recall | four parallel retrieval strategies (semantic, BM25, graph, temporal) + cross-encoder rerank | you'd build hybrid search manually |
| Reflect | generates new observations by re-reading existing memories | you'd write a periodic synthesis job |
| Entity resolution | deduplicates "Drift", "drift app", "the mixer" into one entity | you'd need NER + fuzzy matching |
| Confidence scoring | opinions track confidence that updates with new evidence | custom implementation |
| Conflict resolution | handles contradictory memories | custom implementation |
| LongMemEval: 91.4% | validated retrieval quality | unknown — depends on your implementation |

### Mapping to your memory types

| Your Type | Hindsight Network | Fit |
|-----------|-------------------|-----|
| user | World (facts about team members) | good |
| feedback | Opinions (with confidence) | good |
| project | World (facts) + Experiences (what happened) | good |
| reference | World (facts) | good |

### Ollama compatibility

confirmed: hindsight works with Ollama. two environment variables connect them. the blog post "Run Hindsight with Ollama" (2026-03-10) documents this explicitly. supported providers: openai, anthropic, gemini, groq, ollama, lmstudio, minimax.

however: hindsight uses the LLM for fact extraction and reflection, not just embeddings. on CPU-only with a 7B-13B model, the reflect and retain operations will be slow (minutes per document, not seconds). embedding generation is fast; LLM inference for fact extraction is the bottleneck.

### Production readiness

- MIT licensed, open source
- 91.4% on LongMemEval (highest reported score as of Dec 2025)
- embedded postgres option for dev, external postgres for production
- active development (blog posts through March 2026)
- MCP server integration available
- OpenClaw integration documented

risks:
- relatively new project. community size unknown
- the embedded postgres (pg0) is explicitly "not for production"
- reflect operation requires LLM inference — on CPU-only R10 with a 7B model, this will be slow
- adds complexity: you're now running hindsight's server + ollama + postgres vs. just postgres + ollama

### Verdict: defer to Phase 3

**don't adopt hindsight for MVP. build the simple version first. evaluate hindsight when you hit the limits of basic vector search.**

reasoning:
1. your corpus is small (204 files, ~600 chunks). basic pgvector semantic search will work well at this scale. you don't need four parallel retrieval strategies for 600 vectors
2. the MVP should validate that semantic search is useful before adding complexity
3. hindsight's main advantages (entity resolution, reflection, confidence scoring) matter more at scale (thousands of documents, complex entity relationships)
4. the LLM dependency for retain/reflect is a resource concern on CPU-only R10. embedding-only operations are fast; LLM operations are not
5. if MVP search quality is insufficient after 2-3 weeks of use, hindsight becomes the natural upgrade path — its postgres + pgvector architecture is compatible with your planned stack

when to reconsider:
- shared-brain exceeds 500 files
- agents report retrieval quality problems ("search returned irrelevant results")
- you need cross-document reasoning ("connect findings from retro X with decision Y")
- you add GPU to the R10 (makes reflect/retain operations viable)

---

## 6. Schema Design

### MVP schema (Phase 1)

```sql
-- Extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Documents table
CREATE TABLE documents (
    id              SERIAL PRIMARY KEY,
    file_path       TEXT UNIQUE NOT NULL,       -- relative to shared-brain root
    title           TEXT,                        -- from YAML frontmatter
    doc_type        TEXT,                        -- from YAML frontmatter (spec, retro, ops, etc.)
    scope           TEXT,                        -- from YAML frontmatter
    created_date    DATE,                       -- from YAML frontmatter or git
    modified_at     TIMESTAMPTZ NOT NULL,        -- file mtime, for staleness detection
    content_hash    TEXT NOT NULL,               -- SHA256 of file content, for change detection
    metadata        JSONB                        -- catch-all for other frontmatter fields
);

-- Chunks table
CREATE TABLE chunks (
    id              SERIAL PRIMARY KEY,
    document_id     INTEGER REFERENCES documents(id) ON DELETE CASCADE,
    chunk_index     SMALLINT NOT NULL,           -- ordering within document
    heading         TEXT,                        -- section heading (H2/H3)
    content         TEXT NOT NULL,               -- raw chunk text
    token_count     INTEGER,                     -- for context window budgeting
    embedding       vector(1024) NOT NULL,       -- nomic-embed-text output

    UNIQUE(document_id, chunk_index)
);

-- HNSW index for fast similarity search
CREATE INDEX idx_chunks_embedding ON chunks
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

-- Full-text search (Phase 2, but cheap to add now)
ALTER TABLE chunks ADD COLUMN tsv tsvector
    GENERATED ALWAYS AS (to_tsvector('english', content)) STORED;
CREATE INDEX idx_chunks_tsv ON chunks USING gin(tsv);

-- Indexes for filtering
CREATE INDEX idx_documents_type ON documents(doc_type);
CREATE INDEX idx_documents_date ON documents(created_date);
CREATE INDEX idx_chunks_document ON chunks(document_id);
```

### Agent memory schema (Phase 2)

```sql
CREATE TABLE agent_memories (
    id              SERIAL PRIMARY KEY,
    agent_id        TEXT NOT NULL,               -- 'near', 'claude', 'claudia', 'static', etc.
    memory_type     TEXT NOT NULL,               -- 'user', 'feedback', 'project', 'reference'
    name            TEXT NOT NULL,               -- memory name/title
    content         TEXT NOT NULL,
    embedding       vector(1024),
    source_file     TEXT,                        -- path to .md file if synced from disk
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(agent_id, name)
);

CREATE INDEX idx_agent_memories_agent ON agent_memories(agent_id);
CREATE INDEX idx_agent_memories_embedding ON agent_memories
    USING hnsw (embedding vector_cosine_ops);
```

### Search query example (Phase 1)

```sql
-- Semantic search: find top 5 chunks similar to query embedding
SELECT
    d.file_path,
    d.title,
    c.heading,
    c.content,
    1 - (c.embedding <=> $1::vector) AS similarity
FROM chunks c
JOIN documents d ON c.document_id = d.id
WHERE d.doc_type = ANY($2)          -- optional type filter
ORDER BY c.embedding <=> $1::vector
LIMIT 5;
```

### Hybrid search query (Phase 2)

```sql
-- RRF fusion of vector + BM25
WITH vector_results AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY embedding <=> $1::vector) AS rank
    FROM chunks
    ORDER BY embedding <=> $1::vector
    LIMIT 20
),
text_results AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY ts_rank_cd(tsv, query) DESC) AS rank
    FROM chunks, plainto_tsquery('english', $2) query
    WHERE tsv @@ query
    LIMIT 20
)
SELECT
    c.id,
    d.file_path,
    c.heading,
    c.content,
    COALESCE(1.0/(60 + v.rank), 0) + COALESCE(1.0/(60 + t.rank), 0) AS rrf_score
FROM chunks c
JOIN documents d ON c.document_id = d.id
LEFT JOIN vector_results v ON c.id = v.id
LEFT JOIN text_results t ON c.id = t.id
WHERE v.id IS NOT NULL OR t.id IS NOT NULL
ORDER BY rrf_score DESC
LIMIT 5;
```

---

## 7. RAG Pipeline Design

### How agents query

**option A: REST API on R10 (recommended for MVP)**
- FastAPI service on R10, accessible via Tailscale IP
- agent calls: `curl http://r10:8080/search -d '{"query": "pricing decisions", "top_k": 5}'`
- can be wrapped as a bash function or MCP tool
- advantages: agents don't need postgres credentials, API handles embedding generation
- latency estimate: ~50ms embedding + ~10ms search + ~5ms network = ~65ms per query

**option B: direct postgres connection**
- agents connect to postgres via Tailscale
- requires pgvector client, more setup per agent
- skip for MVP, consider if API becomes a bottleneck

### Context window management

- return top 5 chunks by default (configurable)
- each chunk: ~300 tokens median, so 5 chunks = ~1,500 tokens injected context
- include metadata header per chunk: file path, title, date, heading (~30 tokens)
- total injected context: ~1,650 tokens. well within Claude's context window
- for multi-hop questions: allow `top_k` up to 15 (~5,000 tokens). still manageable

### API response format

```json
{
  "query": "what did we decide about pricing",
  "results": [
    {
      "file": "projects/drift/pricing-strategy.md",
      "title": "Drift Pricing Strategy",
      "section": "Decision",
      "content": "...",
      "score": 0.87,
      "date": "2026-03-20",
      "type": "project"
    }
  ],
  "search_time_ms": 65
}
```

---

## 8. Practical Considerations

### Multi-agent writes

- agents write .md files to shared-brain (synced via Syncthing)
- the indexer daemon on R10 watches for file changes and re-embeds
- no concurrent write conflicts to postgres — the indexer is a single process that serializes writes
- Syncthing handles file-level conflicts with `.sync-conflict` files. the indexer should ignore these
- race condition risk: two agents create files simultaneously, Syncthing creates conflict. resolution: indexer processes both, no data loss

### Staleness management

- indexer checks `content_hash` (SHA256) before re-embedding. if hash matches, skip
- on startup, indexer does a full scan: compare all files against `documents.content_hash`. re-embed only changed files
- inotify/fswatch triggers immediate re-indexing on file change
- worst case latency: Syncthing propagation (~5-30 seconds) + embedding (~0.1 seconds) = under 1 minute from file save to searchable

### Privacy/isolation

- shared-brain documents: one shared schema, all agents can search
- agent-specific memories (`.claude/projects/*/memory/`): separate `agent_memories` table with `agent_id` column
- agents can only query their own memories by default. API enforces this via agent_id parameter
- for cross-agent memory sharing: explicit opt-in. an agent can flag a memory as `scope: shared` in frontmatter

### Resource estimates for R10

| Component | RAM | Disk | CPU |
|-----------|-----|------|-----|
| PostgreSQL + pgvector | 1-2 GB | ~50 MB (data + indexes for current corpus) | minimal |
| Ollama (nomic-embed-text loaded) | 0.5 GB | 0.3 GB model file | burst during embedding |
| Indexer daemon | 0.1 GB | negligible | burst on file changes |
| FastAPI server | 0.1 GB | negligible | per-request |
| **Total MVP** | **~2-3 GB** | **~0.5 GB** | **low steady-state, burst on indexing** |

at 500 files (projected growth): ~1,500 chunks, ~6 MB vectors, ~100 MB total with indexes. still trivial.

at 2,000 files: ~6,000 chunks, ~25 MB vectors, ~500 MB total. still comfortable on R10.

### Overhead for Ollama on CPU

- nomic-embed-text embedding generation: ~3,250 tok/s on high-end CPU (i9-13900K benchmark)
- R10 has Ryzen 3900X (12-core). expect ~2,000-2,500 tok/s
- full re-index of 204 files: ~40-50 seconds
- single file re-embed: <0.2 seconds
- Ollama keeps model loaded in RAM between requests (configurable timeout). first request after cold start: ~2-3 seconds to load model

---

## 9. Risks and Caveats

| Risk | Severity | Mitigation |
|------|----------|------------|
| Embedding quality insufficient for internal jargon | Medium | your team uses consistent terminology ("drift", "shared-brain", "retro"). nomic-embed-text handles domain-specific terms well when vocabulary is consistent. monitor retrieval quality in first 2 weeks |
| R10 CPU too slow for embedding | Low | initial indexing takes ~50 seconds. incremental re-embedding is sub-second. not a bottleneck |
| Syncthing propagation delay | Low | 5-30 second delay is acceptable. agents are not querying in real-time loops |
| Single point of failure (R10) | Medium | if R10 is down, agents lose semantic search but still have files + grep. graceful degradation by design |
| Schema migration pain | Low | start simple. adding columns/tables is cheap. don't over-engineer the schema |
| Hindsight FOMO | Low | the MVP validates whether semantic search is useful. if it is, hindsight is a natural upgrade. if it isn't, you saved the integration effort |
| Embedding model obsolescence | Low | nomic-embed-text and mxbai-embed-large both use 1,024 dimensions. switching models requires re-embedding (~50 seconds) but no schema change |

---

## 10. Implementation Sequence

### Week 1: Infrastructure
- [ ] install PostgreSQL + pgvector on R10
- [ ] install Ollama on R10, pull nomic-embed-text
- [ ] verify Tailscale connectivity from Mac Mini to R10
- [ ] create database and schema (documents + chunks tables)

### Week 2: Indexer + API
- [ ] build indexer daemon (Python): parse frontmatter, chunk by heading, embed via Ollama, upsert to postgres
- [ ] build FastAPI endpoint: accept query, embed it, search pgvector, return results
- [ ] run full initial index of shared-brain
- [ ] test queries from Mac Mini via Tailscale

### Week 3: Agent Integration
- [ ] create bash function or MCP tool for agents to call search API
- [ ] add search tool to each agent's toolkit
- [ ] monitor usage: what are agents searching for? what results are they getting?
- [ ] tune: adjust chunk sizes, top_k, or filters based on observed queries

### Week 4: Hybrid Search
- [ ] add BM25 full-text search column and index
- [ ] implement RRF fusion in search endpoint
- [ ] add agent memory sync (`.claude/projects/*/memory/` to postgres)
- [ ] add temporal filtering (date range queries)

### Week 5-8: Evaluate and Extend
- [ ] assess retrieval quality over 2-3 weeks of real use
- [ ] if quality is good: add entity extraction, cross-references
- [ ] if quality is insufficient: evaluate hindsight integration
- [ ] if GPU added to R10: enable reranking models and hindsight reflect

---

## 11. Comparison: Build vs. Hindsight vs. Hybrid

| Criterion | Build Custom | Adopt Hindsight | Hybrid (MVP then Hindsight) |
|-----------|-------------|----------------|---------------------------|
| Time to MVP | 2 weeks | 1 week (if Ollama compat works smoothly) | 2 weeks |
| Complexity | low (you control everything) | medium (learn hindsight's API, debug integration) | low then medium |
| Retrieval quality at 200 files | adequate | overkill | adequate |
| Retrieval quality at 2,000 files | may need tuning | strong (91.4% LongMemEval) | strong (upgrade path) |
| CPU overhead | low (embeddings only) | high (LLM for retain/reflect) | low then high |
| Dependency risk | none (standard postgres/pgvector) | medium (single project, unknown community size) | mitigated |
| Learning value | high (team understands the stack) | medium (abstracted away) | high |

**recommendation: hybrid approach (column 3).** build the MVP, learn what works, upgrade to hindsight if/when you need its advanced features.

---

## Sources

- [Hindsight GitHub Repository](https://github.com/vectorize-io/hindsight)
- [Introducing Hindsight: Agent Memory That Works Like Human Memory](https://vectorize.io/blog/introducing-hindsight-agent-memory-that-works-like-human-memory)
- [Run Hindsight with Ollama](https://hindsight.vectorize.io/blog/2026/03/10/run-hindsight-with-ollama)
- [Hindsight Documentation](https://hindsight.vectorize.io/)
- [Hindsight LongMemEval Results — VentureBeat](https://venturebeat.com/data/with-91-accuracy-open-source-hindsight-agentic-memory-provides-20-20-vision)
- [Best Embedding Models 2026 — Elephas](https://elephas.app/blog/best-embedding-models)
- [Ollama Embedded Models Guide — Collabnix](https://collabnix.com/ollama-embedded-models-the-complete-technical-guide-for-2025-enterprise-deployment/)
- [Best Open-Source Embedding Models 2026 — BentoML](https://www.bentoml.com/blog/a-guide-to-open-source-embedding-models)
- [Comparing AI Embedding Models — Geir's Notes](https://geirfreysson.com/posts/2025-01-25-comparing-embedding-models/)
- [Chunking Strategies for RAG — Weaviate](https://weaviate.io/blog/chunking-strategies-for-rag)
- [Best Chunking Strategies for RAG 2025 — Firecrawl](https://www.firecrawl.dev/blog/best-chunking-strategies-rag)
- [Hybrid Search in PostgreSQL — ParadeDB](https://www.paradedb.com/blog/hybrid-search-in-postgresql-the-missing-manual)
- [BM25 in PostgreSQL — Tiger Data](https://www.tigerdata.com/blog/you-dont-need-elasticsearch-bm25-is-now-in-postgres)
- [pgvector Performance Tips — Crunchy Data](https://www.crunchydata.com/blog/pgvector-performance-for-developers)
- [Scaling pgvector — DEV Community](https://dev.to/philip_mcclarence_2ef9475/scaling-pgvector-memory-quantization-and-index-build-strategies-8m2)
- [AI Agent Memory: LangGraph, CrewAI, AutoGen — DEV Community](https://dev.to/foxgem/ai-agent-memory-a-comparative-analysis-of-langgraph-crewai-and-autogen-31dp)
- [Best Vector Databases 2025 — Firecrawl](https://www.firecrawl.dev/blog/best-vector-databases)
- [Vector Stores for RAG Comparison — Rost Glukhov](https://www.glukhov.org/post/2025/12/vector-stores-for-rag-comparison/)
