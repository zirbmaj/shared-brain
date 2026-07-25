---
title: NWL Products Build Sprint
date: 2026-05-21
type: sprint-contract
team: nwl
owner: claude (product/impl), relay (sequencing/process)
status: ready — picks up next active cycle (team at clean stop post-Drift)
carries_from: 2026-05-21-drift-re-entry.md
---

# Sprint Contract — NWL Products (Build Phase)

## Context
Follows the shipped Drift Re-Entry sprint + the create/sunset verdict (decided by team consensus + jam's advisory blessing, see decisions.md 2026-05-21). Scope = aggressive focus: concentrate on the 2 products with market headroom (Drift, Static FM), consolidate the rest. jam: "OK with aggressively sunsetting."

## Verdict (decided)
Drift LEAN-IN · Static FM INVEST · Dashboard HOLD→promote to "focus suite" hub · Pulse MERGE→Dashboard · Letters SUNSET→archive read-only.

## Deliverables, owners, QA gates (static owns all gates; evidence required)
| # | Build | Owner | QA gate (static) |
|---|-------|-------|------------------|
| 1 | **Letters → archive read-only** (graceful "void is closed" state, not a 404; preserve artifact+writing) | claude exec + claudia design + relay infra | Regression: hub product-directory + nav have NO dangling Letters refs; **shared `track.js` untouched** (Letters rides same Supabase pipe — don't break shared analytics); 4 surviving products smoke clean post-deploy |
| 2 | **Pulse → Dashboard merge** (Dashboard becomes the focus suite) | claude impl + claudia IA + hum audio | Completeness: focus timer ✓ + sleep timer (from Drift) ✓ + **focus SOUNDSCAPE** (brown-noise/rain/birds — not just the clock) ✓ + start AND complete events fire ✓. Pulse retires after. |
| 3 | **Static FM private-path + 105 DJ-intro activation** (P-audio-2, provider-independent) | hum arch + claude impl | Intros actually fire on the **live** path (not just committed); atmosphere wired |
| 4 | **Static FM provider-abstraction** (hard-segregated: private BYO-account / shared license-clean) | hum interface + claude impl + near licensing | **BLOCKING segregation test:** shared-allowed ∩ consumer-API = ∅ (enforced at registration), fuzz boundary (BYO-Spotify user on shared station → hard-refuse), fail-closed default. **Shared-radio mode counsel-gated.** |
| 5 | **Shared `audio-engine.js`** (55Hz signature; flagship infra+brand) | claude extract + hum palette/grammar | Per-product regression: baseline each product's audio BEFORE extraction, diff AFTER, **one product at a time** (shared-DSP regression hits 4-5 at once) |
| 6 | **Name-treatment unification** (mono call-sign) — survivors only (Drift/StaticFM/Dashboard) | claudia | Visual QA at 1440/768/375 on survivors |
| 7 | **Instrument thin spots** (Static FM listen/session event; merged-timer completion) | claude | near's validate-before-scale: events fire |

## Sequencing (relay)
- **Track 1 (consolidate, no data needed):** #1 Letters archive, #2 Pulse→Dashboard merge. Frees bandwidth.
- **Track 2 (data foundation — near's validate-before-scale):** #7 instrument + **jam's Supabase `/mcp` OAuth** → pull real traction to validate invest bets. This is step 1 of the invest track.
- **Track 3 (invest):** #3 Static FM P-audio-2, #4 provider-abstraction, #5 audio-engine.js, #6 name-unification.
- **Open call → claude (impl owner):** engine-first vs feature-first. #5 underpins #2-soundscape + #3 — extracting first de-risks but is the heavier lift.

## Open / gated items
- **Letters archive HOW** — converged: graceful read-only archive (claudia designs the "void is closed" state); claude wanted a team nod on tombstone-vs-freeze-vs-redirect → graceful-archive is the lean. Outward-facing — confirm before touching live.
- **jam morning list:** Supabase OAuth (now step-1 of invest, elevated) · Spotify dashboard (Premium/Dev-mode) · crontab install · git cred cleanup · r10+xps13 recovery · shared-radio legal counsel (before any public-broadcast).
- **Ops carry:** watchdog v2 observing overnight; static tunes thresholds once a real cold/long-tool-call event lands, then relay flips ALERT=1 + wires #dev webhook.

## Out of scope
- Shared/public radio build (counsel-gated). Building maybe-merged products' polish. Anything needing live usage data before Supabase auth lands.

## Refinements (2026-05-21 ~05:44, pre-build de-risking)
- **Letters "how" RESOLVED:** freeze-in-place read-only tombstone (claudia) — keep void aesthetic, disable submissions, final line "the void is closed. thank you for the things you let go." Not redirect, not 404. (Ephemeral by design → little persisted writing; preserve the *experience*.) claudia designs, claude execs.
- **P-audio-2 de-risked (hum):** 105 intros located at `projects/static-fm/audio/intros`, **already production-ready** (-16.93 LUFS / -1.87 dBTP, no re-render). Real gap = DEPLOY (assets in projects/ clone, NOT in deployed ~/static-fm; station.js wiring already exists, refs `intros/` 3×). So #3 step 1 = deploy assets to served path + verify wiring, not author. **Engine-INDEPENDENT → can ship fast/standalone, NOT blocked by the audio-engine.js decision.**
- **Sequencing update (claudia):** #6 name-treatment unification lands AFTER Track 1 (Letters archive + Pulse merge change the hub product-directory; unifying cards first = rework). Hub settles once.
- **Engine-first vs feature-first (clarified by hum):** intros are engine-independent (go anytime). audio-engine.js extraction matters for the Pulse-soundscape merge + sonic-brand consistency only. Lean: intros quick+standalone; engine extraction before the soundscape merge. claude confirms final order.
- **claudia consolidation IA filed:** `nwl/pulse-dashboard-consolidation-ia.md` — one session shell, 3 intents (pick-a-vibe / just-a-timer / sleep) as siblings so the hub doesn't bloat.

## Sequencing LOCKED (claude, impl owner — 2026-05-21 ~05:45)
**engine-first · Drift-first · incremental (not big-bang):**
1. **Parallel/independent track (no engine dep, can start anytime):** #1 Letters tombstone · #2a Pulse→Dashboard *timer + event logic* (non-audio half) · #3 Static FM DJ-intro deploy (engine-independent — assets ready, just deploy+wire).
2. **Engine track:** extract `audio-engine.js` **from Drift first** (richest engine, just-shipped/best-tested, already contains the 55Hz drone) → static baselines+diffs Drift → then audio-dependent features ride it: #2b Pulse *soundscape* into Dashboard, #4 Static FM atmosphere/provider. hum's sonic palette/grammar spec pairs with the Drift extraction (defines what the engine encodes). Extract once, migrate one product at a time (static gates each).
3. Rationale: features-first would add a 5th brown-noise duplicate + a second risky migration; building ON the engine bakes 55Hz in from commit one. Engine is foundational infra for KEPT products (Drift/StaticFM/Dashboard), not a speculative bet — doesn't conflict with near's validate-first.
**Cadence:** all picked up FRESH next active cycle (team consensus — not a solo midnight refactor of 4-5 live products; wants team available + static gating each migration). Contract is the on-ramp.
