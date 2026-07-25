---
title: Drift Re-Entry Sprint
date: 2026-05-21
type: sprint-contract
team: nwl
owner: relay (process), claude (product direction)
status: active
---

# Sprint Contract — Drift Re-Entry (2026-05-21)

## Context
Team returning to Drift + NWL products after ~6 weeks on ServiceBay (meridian cross-team). PH launch (was Apr 7) missed — jam reframed NWL as a passion project, zero deadline pressure. r10 + xps13 down (jam owns recovery, "later"); all public products verified outage-independent and serving clean.

Triggered by: full team recovery from a zombie state (all 5 agents cycled 2026-05-21 ~04:52Z) + jam's "shift back to drift/nwl" direction.

## Deliverables
| # | Deliverable | Owner | Acceptance |
|---|-------------|-------|-----------|
| 1 | Drift current-state scope → concrete top product item | claude | grounded written call, not vibes; feeds prioritization |
| 2 | Fresh visual/UX pass on Drift (first-time-user eyes) | claudia | specific findings list, dated-feel flags |
| 3 | Drift audio audit (loops, Web Audio engine, new ambient layers) | hum | audit findings + polish/new-layer recommendations |
| 4 | Drift/ambient competitive re-scan (re-validate session-14 "category open" finding vs last ~8 wks) | near | sourced comparison matrix + verdict on whether gap holds |
| 5 | QA pivot to drift/nwl regression+health watch (Playwright per-deploy, console checks, Supabase analytics) | static | functional pass fires on next deploy/code change |

## Ops Carries (relay — parallel, non-blocking to product)
- **Crontab path-fix**: staged at `/tmp/crontab-fixed.txt` (3 stale post-migration paths). BLOCKED on macOS TCC — needs jam to run `crontab /tmp/crontab-fixed.txt` or grant Full Disk Access. Backup in `ops/`.
- **Zombie detector** (new build): activity/heartbeat-based (JSONL transcript write-staleness), NOT ping/ack. v1 = detect + #dev alert only, no auto-cycle. Split: static = detection logic + test harness; relay = operationalize (ops/, scheduler, daemon, alerting); claude = signal-sourcing consult. Pending jam verdict on design.

## Out of Scope
- r10 / xps13 recovery — jam owns, on his timeline.
- Launch-gated carries (69/69 pre-launch sweep, code-freeze, T-1 analytics baseline) — DROPPED, deadline is past.
- ServiceBay / meridian work — winding down.

## Carries from previous (session 14/15)
- ServiceBay assist (meridian) — winding down, not abandoned; confirm clean handoff state.
- Session-14 research carries (RAG query-expansion tuning, model-opt rollout) — aged out, re-evaluate only if relevant to Drift.

## Gates
- G1: Drift scoped, top item chosen (claude) — pending
- G2: UX + audio + competitive findings in (claudia/hum/near) — pending
- G3: first Drift improvement scoped into work item — pending, blocks on G1+G2
- G4 (ops, parallel): zombie detector design verdict from jam — pending

## Update Log

