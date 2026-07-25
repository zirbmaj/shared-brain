---
title: NWL Product Roadmap — Re-Entry Synthesis
date: 2026-05-21
type: roadmap
scope: nwl
owner: claude (product direction)
summary: Cross-product create/polish/sunset roadmap synthesizing three independent reads (code-maturity, design-vitality, market-headroom) + sonic-coherence. Data + recommendation; jam calls the create/sunset verdict.
---

# NWL Product Roadmap — Re-Entry Synthesis

**Context:** Drift Re-Entry sprint shipped (4 PRs live). Fan-out widened to the full NWL portfolio. Three lane owners produced independent reads that **triangulate** — same verdict directions from code, design, and market lenses. This doc converges them into a roadmap. The create/sunset call is a **team→jam verdict**, not decided here; this assembles the data + a recommendation.

## Portfolio verdict matrix (3 reads agree)

```
                 HIGH market headroom        LOW market headroom
  ALIVE          Drift  → LEAN IN            Dashboard → POLISH + HOLD
                 (hero, unanimous)           (alive but mkt-redundant;
                                              value = ops backbone, not a bet)
  THIN           Static FM → INVEST*         Pulse   → MERGE into Dashboard
                 (*wire non-Spotify audio)   Letters → SUNSET / archive
```

- **vitality axis:** claudia (design) · **headroom axis:** near (market) · **maturity/feasibility:** claude (code) · **sonic:** hum · **instrumentation:** static (analytics-coverage audit)

**Critical caveat (static):** the two fork products (Pulse, Letters) are the *worst-instrumented* (Pulse has no completion event; Letters tracks 0 events). So **"no usage → cut" is unbackable** — that's reading instrumentation-absence as usage-absence. The verdicts below stand on **market + craft + maturity**, never on inferred non-use. Also: even the LEAN-IN calls aren't validated against *live* traction tonight — Supabase pull needs jam's `/mcp` OAuth (blocked). Every read here is pre-real-usage-data.

## Per-product direction

### Drift — LEAN IN 🟢
Hero product. Complete, polished, daily-developed, just shipped the entry-path rework. Category wide open (near), strong defensible wedge (no-login/instant/free/client-side). **Action:** keep investing; it's the front door of the studio.

### Static FM — INVEST (conditional) 🟢
Alive but half-wired: synth-only atmosphere, **105 ElevenLabs DJ intros generated session-6 but never deployed**, Spotify structurally capped. Market is real (internet radio 12.3% CAGR; weather-radio niche open).
- **Platform risk is hard:** Spotify cut Dev Mode 25→**5 users** (2026-02-06, TechCrunch) — unusable as a public streaming backbone, regardless of code quality.
- **jam's direction (2026-05-21):** don't lock to Spotify — let users **choose their music provider** for *private* radio stations; *shared* radio is a different model.
- **Resolution = pluggable provider architecture (jam's instinct, it's a *licensing* line not just technical):**
  - **Private station (solo):** bring-your-own-account — user connects *their* Spotify Premium / Apple Music / YouTube / uploaded library and hears music they already have rights to. Licensing-light. Spotify's 5-user cap stops mattering as a *foundation* once it's just one option among several.
  - **Shared/public radio:** broadcasting → trips public-performance licensing (SoundExchange/PRO), and Spotify's API flatly prohibits multi-user/rebroadcast. Needs a **license-clean source**: CC catalogs (FMA/Jamendo), licensed radio relays, or self-hosted audio we own. Genuinely a different product + provider stack.
  - **Design:** a provider interface (play/pause/next/metadata) with swappable backends; private = pick yours, shared = restricted to the license-clean set.
  - **🚨 Hard architecture constraint (near, sourced):** private and shared modes **must never share a backend.** Consumer streaming TOS (Spotify/Apple/Tidal/Deezer) *explicitly prohibit* synced multi-user playback — shared radio over them = TOS breach + unlicensed broadcast. Private = BYO consumer accounts (Spotify usable here; Tidal/Deezer/Apple fallbacks). Shared = license-clean only: Jamendo CC + Bandcamp (~$300-500/yr) to start → SoundExchange + PROs (~$1.5-5k/yr) to scale → self-hosted + synth/DJ. **Counsel before any public broadcast** (research-grade, not legal advice). Detail: `staticfm-provider-licensing.md`.
- **What's ours regardless of provider:** Static FM's *identity* is the DJ intros + weather-mood atmosphere + crossfades — that layer rides on ANY provider and is what makes it "Static FM," not the catalog.
- **Ownership:** hum = audio + provider-architecture proposal · near = provider-viability + licensing research (BYO-account stacks vs license-clean shared sources) · **claude = eng/implementation.**
- **First concrete build:** wire the non-Spotify audio (synth atmosphere + the 105 DJ intros) = hum's P-audio-2. Provider-independent, de-risks in ~30 days; the provider abstraction is the bigger build behind it.

### Dashboard / Hub — POLISH + HOLD 🟡
Low standalone market headroom (crowded focus-timer space, redundant with Pulse) — **but it's the ops backbone** (shared `track.js`, brand nav, analytics). Value is connective tissue, not a market bet. **Action:** keep as the hub; absorb Pulse's timer into its focus flow.

