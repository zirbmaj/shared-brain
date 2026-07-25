---
title: Homelab Service Architecture
date: 2026-03-27
type: project
scope: infrastructure
owner: claude
status: draft
parent: homelab-cluster.md
---

# Homelab Service Architecture

Service distribution, communication patterns, and health monitoring for the 2-node NWL cluster.

## Node Roles

### NWL-Mini (Mac Mini — macOS)
**Role:** Agent host, web serving, external connectivity

| Service | Port | Manager | Notes |
|---------|------|---------|-------|
| NWL agents (6) | — | screen + launchd | claude, claudia, static, near, hum, relay |
| Meridian agents (4) | — | screen + launchd | axis, forge, lens, locus (on hold) |
| Chowder bot | — | screen + launchd | sonia's PA bot |
| Vigil NWL | 3847 | launchd | ops dashboard + websocket |
| Vigil Meridian | 3849 | launchd | meridian ops dashboard |
| Cloudflare tunnel (NWL) | — | launchd | external access to vigil, products |
| Cloudflare tunnel (Meridian) | — | launchd | meridian external access |
| UPS shutdown receiver | — | SSH from R10 | R10 triggers agent-shutdown-all.sh via SSH on low battery |
| Node health API | 3850 | launchd | new — lightweight /health endpoint |

### NWL-R10 (Alienware R10 — Linux)
**Role:** Compute, storage, monitoring

| Service | Port | Manager | Notes |
|---------|------|---------|-------|
| PostgreSQL + pgvector | 5432 | systemd | internal data: agent memory, logs, embeddings |
| Ollama | 11434 | systemd | local LLM, CPU-only start. standard port is 11434 |
| Home Assistant | 8123 | systemd/docker | smart plug control, power monitoring |
| NUT server (upsd) | 3493 | systemd | UPS monitoring, master role |
| Node health API | 3850 | systemd | new — lightweight /health endpoint |
| RAG indexer daemon | — | systemd | watches shared-brain via inotify, chunks + embeds to pgvector |
| RAG search API | 8080 | systemd | REST API for semantic search over shared-brain |
| Batch compute | — | systemd timers | spectral analysis, embedding generation |
| Browser service | 3860 | systemd (docker) | headless chromium — screenshots, web fetch, visual diff. sandboxed container, mesh-only |
| Syncthing | 22000 | systemd | shared-brain sync with Mini |

## Mesh Network (Tailscale)

All inter-node communication goes through Tailscale's WireGuard mesh. MagicDNS enables hostname-based service discovery — no hardcoded IPs.

| Device | Tailscale hostname | Role |
|--------|-------------------|------|
| Mac Mini | `nwl-mini` | Agent host, web serving |
| Alienware R10 | `nwl-r10` | Compute, storage |
| Jam's MacBook Air | `jam-mba` | Admin access (read-only mesh ACL) |
| Jam's phone | `jam-phone` | Emergency access |

**Setup:**
- R10: `curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --authkey=<key>`
- Mini: `brew install tailscale && tailscale up --authkey=<key>`
- Auth keys: pre-generated from Tailscale admin console, ephemeral for servers, reusable for jam's devices
- LAN detection: both machines on same subnet → traffic stays local, no relay overhead

**Tailscale ACLs** (managed in Tailscale admin console):
```json
{
  "acls": [
    {"action": "accept", "src": ["nwl-mini"], "dst": ["nwl-r10:5432,11434,3493,3850,8123"]},
    {"action": "accept", "src": ["nwl-r10"], "dst": ["nwl-mini:3847,3849,3850"]},
    {"action": "accept", "src": ["jam-mba", "jam-phone"], "dst": ["nwl-mini:3847,3849,3850", "nwl-r10:3850,8123"]},
    {"action": "accept", "src": ["nwl-r10"], "dst": ["nwl-mini:22"]}
  ]
}
```

Note: R10 → Mini SSH access for UPS shutdown only. Jam's devices get read-only access to monitoring endpoints.

**Tailscale SSH:** Enabled for jam's devices → both nodes. No key management needed for human access.

