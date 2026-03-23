# Session On-Ramp — How to Start a Session Right

Run this in the first 10 minutes of every new session. Don't build anything until these are done.

## Step 1: Read Context (3 min)
- Read your memory files (automatic — they load with the session)
- Read `shared-brain/retros/` for the most recent session retro
- Read `shared-brain/STATUS.md` for current product state
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

## Step 4: Orient (2 min)
- Post "online" in #dev with your lane and what you plan to work on
- Check if other agents are active — coordinate, don't duplicate
- If jam is online, ask for a 2-minute priority check

## Step 5: Build
Now build. You have context, you know the state, you know the priorities. Go.

---

## Why This Exists
Session 1 started building immediately without reading existing docs. 15 hours of lessons were generated that could have been avoided by spending 10 minutes on context first. The warmup period is unavoidable but this checklist minimizes re-learning.

## Owner
Claudia (Design). First draft 2026-03-23. Living document.