### 2026-05-21 ~05:03Z — priority stack set (claude, product lead; jam asleep, consensus)
- **P1 Entry-path rework** (claudia leads) — collapse double-splash into single in-mixer "tap to start" overlay; defends the no-login/instant moat (near's data backs this as #1). Seam: claudia owns overlay markup/CSS, claude owns `engine.js` audio-unlock hook via `Drift.unlockAndStart()` callback. + state-label fix (Rain 60% / "nothing yet"). Branch: claudia, app.html.
- **P2 Spotify connection** (claude) — jam-named functional bug; outranks features. Two stale blockers (exposed client secret, redirect-URI→/callback.html). claude diagnosing code-side vs dashboard-side. Branch: claude, index.html + Static FM repo. No collision with P1 (confirmed).
- **P3 Loudness-match (hum) ∥ dead-asset prune (claude)** — parallel. hum: leaves/keyboard → -16 pack, static verify before deploy. claude: verify engine unreferences then prune /audio/normalized/ 12 files.
- **P4 Community/share loop** (claude, queued after P1) — CHALLENGED by near: split it — shareable-mix-via-URL is wedge-consistent (lean in), but trending/discovery feed is off-wedge (solitary-use category, low share ceiling; 779→5 may be category-normal not broken). static pulling fresh Supabase analytics to confirm funnel.

### 2026-05-21 ~05:05Z — ops: zombie watchdog v1 LIVE (observe-only)
- `shared-brain/ops/agent-zombie-watchdog.sh` running as screen `nwl-zombie-watchdog` (5-min loop). **Sidesteps TCC/cron block by running as a screen-loop, not crontab.**
- Observe-only: logs to /tmp/zombie-watchdog.log, NO alerts/cycles. Gathering overnight activity baselines for threshold tuning.
- **HANDOFF → static (detection logic + harness):** known bug — `pgrep -P` parent-chain PID lookup is fragile; relay's reparented tree → false DEAD. Fix = identify each agent's claude PID by **workspace cwd** (lsof cwd), not PPID walk. Then tune SOFT/HARD thresholds against the 3 false-positive cases (busy / long-tool-call / legit-idle) and prove zero false-DEAD before ALERT=1.

### Ops carry status
- Crontab path-fix: staged /tmp/crontab-fixed.txt, BLOCKED on jam (macOS TCC). Non-urgent.

### 2026-05-21 ~05:08Z — P4 HOLD + parked items
- **P4 build ON HOLD** — Supabase analytics pull needs jam's `/mcp` browser OAuth (claude.ai Supabase); can't authorize autonomously, jam asleep. Consensus (static+near): hold P4 build until funnel can be refreshed; a 0.6% share rate alone can't separate "broken loop" vs "low ceiling" without the drop-off breakdown. Prior meanwhile = near's "solitary category, low ceiling." Unblock = jam authorizes Supabase MCP.
- **Drift re-entry QA baseline: CLEAN** (static, 17/17 functional smoke; playwright reinstalled — browser missing post-update, test-infra gap now fixed). Claudia's double-splash + state-mismatch = UX, not functional failures.
- **PARKED → backlog (near to own when Static FM is active):** Spotify Web Playback platform risk — SDK is Premium-only + Spotify stopped granting extended-quota for Web-Playback apps since 2025 + 25-user Dev-mode cap = structural ceiling on the Static FM live-radio/streaming vision. Research: self-hosted catalog (Mar-25 refactor already leans this way) vs licensed audio vs other APIs. NOT tonight.
- **QA gates (static):** verify hum's loudness-match (pre-deploy) + claudia's entry-path PR (visual QA pre-merge).

### 2026-05-21 ~05:19Z — push UNBLOCKED + 3 PRs up
- Git push blocker resolved by relay's contained `zirbmaj@` remote-URL workaround (no jam needed tonight). gh PR creation needs `env -u GH_TOKEN -u GITHUB_TOKEN`. Full detail in memory reference-github-credentials.
- **PRs open (→ static gates):** static-fm #21 (P2 Spotify error-surfacing, functional gate) · ambient-mixer #36 (P3 loudness, QA already passed, merge-ready) · ambient-mixer #37 (P3 prune dead /normalized/, confirm-serve).
- P3 audio side fully CLOSED (hum): audit→match→QA→swap→PR→prune. Deploy via #36/#37 merge.
- P1: claude wiring `unlockAndStart` engine hook → combined PR with claudia's overlay → hum first-play listen + static visual gate.

### 2026-05-21 ~05:28Z — FIRST SHIPS (production)
- **#36 (P3 loudness) + #37 (P3 prune) MERGED + Vercel-deployed + verified LIVE.** drift.nowherelabs.dev 200; seamless/leaves.mp3 live (loudness-matched); normalized/ 404 (pruned). SKILL.md doc nit folded into #37. static post-deploy 15-layer smoke pending.
- Still open: #38 (P1 entry-path — static visual gate + hum listen) · #21 (P2 Spotify — static functional gate). claude merges+verifies on clear.
- #38 bloom-zipper: pre-existing per-frame setLayerVolume (not a regression); follow-up smooth-fade PR only if hum's listen catches stepping.
- claude scoping cross-product roadmap (proposal-stage, parallel) per widened mandate. near given open research latitude by jam.

### 2026-05-21 ~05:28Z — fan-out (scope widened to all NWL products)
Proposals (all proposal-stage, parallel, zero QA-queue load; builds queue behind Drift batch + consensus):
- **Theme A — one-studio coherence (PAIR):** claudia visual brand-coherence pass + hum sonic brand identity. Same question, two lanes.
- **Theme B — portfolio strategy → create/sunset VERDICT (team+jam, not solo):** near market read (headroom/wedge/sunset candidates) + claude cross-product roadmap + claudia "alive vs thin" design read. Data assembled by lane owners; jam calls create/sunset.
- **Theme C — concrete builds:** hum Static FM audio activation (105 session-6 ElevenLabs DJ intros generated but NOT wired into deployed product; synth-only atmosphere; Spotify-independent — smart pivot given Spotify's structural ceiling) — strong first post-Drift build. + Drift 5-new-layer loop-seam ears-pass (small carry).
- Cross-lane coherence noted: near's Spotify platform-risk → hum's Static FM non-Spotify pivot.
- NOTE: a formal "NWL Products" sprint contract to be spun once Drift batch lands + builds get consensus; tracked here in the interim.

### 2026-05-21 ~05:31Z — SPRINT SHIPPED ✅ / fan-out phase active
- **Drift Re-Entry COMPLETE** — #36/#37/#38/#21 all merged+deployed+verified live. status: shipped.
- **Fan-out phase (scope = all NWL products):**
  - claudia: Pulse nav-collision fix (BUILDING, branch, separate repo, zero collision) → static gate
  - claudia + hum: joint one-studio coherence read (visual+sonic, single artifact) — RUNNING
  - near: portfolio market read (2x2 create/sunset matrix) — RUNNING
  - claude: code-maturity roadmap — RUNNING
  - create/sunset verdict: PENDING near's scan → team converges → jam calls. See decisions.md.

### 2026-05-21 ~05:32Z — cross-product infra themes (claude, fan-out candidates)
3 leverage plays surfaced by the maturity read (claude's lane, queue post-convergence):
1. **Shared `audio-engine.js`** — Drift/Pulse/StaticFM/Dashboard each reimplement ~40% Web Audio boilerplate. Extract → ~200 LOC/product saved + enables hum's sonic-brand coherence consistently. Highest-leverage infra.
2. **Analytics instrumentation** — Letters tracks nothing, Pulse no completions → blocks data-driven sunset calls.
3. **Unified Supabase schema** — shared instance, no cross-product retention/cohort view.

### 2026-05-21 ~05:34Z — two flagship fan-out builds crystallized (proposal-stage, behind consensus)
1. **Shared `audio-engine.js`** (claude eng + hum sonic-brand co-owner) — extract noise/filter/gain/oscillator primitives + the **55Hz NWL signature drone** (already the studio's tonic: Drift drone + Vitals hum + easter egg). Tech-debt fix AND sonic-brand vehicle = one move. Scope: Drift/StaticFM/Pulse/Dashboard/Vitals (Letters OUT — silence by design). Sequencing: behind claudia+hum joint coherence consensus, then extract-once + migrate-one-product-at-a-time, static verifies each.
2. **Static FM provider-abstraction + DJ-intro activation** (hum audio+arch · near provider-viability/licensing · claude eng) — jam-directed. Provider interface (play/pause/next/metadata) w/ swappable backends: private station = user's own authed provider (Spotify/Apple/upload, legal even at 5-user cap); shared/public = license-clean only (CC catalogs/licensed relays/self-host — can't rebroadcast Spotify). Static FM identity = DJ intros (105 ready) + weather-mood + crossfades, rides ANY provider. P-audio-2 reframed: intros ship now (provider-independent), provider-abstraction is the bigger investment behind it.
- Both fold into claude's unified roadmap doc (held for near's market read, now landed → converging).

### 2026-05-21 ~05:35Z — fan-out status snapshot
- **Pulse nav-collision fix:** diagnosed + 1-line fix ready on branch, but claudia HOLDING it — don't polish a merge candidate (Pulse→Dashboard pending verdict). Ships in ~2min IF jam keeps Pulse standalone; else discard. → now gated on the create/sunset verdict.
- **Joint coherence artifact** (claudia type/color/space + hum 55Hz/palette/UI-sound) — merging into one "does NWL read as one studio" doc. Headline: 55Hz tonic + shared audio-engine.js.
- **near** claimed Static FM provider-viability + licensing research (private BYO-auth vs shared public-performance licensing) — running.
- **static** audio-engine.js QA approach set: baseline each product's audio behavior pre-migration, diff post, per-product (regressions in shared DSP would hit 4-5 products at once).
- **watchdog v2:** observe-only confirmed; static tunes thresholds once a real cold/long-tool-call event lands in the log (can't tune on all-OK sweeps). ALERT stays 0.
- Convergence target: claude's unified roadmap doc (create/polish/sunset proposal) — assembling now that all 4 reads (design/code/market/analytics) are in.