## Service Communication

```
┌─────────────────────────────────┐    tailscale mesh     ┌─────────────────────────────────┐
│         nwl-mini (macOS)        │◄──────────────────────►│        nwl-r10 (Ubuntu 24.04)    │
│                                 │                        │                                  │
│  agents ──► ollama API ─────────┼── nwl-r10:11434 ─────►│  ollama (CPU, 7B-13B models)     │
│  agents ──► postgres ───────────┼── nwl-r10:5432 ──────►│  postgresql + pgvector            │
│  vigil  ──► R10 health ─────────┼── nwl-r10:3850 ──────►│  node health API                 │
│                                 │                        │                                  │
│  agent-shutdown-all.sh ◄────────┼── SSH (UPS shutdown) ─│  cluster-shutdown.sh             │
│  node health API :3850 ◄────────┼── nwl-mini:3850 ──────│  watchdog                        │
│                                 │                        │                                  │
│  cloudflare tunnels ────────────┼──── :443 ─────────────►  internet (products, vigil)      │
└─────────────────────────────────┘                        └─────────────────────────────────┘

                        ▲
                        │ tailscale mesh
                        ▼
              ┌──────────────────┐
              │  jam's devices   │
              │  jam-mba + phone │
              │  read-only ACL   │
              └──────────────────┘
```

## Health API Contract

Each node exposes a lightweight HTTP endpoint at port 3850. No authentication (mesh-only access, not exposed to internet).

### GET /health

```json
{
  "node": "nwl-mini",
  "status": "ok",
  "uptime_seconds": 86400,
  "timestamp": "2026-03-27T23:00:00Z",
  "services": {
    "vigil-nwl": { "status": "ok", "port": 3847 },
    "vigil-meridian": { "status": "ok", "port": 3849 },
    "tunnel-nwl": { "status": "ok" },
    "tunnel-meridian": { "status": "ok" }
  },
  "agents": {
    "claude": { "status": "online", "context_pct": 57 },
    "claudia": { "status": "online", "context_pct": 35 },
    "static": { "status": "online", "context_pct": 61 },
    "near": { "status": "online", "context_pct": 80 },
    "hum": { "status": "online", "context_pct": 69 },
    "relay": { "status": "online", "context_pct": 38 }
  }
}
```

```json
{
  "node": "nwl-r10",
  "status": "ok",
  "uptime_seconds": 86400,
  "timestamp": "2026-03-27T23:00:00Z",
  "services": {
    "postgresql": { "status": "ok", "port": 5432 },
    "ollama": { "status": "ok", "port": 11434, "model_loaded": "mistral:7b" },
    "homeassistant": { "status": "ok", "port": 8123 },
    "nut": { "status": "ok", "port": 3493 }
  },
  "ups": {
    "status": "online",
    "battery_pct": 100,
    "runtime_seconds": 1800,
    "load_pct": 45
  }
}
```

### Status values
- `ok` — service running, healthy
- `degraded` — service running with issues (e.g., high load, low battery)
- `down` — service not responding

### Consumers
- **Claudia's vigil display** — polls both /health endpoints, maps to vitals bar (NWL-Mini, NWL-R10, UPS, Mesh dots)
- **Vigil watchdog** — replaces localhost-only checks with mesh-aware cross-node monitoring
- **UPS notify** — ups field feeds the dedicated UPS status indicator

## Service Startup Order

**Definitive source:** `ops/r10-systemd/README.md` — full dependency graph with systemd After=/Requires= chains.

### R10 (systemd)
```
1.  network-online.target
2.  tailscaled.service (mesh overlay)
3.  postgresql.service
4.  ollama.service
5.  syncthing@nwl-svc.service
6.  nwl-node-health.service
7.  nwl-rag-indexer.service
8.  nwl-rag-search.service
9.  nwl-homeassistant.service
10. nwl-browser.service
11. nut-server.service / nut-monitor.service (independent chain)
```

### Mini (launchd)
```
1. network + mesh overlay
2. NUT client (or rely on R10 SSH fallback)
3. vigil servers
4. cloudflare tunnels
5. node health API
6. agents (staggered per agent-cycle-config.json)
```

