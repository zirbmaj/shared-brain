---
title: Universal Infrastructure Reference
date: 2026-03-28
type: ops
scope: shared
author: near
summary: Tenant-neutral reference for both nodes, all services, ports, access patterns, resource limits, and failure modes
---

# Infrastructure Reference

Two-node compute cluster serving three tenants (NWL, Meridian, Chowder) over a Tailscale mesh. This document is tenant-neutral — every section applies equally regardless of which team you belong to.

For NWL-specific operational procedures, see `nwl-infrastructure-guide.md`.

---

## 1. Nodes

| Node | Hardware | OS | Tailscale IP | Local IP | Role |
|------|----------|-----|-------------|----------|------|
| nwl-mini | Apple M4, 16GB RAM | macOS 26.2 | 100.119.24.85 | 192.168.0.72 | Agent host — all 10 agents run here |
| nwl-r10 | AMD Ryzen 7 5800X (8c/16t), 32GB RAM, RX 5700 XT 8GB | Ubuntu 24.04 LTS | 100.69.185.101 | 192.168.0.12 | Compute — databases, inference, search, UPS |
| nwl-xps13 | Dell XPS 13 9305, i5-1135G7 (4c/8t), 8GB RAM | Ubuntu 24.04 LTS | 100.64.51.13 | — | Sentinel — test runner, monitoring, lightweight services |
| fran-pc | RX 7900 GRE 16GB VRAM | Windows | 100.89.96.110 | — | GPU compute (intermittent — residential, online when fran is home) |
| jam's MBA | MacBook Air | macOS | 100.96.255.35 | — | Remote cockpit — SSH, monitoring |

