---
title: Homelab Cluster Buildout
date: 2026-03-27
type: project
scope: infrastructure
owner: relay (orchestrator), claude (architecture), static (security)
status: planning
priority: high — parallel to PH launch
---

# The Rack — Homelab Cluster Buildout

NWL is expanding from a single Mac Mini to a 2-node headless cluster. This is the team's permanent infrastructure. Jam retains ownership but interacts only via MacBook Air, phone, or Discord.

## Hardware Inventory

### Node 1: NWL-Mini (Mac Mini — current)
- **Role:** Primary agent host, current production machine
- **OS:** macOS (current install, clean wipe planned post-PH launch)
- **Running:** 6 NWL agents + meridian agents + vigil + chowder
- **Network:** Ethernet via unmanaged switch

### Node 2: NWL-R10 (Alienware R10 ~2021)
- **Role:** Compute node (local LLM, data processing, RAG, future services)
- **CPU:** TBD (AMD Ryzen, exact model TBD)
- **RAM:** 32GB DDR4
- **GPU:** AMD Radeon RX 5700 XT (8GB VRAM)
- **Storage:** 1TB HDD + 1TB SSD (medium-high speed)
- **OS:** Windows (to be wiped for Linux — distro TBD, leaning Ubuntu Server 24.04 LTS)
- **Network:** Ethernet via unmanaged switch
- **Status:** Powered on, monitor + keyboard available for initial setup

### Power
- **UPS:** APC UPS 600 — powers both machines + network switches
- **UPS data port:** Connected to R10 (for graceful shutdown signaling)
- **Smart plugs:** 3x TP-Link Tapo (Matter supported)
  - Plug 1: Connected to UPS
  - Plug 2: Connected to wall
  - Plug 3: Unassigned (home automation candidate)

### Network
- **Switches:** Unmanaged (no VLANs, no managed config)
- **Topology:** Wall → switch → ethernet to both machines
- **Mesh overlay:** TBD (Tailscale vs ZeroTier — research pending)
- **Remote access:** Jam connects via MacBook Air / phone through mesh VPN

## Tenants (shared infrastructure)
| Tenant | Owner | Current Home | Notes |
|--------|-------|-------------|-------|
| NWL (Nowhere Labs) | jam | Mac Mini | 6 agents, vigil, products |
| Meridian | fran (via axis) | Mac Mini | 4 agents, on hold per jam |
| Chowder | sonia | Mac Mini | PA bot, needs auth switch |

Isolation between tenants is required. Approach TBD (Docker, separate users, VMs).

## Workstreams

### 1. Linux Installation (R10)
- **Status:** DECIDED — Ubuntu Server 24.04 LTS
- **Decision:** Ubuntu Server 24.04 LTS (scored 38/40 vs Debian 31, Rocky 32). Best ROCm community support, simplest installer (6 screens), 12-year Ubuntu Pro support (free tier), Docker/Ollama reference platform
- **Storage layout:** OS + Docker on SSD, bulk data on HDD
- **Jam's role:** Physical setup (boot from USB, run installer). Team guides remotely after that
- **Research:** shared-brain/references/homelab-linux-distro-2026-03-27.md

### 2. Mesh Networking
- **Status:** DECIDED — Tailscale
- **Decision:** Tailscale. MagicDNS (hostname-based service discovery), WireGuard kernel module on Linux, SSO auth, auth keys for headless, free tier 100 devices, Tailscale SSH for keyless access from phone/laptop, LAN detection keeps local traffic local
- **Outcome:** Both machines + jam's MBA on same virtual network. Agents call services by hostname (e.g. `http://nwl-r10:11434`)
- **Research:** shared-brain/references/homelab-mesh-networking-2026-03-27.md

### 3. Shared Storage
- **Status:** DECIDED — Syncthing
- **Decision:** Syncthing. Degrades gracefully on network blips (vs NFS/SMB which hang). 1-10 second propagation with filesystem watcher. Conflict detection via .sync-conflict files. TLS 1.3 + device auth. Full local copy on each node
- **Fallback:** `fswatch | rsync` for one-way push if Syncthing feels heavy
- **Research:** shared-brain/references/homelab-shared-storage-2026-03-27.md