## Agent Cycle Config — Multi-Node Extension

Current `agent-cycle-config.json` has all agents on `"host": "mac-mini"`. For the cluster:

```json
{
  "version": 3,
  "nodes": {
    "nwl-mini": {
      "hostname": "nwl-mini",
      "tailscale_name": "nwl-mini",
      "os": "darwin",
      "service_manager": "launchd"
    },
    "nwl-r10": {
      "hostname": "nwl-r10",
      "tailscale_name": "nwl-r10",
      "os": "linux",
      "service_manager": "systemd"
    }
  },
  "agents": [
    { "name": "claude", "host": "nwl-mini", "...": "existing fields" }
  ]
}
```

The `host` field becomes a reference to the `nodes` map. Cycle script uses Tailscale hostnames for cross-node operations and the right service manager commands per OS.

## Vigil Watchdog — Mesh-Aware Extension

Current `vigil-watchdog.sh` checks only localhost. Cluster version adds:

1. **Cross-node health checks** — Mini's watchdog pings R10's /health endpoint over mesh. R10's watchdog pings Mini's
2. **Mesh connectivity check** — ping the other node's mesh IP. If unreachable, alert but don't restart local services
3. **UPS status relay** — R10's watchdog includes UPS data in its health response. Mini's watchdog reads it and surfaces to vigil

The watchdog stays on each node (cron on R10, cron on Mini). Each checks its own local services AND the remote node's health endpoint.

## Port Assignment Registry

All ports documented here to avoid conflicts.

| Port | Node | Service | Protocol |
|------|------|---------|----------|
| 3493 | R10 | NUT (upsd) | TCP |
| 3847 | Mini | Vigil NWL | HTTP/WS |
| 3849 | Mini | Vigil Meridian | HTTP/WS |
| 3850 | Both | Node health API | HTTP |
| 5432 | R10 | PostgreSQL | TCP |
| 8123 | R10 | Home Assistant | HTTP |
| 11434 | R10 | Ollama | HTTP |
| 3860 | R10 | Browser service (docker) | HTTP |
| 8080 | R10 | RAG search API | HTTP |
| 8090 | R10 | Whisper STT | HTTP |
| 22000 | Both | Syncthing | TCP |

## Shared Storage (Syncthing)

Syncthing for bidirectional file sync between nodes. Both machines maintain a full local copy — no dependency on mesh being up for local reads.

**Sync folders:**

| Folder | Mini path | R10 path | Direction | Notes |
|--------|-----------|----------|-----------|-------|
| shared-brain | `~/shared-brain/` | `/srv/nwl/shared-brain/` | Bidirectional | Agent docs, retros, backlog, ops |
| reports | (via shared-brain) | (via shared-brain) | Bidirectional | Spectral analysis output, analytics |

**Configuration:**
- Syncthing runs as a systemd service on R10 (`syncthing@nwl-svc.service`)
- Syncthing runs via Homebrew service on Mini
- Device pairing over Tailscale mesh (devices see each other via `nwl-mini:22000` / `nwl-r10:22000`)
- Filesystem watcher enabled: 1-10 second propagation for .md file changes
- Conflicts create `.sync-conflict-*` files — no silent data loss

**Not synced via Syncthing:**
- Audio files (large, one-directional) — use `rsync` from R10 to Mini if needed
- Database data (PostgreSQL handles its own persistence)
- Model weights (Ollama manages its own cache on R10)

## R10 Systemd Service Units

All R10 services run under tenant users via systemd. Ubuntu 24.04 LTS.

### PostgreSQL
```ini
# Installed via apt: sudo apt install postgresql-16 postgresql-16-pgvector
# Default systemd unit from package, runs as postgres user
# Config: listen_addresses = 'localhost,nwl-r10' in postgresql.conf
# UFW: sudo ufw allow from <tailscale-subnet> to any port 5432
```

