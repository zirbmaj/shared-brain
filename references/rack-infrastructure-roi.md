---
title: Rack Infrastructure ROI Analysis
date: 2026-03-28
type: research
scope: shared
author: near
summary: Before/after analysis of 2-node homelab buildout — what it unlocked, utilization, API savings, cloud comparison
---

# Rack Infrastructure ROI Analysis

Quantifying the value of the 2-node homelab (nwl-mini + nwl-r10) with fran's PC as a third mesh node.

---

## 1. Hardware Investment

| Node | Hardware | Estimated Cost | Role |
|------|----------|---------------|------|
| nwl-mini | Mac Mini M4, 16GB | ~$600 | Agent host (10 agents) |
| nwl-r10 | Alienware R10, Ryzen 7 5800X, 32GB, RX 5700 XT | ~$400 (used) | Compute node |
| APC UPS | Back-UPS ES 600M1 | ~$70 | Power protection |
| Networking | Tailscale (free), existing LAN | $0 | Mesh VPN |
| **Total** | | **~$1,070** | One-time cost |

Fran's PC is his existing hardware — $0 incremental cost to the project.

---

## 2. What R10 Unlocked (Before → After)

### Before R10 (mini only, sessions 1-6)
- All compute on Mac Mini
- No local databases — fully dependent on Supabase
- No local inference — every AI query costs API tokens
- No embeddings — no semantic search over docs
- No TTS — browser Web Speech API only
- No file sync infrastructure
- No hardware monitoring
- No GPU compute

### After R10 (sessions 7-14)

| Capability | Service | Port | Status | What It Enables |
|-----------|---------|------|--------|----------------|
| Local database | PostgreSQL 16 + pgvector | 5432 | Running | RAG storage, agent memory, metrics. 3 tenant databases |
| Local inference | Ollama (Vulkan GPU) | 11434 | Running | 65.6 tok/s. Doc Q&A, RAG chatbot, embeddings. $0 per query |
| Semantic search | RAG Search API | 8080 | Running | 57ms queries over 214 docs / 2,038 chunks. Query expansion + re-ranking |
| Text-to-speech | Piper TTS | 8091 | Running | 64 cached phrases at 0.8ms. Vigil voice alerts |
| Speech-to-text | Whisper STT | 8090 | Running | Voice input pipeline (spec phase) |
| File sync | Syncthing | 22000 | Running | Bidirectional shared-brain sync, 1-10s propagation |
| Health monitoring | Node Health API | 3850 | Running | CPU, RAM, disk, GPU, UPS, service status |
| Power protection | NUT (UPS) | 3493 | Running | 49 min runtime, graceful shutdown cascade |
| Smart home | Home Assistant | 8123 | Running | Device control (needs onboarding) |

**9 services running on R10, all at $0/month ongoing cost.**

---

## 3. Current Utilization

### R10 (as of session 14)

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| CPU | 0.9% | 100% (8c/16t) | **<1%** — massively underutilized |
| RAM | 14.8% (4.6GB) | 31.3GB | **15%** — 26.6GB available |
| Disk | 40% | 60% free | Moderate |
| GPU VRAM | 5.7GB (mistral + nomic-embed + llama3) | 8GB | **71%** — room for one more small model |
| GPU compute | Idle between queries | 65.6 tok/s capacity | Low — burst workload, idle most of the time |

### Mini

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| Agents | 10/10 running | — | Full capacity |
| RAM | ~12GB (10 Claude Code processes) | 16GB | **75%** — tight |
| Services | 3 (vigil, health, tunnel) | — | Light |

### Fran's PC (when online)

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| GPU VRAM | 0GB | 16GB | **0%** — completely idle |
| Everything else | Idle | Full capacity | Untouched |

**Key finding: R10 is massively underutilized on CPU and RAM. GPU VRAM is 71% utilized. Fran's PC is 0% utilized.**

---

## 4. API Cost Savings from Local Inference

### What We Run Locally (Zero API Cost)

| Workload | Queries/Day (est.) | If API (Sonnet 4.6) | Local Cost |
|----------|-------------------|---------------------|------------|
| RAG search (embedding) | ~50 | ~$0.15/day (embedding API) | $0 |
| Doc Q&A (llama3:8b) | ~20 | ~$0.60/day (Sonnet, 1K tokens/query) | $0 |
| RAG chatbot | ~10 | ~$0.45/day (Sonnet, 1.5K tokens/query) | $0 |
| TTS (piper) | ~30 phrases/day | ~$0.15/day (ElevenLabs at scale) | $0 |
| Re-ranking (cross-encoder) | ~50 | ~$0.50/day (API-based re-ranking) | $0 |
| **Daily total** | | **~$1.85/day** | **$0** |
| **Monthly total** | | **~$55/month** | **$0** |

### What We Still Pay For

| Service | Cost | Purpose |
|---------|------|---------|
| Anthropic API (Claude Code agents) | ~$100-200/mo (est.) | 10 agents running Claude Opus/Sonnet |
| Supabase (2 projects) | $0 (free tier) | Product databases (drift, static fm) |
| Vercel | $20/mo (pro) | Frontend hosting |
| ElevenLabs | $5/mo | DJ voice intros (brand voice) |
| Cloudflare | $0 (free) | Tunnel for vigil |
| **Total ongoing** | **~$125-225/mo** | |

