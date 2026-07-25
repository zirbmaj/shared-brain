---
title: claude retro -- session 14
date: 2026-03-28
type: retro
scope: claude
summary: Vigil v3 full build (20+ features), R10 GPU unlock (Vulkan 65.6 tok/s), PR #35 share button fix, fran PC setup script, piper TTS, search improvements, sparklines, 69/69 launch verification
---

# Claude Retro -- Session 14 (2026-03-28, T-3)

## What shipped
- **PR #35**: share button visibility fix -- border opacity 7%->15%, font bump, accent treatment on Share button. addresses 0.5% share rate funnel leak
- **R10 GPU unlock**: Vulkan backend on RX 5700 XT, 6.7->65.6 tok/s (10x speedup). ROCm failed on gfx1010, Vulkan bypasses it entirely
- **Fran PC setup script**: PowerShell script for Windows 11 mesh onboarding (ollama ROCm, OpenSSH, power settings, reversible). Admin SSH key path fix from static's review
- **Vigil v3 server merge**: NWL + Meridian vigils merged into single multi-tenant server
  - 4-tab UI: NWL / Meridian / All / Mesh
  - GPU monitoring: polls ollama /api/ps every 10s, shows model loaded, VRAM, node status
  - Mesh health: 3 nodes (mini, R10, fran-pc) with intermittent vs always-on thresholds
  - Agent status push: POST /api/agent-status -- agents push structured summaries
  - Health webhook: POST /api/agent-health -- health check script reports dead/recovered agents
  - Verification results: POST /api/verification -- test/audit results persisted
  - Changelog feed: GET /api/changelog -- git log across all 5 repos
  - RAG search: GET /api/search -- proxies to R10:8080 with inline document preview
  - User-specific defaults: jam->NWL tab, fran->Meridian tab
  - Tenant-scoped tasks + activity feed
  - Expandable agent cards with identity audio
  - Persistence: summaries + verifications saved to disk
- **Health check cron**: launchd service (relay), 5-min interval, closes silent death gap
- **Launch day RPC verified**: get_launch_day_stats working, funnel data accurate

## What worked well
- **Team velocity on vigil**: from green light to production in ~10 minutes. claudia had CSS ready, hum had audio ready, static verified each deploy. parallel execution
- **Jam pushing on ROCm**: we gave up after one failed override. jam said keep trying. static found Vulkan which was 10x. lesson: exhaust options before declaring failure
- **Claudia's UX review**: diagnosed the share button visibility problem from pure data (funnel numbers). the 83%->0.5% gap was a CSS issue, not a product issue. right diagnosis, right fix
- **Static's QA discipline**: caught admin SSH key path, search POST vs GET, auth bypass needed for agent endpoints, recovery POST gap. every review improved the code

## What didn't work
- **TDZ bug**: declared `activeTenant` with `let` at line 1465 but referenced it at line 1077. JavaScript temporal dead zone. took 3 deploys to find because the error was swallowed by the refresh cycle. lesson: hoist state variables to the top of the file
- **In-memory state wiped on restart**: agent summaries were lost every deploy until I added disk persistence. should have persisted from the start
- **Counter bug**: agent cards use `active` class but counter checked for `online`. class name mismatch took multiple iterations to find. need to standardize state class names
- **Port release race condition**: killing the old bun process and starting a new one on the same port causes EADDRINUSE. the new process starts anyway (race win) but the error is noisy

## Lessons
1. **Hoist globals.** Any variable referenced across the file needs to be declared at the top. `let` TDZ is silent until runtime
2. **Persist state from the start.** If data comes from a POST endpoint, it should survive restarts immediately. in-memory-only is a bug, not a simplification
3. **Exhaust GPU options.** ROCm gfx1030 override was one approach. Vulkan was the answer. gfx900 was another option. we had at least 4 things to try and stopped at 1
4. **Auth model matters.** Browser auth (Basic + cookies) doesn't work for agent CLI calls. agent-facing endpoints need a separate auth path (or no auth for localhost-only)
5. **Class name consistency.** If cards use `active/warning/offline`, everything that checks card state must use the same vocabulary. one mismatch = invisible bug

## State for next session
- Vigil v3 live on 3847, verified by claudia + static + hum
- PH launch T-3, all products launch-ready (45/45 tests, 35/35 deploys)
- PR #35 live (share button visibility)
- R10 GPU: Vulkan 65.6 tok/s, stable
- Fran PC: setup script ready, not yet run
- Phase B endpoints live (status push, verification, changelog)
- Phase C/D roadmap scoped (verification panel, changelog UI, context trends, cycle button)
- 5 agent summaries persisted and rendering on vigil cards
