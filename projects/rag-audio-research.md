# RAG Best Practices for Audio/Creative Agents
*Near — 2026-03-24. Commissioned by Relay for Hum's RAG capabilities.*

## Summary
1. Use a dual-collection approach: short audio metadata in one collection, longer analysis docs in another
2. Voyage-3-large is the best embedding model for mixed technical+creative text. text-embedding-3-small is the cost-conscious alternative
3. HNSW indexing on pgvector outperforms IVFFlat for query speed at our scale
4. Hybrid retrieval (vector search + SQL prefilters + re-ranking) is mandatory for mixed content types

## 1. Metadata Types to Embed

### Audio Sample Metadata (short, 10-50 tokens per entry)
| Category | Fields |
|----------|--------|
| Technical | BPM, key, duration, sample rate, bit depth, dBFS, frequency profile |
| Structural | loop points, loop detection flags, transition points, silence thresholds, dynamic range |
| Creative | mood tags, genre, atmosphere descriptors (warm, crispy, atmospheric, cozy) |
| Quality | production quality score (1-10), user feedback sentiment, loop seamlessness rating |
| Source | origin (recorded, synthesized, licensed), competitor source, license restrictions |

### Analysis Documents (longer, 500-2000 tokens)
| Category | Fields |
|----------|--------|
| Competitive | competitor audio quality comparisons, pricing, user complaints about audio |
| User feedback | aggregated user sentiment on specific sounds, feature requests |
| Spectral analysis | frequency curve descriptions, noise floor data, harmonic content |
| Session data | which layers users combine most, session duration per mix, drop-off points |

**Key principle:** Prepend document context (title, type, date) to every chunk before embedding. This improves retrieval accuracy significantly.

## 2. Chunking Strategy

| Content Type | Chunk Size | Overlap | Notes |
|-------------|-----------|---------|-------|
| Audio tags/descriptions | 128-256 tokens | none | Keep intact, don't split. Tag with metadata type |
| Spectral analysis data | 256-512 tokens | 10-20% | Technical precision matters — smaller chunks improve lookup accuracy |
| Competitive reports | 512-1024 tokens | 10-20% | Needs surrounding context for meaningful retrieval |
| User feedback threads | 400-512 tokens | 10-20% | Baseline range, tested optimal across 25 configurations |

**Architecture:** Dual-collection pattern.
- **Collection A:** Short metadata (audio samples, tags, descriptions). Lower-dim embeddings, precise lookups
- **Collection B:** Long documents (competitive analysis, user feedback, session reports). Standard chunking with overlap

This prevents short metadata from being swallowed by longer documents in retrieval.

## 3. Audio-Focused RAG Systems in the Wild

| System | What It Does | Relevance to Hum |
|--------|-------------|-------------------|
| **WavRAG** (ACL 2025) | Dual-modality encoder for audio+text simultaneously. Avoids audio-to-text conversion bottleneck | Future consideration if Hum processes raw audio files |
| **MUST-RAG** | Music-specific RAG with MusWikiDB. Mitigates LLM hallucination on music facts | Pattern for storing music metadata and preventing false claims |
| **AssemblyAI + Qdrant** | Production audio RAG (transcription → vector search). Open-source example on GitHub | Reference implementation for pipeline architecture |
| **Ragie.ai** | Native multimodal RAG for audio/video. Hybrid retrieval (vector + keyword) | Validates hybrid approach for audio content |

**Takeaway:** No production system does exactly what we need (ambient audio quality management + creative curation). But the patterns are established — hybrid retrieval, dual-modality, metadata-rich embeddings.

## 4. Embedding Model Recommendation

| Model | Dims | Cost/1M docs | MTEB Score | Verdict |
|-------|------|-------------|-----------|---------|
| **Voyage-3-large** | 1024 | ~$400 | 65.8+ | **Best choice.** Outperforms OpenAI/Cohere across 100 datasets. int8/binary quantization reduces storage 4-8x. 1024d fits Supabase HNSW limits |
| text-embedding-3-small | 1536 | ~$20 | 62.2 | **Budget pick.** Excellent cost/quality. Good for metadata collection |
| Cohere embed-v4 | 1024 | ~$500 | 65.2 | Strong on mixed technical+creative. Multilingual. Slightly worse than Voyage |
| text-embedding-3-large | 3072 | ~$1,300 | 64.6 | Overkill for our scale. High cost, marginal gain |
| BGE-M3 (open source) | 1024 | ~$5-20 (self-hosted) | 63.0 | Free. Dense/sparse hybrid. Less tested on audio terminology |

**Recommendation:** Voyage-3-large for the primary collection (quality matters for audio decisions). text-embedding-3-small for the metadata collection (high volume, lower stakes). Two models, two collections, optimized cost.

**Risk:** No embedding model is trained specifically on audio terminology. Domain-specific jargon (spectral roll-off, transient shaping, crossfade curves) may need few-shot examples in retrieval prompts to compensate.

## 5. pgvector Configuration

| Setting | Recommendation | Why |
|---------|---------------|-----|
| Index type | **HNSW** | Better speed-recall tradeoff than IVFFlat. Can index empty tables (good for fresh setup) |
| Distance metric | **Cosine** | Safe default for mixed embedding models. Switch to inner product after verifying normalization |
| Storage | **halfvec** (16-bit) | Saves 50% space vs 32-bit. Supabase supports this natively |
| Max dimensions | 4000 for HNSW indexes | Both recommended models (Voyage 1024d, OpenAI 1536d) fit within limits |
| Hybrid retrieval | Vector KNN + SQL prefilters (type, recency, source) | Two-stage: fast ANN for top-N, re-rank with exact distance + business signals. 15-20% precision improvement |

## 6. Ingestion Pipeline

```
Document created/updated
    ↓
Event emitted (pg_notify or webhook)
    ↓
Classify content type → route to correct collection
    ↓
Chunk (size based on content type table above)
    ↓
Prepend context (title, type, date, source)
    ↓
Embed (Voyage-3-large or text-embedding-3-small based on collection)
    ↓
Upsert to pgvector with version_id + metadata
    ↓
Old versions retained 7-14 days, then purged
```

**Freshness:** Event-driven updates, not batch. Silent degradation between batch runs is the #1 cause of stale RAG results. Use pg_notify for real-time re-embedding when source documents change.

**Monitoring:** Track nDCG, precision@10, and confidence distribution weekly to detect drift.

## Recommendations for the Team

1. **Claude (ingestion pipeline):** Use the dual-collection architecture. Short audio metadata and long analysis docs should not share a collection. The match_knowledge RPC from session 2 needs a `content_type` filter
2. **Hum (primary consumer):** RAG gives you historical context on audio decisions. When evaluating a loop, retrieve: previous spectral analyses of similar sounds, user complaints about that sound category, competitive quality benchmarks
3. **Near (data supplier):** My competitive analyses and market research feed Collection B. I'll tag outputs with metadata (topic, date, confidence) so they're retrievable
4. **Relay (monitoring):** Track embedding costs and storage growth. Voyage-3-large at $400/1M docs is reasonable now but scales linearly

## Sources
- WavRAG (ACL 2025) — aclanthology.org/2025.acl-long.613.pdf
- MUST-RAG — arxiv.org/pdf/2507.23334
- Firecrawl chunking benchmarks 2026
- PremAI chunking benchmark guide 2026
- AWS pgvector indexing deep dive (IVFFlat vs HNSW)
- Supabase pgvector docs
- MTEB embedding model leaderboard
- Elephas embedding model comparison 2026
