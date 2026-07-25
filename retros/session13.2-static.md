---
title: session 13.2 retro — static
date: 2026-03-28
type: retro
scope: static
---

# Session 13.2 Retro — Static

## What I Did

### Rack Infrastructure (3/3 assigned items delivered)

1. **backup-restore-testing** [PRIORITY] — `ops/r10-backup-restore-test.sh`
   - 5-phase validation: dump postgres → restore to parallel test DB → verify row counts + indexes → rebuild schema from scratch → integrity checksums
   - Two modes: non-destructive (default, creates test DB) and --destructive (actual drop/rebuild for scheduled drills)
   - Validates: document/chunk row counts, HNSW index, vector embeddings, FTS index, ollama embedding generation, RAG schema from-scratch rebuild
   - Auto-prunes backups older than 7 days

2. **disk-growth-log-rotation** — `ops/r10-logrotate.conf` + `ops/r10-retention-cron.sh`
   - Logrotate config covering all R10 log files: first-boot, UPS notify, cluster shutdown, agent shutdown, restore test, RAG indexer, health API, per-tenant app logs
   - Retention cron for non-log large data: backup dumps (7d), screenshots (30d), spectrograms (30d), processed audio (14d), stale syncthing conflicts (7d)

3. **tenant-blast-radius** — `ops/r10-tenant-slices.md` + `ops/r10-systemd-slices/` (3 slice files + installer)
   - cgroup v2 via systemd slices: NWL 45% CPU / 14GB RAM, Meridian 45% / 14GB, Chowder 10% / 4GB
   - CPUWeight as proportional weights, MemoryMax as hard OOM cap
   - Blast radius scenario table, monitoring commands, disk quota notes

### Cross-Team Verification

- Caught missing `Slice=nwl.slice` in all 5 of claude's systemd service units. Flagged it, claude fixed it within minutes
- Ran consistency audit across all infra docs: ports, tenant users, service names, ACL policy. Found one gap: boot order in homelab-service-architecture.md listed 7 services, actual systemd chain has 11. Fixed it
- Verified backup script service names (nwl-rag-search.service, nwl-rag-indexer.service) match claude's actual unit files
- Reviewed claudia's vitals bar screenshots: caught missing "unreachable" state for pills with no data. Claudia added `data-threshold="unreachable"` with dashed border + 40% opacity
- Reviewed hum's vitals-audio.js: clean MutationObserver pattern, proper AudioContext lifecycle, correct state machine transitions

### Session Onramp

- Playwright: 45/45 passing
- Retros read, STATUS.md reviewed, deploy log checked
- No issues found in onramp

## What Worked

1. **Delivering all 3 items fast, then shifting to cross-verification.** Having the scripts done early left time to audit claude's work and catch the Slice= gap. The consistency audit (run as background agent) found the boot order doc mismatch. Verification is higher value than producing more artifacts

2. **The "unreachable" state catch on the vitals bar.** False-green (no data displayed as healthy) is exactly the kind of silent failure mode that causes incidents. Hum immediately mapped it to a sonic state (dead radio static). The fix was trivial but the failure mode would have been invisible

3. **Silence when not in my lane.** Claudia + hum designed the vitals bar audio spec. Near did the fish-speech/whisper research. I read along but didn't add noise. The response protocol works when everyone follows it

## What Didn't Work

1. **No way to test the backup script until the R10 is live.** The script is syntax-validated and logically sound, but it's untested against real postgres. This is a known constraint, not a failure, but the verification items I posted are carries that need to happen before we call the restore path validated

## Key Insight

This session was infrastructure paperwork: scripts, configs, docs. The most impactful thing I did was not what I built but what I caught in someone else's work. The Slice= gap would have meant tenant resource limits existed on paper but weren't enforced. Cross-verification between parallel workstreams is where QA adds the most value on infra work.

### R10 Live Verification (post-deployment)

Verified against live R10 over Tailscale SSH:

1. **Health API** — pass after fix. `cpu_temp_c: 38.0`, `disk_pct: 22`, all service statuses correct. Caught missing cpu_temp_c field, claude fixed it
2. **Tenant slices** — pass. nwl.slice active, node-health and rag-search assigned correctly. Caught StartLimitIntervalSec in wrong section, claude fixed it
3. **Logrotate** — pass after fix. Deployed, parsing correctly. Found `su` directive needed for nwl-svc-owned logs, fixed in source. Updated config will deploy after syncthing pairing
4. **Backup-restore** — pass. 15/15 checks. Found 3 bugs in my own script during live testing: backup dir permissions (/srv/nwl is mode 700, postgres can't write), timestamp hyphens invalid in DB names, psql -f can't read files through 700 dirs. All fixed, full restore path verified

### GPU Vulkan Discovery

Ran the ROCm experiment on the R10's RX 5700 XT. Systematic approach:
1. gfx1030 override: model loaded (33/33 layers, 4GB VRAM) but inference hung. Reverted
2. gfx900 override: runner crashed entirely. ROCm is a dead end for gfx1010
3. **OLLAMA_VULKAN=1: 65.6 tok/s.** 10x speedup over CPU (6.7 tok/s). Stable across 5 back-to-back runs, 53°C, no degradation

Key lesson: jam pushed back when we called it after one attempt. The first failure (ROCm) was the wrong driver path, not a hardware limitation. Vulkan bypasses ROCm entirely and works on all AMD GPUs. Config persisted in systemd.

### Vigil V3 Verification

Full QA pass on multi-tenant vigil refresh:
- Staging verification on port 3851: 5/5 endpoints tested (tenants, status filtering, GPU, nodes, search)
- Cross-verified API data against live R10 health endpoint — all fields match
- Found search proxy bug: GET→POST mismatch with RAG API. Claude fixed, re-verified
- Found fran-pc not in vitals bar + mesh grid empty. Claude fixed
- Found health API `backend=cpu` when GPU was vulkan. Relay patched health-server.py, I deployed to R10 (source at /srv/shared/bin/ was stale vs syncthing copy)
- Found agent-status endpoint: auth blocking agent POSTs + agentSummaries ReferenceError. Claude fixed both
- Found summaries wiped on restart (in-memory only). Claude added file persistence
- Verified final state: 10/10 agents, summaries rendering, counter correct, search working

### Session Contributions Summary

- 3 rack concern deliverables (backup-restore, logrotate, tenant slices)
- Cross-verified all of claude's systemd units (caught Slice= gap)
- Caught vitals bar "unreachable" state gap
- Ran full R10 live verification (4 items, found 3 bugs)
- Executed ROCm/Vulkan GPU experiment (found 65.6 tok/s via Vulkan)
- Caught Windows admin SSH key path issue in fran's setup script
- Updated port registry and boot order docs
- Verified vigil v3 across staging and production (found 6 bugs total)
- Phase B endpoints tested end-to-end

### Session 14 Continuation (afternoon)

Vigil v3 multi-tenant refresh — full QA across 26+ deploys:
- Verified all new endpoints: tenants, status filtering, GPU, nodes, search, agent-summaries, verifications, changelog, doc-qa, agent-health webhook
- Wrote vigil API test suite (tests/vigil-api-tests.sh): 24 tests, 3-second runtime, ran after every deploy
- Caught search proxy regression (hybrid mode 500), flagged until fixed
- Caught doc Q&A hallucination (mistral:7b answering "Tesla V100" when excerpt says "Vulkan"), flagged prompt and model issues
- Caught test suite triggering phantom TTS alerts ("test is back"), fixed test agent naming
- Deployed near's query expansion + re-ranking to R10 (copy from syncthing path to service path, restart)
- Deployed health-server.py GPU backend fix to R10 (backend=cpu → backend=gpu)
- Deployed health-server.py CPU/RAM patch (hum applied)
- Topology rendering: flagged 6 times alongside claudia until root cause found (services object vs array)
- Pushed back on adding features mid-brainstorm, advocated for ideate→plan→execute
- Pushed back on push notifications before code freeze (risk vs reward)

## Carries for Next Session

- Re-deploy updated logrotate config after syncthing sync
- T-1 analytics baseline (Monday March 30)
- Code freeze verification Sunday night
- Re-run full pre-launch sweep before freeze (69/69 target)
- Verify llama3:8b doc Q&A quality when model is pulled
- Re-auth tailscale SSH (session expired)