nwl-mini and nwl-r10 are on the same LAN (192.168.0.x). DNS resolves through the router at 192.168.0.1. nwl-xps13 is portable (jam's carry device). fran-pc is remote on a residential connection (intermittent availability).

---

## 2. Network

### Tailscale Mesh

Private WireGuard mesh connecting all nodes. No port forwarding, works through NAT. MagicDNS enables hostname-based discovery (`nwl-r10`, `nwl-mini`).

**ACL rules (summary):**

| Source | Destination | Allowed Ports |
|--------|-------------|---------------|
| nwl-mini | nwl-r10 | 22, 3493, 3850, 3860, 5432, 8080, 8090, 8123, 11434, 22000 |
| nwl-r10 | nwl-mini | 22, 3847, 3849, 3850, 22000 |
| jam's devices | both nodes | 22, 3847, 3849, 3850, 8123 |

Full ACL policy: `shared-brain/ops/tailscale-acl-policy.json`

### SSH

```
ssh jambriz@nwl-r10       # Tailscale SSH, no password
ssh jambrizr@nwl-mini      # Standard SSH
```

Fallback (if Tailscale down): use local IPs (192.168.0.12, 192.168.0.72).

### Firewall (R10)

UFW active. Default deny inbound, allow outbound. All Tailscale traffic allowed. Services are reachable only over the mesh, not the public internet.

---

## 3. Services — Mini (macOS)

| Service | Port | Manager | Purpose |
|---------|------|---------|---------|
| NWL agents (6) | — | screen | Claude, Claudia, Static, Near, Hum, Relay |
| Meridian agents (4) | — | screen | Axis, Forge, Lens, Locus (on hold) |
| Vigil v3 (multi-tenant) | 3847 | launchd | Unified ops dashboard — NWL + Meridian + Mesh tabs, GPU monitoring, RAG search |
| Node Health API | 3850 | launchd | Agent status, service health |
| Cloudflare Tunnel | — | launchd | Public access to vigil |

### Agents

Each agent is a Claude Code process in a GNU Screen session with `--dangerously-skip-permissions` and Discord plugin integration. Dedicated `DISCORD_STATE_DIR` per agent.

| Agent | Team | Workspace | Screen Session | Cycle Interval |
|-------|------|-----------|----------------|----------------|
| Claude | NWL | ~/teams/nwl/claude-workspace | agent-claude | 5h |
| Claudia | NWL | ~/teams/nwl/claudia-workspace | agent-claudia | 6h |
| Static | NWL | ~/teams/nwl/static-workspace | agent-static | 6h |
| Near | NWL | ~/teams/nwl/near-workspace | agent-near | 8h |
| Hum | NWL | ~/teams/nwl/hum-workspace | agent-hum | 10h |
| Relay | NWL | ~/teams/nwl/relay-workspace | relay | 6h |
| Axis | Meridian | ~/shadow-relay-workspace | shadow-relay | — |
| Forge | Meridian | ~/shadow-claude-workspace | shadow-claude | — |
| Lens | Meridian | ~/shadow-static-workspace | shadow-static | — |
| Locus | Meridian | ~/shadow-near-workspace | shadow-near | — |

### Mini Health Endpoint

```bash
curl -s http://nwl-mini:3850/health
```

Returns: agent status (online/offline, context %), vigil/tunnel status, disk usage.

Agent status sourced from `/tmp/agent-monitor/{name}-context.json` (< 10 min old = fresh), falls back to `screen -list`.

---

## 4. Services — R10 (Ubuntu 24.04)

| Service | Port | Manager | Status |
|---------|------|---------|--------|
| PostgreSQL 16 + pgvector | 5432 | systemd | Running |
| Ollama | 11434 | systemd | Running (Vulkan GPU) |
| RAG Search API | 8080 | systemd (uvicorn) | Running |
| RAG Indexer | — | systemd (daemon) | Running |
| Syncthing | 22000 | systemd | Running |
| Node Health API | 3850 | systemd | Running |
| NUT (UPS Monitor) | 3493 | systemd | Running |
| Browser (headless Chromium) | 3860 | systemd (docker) | Running |
| Piper TTS | 8091 | nohup (needs systemd unit) | Running |
| Whisper STT | 8090 | systemd | Running |
| Home Assistant | 8123 | systemd (docker) | Running (needs onboarding wizard) |

### R10 Health Endpoint

```bash
curl -s http://nwl-r10:3850/health
```

Returns: CPU temp (C), CPU %, RAM % (total/available), disk %, UPS (battery/runtime/load/status), per-service status with latency.

---

## 5. Tenant Isolation

Three tenants share the R10. Isolation is enforced via Linux users, systemd cgroup v2 slices, and separate databases.

### Resource Limits

| Tenant | User | CPUWeight | MemoryHigh | MemoryMax | IOWeight | Database |
|--------|------|-----------|------------|-----------|----------|----------|
| NWL | nwl-svc | 450 (45%) | 12GB | 14GB | 450 | nwl |
| Meridian | meridian-svc | 450 (45%) | 12GB | 14GB | 450 | meridian |
| Chowder | chowder-svc | 100 (10%) | 3GB | 4GB | 100 | chowder |

- **CPUWeight** is relative, not a reservation. Idle tenants' resources are available to others
- **MemoryHigh** (soft limit): kernel reclaims aggressively when exceeded, services slow but survive
- **MemoryMax** (hard cap): OOM killer activates. blast radius contained to the tenant's slice
- Total RAM allocation: 32GB (no overcommit)
- Shared services (PostgreSQL, Ollama) run in the default system slice, not per-tenant

Slice files: `/etc/systemd/system/{nwl,meridian,chowder}.slice`

### Database Isolation

| Database | App User | Service User | Credentials |
|----------|----------|-------------|-------------|
| nwl | nwl_app | nwl-svc | /srv/nwl/.env |
| meridian | meridian_app | meridian-svc | /srv/meridian/.env |
| chowder | chowder_app | chowder-svc | /srv/chowder/.env |

Credentials: mode 600, 32-char random passwords (openssl). Quarterly rotation: `sudo bash r10-secret-setup.sh --rotate`

---

## 6. Ollama (Local LLM Inference)

### Architecture

CPU-only. The R10's Ryzen 7 5800X handles 7B models at usable latency. The RX 5700 XT (RDNA1/gfx1010) is not officially supported by AMD ROCm — GPU acceleration is not available without manual compilation.

### Performance (CPU-only, mistral:7b)

| Operation | Latency | Notes |
|-----------|---------|-------|
| Embedding (nomic-embed-text) | 200-500ms/chunk | Lightweight, fast even on CPU |
| Generation (mistral:7b, 100 tokens) | 5-15s | Acceptable for batch, slow for interactive |
| Cold start (model load) | 10-30s | First request after service start |
| Memory usage | 4-6GB | mistral:7b quantized, fits with room to spare |

### Thermal

Sustained CPU inference raises temperature. Kernel throttles at 85C. Schedule full re-indexes during off-peak hours (2-5am CST).

### Failure Behavior

When Ollama is down:
- RAG indexer: queues files, retries embedding every 60s
- RAG search: falls back to keyword-only search (response includes `method: "keyword"`)
- Node health: reports `ollama: { status: "down" }`
- All other services: unaffected

### GPU Status

RX 5700 XT (RDNA1/gfx1010) — **GPU inference working via Vulkan** (2026-03-28).

ROCm is incompatible (model loads but compute hangs on gfx1010). Vulkan compute bypasses ROCm entirely and works on all AMD GPUs.

```
OLLAMA_VULKAN=1 → 65.6 tok/s (10x over CPU baseline of 6.7 tok/s)
```

Set in ollama systemd unit so it persists across restarts. The R10 is now a real GPU inference node.

Additionally, fran's PC (RX 7900 GRE, 16GB VRAM, gfx1100, native ROCm) on the tailscale mesh at 100.89.96.110 provides a second GPU node for larger models.

---

## 7. RAG Pipeline (Semantic Search)

### How It Works

1. Syncthing delivers markdown files to `/srv/nwl/shared-brain/` on R10
2. RAG Indexer watches via inotify, splits files into chunks by heading (H2/H3)
3. Each chunk embedded via Ollama (nomic-embed-text, 768-dim vectors)
4. Stored in PostgreSQL + pgvector with HNSW index (cosine distance, m=16, ef_construction=64)
5. Agents query the Search API over the mesh

### Current Index

- 214 documents, 2,038 chunks
- Embedding model: nomic-embed-text (768 dimensions)
- Full-text search: GIN index on tsvector

### Search API

All tenants use the same endpoint. Scope queries with `tenant_id` parameter if needed.

```bash
# Semantic search (vector similarity)
curl -s -X POST http://nwl-r10:8080/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "your question here", "top_k": 5}'

# Keyword search (BM25)
curl -s -X POST http://nwl-r10:8080/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "exact terms", "top_k": 5, "mode": "keyword"}'

# Hybrid search (semantic + keyword, RRF fusion)
curl -s -X POST http://nwl-r10:8080/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "broad topic", "top_k": 5, "mode": "hybrid"}'
```

### Search Enhancements

**Query expansion:** 42-term dictionary at `ops/rag/query_expansions.json`. Vague queries are enriched with domain-specific terms before embedding. Example: "AI decisions" expands to include "roadmap tier strategy consensus." Zero latency, deterministic. Editable without code changes.

**Cross-encoder re-ranking:** Over-fetches top 20 results, re-ranks with `cross-encoder/ms-marco-MiniLM-L-6-v2` (22MB model). Adds ~50ms latency. Method field shows `vector+rerank` or `hybrid_rrf+rerank` when active. Requires `sentence-transformers` in the RAG venv.

**Health endpoint** reports: `reranking: true/false`, `query_expansions: 42`.

### Adding Knowledge

Write a markdown file to `shared-brain/`. The indexer picks it up automatically. Frontmatter (title, date, type, scope) is parsed as filterable metadata.

---

## 8. Syncthing (File Sync)

`shared-brain/` syncs bidirectionally between mini and R10 (to `/srv/nwl/shared-brain/`). Changes propagate in 1-10 seconds.

### Ownership Rules

- Mini writes everything (all agents live on mini)
- R10 only writes `reports/r10-*` prefixed files
- `.stignore` excludes `.env`, `*.key`, `credentials.*`

### Conflict Handling

- `.sync-conflict-*` files detected by a cron every 5 minutes
- Append-heavy .md: auto-merged via union merge
- Structured files (STATUS.md, configs): manual resolution by lane owner
- Conflicts alert to vigil + Discord #bugs

---

## 9. Boot Order & Dependencies (R10)

```
network-online.target
  └── tailscaled
        ├── postgresql (BindsTo by RAG services)
        ├── ollama (Wants by RAG services — soft dependency)
        ├── syncthing (watched by RAG indexer)
        ├── nwl-node-health
        ├── nwl-rag-indexer
        ├── nwl-rag-search
        ├── nwl-homeassistant (docker)
        ├── nwl-browser (docker, headless chromium)
        ├── nut-server
        │     └── nut-monitor
```

### Restart Policies

| Service | Restart | RestartSec | Burst Limit | Rationale |
|---------|---------|------------|-------------|-----------|
| tailscaled | always | 5s | 5 | Mesh is critical |
| postgresql | always | 10s | 3 | Slow restart avoids WAL corruption |
| ollama | on-failure | 15s | 3 | CPU-heavy, slow restart avoids thermal spike |
| syncthing | on-failure | 10s | 3 | Catches up after downtime |
| node-health | always | 5s | 5 | Lightweight, must stay up |
| rag-indexer | on-failure | 30s | 3 | Batch processor, re-indexes on startup |
| rag-search | on-failure | 10s | 3 | HTTP API, clients retry |
| nut-server | always | 5s | 5 | Power monitoring critical |
| nut-monitor | always | 5s | 5 | UPS watchdog, triggers shutdown |

### Failure Cascades

| If this dies... | Then... |
|-----------------|---------|
| PostgreSQL | RAG indexer + search stop (BindsTo). Restart when postgres returns |
| Ollama | RAG services continue degraded (keyword-only search). Auto-recover when ollama returns |
| Tailscale | All services stay running locally. Mini loses mesh connectivity to R10 |
| Syncthing | RAG indexer stays up but processes no new files. Catches up when sync resumes |

---

## 10. UPS Protection

APC Back-UPS ES 600M1 connected to R10 via data port. Monitored by NUT (Network UPS Tools).

- Battery: 100%, ~49 min runtime at 15% load
- Status check: `upsc apc600@localhost`

### Shutdown Sequence (on low battery)

1. NUT detects low battery
2. Alerts vigil + Discord #bugs webhook
3. SSH to mini: runs `agent-shutdown-all.sh` (graceful agent stop)
4. Shutdown mini
5. Shutdown R10

### NUT Config

- Mode: standalone (master on R10)
- Monitor: `apc600@localhost`
- Shutdown command: `/srv/shared/bin/cluster-shutdown.sh`
- Notify script: `/srv/shared/bin/ups-notify.sh`
- FINALDELAY: 10s, DEADTIME: 15s

---

## 11. Backup & Recovery

### Automated Backups

- PostgreSQL dumps daily to `/var/backups/nwl/`
- Compressed (.sql.gz) with SHA256 checksums
- Retention: 7 days
- Alert if newest backup > 25 hours old

### Restore Path (Verified)

1. Restore postgres from dump
2. Rebuild pgvector embeddings from markdown source via ollama
3. Schema rebuild from `schema.sql`
4. 15 validation checks pass

### Break-Glass Recovery

- R10: HDMI on rear panel, F2 for BIOS. USB recovery installer in desk drawer (Ubuntu 24.04)
- Mini: screen share from MBA (`vnc://192.168.0.72`) or physical access
- First-boot script (`r10-first-boot.sh`) is idempotent — safe to re-run

---

## 12. Monitoring & Alerting

### Vigil v3 (Multi-Tenant Dashboard)

Single server on port 3847 (replaces separate NWL/Meridian instances). Accessible via Cloudflare tunnel.

Auth: username `jam`, password is MC_AUTH_TOKEN.

**Tabs:**
- NWL — 6 NWL agents, scoped vitals, NWL tasks and activity
- Meridian — 4 Meridian agents, scoped vitals, Meridian tasks and activity
- All — combined view, all 10 agents with tenant badges
- Mesh — infrastructure only: nodes, services, GPU, health. No agents

**Endpoints (browser, auth required):**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/tenants` | GET | Tenant list with agent counts and accent colors |
| `/api/status?tenant=nwl\|all` | GET | Agent status, filtered by tenant |
| `/api/gpu` | GET | Per-node GPU status (VRAM, model, tok/s, temp) |
| `/api/nodes` | GET | Mesh health — all nodes with vitals and service status |
| `/api/search?q=` | GET | RAG search proxy (converts to POST against R10:8080) |
| `/api/agent-summaries` | GET | All persisted agent status summaries |
| `/api/verifications` | GET | All persisted verification results |
| `/api/changelog?since=` | GET | Recent commits, PRs, deploys across repos |

**Endpoints (agent-facing, no auth):**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/agent-status` | POST | Push structured status summary (`{agent, summary}`) |
| `/api/verification` | POST | Push test/audit results (`{agent, type, results, summary}`) |
| `/api/agent-health` | POST | Push health state change (`{agent, status}`) |

Agent POST data persisted to `data/agent-summaries.json` (survives restarts).

**Websocket events:**
- `gpu-status` — VRAM, loaded model, tok/s, temp (every 10s)
- `node-vitals` — CPU/RAM/disk per node (every 30s)
- `agent-status` — structured summary pushed by agents
- `agent-offline` / `agent-recovered` — health state transitions
- All events include `tenant` field for UI filtering

**Node types:**
- `always-on` — R10, mini. Unreachable after 30s = alarm
- `intermittent` — fran's PC. Unreachable after 5min = expected-offline (no alarm)

**Audio monitoring (vitals-audio.js, 851 lines):**
- GPU inference tone: 35Hz idle → 55Hz at nominal throughput (harmonizes with infrastructure drone)
- GPU thermal alerts: E4 (330Hz) warning at 70C, detuned pair at 80C
- VRAM pressure: gain boost at 60%, noise layer at 80%, tremolo at 95%
- Stereo separation: NWL left-center (-0.3), Meridian right-center (+0.3), infrastructure center
- Drone modulation: GPU thermal detunes second harmonic, VRAM critical doubles LFO rate

Vitals bar shows: CPU temp, GPU temp, disk, UPS, VRAM, inference load per node.

### Rack Alerts

`rack-alerts.sh` runs every 2 minutes via cron on R10:
- Checks: disk space, CPU temp, postgres, ollama, syncthing, RAG API, UPS, backup age
- Routes to: vigil chat + Discord #bugs webhook
- 30-minute deduplication
- Severity: warn (watch) and crit (act now)
- Log: `/var/log/rack-alerts.log`

---

## 13. Key Paths

### R10

| Path | Purpose |
|------|---------|
| /srv/nwl/shared-brain/ | Synced shared-brain |
| /srv/nwl/.env | NWL credentials |
| /srv/meridian/.env | Meridian credentials |
| /srv/chowder/.env | Chowder credentials |
| /srv/nwl/rag/ | RAG indexer + search API source |
| /srv/shared/bin/ | Shared scripts (health, shutdown, notify) |
| /var/backups/nwl/ | PostgreSQL backups |
| /var/log/rack-alerts.log | Alert history |
| /etc/systemd/system/*.slice | Tenant resource slices |
| /etc/systemd/system/nwl-*.service | Service unit files |
| /etc/logrotate.d/nwl | Log rotation |

### Mini

| Path | Purpose |
|------|---------|
| ~/shared-brain/ | Shared knowledge base (syncs to R10) |
| ~/teams/nwl/[agent]-workspace/ | Per-agent working directories |
| ~/.claude/channels/ | Agent Discord configs |
| ~/.env.nowherelabs | Product credentials |
| /tmp/agent-monitor/ | Agent context freshness files |

---

## 14. Port Map (Complete)

| Port | Service | Node | Access |
|------|---------|------|--------|
| 22 | SSH | Both | Tailscale mesh |
| 3493 | NUT (UPS) | R10 | Tailscale mesh |
| 3847 | Vigil v3 (multi-tenant) | Mini | Cloudflare tunnel + mesh |
| 3850 | Node Health API | Both | Tailscale mesh |
| 3860 | Browser (headless Chromium) | R10 | Tailscale mesh |
| 5432 | PostgreSQL | R10 | Tailscale mesh |
| 8080 | RAG Search API | R10 | Tailscale mesh |
| 8090 | Whisper STT | R10 | Tailscale mesh |
| 8091 | Piper TTS | R10 | Tailscale mesh |
| 8123 | Home Assistant | R10 | Tailscale mesh |
| 11434 | Ollama | R10 | Tailscale mesh |
| 22000 | Syncthing | Both | Tailscale mesh |

---

## 15. Related Documents

| Document | Path | Covers |
|----------|------|--------|
| NWL Infrastructure Guide | ops/nwl-infrastructure-guide.md | NWL-specific operational procedures |
| Tenant Resource Slices | ops/r10-tenant-slices.md | Detailed cgroup v2 configuration |
| Tailscale ACL Policy | ops/tailscale-acl-policy.json | Full access control rules |
| Ollama Fallback Behavior | ops/r10-ollama-fallback.md | CPU-only degradation details |
| Service Architecture | projects/homelab-service-architecture.md | Communication patterns, health monitoring design |
| Systemd Boot Order | ops/r10-systemd/README.md | Dependency chain, failure policies |
| RAG Schema | ops/rag/schema.sql | Database tables, indexes, embeddings |
| UPS Config | ops/r10-nut-config/ | NUT installation, monitoring, shutdown scripts |
| First Boot | ops/r10-first-boot.sh | Idempotent R10 setup from fresh Ubuntu |
| Security Model | projects/homelab-security-model.md | Tenant isolation design |

---

**Note:** R10 services run from `/srv/nwl/rag/` and `/srv/shared/bin/`, not directly from the syncthing path at `/srv/nwl/shared-brain/ops/`. Syncthing updates the source files but running copies must be manually synced to service directories. This applies to health-server.py, search_api.py, and other R10 services.

*Written by Near, session 13.2, 2026-03-28. Updated session 14 with Vigil v3, Vulkan GPU, fran-pc, Piper TTS, RAG re-ranking + query expansion, CPU/RAM health fields. Factual reference — no opinions, no procedures.*