### Savings Trajectory

The $55/mo local inference savings grows as we add more workloads:
- Post-launch analytics processing → +$20-30/mo saved
- Agent pre-screening via local Qwen → +$30-50/mo saved (from model optimization research)
- Model downgrade (Sonnet default) → +$50-100/mo saved

**Projected savings with full local utilization: $150-235/mo** — the R10 pays for itself in 2-5 months.

---

## 5. Cloud-Only Cost Comparison

What would our current infrastructure cost on cloud services?

| Service | Cloud Equivalent | Monthly Cost |
|---------|-----------------|-------------|
| GPU inference (65 tok/s) | AWS g4dn.xlarge (T4 GPU) | $380/mo (24/7 on-demand) |
| PostgreSQL + pgvector | AWS RDS db.t4g.small | $30/mo |
| RAG API + indexer | AWS ECS (0.5 vCPU, 1GB) | $15/mo |
| TTS service | AWS ECS or Lambda | $10/mo |
| Whisper STT | AWS ECS with GPU | $50/mo (shared g4dn) |
| File sync | AWS EFS or S3 sync | $5/mo |
| Health monitoring | CloudWatch | $10/mo |
| UPS protection | N/A (cloud handles) | $0 |
| Agent hosting (10 agents) | Not replaceable — Claude Code needs local | Can't cloud this |
| **Total cloud equivalent** | | **~$500/mo** |

**Cloud cost: ~$500/mo. Our cost: ~$0/mo (after one-time $1,070 investment).**

The R10 alone replaces ~$500/mo of cloud infrastructure. At that rate, the hardware investment pays for itself in **~2 months**.

Note: The GPU instance ($380/mo) dominates the cloud cost. Without GPU inference needs, the comparison drops to ~$120/mo — still more than our $0 ongoing cost.

---

## 6. What's Underutilized

| Resource | Current | Potential |
|----------|---------|-----------|
| R10 CPU (99% idle) | Handles burst RAG/TTS queries | Could run continuous batch jobs: analytics processing, doc summarization, spectral analysis |
| R10 RAM (85% free, 26.6GB) | 4.6GB used by services | Could run additional databases, cache layers, or larger models |
| Fran's PC (100% idle) | Expected-offline when fran isn't home | When online: 16GB VRAM for large model inference, batch processing, code review |
| R10 GPU (burst-idle) | 65.6 tok/s when queried, idle otherwise | Could run continuous inference for agent pre-screening, analytics, content generation |
| Syncthing capacity | Only syncs shared-brain | Could sync agent workspaces, logs, or media assets |

### Specific Underutilized Opportunities

1. **Qwen 2.5 Coder 7B on R10** — local code pre-screening for PRs. ~5GB VRAM, can time-share with current models. Reduces API calls for obvious issues
2. **Batch analytics on R10 CPU** — process Supabase analytics data locally instead of through API queries. R10 has direct postgres access
3. **Agent workspace backup** — syncthing could mirror agent workspaces to R10 for redundancy
4. **Fran's PC for 14B models** — when online, run larger inference models that don't fit R10's 8GB VRAM

---

## 7. Capability Gains (Non-Financial)

Things we can do now that were impossible before R10:

1. **RAG chatbot** — jam asks questions about docs, gets grounded answers in 2-3 seconds. Not possible without local inference + local database + local embeddings
2. **Vigil as ops platform** — real-time health monitoring, agent status, service inventory, mesh topology. Requires a compute node running health APIs
3. **Voice alerts** — piper TTS announces agent failures. Web Speech API was the only option before
4. **Multi-tenant isolation** — 3 separate database tenants with cgroup resource limits. Can't do this on Supabase free tier
5. **Query expansion + re-ranking** — search quality improvements running on local compute. Would cost per-query on cloud
6. **69/69 verification suite** — health checks across 2 nodes, 10+ services. Requires infrastructure to check
7. **Offline resilience** — if internet goes down, local inference, database, and monitoring still work. Cloud-only = total failure

---

## 8. Summary

| Metric | Value |
|--------|-------|
| Hardware investment | ~$1,070 (one-time) |
| Monthly ongoing cost | $0 |
| Cloud equivalent cost | ~$500/mo |
| Payback period | ~2 months |
| Current local inference savings | ~$55/mo |
| Projected savings (full utilization) | ~$150-235/mo |
| Services running | 9 on R10 + 3 on mini |
| Utilization | R10 CPU <1%, RAM 15%, GPU 71% |
| Underutilized capacity | R10 CPU, R10 RAM, fran's PC (100% idle) |

**The rack pays for itself in 2 months against cloud pricing. The bigger value is capabilities that didn't exist before: RAG chatbot, voice alerts, semantic search, multi-tenant isolation, offline resilience. These aren't cost savings — they're new capabilities that make the team more effective.**

The underutilization on R10 CPU/RAM and fran's PC means we have significant headroom for growth without additional hardware investment.

---

*Near, session 14, 2026-03-28. Estimates based on current usage patterns and published cloud pricing.*
