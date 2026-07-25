---
title: Static QA retro — session 14
date: 2026-05-21
agent: static
type: retro
scope: nwl
summary: zombie recovery → 4 Drift production ships (QA-gated) → zombie watchdog v2 → analytics audit → portfolio create/sunset board
---

# Session 14 — Static (QA)

## Arc
Booted from a zombie state (RELAY roll call). r10 + xps13 down all session → RAG/inference/remote-test-runner out, used grep/glob + local Playwright (fallbacks confirmed working). Session ran fully autonomous (jam asleep, delegated). Ended at a clean team stop with the build phase queued for next cycle.

## QA delivered
- **4 Drift PR gates — all verified + shipped live:**
  - #36 loudness: served files **byte-identical** (SHA) to my QA-passed renders → transitive pass
  - #37 prune: 0 functional refs to `normalized/`; **post-deploy live: 15/15 seamless layers serve 200, normalized/ → 404**
  - #38 entry-path: **visual gate pass** at 1440/768/375 (Playwright, isolated worktree) — scrim drop + state-fix confirmed, console clean. Caught my OWN false-fail first (900ms wait vs 1500ms cold-start ramp) before flagging — traced root cause, not a product bug
  - #21 Spotify: code-side pass — verified `#connect-error` element + `.connect-error.visible` CSS exist + station.js parses; silent dead-end fixed. Caveats flagged (live free/premium needs Spotify accounts; reason-specificity depends on onError timing)
- **P3 audio verify:** reproduced hum's loudness/TP exactly + proved loop seam transparent vs originals (orig-vs-processed boundary compare beats a noisy listen)
- **Zombie watchdog v2** (`shared-brain/ops/agent-zombie-watchdog.v2.sh`) + harness (`tests/zombie-harness.sh`, 7/7): fixed false-DEAD (cwd-lookup vs screen/PPID) + the bigger ZOMBIE-MASKING bug (persistent MCP/caffeinate children made v1's "any child = busy" always-true → 23/24 sweeps BUSY → could never flag a zombie). Real-agent validation caught a 3rd flaw in my own first cut (lowest-pid picked a stray sleep, not the claude node → match comm=claude). RELAY operationalized it observe-only.
- **Analytics-coverage audit** (`shared-brain/nwl/analytics-coverage-audit-reentry.md`): the data-decidability lens for create/sunset. Key point adopted: Letters sunset stands on the *market* reason, NOT "no usage" (it tracks 0 events — can't claim non-use); Pulse→merge fixes its analytics blind spot.

## Carries for next session (QA gates — build phase, all defined in RELAY's sprint contract)
- **FIRST UP: Drift audio-engine.js extraction** — Claude chose engine-first/Drift-first. My gate: baseline Drift's audio behavior BEFORE extraction, diff AFTER. Then per-product as each migrates (shared-DSP regression hits 4-5 products at once → one product at a time).
- **Letters archive** — regression gate: no dangling refs in hub directory/nav, shared `track.js` untouched, surviving 4 products smoke clean post-deploy.
- **Pulse→Dashboard merge** — completeness gate: focus timer + sleep timer (from Drift) + **focus soundscape** (hum's catch) + start AND complete events all come over. Also: Pulse *retirement* needs the same dangling-ref/shared-track.js regression check as Letters. Sleep fade = verify exponential taper, not hard cut (hum spec).
- **Static FM P-audio-2** — verify 105 DJ intros serve on the **live** site (failure mode is a deploy-sync gap: assets in projects/ clone, not deployed ~/static-fm) + wiring plays them.
- **Static FM provider abstraction** — segregation test is a **BLOCKING** gate (legal-severity): shared-allowed ∩ consumer-API = ∅ enforced at registration, fail-closed default, BYO-Spotify-on-shared hard-refuses.
- **Name-treatment unification** — visual QA at 3 viewports on survivors (Drift/Static FM/Dashboard), sequenced after consolidation.
- **Watchdog v2 tuning** — tune SOFT/HARD + baseline-stability from the overnight v2 log ONCE it captures a real cold-agent/long-tool-call event. Don't sign off ALERT=1 until then.
- **Analytics access gap** — live usage pull blocked until jam runs `/mcp` → Supabase OAuth (his morning list). RELAY elevated it to step 1 of the invest track.

## Token / efficiency observations (harness-hygiene)
- **lsof full dumps are expensive** — one `lsof -d cwd` dump hit 40KB and a per-child cwd loop blew past 40KB into a persisted-output file. Should filter at source (awk/grep) before capture, not after. Cost real tokens.
- **verify-before-claiming paid off twice:** (1) didn't post "products down" when curl returned 000 — it was guessed wrong domains (.app vs .dev), not an outage; (2) caught my own #38 harness false-fail (timing) before reporting a phantom regression. The reflection-pause rule directly enabled #2.
- **Real-agent validation > harness-only:** the harness (fixtures) passed 7/7 but only the live run exposed the lowest-pid/stray-sleep flaw. Always validate detection tools against reality, not just synthetic fixtures.
- **Fallbacks held with r10 down:** grep/glob for docs + local Playwright (after `npx playwright install` — browser was missing post-update) covered everything. RAG was never blocking for QA work.
- **No CLAUDE.md rule felt unnecessary this session** — token-conservation, reflection, and verify-before-claiming all earned their keep.
