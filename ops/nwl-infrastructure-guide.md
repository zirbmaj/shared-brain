---
title: NWL Infrastructure Guide
date: 2026-03-28
author: relay
scope: shared
summary: Complete guide to the NWL home network, compute cluster, and agent infrastructure
---

# NWL Infrastructure Guide

This document covers the entire NWL infrastructure: two-node compute cluster, agent architecture, semantic search, health monitoring, and how to interact with all of it.

---

## 1. The Network

### Nodes

| Node | Hardware | OS | Role | Tailscale IP |
|------|----------|-----|------|-------------|
| **nwl-mini** | Apple M4, 16GB RAM | macOS 26.2 | Agent host — runs all 10 agents | 100.119.24.85 |
| **nwl-r10** | AMD Ryzen 7 5800X, 32GB RAM, RX 5700 XT 8GB | Ubuntu 24.04 LTS | Compute — postgres, ollama, RAG, UPS, syncthing | 100.69.185.101 |
| **jam's MBA** | MacBook Air | macOS | Remote cockpit — SSH, vigil, monitoring | 100.96.255.35 |

### Mesh Network

All three machines are connected via **Tailscale**, a private mesh VPN. Every node can reach every other node by hostname or IP. No port forwarding, no VPN server, works through NAT and firewalls.

- SSH between nodes: `ssh jambriz@nwl-r10` or `ssh jambrizr@nwl-mini`
- Tailscale SSH is enabled on the R10 (no password needed from authorized machines)
- The mesh works from anywhere — jam can SSH from a coffee shop on his MBA

### Local Network

Both the mini and R10 are on the same LAN (192.168.0.x). The router intercepts external DNS, so all DNS resolution goes through `192.168.0.1`. This is configured in `/etc/resolv.conf` on the R10.

---

## 2. The Mac Mini (nwl-mini)

### What It Does

The mini is the agent host. All 10 agents (6 NWL + 4 meridian) run here as Claude Code instances inside GNU Screen sessions.

### Agents

| Agent | Role | Workspace | Screen Session |
|-------|------|-----------|---------------|
| Claude | Engineering | ~/teams/nwl/claude-workspace | agent-claude |
| Claudia | Creative/Design | ~/teams/nwl/claudia-workspace | agent-claudia |
| Static | QA/Testing | ~/teams/nwl/static-workspace | agent-static |
| Near | Research | ~/teams/nwl/near-workspace | agent-near |
| Hum | Audio Engineering | ~/teams/nwl/hum-workspace | agent-hum |
| Relay | Ops/Process | ~/teams/nwl/relay-workspace | relay |
| Axis | Meridian Lead | ~/shadow-relay-workspace | shadow-relay |
| Forge | Meridian Eng | ~/shadow-claude-workspace | shadow-claude |
| Lens | Meridian Research | ~/shadow-static-workspace | shadow-static |
| Locus | Meridian Ops | ~/shadow-near-workspace | shadow-near |

### How Agents Run

Each agent is a Claude Code v2.1.86 process running in a screen session with:
- `--dangerously-skip-permissions` (no confirmation prompts)
- `--channels plugin:discord@claude-plugins-official` (Discord integration)
- A dedicated `DISCORD_STATE_DIR` pointing to their bot token and access config

### Managing Agents

```bash
# Check who's running
screen -ls

# Cycle (restart) an agent
bash ~/teams/nwl/relay-workspace/shared-brain/ops/agent-cycle.sh claude

# View an agent's screen
screen -r agent-claude
# Detach: Ctrl+A, then D

# Boot all NWL agents
for agent in claude claudia static near hum; do
  bash ~/teams/nwl/relay-workspace/shared-brain/ops/agent-cycle.sh $agent
done

# Boot meridian agents
bash ~/teams/nwl/relay-workspace/shared-brain/ops/launch-shadows.sh
```

### Services on the Mini

| Service | Port | Purpose |
|---------|------|---------|
| Vigil (NWL) | 3847 | Mission control dashboard |
| Vigil (Meridian) | 3849 | Meridian team dashboard |
| Node Health API | 3850 | Agent status, service health |
| Cloudflare Tunnel | — | Public access to vigil via cloudflare |

### Shared Brain

`~/shared-brain/` is the team's shared knowledge base. Every agent has a symlink to it in their workspace. It contains:
- `ops/` — deployment scripts, configs, monitoring tools
- `projects/` — project docs, specs, architecture
- `references/` — research, external docs
- `reports/` — analytics, baselines
- `retros/` — session retrospectives
- `rules/` — team behavioral rules and protocols
- `roles/` — agent identity docs

Shared-brain syncs bidirectionally between the mini and R10 via Syncthing.

---

## 3. The R10 (nwl-r10)

### What It Does

The R10 is the compute node. It runs all backend services that agents query over the mesh.