### 4. Local LLM (R10)
- **Status:** Not started
- **Decision needed:** Framework (Ollama vs llama.cpp vs vLLM), model size (7B-13B quantized)
- **Research:** Near assigned
- **Hardware constraint:** 32GB RAM + 8GB VRAM (RX 5700XT)
- **ROCm finding (2026-03-27):** RX 5700XT (RDNA1/gfx1010) is NOT officially supported by AMD ROCm. Community builds exist but require source compilation and debugging. vLLM segfaults on gfx1010 — ruled out. Ollama/llama.cpp can work with manual setup
- **GPU inference:** 7B quantized models fit in 8GB VRAM (~40 tok/s). 13B is tight (3-5 tok/s with offloading)
- **CPU-only fallback (recommended starting point):** 32GB RAM handles 7B-13B at 5-15 tok/s. Stable, no driver issues. Good for batch processing: file parsing, embeddings, summarization
- **GPU upgrade path:** Used RDNA2 card (RX 6700 XT, ~$150) gives official ROCm support if CPU speed is insufficient
- **Use cases:** File parsing, embedding generation (RAG), code search, document summarization
- **Architecture:** Ollama HTTP API on R10, agents on Mac Mini call it over mesh network

### 5. Data Architecture
- **Status:** Conceptual
- **Vision:** Move from flat files to DB-backed persistence
- **Current:** shared-brain is flat .md files in git repos
- **Proposed:**
  - Self-hosted PostgreSQL on R10 (internal data: agent memory, logs, metrics, embeddings)
  - pgvector extension for vector search / RAG
  - Supabase stays for public-facing products (drift, static fm, etc.)
  - File system remains as working interface, DB as persistence layer
  - Agents read/write files, sync to DB, push embeddings to vector store
- **Research needed:** Agentic memory best practices, MD-to-DB pipelines, vector DB options

### 6. Home Automation
- **Status:** DECIDED — Home Assistant
- **Decision:** Home Assistant. Only self-hosted platform with production-ready Matter support for Tapo plugs. Native NUT integration (UPS as sensor entity). Full REST API for scripted control. 2 Docker containers, ~256MB RAM
- **Critical risk:** Plug 1 controls UPS powering both servers. Never toggle without graceful shutdown sequence
- **Research:** shared-brain/references/homelab-home-automation-2026-03-27.md

### 7. UPS Integration
- **Status:** Not started
- **Approach:** NUT (Network UPS Tools) on R10 (has data port), signals Mac Mini over network
- **Requirement:** Both machines shut down gracefully on power loss
- **Smart plug integration:** UPS plug can signal power state to home automation

### 8. Service Isolation
- **Status:** Not started
- **Tenants:** NWL, Meridian, Chowder
- **Options:** Docker containers, separate Linux users, VMs, or hybrid
- **Requirement:** Context/workspace separation so tenant projects don't pollute each other
- **Jam's directive:** Meridian on hold until isolation is solved (2026-03-27)

### 9. Machine Identity
- **Status:** Not started
- **Naming:** NWL-Mini, NWL-R10 (or serial-based)
- **Action:** Set hostnames on both machines after clean installs

### 10. Mac Mini Clean Install (post-PH)
- **Status:** Planned for after 2026-03-31
- **Prerequisite:** Full backup of all workspaces, .env files, discord state, vigil configs, cron jobs
- **Goal:** Clean directory structure designed for multi-tenant agent hosting
- **Risk:** High — this is production. Must be fully documented and reversible

## Research Queue (assigned to Near)
1. Linux distro comparison (Ubuntu Server vs Debian vs Rocky)
2. Mesh networking (Tailscale vs ZeroTier)
3. Local LLM on R10 hardware (ROCm + 5700XT feasibility)
4. Home automation platforms (Home Assistant focus)
5. Shared storage solutions (NFS, SMB, Syncthing)
6. Agentic memory best practices
7. Data lakehouse patterns for small-scale infra

## Team Assignments
| Agent | Role |
|-------|------|
| Relay | Project orchestrator, documentation, progress tracking |
| Claude | Network architecture, service design, implementation |
| Static | Security, permissions model, UPS scripting, isolation |
| Near | Research (all workstreams) |
| Hum | Audio pipeline implications, spectral analysis on local compute |
| Claudia | Vigil dedicated display, ambient dashboard design |
| Axis | Meridian liaison, briefed on potential disruptions |

## Team Initial Input (Session 13)

**Hum (audio pipeline):**
- R10 32GB RAM ideal for offline spectral analysis (librosa + scipy on linux)
- CPU-only ollama for batch audio tagging (frequency profile, loop quality, loudness)
- Mesh network enables remote analysis jobs from mini without blocking agents
- 231-pair spectral conflict map (462 FFT comparisons) benefits from dedicated R10 compute

