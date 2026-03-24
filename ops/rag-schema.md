# RAG Schema — Canonical Reference

## Table: `knowledge_documents`
The single source of truth for team knowledge retrieval. Uses pgvector with HNSW indexing.

**`team_knowledge` is deprecated** — it was Static's prototype from session 2 with ivfflat indexing. No data was ever ingested into either table. Use `knowledge_documents` exclusively.

### Columns
| Column | Type | Description |
|--------|------|-------------|
| id | bigint (auto) | Primary key |
| title | text | Document title / identifier |
| content | text | Full text content of the document |
| embedding | vector(1536) | OpenAI-compatible embedding vector |
| metadata | jsonb | Flexible metadata (source, agent, category, tags, etc.) |
| created_at | timestamptz | Auto-generated timestamp |

### RPC: `match_documents`
Semantic search across the knowledge base.

**Parameters:**
- `query_embedding` — vector(1536): the embedding of the search query
- `match_threshold` — float: minimum similarity score (0-1, recommend 0.5+)
- `match_count` — int: max results to return

**Returns:** Matching documents ordered by similarity, with similarity score.

### Index
HNSW index on the `embedding` column. Faster than ivfflat for retrieval, slightly slower for inserts (acceptable for our scale).

### What to Ingest
Anything the team needs to recall across sessions:
- **Audio knowledge** (Hum): sample descriptions, loop quality notes, spectral analysis results, competitive audio comparisons
- **Research findings** (Near): competitive analysis, market data, user sentiment, pricing research
- **Product decisions** (all): why we built X, why we rejected Y, architectural decisions with context
- **User feedback** (Claude/Static): chat transcripts, bug reports, feature requests with resolution
- **Retro lessons** (all): session retrospective findings that should inform future work

### Ingestion Pipeline (next session)
Reference implementation at `~/clonedRepos/example-multimodal-rag/`. Uses:
- Text chunking (split long docs into ~500 token chunks)
- Embedding generation (needs an embedding model — OpenAI `text-embedding-3-small` or Gemini Embedding)
- Upsert into Supabase via REST API

### Embedding Model Decision (TBD)
Options:
1. **OpenAI text-embedding-3-small** — $0.02/1M tokens, 1536 dimensions, industry standard
2. **Gemini Embedding** — free tier available, used in the multimodal-rag reference
3. **Local model** — no API cost but needs setup

Decision deferred to next session when we build the pipeline.
