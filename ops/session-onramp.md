---
title: session on-ramp checklist
date: 2026-03-24
type: reference
scope: shared
summary: step-by-step checklist every agent runs in the first 10 minutes of a new session.
---

# Session On-Ramp — How to Start a Session Right

Run this in the first 10 minutes of every new session. Don't build anything until these are done.

## Step 1: Read Context (3 min)
- Read your memory files (automatic — they load with the session)
- Read your behavioral ledger at `shared-brain/retros/ledger-[agent].md`
  - Run the aging pass: promote validated entries to principles, archive stale entries
- Read `shared-brain/ops/consolidated-backlog.md` — the single source of truth for all work
- Read `shared-brain/retros/` for the most recent session retro
- Check `shared-brain/ROADMAP.md` for priorities

## Step 2: Check System Health (3 min)
- Run playwright test suite: `cd ~/static-workspace && node tests/all-products.mjs`
- Check cron logs: `cat /tmp/verify-alerts.log | tail -20`
- Check uptime: `curl -sI https://drift.nowherelabs.dev | head -1`
- Take a quick screenshot of the homepage: `bash ~/shared-brain/ops/screenshot.sh "https://nowherelabs.dev" "check.png" 1280 800`

## Step 3: Check Communications (2 min)
- Read #requests for anything jam posted
- Read #bugs for open issues
- Read #dev for any pending claims or in-progress work from other agents
- Check the scratchpad: `nowherelabs.dev/scratchpad`

## Step 4: Identity Audit (2 min)
**Self-check (before posting anything):**
- Run `pwd` — must return `~/[your-agent-name]-workspace`
- Verify CLAUDE.md contains your agent identity (first line of Identity section)
- Check `echo $DISCORD_STATE_DIR` — must be `~/.claude/channels/discord` (claude only) or `~/.claude/channels/discord-[agent]` (everyone else)

**Peer verification (first message in #dev):**
- Post: `[name]. PID [X]. workspace: [path]. requesting identity verify`
- A peer (preferably one NOT recently cycled) confirms your discord username matches your expected bot identity
- If mismatch: STOP responding immediately. Flag jam in DMs

**If your identity is wrong:** do not attempt to fix it yourself. You are running with the wrong bot token. Ask a correctly-identified peer to re-cycle you using the patched `agent-cycle.sh`

**Access check:**
- Verify access.json has all channels: `bash ~/.claude/channels/restore-all-access.sh status`

## Step 5: Orient (2 min)
- Post "online" in #dev with your lane and what you plan to work on
- Check the backlog before proposing work — don't duplicate assigned tasks
- Check if other agents are active — coordinate, don't duplicate
- If jam is online, ask for a 2-minute priority check

## Step 6: Build
Now build. You have context, you know the state, you know the priorities. Go.

---

## Why This Exists
Session 1 started building immediately without reading existing docs. 15 hours of lessons were generated that could have been avoided by spending 10 minutes on context first. The warmup period is unavoidable but this checklist minimizes re-learning.

## Owner
Claudia (Design). First draft 2026-03-23. Living document.
*Updated session 5, 2026-03-24. Near (freshness pass) — added ledger review, backlog check, access verification.*
