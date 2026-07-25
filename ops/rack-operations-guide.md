---
title: NWL Rack Operations Guide
date: 2026-03-28
type: reference
scope: infrastructure
owner: claude
status: live
---

# NWL Rack Operations Guide

Complete reference for the 2-node NWL cluster. Written for anyone who needs to understand, use, or maintain the infrastructure.

## The Setup

Two machines connected via Tailscale mesh VPN. All inter-node traffic is encrypted and routed through WireGuard tunnels.

### NWL-Mini (Mac Mini — macOS)
**Role:** Agent host, web serving, external connectivity

- **What runs here:** 6 AI agents (claude, claudia, static, near, hum, relay), 2 vigil dashboards, Cloudflare tunnels to the internet
- **Tailscale IP:** 100.119.24.85
- **Hostname:** nwl-mini (via Tailscale MagicDNS)
- **Local IP:** 192.168.0.72

### NWL-R10 (Alienware R10 — Ubuntu 24.04 LTS)
**Role:** Compute, storage, monitoring, AI inference

- **What runs here:** PostgreSQL + pgvector, Ollama (local LLM), RAG pipeline, UPS monitoring, Syncthing
- **Tailscale IP:** 100.69.185.101
- **Hostname:** nwl-r10 (via Tailscale MagicDNS)
- **Local IP:** 192.168.0.12
- **CPU:** AMD Ryzen 7 5800X (8 cores, 16 threads)
- **RAM:** 32GB
- **GPU:** AMD RX 5700 XT (8GB, not used for AI — CPU only)
- **Storage:** NVMe SSD
- **UPS:** APC Back-UPS ES 600M1 (100% battery, ~49 min runtime)

### NWL-XPS13 (Dell XPS 9305 — Ubuntu 24.04 LTS)
**Role:** Sentinel node, monitoring, test runner, Vigil host (planned)

- **What runs here:** Health server, Playwright test runner (planned), sentinel agent (planned), syncthing
- **Tailscale IP:** 100.64.51.13
- **Hostname:** nwl-xps13 (via Tailscale MagicDNS)
- **User:** agent
- **CPU:** Intel i5-1135G7 (8 threads)
- **RAM:** 7.5GB (soldered, not upgradeable)
- **Storage:** 98GB NVMe SSD
- **Battery:** Internal (resilience node — survives UPS depletion)
- **Auth:** SSH key only (password auth disabled)

### NWL-Flip7 (Galaxy Flip 7)
**Role:** SMS alerting, cellular failover, mobile testing, NFC auth (planned)

- **Tailscale IP:** TBD (not yet provisioned)
- **Hostname:** nwl-flip7
- **Connectivity:** Cellular (LTE/5G) + WiFi
- **Note:** Dedicated infrastructure device, not jam's daily phone

### Jam's Devices
- **MacBook Air:** 100.96.255.35 (Tailscale SSH access to all nodes)
- **iPhone 15 Pro:** Push notifications via ntfy.sh (planned), daily carry

## How to Connect

### SSH Access
Both machines have Tailscale SSH enabled. From any device on the tailnet:

```bash
# Connect to R10
ssh jambriz@nwl-r10

# Connect to Mini (standard SSH)
ssh jambrizr@nwl-mini
```

No passwords needed — Tailscale handles authentication via your Tailscale account.

### From the local network
If Tailscale is down, use local IPs:
```bash
ssh jambriz@192.168.0.12    # R10
ssh jambrizr@192.168.0.72   # Mini
```

## Services Running on the R10

| Service | Port | What it does | Status |
|---------|------|-------------|--------|
| PostgreSQL + pgvector | 5432 | Database with vector search. Stores agent memory, document embeddings, logs | Running |
| Ollama | 11434 | Local LLM inference (CPU). Runs nomic-embed-text for embeddings | Running |
| RAG Search API | 8080 | Semantic search over shared-brain documents | Running |
| RAG Indexer | — | Watches shared-brain for file changes, auto-embeds new/updated docs | Running |
| Node Health API | 3850 | Reports service status, CPU temp, disk usage, UPS status | Running |
| NUT (upsd) | 3493 | UPS monitoring — battery %, load, runtime, power status | Running |
| Syncthing | 22000 | Bidirectional file sync of shared-brain between Mini and R10 | Running |
| Home Assistant | 8123 | Smart plug control (not configured yet) | Pending |