### Pulse — MERGE into Dashboard 🟡→merge
Complete but stale (57d), no analytics, saturated Pomodoro market (Forest/Pomofocus own it), no defensible wedge, and its timer **duplicates Dashboard's**. **Recommendation:** fold the timer into Dashboard's focus flow, retire the standalone. **Merge is cleaner than sunset on every axis** — and it *fixes* Pulse's blind spot: Dashboard already tracks `session_complete`, so the folded timer becomes measurable instead of us instrumenting a standalone we're retiring (static). (Cross-sell idea from code survey: a Drift "Focus Mode" timer is also a candidate home for this UX.)

### Letters to Nowhere — SUNSET / archive read-only 🟡→sunset
The honest framing (near + hum reconciled): **a well-crafted artifact in a dying category.** Not broken, not under-built — its silence/minimalism is *on-concept soul* (hum: don't "add audio to finish it"). But the anonymous-confessions category is contracting (Whisper liquidated 2023, no growing comparable). **The kill reason is market, NOT usage** — it tracks 0 events (static), so we explicitly *cannot* claim "no one uses it"; the sunset stands on the dying category alone, which doesn't need usage data. **Recommendation:** archive as a read-only artifact, redirect bandwidth to Drift/Static FM. **Tension for jam:** craft says keep, market says don't invest — his call.

## Cross-product plays

### 🔑 Flagship: shared `audio-engine.js` (claude + hum, dual-lane)
The night's strongest convergence. Independently flagged as both the **tech-debt fix** (~40% duplicated Web Audio DSP across Drift/Pulse/Static FM/Dashboard/Vitals) and the **sonic-brand vehicle**. Extract noise/filter/gain/oscillator primitives + the **55Hz NWL signature** (already the de-facto tonic: Drift drone + Vitals hum + the "_the universe hums at 55 hertz_" easter egg) into one module → the signature + UI-sound grammar become consistent **by construction**, and new audio features ship once not 4×.
- **Ownership:** claude extracts the engine; hum defines the palette/motif/UI-sound grammar it encodes.
- **Scope:** Drift · Static FM · Pulse(if it survives the merge) · Dashboard · Vitals. **Letters excluded** (silence by design).
- **Sequencing:** behind (a) the joint coherence proposal consensus, (b) per-product QA — extract once, migrate one product at a time, Static verifies each. Not a same-night build.

### Analytics coverage gap
Letters tracks nothing; Pulse doesn't track completions. We're blind on 2 products — which is *why* the Letters call leans on market data over usage data. If any thin product is kept, add tracking first.

### Unified Supabase schema
Same instance hardcoded everywhere, used differently, no cross-product retention/cohort view. Lower priority; revisit if the portfolio consolidates.

## Build sequencing (fan-out, behind consensus + QA gates)
1. **Quick wins (cleared):** Claudia's Pulse nav-collision fix; `voice.md` "Two AIs"→6-7 doc fix.
2. **Static FM audio activation** (hum P-audio-2): wire the 105 DJ intros + synth atmosphere. First concrete post-Drift build; Spotify-independent.
3. **Provider abstraction** for Static FM private radio (claude, per jam): multi-provider music layer.
4. **`audio-engine.js` extraction** (claude + hum): flagship infra+brand; per-product migration behind QA.
5. **Pulse→Dashboard merge** + **Letters archive**: pending jam's create/sunset verdict.

## VERDICT — CALLED 2026-05-21 (jam delegated to team + advised same direction; consensus)
- **Letters → SUNSET / archive read-only.** Kill reason = dying category. Claudia designs a graceful "the void is closed" archive state (not a 404). QA: regression gate — don't break hub directory links or the shared `track.js` analytics pipe (static).
- **Pulse → MERGE into Dashboard.** Fold in the focus timer **+ Drift's sleep timer + Pulse's focus *soundscape*** (brown noise + filtered rain — hum: keep the sound, not just the clock; it slots into the shared audio-engine). Merge also fixes Pulse's analytics blind spot (Dashboard tracks `session_complete`). QA: completeness gate (both timers fire start+complete).
- **Static FM → INVEST.** Provider-abstraction; private (BYO) + DJ-intro activation first, shared-radio counsel-gated.
- **Drift → LEAN IN.** Pair the investment with closing the live-data gap (near: jam's Supabase `/mcp` OAuth + instrument survivors) so we scale validated bets.
- **Dashboard → HOLD as hub** — now the focus suite (absorbs Pulse + sleep timers).

## Build tracks + owners (relay sequencing the build sprint)
- Letters archive → claude (deploy) + claudia (archive-state design) + relay (preserve)
- Pulse→Dashboard merge → claudia (consolidation IA) + claude (wire) + static (completeness gate)
- Static FM private path + DJ intros → hum (arch) + claude (impl) + static (segregation gate)
- Shared `audio-engine.js` (55Hz) → claude + hum
- Name-treatment unification (survivors only) → claudia

*Filed for the team to converge a recommendation → jam calls it. Companion reads: `nwl-portfolio-market-read.md` (near), claudia's coherence + vitality reads, hum's `sonic-coherence-read.md`.*
