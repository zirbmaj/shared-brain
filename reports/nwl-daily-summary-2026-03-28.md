---
title: NWL Daily Summary — 2026-03-28
date: 2026-03-28
type: report
scope: shared
author: relay
---

# NWL Daily Summary — 2026-03-28 (T-3, Launch Tuesday March 31)

## Overview

Full sprint day across all 6 NWL agents. Two major work tracks: (1) vigil ops dashboard improvement sprint shipping 9 features in one session, and (2) infrastructure hardening including GPU unlock, mesh networking, and cross-team integration with Meridian.

---

## Vigil Ops Dashboard — 9 Features Shipped

### Session Bar + State Duration
- Session bar updated from 13.2 to 14 with dynamic focus text
- Agent cards now show state duration ("BUILDING 12m") with amber threshold at 30 minutes
- Duration displays seconds for first minute, then switches to minutes

### Display Mode
- `?display=true` query param activates dedicated screen mode
- Hides search, brand text, compresses header — maximizes content area
- Claudia designed CSS, Claude wired the JS toggle

### Piper TTS Voice Alerts
- Replaced browser Web Speech API with real voice synthesis via Piper on R10
- Service running on R10:8091 with 64 pre-cached alert phrases
- Cached responses return in 8ms through full proxy chain (vigil → R10 → cache → back)
- 7 voice events mapped: agent-offline, agent-cycling, agent-back, context-critical, agent-stalled, needs-input, deploy-failed
- Graceful fallback to Web Speech API if R10 is unreachable
- Loudness normalized to -22 LUFS to match headphone levels

### Query Expansion
- 44-term dictionary for vigil search — rewrites vague queries with domain-specific terms
- "AI decisions" now finds ai-strategy.md (was invisible before)
- Server-side in RAG API, zero client-side latency
- Dictionary is editable JSON, no code changes needed

### Cross-Encoder Re-Ranking
- ms-marco-MiniLM-L-6-v2 (22MB model) re-ranks search results
- Over-fetches top 20, re-ranks, returns top_k
- Adds ~50ms latency, significantly improves result relevance
- Graceful degradation — if model not installed, search works without re-ranking

### Hybrid Search Fix
- Pre-existing SQL parameter count bug in BM25 path exposed and fixed
- Bug existed since hybrid mode was written but never triggered (default was vector-only)
- Near's `mode` field exposed it, Near fixed it same session

### CPU/RAM on Mesh Nodes
- Extended health-server.py on R10 with /proc/meminfo + /proc/loadavg parsing
- Mesh tab now shows CPU%, RAM%, disk%, temp, GPU, services for each node
- Hum applied the patch and restarted the service

### Contrast Pass
- Fran flagged vigil as too dark — claudia bumped contrast on all interactive elements
- Panel borders 6%→10%, secondary text brightened, accent glow 20%
- Same dark aesthetic, more visible structure. Cascades through CSS variables

### Context Burn Rate Sparkline
- SVG sparkline next to context bar on each agent card
- Shows context % trend over last 30 data points
- Green when healthy, amber when ≥75%

### Test Agent Suppression
- Agents prefixed with `_` suppressed server-side and client-side
- Static's API test suite no longer triggers phantom voice alerts

---

## Vigil API Test Suite
- Static wrote 24 automated API tests covering all endpoints
- Authentication, tenants, agent status, mesh nodes, GPU, search, summaries, verifications, changelog
- Runs in 3 seconds, integrated into pre-deploy checklist
- 24/24 green maintained across all deploys today

---

## Infrastructure

### R10 GPU — Already Operational
- RX 5700 XT running via Vulkan at 65.6 tok/s (10x over CPU)
- ROCm incompatible with RDNA1, Vulkan bypasses it
- Stress tested: stable at 53°C, persists across reboots
- Running: ollama (embeddings + mistral), piper TTS, RAG search API

### Fran's PC on Mesh
- SSH key pair generated on R10, exchanged with fran's PC
- `ssh fran-pc` from R10 works (Franc@100.89.96.110)
- Vigil access confirmed at vigil.nowherelabs.dev
- 8TB drive formatted and mounted, setup script completed
- RX 7900 GRE (16GB VRAM) available for ROCm workloads

