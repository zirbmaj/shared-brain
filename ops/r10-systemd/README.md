# R10 Systemd Service Units

Boot dependency chain and failure policies for the NWL-R10 node (Ubuntu 24.04 LTS).

## Dependency Graph

```
network-online.target
  └── tailscaled.service (mesh overlay — package unit)
        ├── postgresql.service (package unit + override)
        │     ├── nwl-rag-indexer.service
        │     └── nwl-rag-search.service
        ├── ollama.service (package unit + override)
        │     ├── nwl-rag-indexer.service
        │     └── nwl-rag-search.service
        ├── syncthing@nwl-svc.service (package unit + override)
        │     └── nwl-rag-indexer.service (watches synced files)
        ├── nwl-homeassistant.service (docker compose)
        ├── nut-server.service (package unit)
        │     └── nut-monitor.service (package unit)
        ├── nwl-browser.service (docker, headless chromium)
        └── nwl-node-health.service (starts early, reports what it sees)
```

## Boot Order (verified sequence)

1. `network-online.target` — kernel networking
2. `tailscaled.service` — mesh overlay (all inter-node traffic)
3. `postgresql.service` — database (required by RAG services)
4. `ollama.service` — LLM inference (required by RAG services)
5. `syncthing@nwl-svc.service` — file sync (RAG indexer watches synced dirs)
6. `nwl-node-health.service` — health API (reports service status)
7. `nwl-rag-indexer.service` — watches shared-brain, embeds to pgvector
8. `nwl-rag-search.service` — REST API for semantic search
9. `nwl-homeassistant.service` — smart home automation
10. `nwl-browser.service` — headless chromium for screenshots
11. `nut-server.service` / `nut-monitor.service` — UPS monitoring (independent chain)

## Failure Policies

| Service | Restart | RestartSec | StartLimitBurst | StartLimitInterval | Rationale |
|---------|---------|------------|-----------------|--------------------|-----------|
| tailscaled | always | 5s | 5 | 300s | Mesh is critical — all inter-node traffic depends on it |
| postgresql | always | 10s | 3 | 600s | Data store — must recover, but slow restart to avoid WAL corruption |
| ollama | on-failure | 15s | 3 | 600s | CPU-heavy — slow restart to avoid thermal spike. Don't restart on clean stop |
| syncthing | on-failure | 10s | 3 | 600s | File sync — can catch up after downtime |
| node-health | always | 5s | 5 | 300s | Monitoring — lightweight, must stay up |
| rag-indexer | on-failure | 30s | 3 | 600s | Batch processor — slow restart, will re-index on startup |
| rag-search | on-failure | 10s | 3 | 600s | HTTP API — clients retry |
| homeassistant | on-failure | 30s | 3 | 600s | Automation — no urgency, docker compose needs time |
| browser | on-failure | 15s | 3 | 600s | Sandboxed container — restart on crash only |
| nut-server | always | 5s | 5 | 300s | Power monitoring — must stay up for safety |
| nut-monitor | always | 5s | 5 | 300s | UPS watchdog — triggers shutdown on low battery |

## Dependent Behavior

When a dependency goes down, systemd handles propagation:
- **postgresql down** → rag-indexer and rag-search stop (BindsTo=). They restart when postgres comes back (via Requires= + restart chain)
- **ollama down** → rag-indexer and rag-search continue running but return degraded responses (Wants=, not Requires=). Ollama is optional acceleration
- **tailscale down** → all services stay running locally. Mini loses connectivity to R10 services. Health API reports mesh as down
- **syncthing down** → rag-indexer stays running but processes no new files. Will catch up when sync resumes

## Installation

```bash
# Copy unit files
sudo cp nwl-*.service /etc/systemd/system/

# Copy overrides
sudo mkdir -p /etc/systemd/system/postgresql.service.d
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo mkdir -p /etc/systemd/system/syncthing@.service.d
sudo cp overrides/postgresql.conf /etc/systemd/system/postgresql.service.d/nwl-dependency.conf
sudo cp overrides/ollama.conf /etc/systemd/system/ollama.service.d/nwl-dependency.conf
sudo cp overrides/syncthing.conf /etc/systemd/system/syncthing@.service.d/nwl-dependency.conf

# Reload and enable
sudo systemctl daemon-reload
sudo systemctl enable nwl-node-health nwl-rag-indexer nwl-rag-search nwl-homeassistant nwl-browser

# Verify boot order
sudo bash boot-test.sh
```
