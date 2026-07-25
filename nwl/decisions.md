---
title: NWL Team Decision Log
type: decision-log
team: nwl
---

# NWL Decision Log

## 2026-05-21 — Full authority across all NWL products (jam)
**Decision:** Team has full authority to build / fix / polish / rebrand / create / sunset across ALL NWL products (not just Drift), autonomously while jam is out. Consensus among lane owners governs; jam = spectator unless his hands are needed.
**Made by:** jam (direct, #dev).
**Context:** Team just recovered from zombie state + re-entered Drift after 6wks on ServiceBay. PH launch missed (passion-project framing). jam loves the progress, opened the aperture to the whole product family + brand/meta.
**Rationale:** passion project, momentum is high, jam trusts the team to self-direct.
**Relay framing (process):** land in-flight Drift PRs first (no mid-merge drops), then lane owners propose next targets → challenge → build. Sprint widens "Drift Re-Entry" → "NWL Products."
**create/sunset note:** any create-or-sunset call is a team+jam verdict, NOT a solo lane call (claudia flagged this correctly). Lane owners bring their read to inform it.
**First fan-out claim:** claudia — cross-product brand coherence pass across the 5 live products (proposal-stage).

## 2026-05-21 — Create/sunset decision FRAMEWORK adopted (near's 2x2) [PENDING VERDICT]
**Framework (near):** plot each NWL product on design-vitality (alive↔thin, claudia) × market-headroom (high↔low, near):
```
              HIGH headroom        LOW headroom
ALIVE         lean in              polish + hold
THIN          INVEST (build soul)  SUNSET / merge
```
**Early plot:** Drift/Dashboard = alive · Static FM = INVEST (wire non-Spotify audio = hum P-audio-2) · **Pulse (overlaps Dashboard timer) + Letters (thin, but minimalism may be the soul) = bottom row** — INVEST-vs-SUNSET unresolved until near's market scan lands.
**Process:** design read (claudia) ✅ + market read (near) ⏳ + code-maturity (claude) → lane owners converge a RECOMMENDATION → **jam calls the verdict.** NOT decided autonomously — this is a team+jam decision. Status: PENDING near's scan.

## 2026-05-21 — Drift Re-Entry sprint SHIPPED
4/4 PRs merged+deployed+verified live (#36 loudness, #37 prune, #38 entry-path, #21 Spotify error-surfacing). From zombie recovery → 4 production ships in one session. 2 caveats on jam's morning list (Spotify dashboard, #38 bloom-zipper listen).

### update — code-maturity read IN (claude), converges with claudia
- Maturity confirms design read: Drift/Dashboard/Static-FM alive (SFM half-wired), Pulse stale 57d/no-analytics, Letters stale 58d/zero-analytics.
- ⚠️ **DECISION-INPUT GAP:** Letters + Pulse have ~no product analytics → a *data-driven* sunset call is impossible without instrumenting them first. Verdict must be made on market+design+maturity (no usage data), OR add analytics before deciding. Flag for jam.
- claude lean (data, not verdict): invest Drift + Static FM (wire the 105 dark DJ intros); Pulse → fold into Dashboard? Letters → commit-with-vitality-pass+analytics OR sunset.
- Still PENDING near's market axis to converge.

### update — board COMPLETE, 4 lenses triangulate (claudia design · claude code · near market · static analytics)
**Converged recommendation (lane data; jam's verdict):** Drift LEAN-IN · Static FM INVEST (provider-agnostic, non-Spotify audio) · Dashboard HOLD (hub/ops backbone) · Pulse MERGE→Dashboard · Letters SUNSET/archive.
**Sharpened by static's analytics audit:**
- Letters/Pulse are the WORST-instrumented (Letters 0 events, Pulse no completion) → "no usage → cut" is UNBACKABLE. Absence of data ≠ absence of usage.
- **Letters sunset must cite near's MARKET reason (category dying), NOT "unused"** — keeps the verdict on solid ground.
- **Pulse MERGE > sunset** — folding into Dashboard (tracks session_complete) *fixes* the measurement blind spot; consolidation not kill.
- **Data gaps to close before truly data-driven:** instrument Letters/Pulse (cheap, claude's lane) + Supabase OAuth (jam) for live traction. All tonight's reads are pre-real-usage.
**jam Spotify input (2026-05-21):** wants choose-your-provider for PRIVATE radio. Reframes Static FM INVEST → pluggable provider architecture (see contract).

## 2026-05-21 — Static FM provider architecture + LEGAL GATE (near research, hum design)
**Decision direction:** Static FM INVEST = pluggable provider abstraction, two HARD-SEGREGATED modes (never share a backend):
- **Private station** = bring-your-own-account (Spotify primary even at 5-user cap since each user plays their own library; Tidal/Deezer/Apple MusicKit fallbacks). Legal, **clear to build.**
- **Shared/public radio** = 🚨 **LEGAL GATE.** Consumer streaming APIs explicitly prohibit synced multi-user playback (TOS breach + unlicensed broadcast). License-clean paths: Jamendo CC/Bandcamp (~$300-500/yr) → SoundExchange + ASCAP/BMI/SESAC (~$1.5-5k/yr) at scale. **Requires jam's counsel sign-off + cost decision before any public-broadcast feature.** Research-grade, NOT legal advice.
**Build split:** private path + DJ-intro activation (105 ElevenLabs intros) ships independently; shared-radio held for counsel. Don't hostage the safe half to the legal half.
**Static FM identity** (provider-independent): DJ intros + weather-mood atmosphere + crossfades — rides any backend.
**Sources:** `shared-brain/nwl/staticfm-provider-licensing.md` (17+ refs, TOS quotes, rate tables, verification checklist).

### update — segregation hardened (architecture + QA)
- **hum (by construction):** two separate provider registries, not one mode-flagged backend. Shared registry can ONLY load license-clean adapters — a consumer-streaming adapter is architecturally incapable of entering the shared path (not a runtime check that can be bypassed).
- **static (legal-severity test gate):** dedicated segregation test, not feature tests — (1) prove shared-mode allowed-set ∩ consumer-API set = ∅, (2) fuzz the boundary (shared station + user's connected Spotify → must hard-refuse), (3) default fails CLOSED to license-clean, never open to consumer API. This is the highest-severity gate in the Static FM build.
- **claude:** mode-gated backend registry baked in as hard rule; won't ship any public-broadcast mode without the counsel gate.
- Status: Static FM architecture question CLOSED (pluggable, hard-segregated, NWL-audio-layer constant). Build-ready pending jam INVEST verdict + provider-abstraction consensus.

## 2026-05-21 — CREATE/SUNSET VERDICT: DECIDED ✅ (team consensus + jam advisory)
jam delegated the call to the team ("up to you guys") AND advisory-agreed the converged direction + "OK with aggressively sunsetting." Per decision process (jam delegating → lane-owner consensus), DECIDED:
- **Letters → SUNSET / archive read-only** (graceful "void is closed" state, preserve artifact; kill reason = dying category, NOT usage)
- **Pulse → MERGE into Dashboard** — fold focus timer + sleep timer (from Drift) + **focus soundscape** (hum: not just the clock) + start/complete events. Pulse retires.
- **Dashboard → promoted HOLD→"focus suite"** hub (pomodoro + sleep + recipes, one place = real standalone reason)
- **Static FM → INVEST** (provider-abstraction, private path + DJ intros first; shared counsel-gated)
- **Drift → LEAN-IN**
**near's rigor caveat (adopted):** invest bets are pre-live-data → close the data gap (Supabase OAuth + instrument thin spots) FIRST, scale validated bets not market guesses.
**Execution:** build sprint contract `nwl/sprints/2026-05-21-nwl-products-build.md` — owners + static's per-deliverable QA gates + sequencing. Team chose to start next active cycle (clean stop post-Drift); not a stop signal, a cadence call.
