---
title: Session 13.2 Retro — Claude
date: 2026-03-28
type: retro
scope: infrastructure
owner: claude
---

# Session 13.2 Retro — Claude

## What shipped

### Rack infrastructure (5/5 assigned items)
1. **boot-dependency-order** — 5 systemd unit files + 3 overrides with full After=/Requires=/BindsTo= chain. boot-test.sh validates the entire graph. install-units.sh for one-command deploy
2. **failure-policy** — bundled into units. Restart=always for critical services, on-failure for others. RestartSec staggered to avoid thundering herd. StartLimitBurst prevents infinite loops
3. **time-sync** — systemd-timesyncd with NTP pools, CST timezone, cross-node clock drift verification via SSH
4. **secret-storage** — r10-secret-setup.sh generates 32-char random passwords per tenant, creates .env files with mode 600, updates PostgreSQL in place. --rotate flag for quarterly rotation
5. **gpu-driver-stability** — documented CPU-only baseline, added Ollama latency/backend detection to health server, keyword-only fallback in RAG search API, resilient embed_texts() in indexer

### Vitals bar support (bonus, unblocking claudia + hum)
- Added cpu_temp_c, disk_pct, ollama latency_ms/backend to health-server.py
- Added /api/node-health/{mini|r10} proxy route to both mission-control and vigil-meridian server.js
- Returns { status: "unreachable" } on timeout — maps to claudia's data-threshold="unreachable" state

### first-boot.sh updates
- Integrated time-sync (step 1b), secret generation (step 12), systemd unit installation (step 13), syncthing inotify tuning (step 9)

## What worked
- **Bundling related items.** boot-dependency-order + failure-policy were tightly coupled — building them together in the same unit files was faster than separate deliverables
- **Static's cross-verification.** Caught missing Slice=nwl.slice before it became a deployment bug. Fixed immediately
- **Near's handoff.** Syncthing config tuning was ready to drop into first-boot.sh. Clean coordination
- **Team velocity.** 12/12 rack concerns addressed in one session across 4 agents. Zero duplication

### R10 live deployment
- Walked jam through Ubuntu DNS fix (router intercepts port 53, must use 192.168.0.1)
- first-boot.sh ran clean: all 11 steps completed, postgres/ollama/syncthing/docker installed
- Installed tailscale on mini (brew), authenticated both nodes on mesh
- Deployed remotely via SSH: firewall, secrets, systemd units, health server, RAG services
- Fixed 3 issues caught by static's verification:
  - cpu_temp_c: added hwmon fallback (AMD k10temp uses /sys/class/hwmon/ not thermal_zone)
  - StartLimitIntervalSec: moved from [Service] to [Unit] in all files
  - logrotate: deployed to /etc/logrotate.d/nwl
- postgresql.service override: removed Restart=always (incompatible with Type=oneshot)

## What worked
- **Bundling related items.** boot-dependency-order + failure-policy were tightly coupled — building them together in the same unit files was faster than separate deliverables
- **Static's cross-verification.** Caught Slice=nwl.slice, then cpu_temp_c missing + StartLimit in wrong section on live deployment. Real hardware finds real bugs
- **Near's handoff.** Syncthing config tuning was ready to drop into first-boot.sh. Clean coordination
- **Team velocity.** 12/12 rack concerns addressed, R10 deployed and verified, all in one session
- **Remote deployment.** Once tailscale mesh was up, full control of R10 from the mini. No more jam bottleneck for software tasks

## What to improve
- **Test with actual systemd earlier.** StartLimitIntervalSec in [Service] and postgresql Type=oneshot conflict were both caught on live deploy. Could have been caught with a systemd-analyze dry run if we had a linux test environment
- **Pre-check tailscale on both nodes.** We should have verified tailscale was on the mini before asking jam to set up the R10. Cost 15 minutes of back-and-forth
- **R10 username assumption.** Assumed `jambrizr` but it was `jambriz`. Should have asked upfront
- **hwmon vs thermal_zone.** AMD Ryzen uses hwmon, not thermal_zone. CPU temp function should have checked both from the start

## State at session end
- **R10 operational**: postgres, ollama, syncthing, node-health, rag-search all running
- **Health API live**: cpu_temp_c (38°C), disk_pct (22%), all service statuses, ollama latency/backend
- **Vitals bar pipeline wired end-to-end**: health API → mesh → proxy → CSS → audio
- **Tailscale mesh**: mini (100.119.24.85), R10 (100.69.185.101), MBA (100.96.255.35)
- **Remaining jam tasks**: syncthing pairing, UPS USB → NUT, home assistant docker
- T-3 to PH launch (Tuesday 2026-03-31)
- Code freeze Sunday night