### R10 Services (7/7 Green)
- PostgreSQL 16 + pgvector
- Ollama (nomic-embed-text + mistral:7b)
- RAG Search API (port 8080) — with re-ranking + query expansion
- Piper TTS (port 8091) — new today
- Syncthing (bidirectional with mini)
- Whisper STT (port 8090)
- Node Health API (port 3850) — extended with CPU/RAM today

---

## Research

### AI Landscape Scan (Near)
- 8 sections: agent frameworks, model landscape, RAG improvements, generative audio competition, fish speech assessment, claude code velocity, actionable items
- 9 actionable items routed across 5 agents with timelines
- Key finding: no ambient product competitors in PH March top 50
- Claude Agent Teams (official multi-agent) is experimental — don't migrate

### Model Optimization Research (Near)
- Estimated 35-50% API cost reduction by switching most agents to Sonnet 4.6
- Relay → Haiku 4.5 (cheapest lane), Claude → Sonnet default with Opus for architecture
- GPU utilization: R10 could run Qwen 2.5 Coder 7B, fran's PC could run 14B models
- Local "draft + refine" pipeline could reduce tokens 50%+ for routine tasks
- OpenAI not worth switching — harness cost outweighs savings
- Phased rollout post-launch, relay as test case

### Piper TTS Benchmark (Hum)
- Medium: 1.50s gen, 5.10s audio, 3.4x real-time
- High: 2.21s gen, 5.02s audio, 2.3x real-time
- Decision: ElevenLabs for brand voice (George), Piper for system alerts
- Piper is free, local, no API limits

---

## Audio (Hum)
- Piper TTS service built and deployed on R10
- 64 alert phrases pre-generated and cached
- Piper endpoint spec written for vigil integration
- Fish-speech S2 confirmed incompatible with Vulkan (needs CUDA/ROCm)
- Systemd unit spec written for R10 persistence (needs jam's hands)

---

## Process & Ops (Relay)

### Memory Audit Protocol
- Stale memory discovered: "standing permission to cycle shadow agents" was outdated
- Updated to: "never cycle meridian agents unless they request it"
- New offramp checklist item: scan feedback memories for conflicts with session corrections
- New protocol: when jam corrects a rule, update memory file immediately before anything else

### Documentation Updates
- agent-cycle-procedure.md: meridian boundary enforced in safeguards + "who can cycle"
- offramp-v2-template.md: memory audit added to persistence checklist
- consolidated-backlog.md: updated to session 14 with all post-launch items
- STATUS.md: updated with afternoon session shipped items
- vigil-improvement-plan.md: created and maintained through the sprint (9/9 items tracked)

### Cross-Team
- #research-lab channel created for near + locus collaboration
- Research lab structure proposed: lane split (market vs infrastructure), shared output format, peer review cadence
- Fran's research summaries delivered via axis

---

## Pre-Launch Verification
- **Playwright tests:** 45/45 green (all products)
- **Vigil API tests:** 24/24 green (all endpoints)
- **R10 health:** 7/7 services, CPU 0.4%, RAM 14.8%, disk 40%, temp 51°C, GPU Vulkan, UPS 100%
- **Mini health:** 3/3 services, 6/6 agents online
- **Total: 69/69 verifications green**

---

## Pre-Launch Visual Baseline (Claudia)
- 32 screenshots captured: 8 products × 4 breakpoints (375px, 768px, 1024px, 1440px)
- Products: drift landing, drift app, static fm, homepage, dashboard, letters, pulse, discover
- All from production URLs — baseline for launch-day regression detection

---

## Team Context Levels (End of Day)
| Agent | Context | Status |
|-------|---------|--------|
| Claude | 35% | healthy |
| Static | 33% | healthy |
| Claudia | 24% | healthy |
| Near | 20% | healthy |
| Hum | 19% | healthy |
| Relay | 13% | healthy |

No cycles needed. All agents productive.

---

## Remaining Jam-Hands Items
1. Piper systemd unit on R10 (spec posted by hum)
2. PH listing submission (Monday night March 30)
3. PH env vars (PH_API_TOKEN, PH_POST_SLUG, PH_WEBHOOK_URL)
4. Vercel pro upgrade ($20/mo — launch day insurance)
5. Spotify redirect URI update
6. Chowder auth switch to Sonia's account

---

*Written by Relay. Session 14, 2026-03-28.*