### Ollama
```ini
# Install: curl -fsSL https://ollama.com/install.sh | sh
# Default systemd unit: ollama.service
# Config: OLLAMA_HOST=0.0.0.0:11434 in /etc/systemd/system/ollama.service.d/override.conf
# Models: ollama pull mistral:7b (fits in 32GB RAM, CPU-only)
# UFW: sudo ufw allow from <tailscale-subnet> to any port 11434
```

### Home Assistant
```ini
# Docker compose on R10
# /srv/nwl/homeassistant/docker-compose.yml
[Unit]
Description=Home Assistant
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/srv/nwl/homeassistant
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=nwl-svc

[Install]
WantedBy=multi-user.target
```

### Syncthing
```ini
# Installed via apt or official repo
# Runs as nwl-svc user
# sudo systemctl enable syncthing@nwl-svc
# Web UI at localhost:8384 (not exposed to mesh)
```

### Node Health API
```ini
[Unit]
Description=Node Health API
After=network-online.target tailscaled.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/srv/shared/bin/node-health-server.sh
User=nwl-svc
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## R10 First Boot Checklist

After jam installs Ubuntu Server 24.04 LTS:

```bash
# 1. System update
sudo apt update && sudo apt upgrade -y

# 2. Set hostname
sudo hostnamectl set-hostname nwl-r10

# 3. Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey=<key>

# 4. Create tenant users (per static's security model)
sudo useradd -r -m -d /srv/nwl -s /bin/bash nwl-svc
sudo useradd -r -m -d /srv/meridian -s /usr/sbin/nologin meridian-svc
sudo useradd -r -m -d /srv/chowder -s /usr/sbin/nologin chowder-svc
sudo chmod 700 /srv/nwl /srv/meridian /srv/chowder

# 5. Install core services
sudo apt install -y postgresql-16 postgresql-16-pgvector docker.io syncthing nut
curl -fsSL https://ollama.com/install.sh | sh

# 6. Configure UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 100.64.0.0/10 to any port 5432,11434,3493,3850,8123  # tailscale CGNAT range
sudo ufw enable

# 7. Pair Syncthing with Mini
# (manual: exchange device IDs, add shared-brain folder)

# 8. Configure NUT (per static's UPS doc)
# Copy configs to /etc/nut/

# 9. SSH key exchange for UPS shutdown
# R10 needs passwordless SSH to nwl-mini for cluster-shutdown.sh
```

## Implementation Phases

| Phase | What | Who | Depends on |
|-------|------|-----|-----------|
| 1 | Ubuntu install on R10 | jam (physical) + team (remote guide) | USB drive |
| 2 | Tailscale on both nodes | claude (remote) + jam (mini install) | Phase 1 |
| 3 | Tenant users + filesystem ACLs | static (guide) + jam (execute) | Phase 1 |
| 4 | Syncthing between nodes | claude | Phase 2 |
| 5 | PostgreSQL + pgvector | claude | Phase 3 |
| 6 | Ollama (CPU-only) | claude | Phase 2 |
| 7 | NUT + UPS shutdown chain | static | Phase 2 |
| 8 | Home Assistant + Tapo plugs | near (guide) | Phase 2 |
| 9 | Node health APIs | claude | Phase 2 |
| 10 | Vigil display integration | claudia + hum | Phase 9 |

## Related Docs
- [homelab-cluster.md](homelab-cluster.md) — parent project doc
- [homelab-security-model.md](homelab-security-model.md) — static's isolation model
- [homelab-ups-shutdown.md](homelab-ups-shutdown.md) — static's UPS/NUT architecture
- [homelab-linux-distro-2026-03-27.md](../references/homelab-linux-distro-2026-03-27.md) — near's distro research
- [homelab-mesh-networking-2026-03-27.md](../references/homelab-mesh-networking-2026-03-27.md) — near's mesh research
- [homelab-shared-storage-2026-03-27.md](../references/homelab-shared-storage-2026-03-27.md) — near's storage research
- [homelab-home-automation-2026-03-27.md](../references/homelab-home-automation-2026-03-27.md) — near's HA research
- [hum-vigil-display-audio-sync.md](mission-control/hum-vigil-display-audio-sync.md) — hum's audio-visual sync spec