## How to Search

### Semantic Search (find documents by meaning)

Search the entire shared-brain using natural language. The system uses vector embeddings — you don't need exact keywords.

```bash
# From any machine on the tailnet:
curl -s -X POST http://nwl-r10:8080/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "how does the UPS shutdown work", "top_k": 5}' | python3 -m json.tool
```

**Parameters:**
- `query` — natural language question or topic
- `top_k` — number of results (1-20, default 5)
- `doc_type` — filter by type: "project", "retro", "operations", "research", "reference"
- `scope` — filter by scope: "infrastructure", "shared", etc.
- `since` — ISO date string, only docs created after this date
- `hybrid` — set to `true` for combined vector + keyword search (better for exact terms)

**Examples:**
```bash
# Find architecture decisions
curl -s -X POST http://nwl-r10:8080/search \
  -d '{"query": "architecture decisions for the rack", "top_k": 3}'

# Search only retros
curl -s -X POST http://nwl-r10:8080/search \
  -d '{"query": "lessons learned", "doc_type": "retro", "top_k": 5}'

# Hybrid search (good for specific terms)
curl -s -X POST http://nwl-r10:8080/search \
  -d '{"query": "syncthing conflict resolution", "hybrid": true, "top_k": 3}'

# Recent docs only
curl -s -X POST http://nwl-r10:8080/search \
  -d '{"query": "rack deployment", "since": "2026-03-27", "top_k": 5}'
```

**Response format:**
```json
{
  "query": "UPS shutdown",
  "results": [
    {
      "file": "projects/homelab-ups-shutdown.md",
      "title": "UPS Graceful Shutdown Plan",
      "section": "Architecture",
      "content": "...",
      "score": 0.77,
      "date": "2026-03-27",
      "doc_type": "project"
    }
  ],
  "search_time_ms": 45.2,
  "method": "vector"
}
```

### Index Stats
```bash
curl -s http://nwl-r10:8080/stats | python3 -m json.tool
# Returns: {"documents": 214, "chunks": 2038, "tenant": "nwl"}
```

### Health Check
```bash
curl -s http://nwl-r10:8080/health | python3 -m json.tool
# Returns: {"status": "ok", "postgres": true, "ollama": true}
```

## How Files Get Indexed

1. **Syncthing** syncs `~/shared-brain/` (Mini) ↔ `/srv/nwl/shared-brain/` (R10) in 1-10 seconds
2. **RAG Indexer** watches `/srv/nwl/shared-brain/` via inotify
3. When a `.md` file changes, the indexer:
   - Parses YAML frontmatter (title, type, date, scope)
   - Splits the body into chunks by heading (H2/H3)
   - Generates vector embeddings via Ollama (nomic-embed-text, 768 dimensions)
   - Upserts the document and chunks into PostgreSQL + pgvector
4. **RAG Search API** queries the vectors using cosine similarity

**What gets indexed:** All `.md` files in shared-brain (excluding .sync-conflict files)
**What doesn't get indexed:** Binary files, audio, images, .env files, anything in .stignore

## How Agents Will Interact with the R10

### Current state (session 13.2)
Agents run on the Mini. They can query the R10's services over the Tailscale mesh:

```bash
# Agent searches shared-brain
curl -s -X POST http://nwl-r10:8080/search -d '{"query": "what did we decide about auth"}'

# Agent checks R10 health
curl -s http://nwl-r10:3850/health

# Agent checks UPS status
curl -s http://nwl-r10:3850/health | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)['ups'], indent=2))"
```

