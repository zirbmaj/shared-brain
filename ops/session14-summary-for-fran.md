---
title: Session 14 Summary — For Fran
date: 2026-03-28
type: report
scope: shared
---

# Session 14 Summary (T-3 to PH Launch)

Quick rundown of what happened today and what it means for meridian.

## Infrastructure

**R10 GPU unlocked.** The RX 5700 XT works for AI inference via Vulkan (not ROCm). 65.6 tok/s — 10x faster than CPU. ROCm doesn't support RDNA1, but Vulkan bypasses it entirely. This was tested and stress-verified. Stable, cool (53C), persists across reboots.

**Fran's PC on the mesh.** Tailscale IP: 100.89.96.110. Setup script ready at shared-brain/ops/fran-pc-setup.ps1. Run as admin — installs ollama with ROCm, SSH, working directory at C:\nwl\meridian\, power settings. One command, fully reversible.

**Two GPU nodes on the mesh:**
- R10: RX 5700 XT, 8GB VRAM, 65.6 tok/s (Vulkan) — always on
- Fran's PC: RX 7900 GRE, 16GB VRAM (ROCm native) — on-demand, larger models

## Vigil v3 (Multi-Tenant Dashboard)

Two separate vigil servers merged into one. Live on port 3847.

- 4 tabs: NWL / Meridian / All / Mesh
- Meridian tab shows meridian agents + meridian-specific activity
- Mesh tab shows all nodes (mini, R10, fran's PC) with GPU stats, service health
- RAG search built in — search shared-brain from the dashboard
- Fran gets his own default view (Meridian tab on login)
- GPU monitoring: VRAM usage, tok/s, model loaded, temperature
- Fran's PC shows as "expected offline" when not on (no false alarms)

## What Fran Needs To Do

1. Run the setup script when ready (shared-brain/ops/fran-pc-setup.ps1)
2. Keep PC on 24/7 if possible (agents fall back to R10 CPU when offline)
3. Access vigil via the cloudflare tunnel URL

## Shared Network Discussion

Relay proposed a shared `mesh` database on R10 for cross-team visibility (health metrics, agent status, verification results). Axis reviewed — waiting on fran's approval. Tenant DBs stay private, mesh DB is the shared layer.

## Docs Created Today

- ops/infrastructure-reference.md — universal infra doc (tenant-neutral)
- ops/agent-cycle-procedure.md — how to cycle agents
- ops/gpu-toolchain-opportunities.md — what GPU enables per agent lane
- ops/proposed-docs-cleanup.md — audit of 216 docs, proposed cleanup
- ops/fran-pc-setup.ps1 — fran's PC setup script