**Static (security):**
- Unix users per tenant (NWL/meridian/chowder) as baseline isolation on both machines
- Filesystem ACLs: chmod 700 per tenant, shared-brain via shared group with read-only for non-NWL
- Docker for network isolation as phase 2 if needed
- UPS shutdown: mac mini first (slower, more agents), R10 second
- Agents need SIGTERM handler/pre-shutdown hook to prevent corrupted state (access.json incident)
- Per-tenant: separate DB users, schema-level isolation, separate SSH keys, no shared credentials

**Claudia (ambient display):**
- Dedicated display = no scroll, no interaction, glanceable from across room
- Grid layout: 6 agent cards (2x3), each showing name/state/last action/context %
- Ambient pulse ring: central viz breathing with team activity
- Ticker bar: bottom strip with commits, discord messages, deploy status
- System vitals strip: uptime, node health, UPS status, network
- Typography at distance: bigger type, higher contrast, fewer words

**Near:**
- Researching linux distro comparison and mesh networking first
- Building on relay's ROCm research for LLM topic

## Known Issues
- **Screen session sleep (macOS):** Agents launched via `screen` go to 0% CPU when terminal is backgrounded. Attaching to the screen wakes them. Likely macOS power management suspending background terminal I/O. Needs fix — possibly `caffeinate`, launchd services, or moving agents to the R10 (Linux won't have this issue)

## Hardware Wishlist (for jam)
- [ ] 32GB DDR4 stick for R10 (~$50-60) — 64GB total enables 13B models + headroom
- [ ] USB audio interface (~$30 Behringer UMC22) — real-time audio capture for hum
- [ ] Managed switch (~$30 TP-Link TL-SG108E) — VLANs + port mirroring
- [ ] Bigger UPS or second UPS — more graceful shutdown time under compute load

## Consolidated Services (port assignments)
| Port | Service | Consumers |
|------|---------|-----------|
| 5432 | PostgreSQL + pgvector | claude, near, all agents |
| 8123 | Home Assistant | relay, static (UPS monitoring) |
| 11434 | Ollama (LLM) | all agents |
| 3860 | Headless Chromium API | near (research), claudia (screenshots), claude (verification) |
| 3493 | NUT (UPS) | local only |

## Permission Tiers
| Tier | Tenant | Access |
|------|--------|--------|
| Admin | NWL | Full sudo, all access, owns infrastructure |
| Near-Admin | Meridian | Sudo for own services + docker, no NWL schema/workspace access |
| Standard | Chowder | No sudo, own workspace only, shared resources read-only |

## Open Questions
- R10 exact CPU model?
- 5700XT ROCm support status (may limit local LLM to CPU-only)
- Mac Mini clean install timeline (after PH launch march 31?)
- Budget for additional hardware (more RAM, NAS, managed switch)?
- Chowder auth switch — does this block on infra changes?

## Decision Log
| Date | Decision | Who |
|------|----------|-----|
| 2026-03-27 | R10 to be wiped for Linux, not Windows | jam |
| 2026-03-27 | Not Arch — needs stable LTS distro | relay (jam approved) |
| 2026-03-27 | Meridian on hold until workspace isolation solved | jam |
| 2026-03-27 | Supabase stays for public products, self-hosted DB for internal | relay (pending team review) |
| 2026-03-27 | Mac Mini wipe planned post-PH launch | jam + relay |
| 2026-03-27 | Ubuntu Server 24.04 LTS for R10 | near (research), team consensus |
| 2026-03-27 | Tailscale for mesh networking | near (research), team consensus |
| 2026-03-27 | Syncthing for shared storage | near (research), team consensus |
| 2026-03-27 | Home Assistant for home automation | near (research), team consensus |
| 2026-03-27 | CPU-only Ollama to start, RDNA2 GPU upgrade path | relay (research) |
| 2026-03-27 | SSH-based UPS shutdown (skip NUT client on macOS) | claude + static |
| 2026-03-27 | Project named "The Rack" | claudia, team consensus |
| 2026-03-27 | NWL full admin, meridian near-admin, chowder standard | jam directive |
| 2026-03-27 | Consolidated headless chromium service (port 3860) | claude + static + near + claudia |
| 2026-03-27 | Data architecture (lakehouse/RAG) deferred to 13.2-13.3 | relay |
