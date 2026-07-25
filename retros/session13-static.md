---
title: session 13 retro — static
date: 2026-03-27
type: retro
scope: static
---

# Session 13 Retro — Static

## What I Did

### Homelab Security & Isolation Model
- Wrote full security architecture for 2-node cluster (shared-brain/projects/homelab-security-model.md)
- 4-layer isolation: unix users, filesystem ACLs, systemd process isolation, network isolation (phase 2)
- Per-tenant design for NWL, Meridian, Chowder on both R10 (Linux) and Mac Mini (macOS)
- Database isolation via PostgreSQL schemas
- Credential management table, SIGTERM handling, atomic state writes proposal
- Finalized with Tailscale ACLs, UFW firewall config, Syncthing security after Near's research landed

### UPS Graceful Shutdown Plan
- Wrote complete NUT architecture (shared-brain/projects/homelab-ups-shutdown.md)
- SSH-only approach (no NUT client on macOS) per Claude's recommendation
- Three shutdown scripts: cluster-shutdown.sh, agent-shutdown-all.sh, ups-notify.sh
- LAN IP fallback in cluster-shutdown.sh for when Tailscale is down during power events
- Home Assistant integration for smart plug safety and UPS monitoring
- 5-step testing plan
- Incorporated Claude's TIMEOUT fix (120→180s)

### Pre-Launch Verification
- Playwright: 45/45 passing
- track.js dev filter: confirmed live on all drift pages. Clean pattern: track.js defines window.nwlTrack only after passing localhost/bot filters, engine.js guards all calls
- Seamless audio: independently verified rain.mp3 and keyboard.mp3 serve correctly
- Caught Claude's stale info on PR #34 (already merged session 11, no review needed)

### Cross-Team Verification
- Reviewed Claude's service architecture doc. Found one inconsistency (NUT client row on Mini service table when we agreed on SSH-only). Claude fixed it
- Verified all three infra docs are aligned: ports, shutdown/startup order, UFW rules, ACLs, tenant users

## What Worked

1. **Producing concrete deliverables while waiting on research.** I wrote both docs as "draft, blocking on Near's research" with placeholder sections for mesh/distro-specific configs. When Near's findings landed, I updated in-place instead of starting from scratch. Total time from Near's post to finalized docs: ~5 minutes

2. **Independent verification of Claude's doc.** Found a real inconsistency that would have caused confusion during implementation. Cross-team review on infra docs prevents misalignment

3. **Session 9.2 carry tracking.** Having explicit carries in my retro meant I knew exactly what to verify. All carries resolved except mobile viewport (needs human eyes)

## What Didn't Work

1. **Spent time verifying audio files that hum already verified.** I independently confirmed 2/15 audio files after hum had already verified all 15. Low value duplication. Should have checked if hum was running audio verification before starting my own

2. **The T-1 baseline naming is confusing.** There are files named t1, t5, and t6 but the dates don't align with what "T-minus" means relative to today. I almost started building another baseline before realizing the existing ones covered it. Naming should use dates, not countdown numbers that shift meaning

## Key Insight

The homelab security model follows the same principle as the session 9.2 auto-cycle fix: **observation must never mutate state by default.** NUT monitoring is read-only until LOWBATT triggers the shutdown sequence. Health APIs are GET-only. Audit logging alerts but doesn't block. The pattern is consistent: safe defaults, explicit opt-in for destructive actions. This should be a design principle we apply to everything we build on the cluster.

### Additional Prep (after initial deliverables)
- NUT deployment package: 8 files in shared-brain/ops/r10-nut-config/ (5 configs, 3 scripts, 1 installer)
- UFW firewall script: shared-brain/ops/r10-firewall-setup.sh
- Tailscale ACL policy: shared-brain/ops/tailscale-acl-policy.json (with meridian node placeholder and port 8080 for RAG)
- Security model updates: double admin for meridian, chromium service port 3860 ACL, tenant-scoped search index note
- Caught data leakage risk in Near's RAG architecture (search API exposes all docs to all tenants)

## Carries for Next Session
- T-1 analytics baseline (Monday March 30, actual T-1)
- Mobile viewport spot-check reminder for jam
- Code freeze verification Sunday night
- Post-PH: R10 setup when jam boots from USB — run install-nut.sh, verify UPS detection, test shutdown chain
- Set MINI_LAN IP in cluster-shutdown.sh once we know Mini's local IP
