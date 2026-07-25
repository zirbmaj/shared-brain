---
title: Vigil Improvement Plan
date: 2026-03-28
type: project
scope: infrastructure
owner: relay (coordination), claude (engineering), claudia (design QA), hum (audio)
status: active
---

# Vigil Improvement Plan

*Owner: Relay. Test-iterate-improve cycle. Claude builds, claudia QAs, hum owns audio layer.*

## Current State (session 14, 2026-03-28)

Vigil v3 is live on port 3847 via cloudflare tunnel. Multi-tenant architecture with NWL/Meridian/All/Mesh tabs. Core panels: activity feed, usage/context meters, tasks, chat. Hardware vitals bar for Mini + R10. Audio layer: ambient drone, agent identity tones, codec chat sounds, voice alerts (Web Speech API).

### What's Working
- Agent status cards with online/offline/context tracking
- WebSocket real-time sync for tasks and chat
- Hardware vitals bar (Mini services/disk, R10 temp/disk/ups/gpu)
- Mesh tab with node cards (Mini, R10, Fran-PC) showing resources, GPU, services
- 3-column layout (claude shipped session 14)
- Changelog feed
- RAG search with preview
- Verification panel
- Audio: drone, identity tones, codec sounds, voice alerts
- Hum's vitals-audio.js module

### Known Issues (pre-launch)
1. Session bar hardcoded to "session 13.2" — needs dynamic update
2. Tenant tab switching may not be wired in app.js (CSS exists, JS unclear)
3. State duration not shown on agent cards ("BUILDING" but not "BUILDING (12m)")
4. No current task description on agent cards — just state label
5. Vigil chat monitoring needs active polling (jam expects real-time responses)

---

## Phase 1: Pre-Launch Polish (before march 31)

Priority: fix what jam sees. No new features.

