---
title: service inventory
date: 2026-03-31
type: reference
scope: shared
summary: every service, cron, hook, and automation running across the homelab — what it does and why
---

# Service Inventory

Last verified: 2026-03-31 by Claude. Update this doc when services change.

---

## Global Services

These run regardless of team and support the entire homelab.

### Tailscale Mesh
- **Runs on:** all nodes
- **What it does:** Encrypted overlay network connecting all machines. Every node talks to every other node via `100.x.x.x` addresses without port forwarding or exposing the home IP.
- **Why it matters:** Without this, nothing can talk to anything.

### Health Servers (port 3850)
- **Runs on:** mini, R10, XPS
- **What it does:** Tiny HTTP API that reports node vitals — CPU, RAM, disk, temps, which agents are running, context window usage. Vigil polls these to build its dashboard.
- **Endpoint:** `GET :3850/health` returns JSON

### Vigil Watchdog
- **Runs on:** mini (cron, every 2 min)
- **What it does:** Checks that vigil dashboards and Cloudflare tunnels are alive. Restarts them if dead. Logs to `/tmp/vigil-watchdog.log`.
- **Script:** `shared-brain/ops/vigil-watchdog.sh`

---

## NWL Services

### Vigil NWL (port 3847)
- **Runs on:** mini
- **What it does:** Team mission control dashboard. Shows node topology, service health, agent status, CPU/RAM/disk/temps, and a changelog of what shipped. The `?display=wall` mode is optimized for the XPS kiosk.
- **URL:** `http://nwl-mini:3847`

### Cloudflare Tunnel (NWL)
- **Runs on:** mini
- **What it does:** Routes `nowherelabs.dev` traffic from the internet through Cloudflare to the mini, without exposing the home IP. All product sites serve through this.
- **Monitored by:** vigil-watchdog

### RAG Search API (port 8080)
- **Runs on:** R10
- **What it does:** Semantic search over shared-brain docs. Agents query it with natural language and get relevant doc chunks back. Uses pgvector embeddings + optional reranking.
- **Endpoint:** `POST :8080/search` with `{"query": "...", "mode": "hybrid"}`
- **Index:** 214 docs, ~2K chunks
- **Script:** `shared-brain/ops/rag/deploy.sh`

### Ollama (port 11434)
- **Runs on:** R10
- **What it does:** Local LLM inference on CPU. Generates embeddings for the RAG pipeline and handles inference tasks that don't need the Claude API.
- **Endpoint:** `http://nwl-r10:11434`

### PostgreSQL + pgvector (port 5432)
- **Runs on:** R10
- **What it does:** Stores RAG vector embeddings (the semantic index of all docs). Also holds local data that doesn't belong in Supabase.

### Piper TTS (port 8091)
- **Runs on:** R10 (manual start, systemd unit not yet installed)
- **What it does:** Text-to-speech service for vigil voice alerts. Serves cached pre-generated phrases (64 alert phrases). Benchmarked at 3.4x realtime (medium quality).
- **Status:** Running manually. Systemd unit spec written but needs jam to install on R10.
- **Script:** `piper-tts-service.py`

### Supabase (cloud)
- **Project:** `lxecuywjwasxijxgnutn`
- **What it does:** Analytics events (track.js), PH upvote tracking, launch-day stats, RLS-protected tables. All products write to it client-side.
- **Key tables:** `analytics_events`, `ph_upvotes`, `ph_launch_correlation`
- **Key functions:** `get_launch_day_stats(hours)`, `get_launch_stats()`

### Vercel (cloud)
- **Account:** vulcwing (zirbmaj)
- **What it does:** Hosts all 5 product repos as static sites. Auto-deploys on push to main. No build step — serves files directly.
- **Products:** ambient-mixer, static-fm, nowhere-labs, pulse, letters-to-nowhere

### Cloudflare DNS
- **What it does:** DNS for `nowherelabs.dev` and subdomains. Points to Cloudflare tunnel. Also handles SSL.

---

## NWL Agents & Pollers

### Agent Screen Sessions (6)
- **Runs on:** mini
- **What they do:** Each NWL agent (claude, claudia, static, near, hum, relay) runs as a Claude Code CLI process inside a `screen` session. The screen keeps them alive across terminal disconnects.
- **Names:** `agent-claude`, `agent-claudia`, `agent-static`, `agent-near`, `agent-hum`, `agent-relay`

### Discord Pollers (6)
- **Runs on:** mini
- **What they do:** Each agent has a dedicated poller that watches Discord for new messages and delivers them to the agent's inbox directory. Without the poller, agents can't see Discord messages.
- **Names:** `poller-claude`, `poller-claudia`, `poller-static`, `poller-near`, `poller-hum`, `poller-relay`
- **Script:** `shared-brain/ops/discord-poller.sh`

---

## Meridian Services

### Vigil Meridian (port 3849)
- **Runs on:** mini
- **What it does:** Same as Vigil NWL but for the Meridian team dashboard.

### Meridian Agent Sessions (4 + coordinator)
- **Runs on:** mini
- **What they do:** Meridian team agents running as Claude Code CLI in screen sessions.
- **Names:** `agent-axis`, `agent-forge`, `agent-lens`, `agent-locus`, `agent-chowder`

### Chowder Cycle
- **Runs on:** mini (cron, every 5 min)
- **What it does:** Checks if the chowder coordinator agent is alive and restarts it if dead.
- **Script:** `chowder-workspace/chowder-cycle.sh`

---

## Cron Jobs (mini)

