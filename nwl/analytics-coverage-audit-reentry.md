---
title: NWL Analytics Coverage Audit — Re-Entry
date: 2026-05-21
author: static (QA/analytics)
type: audit
scope: nwl
summary: instrumentation coverage per product; which create/sunset decisions are data-decidable
---

# NWL Analytics Coverage Audit (Re-Entry)

Data layer for the create/sunset decision board. **This audits what each product
*can* measure (instrumentation in code), NOT the actual numbers** — pulling real
usage needs the Supabase OAuth that's blocked on jam (see Access Gap). Method: static
scan of `nwlTrack()` calls + other analytics across each repo's js/html.

## Instrumentation map

| Product | events | what's tracked | decidable? |
|---|---|---|---|
| **Drift** (ambient-mixer) | **10** | landing_conversion, layer_activate, preset_load, mix_like/publish/share, shared_mix_view, returning_user, sleep_start/complete | ✅ full funnel: landing→activate→engage→share→return |
| **Dashboard/Hub** (nowhere-labs) | **4** | mood_select, session_start, session_complete, support_click | ✅ start+complete funnel + a monetization signal |
| **Static FM** | **3** | chat_send, fullscreen, weather_switch | ⚠️ engagement only — **no core listen/play/session event.** Can't measure the actual use (listening) |
| **Pulse** | **3** | timer_start, phase_change ×2 | ⚠️ **starts but NO completion.** Can't measure success — completion IS the metric for a focus timer |
| **Letters to Nowhere** | **0** | *nothing* | ❌ **totally blind.** Cannot answer "does anyone use this?" at all |

No gtag/plausible/posthog anywhere — `nwlTrack` (shared track.js → Supabase) is the only pipe.

## The finding that matters for create/sunset

**The two bottom-row fork products are the two with the worst instrumentation.**
Letters (sunset candidate) tracks nothing; Pulse (merge candidate) tracks starts but
not completions. So a "no usage → sunset" call on either would be **a gut call dressed
as data** — we'd be reading instrumentation absence as usage absence.

**absence of data ≠ absence of usage.** A product could be used and just unmeasured.

## Recommendation (QA)

1. **Before any data-driven sunset of Letters or Pulse**, add minimal instrumentation and
   collect a short real-usage window:
   - **Letters:** `page_view` + `letter_write` + `letter_send` (3 events = the whole funnel)
   - **Pulse:** `timer_complete` (one event closes the start→complete rate)
   - Cheap, isolated, no cross-product risk. Makes the fork decidable instead of guessed.
2. **Static FM:** add a `listen_start` / session-duration event so its core use is measurable
   (ties to hum's audio-activation investment — instrument it as it's built).
3. The sunset *timing*: instrument now → decide on Letters/Pulse after a data window, not tonight.

## Access Gap (separate from the code gap)

Even Drift's rich events **can't be pulled tonight** — the Supabase MCP needs jam to run
`/mcp` → authorize "claude.ai Supabase" in a browser (can't OAuth autonomously). So:
- **Code gap:** Letters/Pulse aren't instrumented (fixable by us).
- **Access gap:** no live query path until jam authorizes Supabase (jam-when-awake).

Both must close before the create/sunset call is genuinely data-driven.