| # | Item | Owner | Est | Status |
|---|------|-------|-----|--------|
| 1 | Update session bar to session 14 | claude | 5min | DONE |
| 2 | Verify tenant tab switching works end-to-end (NWL/Meridian/All/Mesh) | claude + claudia | 15min | DONE (claudia QA'd) |
| 3 | Mesh tab: deep node cards (disk, GPU, services, uptime) | claude | 30min | DONE |
| 3b | Mesh tab: add CPU% and RAM% (requires health-server.py update on R10) | claude | 30min | queued after query expansion |
| 4 | Verify layout — 3-column grid | claudia | 15min | DONE |
| 5 | State duration on agent cards ("BUILDING 12m", amber after 30m) | claude | 15min | DONE |
| 6 | Display mode CSS (`?display=true`) | claudia + claude | 30min | DONE |
| 7 | Vigil API test suite (24/24) | static | 30min | DONE |

## Phase 2: Pre-Launch — Ship Today (2026-03-28)

Jam directive: all vigil improvements and ops tightening ship pre-launch. No parking.

| # | Item | Owner | Est | Status |
|---|------|-------|-----|--------|
| 1 | State duration on agent cards — "BUILDING (12m)" not just "BUILDING" | claude | 30min | DONE — verifying render |
| 2 | Current task description on cards — auto-push from agent sidecar or manual status | claude | 1hr | assigned |
| 3 | Query expansion for vigil search — 44 terms, server-side in RAG API | near + claude | 2hr | DONE — vector+rerank mode live |
| 4 | Piper TTS integration — replace Web Speech API, 64 cached phrases, 8ms latency | hum + claude | 2hr | DONE — systemd unit needs jam |
| 5 | Dedicated display mode — `?display=true` hides chrome, maximizes content | claudia + claude | 1hr | DONE |
| 6 | Chat → relay routing verification — mc-chat-alert.json working | relay | 30min | DONE |
| 7 | Re-ranking — cross-encoder ms-marco-MiniLM, +50ms latency | near | 2hr | DONE — 24/24 tests green |
| 8 | CPU% and RAM% on R10 health API | hum | 15min | DONE — data live, claude wiring UI |
| 9 | Hybrid search 500 bug on expanded queries (param count) | near | 30min | in progress, non-blocking (vector+rerank is production) |

## Phase 3: Post-Launch

Infrastructure depth. Make vigil the single pane of glass.

| # | Item | Owner | Est |
|---|------|-------|-----|
| 1 | Historical context usage graphs (per agent, over time) | claude | 2hr |
| 2 | Deploy history timeline in vigil (webhook integration) | claude + relay | 2hr |
| 3 | Cost tracking panel — API spend, Vercel deploys, ElevenLabs chars | claude | 2hr |
| 4 | Fran-PC deep integration — ROCm GPU stats when online | claude | 1hr |
| 5 | Shared mesh DB dashboard — cross-team visibility layer | claude + relay | 3hr |
| 6 | Anti-burn-in mode for dedicated display (2px drift, dimming) | claudia | 30min |
| 7 | Audio-visual sync with hum's ambient drone (pulse ring concept from display spec) | hum + claudia | 3hr |

---

## Test-Iterate-Improve Protocol

1. **Relay tests** — after each claude deploy, relay verifies via curl/screenshot that the change works
2. **Claudia QAs** — visual verification on every layout/design change
3. **Static validates** — if a test can be automated, static writes it
4. **Jam sees it** — if jam flags something, it goes to top of the queue
5. **Iterate** — small changes, frequent deploys, verify each one before moving to next

## Phase 2: Shipped Same Day (2026-03-28 late afternoon)

| # | Item | Owner | Status |
|---|------|-------|--------|
| 10 | Contrast pass — bumped borders, text, accents for fran | claudia + claude | DONE |
| 11 | Search v2 — keyboard nav, full-width preview, scores, timing | claude + claudia | DONE |
| 12 | Doc Q&A via llama3 — select text, ask questions, local inference | claude + near | DONE |
| 13 | @agent routing in chat — directives to agents from vigil | claude | DONE |
| 14 | /search in chat — RAG results inline | claude | DONE |
| 15 | / autocomplete command palette | claude | DONE |
| 16 | Mini node 9/9 services (agents as service dots) | claude | DONE |
| 17 | Search truncation + scroll overflow fixed | claudia + claude | DONE |
| 18 | Codec overlap fix | hum + claude | DONE |
| 19 | Mesh topology view — triangle layout with SVG connection lines | claudia + claude | DONE (6 deploys) |
| 20 | llama3:8b on R10 replacing mistral for Q&A | hum | DONE |
| 21 | 30+ interaction sounds across full UI | hum + claude | DONE |
| 22 | Research lab channel + structure | near + relay | DONE |
| 23 | Railway.com evaluation | near | DONE (pass — no use case) |

## Phase 3: Ideation (jam directed — ideate → plan → execute)

| # | Item | Owner | Status |
|---|------|-------|--------|
| 24 | RAG chatbot — conversational AI grounded in shared-brain | near (arch) + claude (build) + claudia (CSS) | DONE — /ask is live |
| 25 | MGS codec chat experience — agent portraits, scan lines, per-agent voice/audio | claudia + hum | ideating — joint spec pending |
| 26 | Doc workspace: tab manager, split view, TOC sidebar | claudia (design) | ideated, needs plan |
| 27 | Conversational search context carry (session buffer) | near (design) | ideated |
| 28 | Push notifications — configurable per event type | claude | service worker deployed, needs testing |
| 29 | Fran PC health monitoring — Windows health server | claude + axis | needs fran's side |
| 30 | Piper systemd unit on R10 | jam hands | spec ready |

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-28 | ElevenLabs for brand voice, piper for system alerts | hum benchmark: piper 3.4x RT but 22kHz vs 44kHz quality gap |
| 2026-03-28 | 3-column layout over 2-column | terminal needs width, bottom panels were cramped |
| 2026-03-28 | vector+rerank as production search mode | hybrid had param bugs, vector+rerank is 57ms and reliable |
| 2026-03-28 | vigil.nowherelabs.dev for all users | meridian.nowherelabs.dev is old single-tenant, main vigil has all features |
