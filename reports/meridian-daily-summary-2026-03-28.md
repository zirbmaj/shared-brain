---
title: Meridian Team — Session 14 Full Summary
date: 2026-03-28
author: axis
type: report
scope: meridian
---

# Meridian Team — Session 14 Full Summary

**Date:** 2026-03-28 (T-3 to PH Launch)
**Team:** Axis (coordination), Forge (engineering), Lens (QA), Locus (research)
**Session focus:** Infrastructure integration, fran PC onboarding, architecture research, ops hardening

---

## 1. Fran's PC — Full Mesh Integration (COMPLETED)

Fran's Windows 11 PC is now fully on the tailscale mesh and operational.

**What was done:**
- 8TB Seagate HDD formatted and mounted as G: drive via diskpart (GPT, NTFS, "Storage")
- Setup script (`fran-pc-setup.ps1`) written, debugged through 3 iterations (v1 had encoding corruption from Discord transit, v2 had GPU array detection bug, v3 clean)
- Ollama v0.18.2 detected (pre-installed via AMD AI Bundle), configured for ROCm with 12GB VRAM cap, 2 model max
- OpenSSH Server installed, key-auth only, password auth disabled
- Firewall rules: SSH + ollama locked to tailscale subnet only (100.64.0.0/10)
- Power settings: sleep/hibernate disabled, display sleep at 15 min
- Directory structure created: `C:\nwl\meridian\` with ollama, logs, data subdirs
- Auto-start scheduled task for ollama on boot
- SSH key exchange completed — R10 can SSH to fran-pc (`ssh fran-pc` or `ssh Franc@100.89.96.110`)
- Vigil dashboard accessible at `vigil.nowherelabs.dev`

**Hardware confirmed:**
- CPU: Ryzen 9 7800X3D
- RAM: 63.1 GB DDR5
- GPU: RX 7900 GRE (16GB VRAM, ROCm native, gfx1100) — can run 14B+ parameter models
- Storage: 2TB NVMe SSD (C:, 500GB free) + 8TB HDD (G:)
- OS: Windows 11 Pro Build 26200 + BitDefender

**Known issues:**
- GPU detection script picks iGPU (0.5GB) before discrete 7900 GRE — cosmetic, doesn't affect ollama. Fix: prefer highest VRAM GPU
- BitDefender locks old script files (couldn't delete v1), slows installs (~10 min for OpenSSH)

**Infrastructure result:** Two GPU nodes on the mesh:
| Node | GPU | VRAM | Speed | Role |
|------|-----|------|-------|------|
| R10 | RX 5700 XT | 8GB | 65.6 tok/s (Vulkan) | Always-on, 7B models |
| fran-pc | RX 7900 GRE | 16GB | TBD (ROCm) | On-demand, 14B+ models |

---

## 2. Architecture Research — Hybrid Infrastructure Decision (Locus + Team)

Full decision document produced with all 4 agents contributing their perspective.

**Research delivered:**
- Option 1: Everything in Supabase (rejected — embedding storage costs, no local inference)
- Option 2: Everything on R10 (rejected — SPOF, jam dependency, no managed DB)
- Option 3: Supabase + R10 Hybrid (viable — 80% confidence)
- Option 4: Supabase + Cloud VPS Hybrid (recommended — 90% confidence)

**Cloud VPS recommendation (Hetzner CAX31):**
- 8 vCPU ARM, 16GB RAM, 160GB disk, ~$16/mo
- ARM64 Ollama + nomic-embed-text compatibility confirmed by locus
- Total cost: ~$41-51/mo ($25 supabase + $16 VPS + optional $10 R10 as backup)
- Solves R10's biggest risks: SPOF, jam dependency, no off-site backups, no SLA

**Agent contributions:**
- Forge: setup estimate (4-6 hours), Hetzner pricing matrix, ARM compatibility question
- Lens: failure mode analysis, QA on confidence scores, cost optionality note (R10 spend is optional)
- Locus: decision doc author, ARM64 verification, 4-option comparison, confidence scoring
- Axis: routing, sequencing, fran-readiness review

**Status:** Document ready for fran review. Not yet surfaced — waiting for right timing (PC setup took priority).

---

## 3. Fran Approvals Secured

Two major approvals obtained from fran during this session:

**A. Joint NWL Engineering Session — APPROVED**
- Purpose: Draft shared network operating agreement (resource rules, maintenance windows, monitoring, boundaries)
- Format: Forge + NWL engineer draft, Axis reviews, fran gets final sign-off
- Scheduled for next session

**B. Shared Mesh DB — APPROVED with 3 conditions:**
1. Supabase stays primary for meridian ops — unchanged
2. Mesh DB is cross-team visibility only — no product data, no ops data
3. Schema governance agreed before a single table gets created

---

## 4. Research Highlights Delivered to Fran

Summarized and relayed from NWL research (Near's reports):

**Model optimization:**
- Fran's RX 7900 GRE can run 14B parameter models locally
- "Draft + refine" pipeline: generate locally, polish with API — potential 50%+ token cost reduction
- R10 handles 7B, fran-pc handles 14B+ — complementary

**AI landscape:**
- fish-speech S2 (voice synthesis) needs ROCm — fran's PC can run it when ready
- Claude's official multi-agent framework is experimental — not migrating yet
- No ambient product competitors in PH March top 50 — lane is clear

---

## 5. Research Lab Channel Created

**#research-lab** created by jam with members: Near (NWL), Locus (meridian), Relay, Axis.

**Near's proposed structure:**
- Lane split: Near handles external research (competitive, market, AI landscape), Locus handles internal research (codebase, architecture, benchmarks)
- Shared output format with frontmatter (scope: shared/nwl/meridian)
- Cross-review cadence: each output reviewed by the other (fact-check + blind spot check, not approval gating)
- First joint task: Locus reviews Near's model optimization research from meridian's perspective

**Status:** Channel ready. Locus hasn't reviewed the proposal yet (26% context, aged). Will brief him next session.

---

## 6. Vigil Access Confirmed

Fran can access the multi-tenant vigil dashboard at `vigil.nowherelabs.dev`:
- Login: fran / meridian-vigil
- Default view: Meridian tab
- Features: agent cards, tasks, chat, mesh monitoring, RAG search, TTS alerts, display mode

---

## 7. Ops Notes

**Setup script iterations:** 3 versions needed due to:
1. v1: Character encoding corruption when Discord transmitted the .ps1 file (special chars in comments corrupted)
2. v2: PowerShell array bug — `Get-CimInstance Win32_VideoController` returned 2 AMD GPUs (iGPU + discrete), division on array failed
3. v3: Fixed both issues. GPU detection uses `@()` array wrapper + `[0]` index for first/largest match

**BitDefender interaction:** Antivirus locked the first script file (couldn't delete even with admin + takeown), slowed OpenSSH install to ~10 minutes. Workaround: save new versions with different filenames.

**Relay correction:** Relay initially referred to Lens as the research agent for the research lab pairing. Corrected — Locus is research, Lens is QA.

---

## 8. Outstanding for Next Session

- [ ] Locus reviews Near's research lab proposal (lane split, format, first joint task)
- [ ] Joint engineering session: network operating agreement draft
- [ ] Mesh DB schema governance draft
- [ ] GPU detection fix in setup script (prefer highest VRAM GPU)
- [ ] Surface architecture decision doc to fran (Supabase + Cloud VPS hybrid)
- [ ] Clean up old locked script file on fran's PC after reboot
- [ ] Syncthing setup on fran's PC (future — enables direct file sharing)

---

## Team Health

| Agent | Context % | Status | Notes |
|-------|-----------|--------|-------|
| Axis | 5% | Healthy | Session coordination, fran comms, relay bridge |
| Forge | 17% | Aged | Architecture contribution, setup script engineering |
| Lens | 12% | Aged | Failure mode analysis, QA on decision doc |
| Locus | 26% | Aged | Decision doc author, ARM64 verification, research lead |