### Services

| Service | Port | Purpose | Status |
|---------|------|---------|--------|
| PostgreSQL 16 | 5432 | Database with pgvector for embeddings | Running |
| Ollama | 11434 | Local LLM inference (CPU), embedding generation | Running |
| RAG Search API | 8080 | Semantic search over shared-brain | Running |
| RAG Indexer | — | Watches shared-brain, chunks + embeds docs | Running (daemon) |
| Syncthing | 22000 | Bidirectional file sync with mini | Running |
| Node Health API | 3850 | Hardware vitals (CPU temp, disk, UPS, services) | Running |
| NUT (UPS Monitor) | 3493 | APC 600 UPS monitoring + graceful shutdown | Running |
| Home Assistant | 8123 | Smart device control | Not configured yet |

### Database

PostgreSQL with pgvector extension. Three tenant databases:

| Database | Owner | Purpose |
|----------|-------|---------|
| nwl | nwl_app | NWL team data — RAG chunks, memories, metrics |
| meridian | meridian_app | Meridian team data |
| (chowder) | chowder_app | Future — Sonia's project |

Secrets are in `/srv/{nwl,meridian,chowder}/.env` (mode 600, per-tenant).

### Tenant Isolation

Three Linux users with systemd cgroup slices:

| Tenant | User | CPU Weight | RAM Max | Slice |
|--------|------|-----------|---------|-------|
| NWL | nwl-svc | 45% | 14GB | nwl.slice |
| Meridian | meridian-svc | 45% | 14GB | meridian.slice |
| Chowder | chowder-svc | 10% | 4GB | chowder.slice |

### UPS Protection

APC Back-UPS ES 600M1 monitored by NUT:
- Battery: 100%, ~49 min runtime at current load (15%)
- On power loss: NUT detects → alerts vigil → graceful shutdown cascade (R10 services → SSH to mini → agent shutdown → system halt)

### Firewall

UFW is active. Default deny inbound, allow outbound. All tailscale traffic is allowed (services are only reachable over the mesh, not the public internet).

---

## 4. Semantic Search (RAG Pipeline)

### What It Is

Every markdown file in shared-brain is automatically chunked, embedded, and stored in pgvector. Agents can search the entire knowledge base by meaning, not just keywords.

### How It Works

1. RAG Indexer watches `/srv/nwl/shared-brain/` via inotify
2. New/changed files are split into chunks by heading
3. Each chunk is embedded via Ollama (nomic-embed-text, 768-dim vectors)
4. Chunks are stored in PostgreSQL with HNSW index for fast similarity search
5. Agents query the Search API

### Current Index

- **214 documents**, **2,038 chunks** indexed
- Embedding model: nomic-embed-text (768 dimensions)
- Index type: HNSW (cosine distance)

### How to Search

```bash
# Semantic search (finds by meaning)
curl -s -X POST http://nwl-r10:8080/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "what did we decide about pricing", "top_k": 5}'

# Keyword search (exact match, BM25)
curl -s -X POST http://nwl-r10:8080/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "deploy pipeline", "top_k": 5, "mode": "keyword"}'

# Hybrid search (combines semantic + keyword with RRF fusion)
curl -s -X POST http://nwl-r10:8080/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "agent cycling protocol", "top_k": 5, "mode": "hybrid"}'
```

### Response Format

```json
{
  "query": "agent cycle",
  "results": [
    {
      "file": "ops/auto-cycling-awareness.md",
      "title": "auto-cycling awareness",
      "section": "How it works",
      "content": "the full chunk text...",
      "score": 0.695,
      "date": "2026-03-26",
      "doc_type": "config"
    }
  ]
}
```

### Adding New Knowledge

Just write a markdown file to shared-brain. The indexer picks it up automatically via inotify. Frontmatter (title, date, type, scope) is parsed and stored as metadata for filtering.

---

## 5. Health Monitoring

### Node Health API

Both nodes run a health server on port 3850 that reports status as JSON.

```bash
# R10 health (full hardware vitals)
curl -s http://nwl-r10:3850/health

# Mini health (agent status)
curl -s http://nwl-mini:3850/health
```

### What the R10 Reports

- `cpu_temp_c` — CPU temperature in Celsius
- `disk_pct` — disk usage percentage
- `ups` — battery percentage, runtime, load, status (online/on_battery)
- `services` — status of every service (ok/down) with port info
- Ollama: latency, backend (cpu/gpu), model loaded

### What the Mini Reports

- `agents` — status of all 6 NWL agents (online/offline, context percentage)
- `services` — vigil, tunnel status
- `disk_pct` — disk usage

### Vigil Dashboard

Vigil is the ops dashboard accessible via browser:
- Shows agent status, terminal feed, tasks, chat
- **Vitals bar** displays live hardware data from both nodes (temp, disk, UPS)
- Audio: threshold tones when metrics cross green→amber→red
- Auth: username `jam`, password is the MC_AUTH_TOKEN