| Schedule | Script | Purpose | Status |
|----------|--------|---------|--------|
| Every 2 min | `vigil-watchdog.sh` | Restart dead vigils/tunnels | ✅ Working |
| Every 5 min | `uptime-monitor.sh` | Ping product URLs, record response times | ❌ Wrong path |
| Every 30 min | `auto-verify.sh` | Full deploy verification against live sites | ❌ Wrong path |
| Every 5 min | `chowder-cycle.sh` | Keep Meridian coordinator alive | ✅ Working |

**Fix for broken crons:** `crontab /tmp/crontab-new.txt` (prepped, needs jam to install — sandbox blocks writes)

---

## Hooks

### NWL Agent Hooks (per-workspace settings.json)

**SessionStart:**
| Hook | Scope | What it does |
|------|-------|-------------|
| `verify-identity.sh {agent}` | All 6 NWL agents | Confirms workspace, CLAUDE.md, and Discord token match. Prevents "zombie agent" bug. |
| `lane-onramp.sh {agent}` | Relay only | Generates agent-specific startup checklist based on lane role. |
| On-ramp checklist injection | All 6 NWL agents | Injects startup checklist — read retros, run tests, check deploy status, check Discord. |

**PostToolUse:**
| Hook | Scope | What it does |
|------|-------|-------------|
| `discord-urgent-hook.sh {agent}` | All 6 NWL agents | Detects urgent messages in Discord that need immediate attention. |

**SessionEnd:**
| Hook | Scope | What it does |
|------|-------|-------------|
| `session-end-{agent}.sh` | All 6 NWL agents | Logs session end, checks for uncommitted changes, reminds agent to write retro. |

**StatusLine (continuous):**
| Hook | Scope | What it does |
|------|-------|-------------|
| `context-sidecar.sh` | All agents | Reads context window % and writes to `/tmp/agent-monitor/` for HUD terminal display. |

### Meridian Hooks (global settings.json)

**PostToolUse:**
| Hook | Scope | What it does |
|------|-------|-------------|
| Devops heartbeat | Shadow agents (forge, lens, locus, axis) | After a tool use, pings heartbeat so devops knows the agent is active. |

### Discord Dedup (`discord-dedup.sh`)
- **Scope:** Meridian only (not deployed on NWL agents)
- **What it does:** PreToolUse hook that prevents duplicate Discord messages within a short time window.
- **Script:** `shared-brain/ops/discord-dedup.sh`

---

## Automation Scripts (on-demand, not scheduled)

### Agent Lifecycle
| Script | Purpose |
|--------|---------|
| `agent-cycle.sh` | Kill + restart an agent. Stashes git work, SIGTERM → SIGKILL → restart in screen. Daily cap of 2 per agent. |
| `agent-health-monitor.sh` | Checks agent processes for stuck/dead state. Read-only by default, can auto-cycle if armed. |
| `agent-health-check.sh` | Lighter health check — screen session alive? Claude process running? Posts alerts to Discord. |
| `new-agent-setup.sh` | Initialize a new agent workspace with CLAUDE.md, Discord access, and identity config. |
| `launch-shadows.sh` | Spin up Meridian shadow agents in screen sessions. |

### Session Hooks
| Script | Purpose |
|--------|---------|
| `session-end-{agent}.sh` | Logs session end, checks for uncommitted changes, reminds agent to write retro. |
| `session-end-generic.sh` | Generic version for any agent. |
| `verify-identity.sh` | SessionStart check — confirms workspace, CLAUDE.md, and Discord token all match. Prevents "zombie agent" bug. |
| `context-sidecar.sh` | StatusLine wrapper — reads context window % and writes to `/tmp/agent-monitor/` for HUD display. |

### Deploy & Verify
| Script | Purpose |
|--------|---------|
| `verify-deploy.sh` | Post-deploy verification — HTTP codes, CSS/JS presence, OG tags, API responses across all products. |
| `batch-deploy.sh` | Push all repos and verify deploys in one shot. For launch day or after Vercel limit resets. |
| `screenshot.sh` | Playwright screenshot of any URL. Used for visual QA and PH gallery. |
| `protect-main-hook.sh` | Pre-commit git hook. Blocks direct commits to main. Forces branch + PR workflow. |

### R10 Maintenance
| Script | Purpose |
|--------|---------|
| `rag/deploy.sh` | Deploy RAG services (indexer + search API) on R10. Creates venv and systemd units. |
| `r10-secret-setup.sh` | Generate/rotate .env files for R10 tenants. Uses openssl rand, chmod 600. |
| `r10-retention-cron.sh` | Clean old backups, screenshots, spectrograms on R10. Prunes files >7-30 days old. |
| `r10-backup-restore-test.sh` | 5-phase backup/restore validation. Non-destructive by default. |
| `rag-search.sh` | CLI wrapper for RAG API queries. Falls back to grep if R10 is unreachable. |

---

## XPS Kiosk (currently down)

- **Runs on:** nwl-xps13 (100.64.51.13)
- **What it does:** Cage (Wayland compositor) + Chromium in fullscreen showing `nwl-mini:3847/?display=wall`. Auto-starts on boot via systemd.
- **Status:** Not rendering. Cage can't find a display/DRM framebuffer. Needs local debug.
- **Blocked on:** SSH key auth from mini, or jam typing commands on the XPS keyboard.

---

## Redundancies to Review

1. **agent-health-monitor.sh vs agent-health-check.sh** — Both check agent liveness. Health-monitor is more comprehensive (context %, JSONL growth, auto-cycle). Health-check is lighter (screen + PID check, Discord alerts). Could consolidate.
2. **session-end-{agent}.sh (5 copies) vs session-end-generic.sh** — Agent-specific versions do the same thing with minor path differences. Could collapse to just the generic version with a parameter.
3. **uptime-monitor.sh vs auto-verify.sh** — Uptime just pings URLs for status codes. Auto-verify does a deeper check (content, OG tags, etc). Uptime could be folded into auto-verify with a `--quick` flag.