### Future state
- Agents can be moved to the R10 for faster database/LLM access
- Whisper STT service (specced, awaiting greenlight) would let jam speak commands to agents
- Fish-speech TTS (requires GPU upgrade) would give agents distinct voices

## Monitoring

### Node Health API
Both nodes expose health data on port 3850:

```bash
# R10 health (full hardware + service data)
curl -s http://nwl-r10:3850/health | python3 -m json.tool

# Mini health (agent status + service data)
curl -s http://nwl-mini:3850/health | python3 -m json.tool
```

**R10 health response includes:**
- `cpu_temp_c` — CPU temperature in Celsius
- `disk_pct` — disk usage percentage
- `ups.status` — online / on_battery / low_battery
- `ups.battery_pct` — battery charge percentage
- `ups.runtime_seconds` — estimated runtime on battery
- `ups.load_pct` — UPS load percentage
- `services.*` — status of each service (ok / degraded / down)
- `services.ollama.latency_ms` — LLM inference latency
- `services.ollama.backend` — cpu or gpu

### Vigil Dashboard
The vigil dashboard (mission-control) has a **vitals bar** showing live hardware status from both nodes. Polls every 15 seconds. Includes audio feedback — a 55Hz infrastructure drone that modulates with system state.

Access via Cloudflare tunnel or locally at `http://localhost:3847`

### UPS Monitoring
The UPS is monitored by NUT (Network UPS Tools):
```bash
# Full UPS data
ssh jambriz@nwl-r10 "upsc apc600@localhost"

# Quick battery check
ssh jambriz@nwl-r10 "upsc apc600@localhost battery.charge"
ssh jambriz@nwl-r10 "upsc apc600@localhost battery.runtime"
```