### Rack Alerting

`rack-alerts.sh` runs every 2 minutes via cron on the R10:
- Checks: disk space, CPU temp, postgres, ollama, syncthing, RAG API, UPS, backup age
- Alerts route to: vigil chat + Discord #bugs webhook
- 30-minute deduplication prevents alert spam
- Severity levels: warn (watch it) and crit (act now)

---

## 6. Syncthing (File Sync)

### What Syncs

`shared-brain/` syncs bidirectionally between mini and R10.

### Ownership Rules

- **Mini writes everything** — all agents write to shared-brain from the mini
- **R10 only writes** `reports/r10-*` prefixed files
- Conflict detection cron runs every 5 minutes, alerts to vigil + #bugs

### Conflict Handling

- `.sync-conflict-*` files are detected automatically
- Append-heavy .md files: auto-merged via union merge
- Structured files (STATUS.md, configs): manual resolution by lane owner

---

## 7. Backup & Recovery

### Automated Backups

- PostgreSQL dumps run daily to `/var/backups/nwl/`
- Dumps are compressed (.sql.gz) with SHA256 checksums
- Retention: 7 days
- Alert fires if newest backup is >25 hours old

### Restore Path (Verified)

1. Restore postgres from dump (214 docs, 2,038 chunks verified)
2. Rebuild pgvector embeddings from markdown source files via ollama
3. Full schema rebuild from `schema.sql`
4. All 15 validation checks pass

### Break-Glass Recovery

If tailscale or networking fails:
- R10: plug in monitor + keyboard, HDMI on rear panel, F2 for BIOS
- Mini: screen share from MBA (`vnc://192.168.0.72`) or physical access
- USB recovery installer in desk drawer (Ubuntu 24.04)
- First-boot script is idempotent — safe to re-run

---

## 8. Service Boot Order

Systemd manages all services on the R10 with explicit dependency chains:

```
tailscale → postgresql → ollama → syncthing → RAG services → health API
```

- `BindsTo=postgresql` on RAG services (they stop if postgres dies)
- `Wants=ollama` (soft dependency — RAG degrades but doesn't die without it)
- All NWL services assigned to `nwl.slice` for resource limits
- Restart policies: always for monitoring, on-failure for services

---

## 9. For Meridian Team

### What You Can Use

- **Semantic search**: same API, same endpoint. Your docs in shared-brain are indexed alongside NWL's. Use `tenant_id` parameter to scope queries to meridian data
- **PostgreSQL**: `meridian` database with `meridian_app` user. Credentials in `/srv/meridian/.env`
- **Ollama**: shared service, available to all tenants
- **Syncthing**: shared-brain syncs for everyone
- **Health API**: same endpoints, same monitoring

### What's Isolated

- Your database is separate from NWL's
- Your systemd services run in `meridian.slice` (45% CPU, 14GB RAM cap)
- Your agent workspaces are in `~/shadow-*-workspace/`

### How Your Agents Interact with the R10

Same as NWL agents — HTTP requests over the tailscale mesh:

```bash
# Search from any agent
curl -s -X POST http://nwl-r10:8080/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "your search query", "top_k": 5}'

# Check R10 health
curl -s http://nwl-r10:3850/health
```

---

## 10. Quick Reference

### SSH Access

```bash
ssh jambriz@nwl-r10          # R10 (tailscale SSH, no password)
ssh jambrizr@nwl-mini         # Mini (needs password)
```

### Key Paths (R10)

| Path | Purpose |
|------|---------|
| /srv/nwl/shared-brain/ | Synced shared-brain |
| /srv/nwl/.env | NWL database credentials |
| /srv/meridian/.env | Meridian database credentials |
| /var/backups/nwl/ | PostgreSQL backups |
| /var/log/rack-alerts.log | Alert history |
| /etc/logrotate.d/nwl | Log rotation config |

### Key Paths (Mini)

| Path | Purpose |
|------|---------|
| ~/shared-brain/ | Shared-brain (syncs to R10) |
| ~/teams/nwl/relay-workspace/shared-brain/ops/ | All deployment scripts |
| ~/.claude/channels/ | Agent Discord configs |
| ~/.env.nowherelabs | Credentials |

### Ports

| Port | Service | Node |
|------|---------|------|
| 3847 | Vigil NWL | Mini |
| 3849 | Vigil Meridian | Mini |
| 3850 | Node Health API | Both |
| 5432 | PostgreSQL | R10 |
| 8080 | RAG Search API | R10 |
| 11434 | Ollama | R10 |
| 22000 | Syncthing | R10 |
| 3493 | NUT (UPS) | R10 |

---

*Written by Relay, session 13.2, 2026-03-28. Last verified against live infrastructure.*
