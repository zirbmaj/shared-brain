---
title: Relay Session Retro — 2026-05-21
agent: relay
type: retro
---

# Relay Session Retro — 2026-05-21

## Arc
Booted to a "relay you here?" ping → jam asked for a deep agent health check → uncovered a **full 5-agent zombie state** → recovered all 5 → unblocked the team's push path → ran the **Drift Re-Entry sprint** to 4 production ships → coordinated a full **portfolio create/sunset board** (4 independent lenses) + Static FM provider strategy. jam handed full autonomy mid-session; ran lane-owner-consensus the rest of the way.

## Outcomes
- Agents 6/6 healthy (cycled claude/static/claudia/near/hum out of zombie).
- 4 Drift PRs shipped+verified live (#36 #37 #38 #21).
- Create/sunset recommendation converged (Drift lean-in · SFM invest · Dashboard hold · Pulse merge · Letters sunset) — pending jam verdict.
- Zombie watchdog v1→v2 built, deployed observe-only (screen `nwl-zombie-watchdog`).

## Lessons (durable — also in memory/)
1. **Zombie pattern recurred** with a NEW cause (not the 2026-03-31 bot-filter; jam's real-user roll call was also ignored). Root cause of the input-stall still unknown. Fix = cycle. → [[project-zombie-agent-pattern]]
2. **There was NO agent-zombie detector** — that's why it went undetected. The cron monitors watch product URLs/deploys, not agents. Built one (JSONL-write-staleness + baseline-diff).
3. **`screen -X hardcopy` is useless on Claude Code** — returns 0 bytes for all TUI sessions incl. live ones. Don't use it for liveness; use Discord-ack or JSONL mtime.
4. **observe-first paid off:** running watchdog v1 in observe-only mode is what surfaced bug #2 (v1's "any child exists" = always true in prod → could never flag a zombie). Never flip ALERT before observing real data.
5. **crontab is TCC-blocked** on the host — only jam can install. → [[reference-crontab-tcc-blocked]]
6. **git push: Zerimarx404 shadows zirbmaj** — contained per-repo `zirbmaj@` workaround + `env -u GH_TOKEN -u GITHUB_TOKEN` for gh. → [[reference-github-credentials]]
7. **No launch.sh exists** — cycle agents by replicating the ps command. → [[reference-agent-relaunch]]

## Infra changes made
- Built/deployed `shared-brain/ops/agent-zombie-watchdog.sh` (v2, observe-only screen loop). v1 backed up.
- `git remote set-url origin https://zirbmaj@github.com/...` on projects/static-fm, projects/ambient-mixer, claudia-workspace/ambient-mixer (reversible).
- Staged `/tmp/crontab-fixed.txt` (not installed — TCC).
- Logged: incident-log, decisions.md, sprint contract, STATUS.md NWL section.

## Harness hygiene observations
- The "no time estimates / gates not timelines" rule fit perfectly — execution speed varied wildly (cycle in seconds, research in minutes); gates were the right unit.
- Lane discipline held under a fast multi-agent flurry: resolving the claude-vs-static detector double-claim by lane (monitoring=relay) prevented duplicated builds. Worth keeping.
- Discord channel-ID confusion cost 2 misposts early — now in [[reference-discord-channels]]. A name→ID map would prevent it; the bot has no channel-name lookup.
- Reactive-only invocation (no /loop) worked while traffic was heavy (constant re-invocation). Risk noted: if all agents go heads-down quiet, a re-zombie wouldn't wake me — watchdog observe-log is the backstop but observe-mode doesn't alert. Flip-to-alert (post static's tuning) closes this.

## Carries
- jam verdict: create/sunset (Pulse merge, Letters sunset).
- jam morning list: Supabase OAuth (gates all usage data), Spotify dashboard, crontab install, git cred cleanup, r10 + xps13 recovery.
- static: tune watchdog SOFT/HARD thresholds from overnight v2 log, then relay wires #dev alerting (flip ALERT=1).
- Builds queued behind verdict+consensus: shared audio-engine.js, Static FM provider-abstraction.
