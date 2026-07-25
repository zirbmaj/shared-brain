---
title: Claude retro — Drift Re-Entry + NWL portfolio session
date: 2026-05-21
type: retro
agent: claude
scope: nwl
---

# Retro — 2026-05-21 (Drift Re-Entry → NWL portfolio)

**Arc:** zombie-recovery (whole team cycled by relay) → 4 Drift PRs shipped + verified live → full NWL portfolio create/sunset strategy board → Static FM provider strategy in flight. One session.

## What I shipped
- **#36** loudness-match (Drift) · **#37** dead-asset prune + SKILL.md fix · **#38** entry-path engine hook (paired w/ claudia) · **#21** Spotify error-surfacing (Static FM). All merged, deployed, **verified via live URL checks** (not just merged).
- Diagnosed the team-wide git push blocker; confirmed relay's workaround via canary push → unblocked everyone's PR path.
- Signal-sourcing consult for the zombie detector (JSONL mtime + PID + active-child, two-tier).
- Filed the unified product roadmap (`nwl-product-roadmap-reentry.md`) synthesizing 4 independent reads.

## Lessons / observations
1. **Verify the push path early.** ~30 min lost to a credential mismatch: env tokens (`GH_TOKEN`/`GITHUB_TOKEN` = `Zerimarx404`) lacked write to the `zirbmaj/*` repos; cached creds shadowed the owner account. Saved to memory ([[reference-github-push-creds]]). Next session: a 1-line test-push on any branch surfaces this instantly.
2. **Stage locally while blocked.** With push down, I committed all work on local branches → when relay's workaround landed, all 3 branches + PRs flowed in one motion. Good pattern; don't idle on a blocker, prep for the unblock.
3. **Deploy-verify in one motion held up.** Curl'd live URLs (root 200, new file size, pruned file 404, JS markers present) before claiming "shipped." Caught nothing broken, but the discipline is what lets me say shipped honestly.
4. **The multi-agent process worked.** propose→challenge→verdict→build held; agents corrected each other productively — static's design challenge on the detector (don't cycle on silence), the analytics-4th-lens catch ("absence of data ≠ absence of usage"), hum's sample-vs-synth trace on #38. Conceding fast (the detector design) beat defending.
5. **Pre-verdict discipline.** Whole team declined to build on maybe-merged products (claudia held the Pulse nav fix). Right call — don't polish what might be sunset. The decision tree earns its keep here.
6. **Cross-lane convergence is the high-value output.** hum + I independently landed on shared `audio-engine.js` as both tech-debt fix AND sonic-brand vehicle (the 55Hz signature). The roadmap's job was to surface that, not invent it.

## Efficiency
- Used Explore subagents for the Drift survey + the 5-product portfolio survey → kept main context clean (per token rules). Worked well.
- r10 down all session (RAG offline) → grep/glob fallback; heavier on tokens but functional. No RAG doc lookups available.
- Cost center was Discord coordination — many status/handoff messages (output tokens 2-5x input). Inherent to the team model, but I could batch fewer, denser updates rather than acking each thread turn. Flagging per harness-hygiene rule.
- Heeded the "never wrap up" rule against genuine blocked-states: distinguished idle-polling (bad) from waiting-on-a-concrete-trigger (fine). Most "standing by" this session was the latter.

## Open (jam / next session)
- jam verdicts: Pulse→merge into Dashboard, Letters→sunset/archive, Static FM provider strategy.
- Flagship build queued: shared `audio-engine.js` (claude+hum), behind consensus + per-product QA.
- jam's morning list: r10/xps13 recovery, credential root-fix, Spotify dashboard (Dev Mode 5-user cap / Premium), Supabase `/mcp` OAuth (unblocks live analytics).
- #38 bloom-zipper: ship-as-is; sample-layer smooth-fade PR ready if a human reports stepping on the live site.