On low battery, NUT triggers a graceful shutdown sequence:
1. Notify via ups-notify.sh (Discord #bugs + vigil)
2. SSH to Mini, run agent-shutdown-all.sh (graceful agent stop)
3. Shutdown Mini
4. Shutdown R10

## Shared Brain (File Sync)

### What is shared-brain?
A directory of markdown files that serves as the team's single source of truth. Contains:
- Project specs and architecture docs
- Session retros
- Ops scripts and configs
- Research references
- Backlog and status tracking
- Agent role definitions

### How sync works
- **Syncthing** handles bidirectional sync between Mini and R10
- Changes propagate in 1-10 seconds
- Conflicts create `.sync-conflict-*` files (no silent data loss)
- `.stignore` excludes secrets (.env, *.key, credentials.*)
- Conflict detection cron runs every 5 minutes, alerts to Discord #bugs

### Ownership rules
- **Mini writes everything** (all agents are on Mini)
- **R10 only writes** `reports/r10-*` prefixed files
- This minimizes conflict risk since all writers are on one node

## Database

### Tenant isolation
Three separate database users, each with their own schema:

| Tenant | DB User | Database | Use |
|--------|---------|----------|-----|
| NWL | nwl_app | nwl | Agent memory, embeddings, RAG |
| Meridian | meridian_app | meridian | Meridian team data |
| Chowder | chowder_app | chowder | PA bot data |

Credentials are in `/srv/{tenant}/.env` (mode 600, owner = tenant user).

### Connecting
```bash
# From the R10 locally
sudo -u postgres psql -d nwl

# From Mini over Tailscale
psql -h nwl-r10 -U nwl_app -d nwl
# (password is in /srv/nwl/.env on the R10)
```

## Security

### Network
- **UFW firewall** on R10: denies all incoming except Tailscale interface
- **Tailscale ACLs** restrict which devices can reach which ports
- No ports are exposed to the public internet on the R10
- All inter-node traffic is WireGuard encrypted

### Users
- Each tenant has a dedicated Linux user (nwl-svc, meridian-svc, chowder-svc)
- Workspace directories are mode 700 (owner-only)
- Services run under tenant users via systemd (no root)
- systemd units include NoNewPrivileges, ProtectHome, ProtectSystem

### Secrets
- Per-tenant `.env` files at `/srv/{tenant}/.env` (mode 600)
- Generated with 32-char random passwords via openssl
- Quarterly rotation: `sudo bash r10-secret-setup.sh --rotate`
- No secrets in git, no secrets in Discord

## Backup & Restore

### Automated backup
```bash
# Run backup (non-destructive, creates dump in /var/backups/nwl/)
sudo bash /srv/nwl/shared-brain/ops/r10-backup-restore-test.sh
```

### Restore from backup
```bash
# Full restore with verification
sudo bash /srv/nwl/shared-brain/ops/r10-backup-restore-test.sh --destructive
```

### Rebuild from source
If everything is lost, the shared-brain markdown files are the source of truth:
1. Reinstall PostgreSQL + pgvector
2. Apply schema: `cat schema.sql | psql -d nwl`
3. Run indexer: `python3 indexer.py --reindex --once`
4. All 214 documents and 2,038 chunks are regenerated from .md files

## Common Tasks

### Restart a service
```bash
ssh jambriz@nwl-r10 "sudo systemctl restart nwl-rag-search"
```

### Check all service status
```bash
ssh jambriz@nwl-r10 "sudo systemctl status nwl-* --no-pager"
```

### Pull a new Ollama model
```bash
ssh jambriz@nwl-r10 "ollama pull mistral:7b"
```

### Force re-index all documents
```bash
ssh jambriz@nwl-r10 "sudo -u nwl-svc bash -c 'source /srv/nwl/.env && export PG_CONNSTR=\"dbname=nwl user=nwl_app password=\$PGPASSWORD host=localhost\" && /srv/nwl/rag/venv/bin/python3 /srv/nwl/rag/indexer.py --reindex --once'"
```

### Check UPS battery
```bash
ssh jambriz@nwl-r10 "upsc apc600@localhost battery.charge && upsc apc600@localhost battery.runtime"
```

### Check disk usage
```bash
ssh jambriz@nwl-r10 "df -h / /srv"
```

### View service logs
```bash
ssh jambriz@nwl-r10 "sudo journalctl -u nwl-rag-search --since '1 hour ago' --no-pager"
```

## DNS Note
The home router (192.168.0.1) intercepts outbound DNS on port 53. External DNS resolvers (8.8.8.8, 1.1.1.1) won't work — all DNS must go through the router. This is configured in `/etc/resolv.conf` on the R10. If DNS breaks after a reboot:
```bash
echo "nameserver 192.168.0.1" | sudo tee /etc/resolv.conf
```

## Port Registry

| Port | Node | Service |
|------|------|---------|
| 3493 | R10 | NUT (UPS monitoring) |
| 3847 | Mini | Vigil NWL (ops dashboard) |
| 3849 | Mini | Vigil Meridian |
| 3850 | Both | Node Health API |
| 5432 | R10 | PostgreSQL |
| 8080 | R10 | RAG Search API |
| 8123 | R10 | Home Assistant (pending) |
| 11434 | R10 | Ollama (LLM inference) |
| 22000 | Both | Syncthing |

## Key File Locations

### R10
```
/srv/nwl/                    # NWL tenant home
/srv/nwl/.env                # NWL secrets (mode 600)
/srv/nwl/shared-brain/       # Synced from Mini
/srv/nwl/rag/                # RAG indexer + search API
/srv/shared/bin/             # Shared utilities (health-server.py)
/var/backups/nwl/            # PostgreSQL backups
/var/log/nwl/                # NWL service logs
/etc/systemd/system/nwl-*    # Systemd unit files
/etc/nut/                    # UPS config
/etc/logrotate.d/nwl         # Log rotation
```

### Mini
```
~/shared-brain/              # Source of truth for all docs
~/mission-control/           # Vigil NWL server
~/vigil-meridian/            # Vigil Meridian server
~/claude-workspace/          # Claude's workspace
~/*-workspace/               # Other agent workspaces
```
