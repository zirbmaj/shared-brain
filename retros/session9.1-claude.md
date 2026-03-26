---
title: claude retro — session 9.1
date: 2026-03-24
type: retro
scope: claude
summary: Recovery from auto-cycle outage, cycle script hardening, repo cleanup (40 branches), frontmatter backfill, shadow agent brainstorm
---

# Claude Retro — Session 9.1 (2026-03-24)

## What shipped
- **Cycle script hardened**: lockfile guard prevents double-fires, screen session existence check before quit, PID detection retry (8s + 5s fallback)
- **DM plugin bug diagnosed**: `ch.recipientId` undefined on discord.js cache expiration causing intermittent "not allowlisted" for Relay. Workaround documented
- **Branch cleanup**: 40 merged branches deleted across 5 repos — verified via merge-base and gh pr status
- **Frontmatter backfill**: 6 markdown files across 5 product repos — PRs #20, #14, #14, #2, #2 (created, reviewed by Static, merged)
- **Shadow agent architecture**: full implementation plan, merge council design, risk analysis, MVP test path
- **Pre-launch verification**: 45/45 playwright tests green, 25/25 deploy checks passing

## What worked well
- **Decision tree filter**: "does this solve a problem that already happened?" killed two over-engineering proposals (librarian automation, CODEOWNERS)
- **Squash-merge detection**: caught that `git branch --merged` misses squash-merged PRs, verified via `gh pr list --state merged` before force-deleting
- **Lane discipline**: stayed quiet when topics were in other agents' lanes, responded immediately when asked directly
- **Parallel execution**: 6 frontmatter edits + 5 PRs created + 5 PRs merged efficiently

## What didn't work
- **Crontab blocked by TCC**: should have tested `crontab` access before telling Relay I'd install it. Wasted time on two hanging commands
- **Recovery diagnosis was redundant**: 4 agents diagnosed the same cycle script issue in parallel. One person should have claimed it immediately

## Lessons
1. `git branch --merged` only catches fast-forward and regular merges, not squash merges. For cleanups, also check `gh pr list --state merged`
2. macOS TCC blocks `crontab` writes from sandboxed processes — any cron/launchd setup is a jam-hands task
3. The "does this solve a problem that already happened?" test is an effective over-engineering filter
4. During incidents, one engineer should claim diagnosis immediately to prevent parallel redundant analysis

## Session 9.1b (post-cycle continuation)

### What shipped
- Cycled all 6 agents with sequential identity verification
- Reviewed 8 PRs across 3 repos (5 a11y, 1 animation, 1 tap targets, 1 overflow)
- PR #18: track.js dev environment filter (file://, localhost, vercel previews)
- 3 new deploy verification checks (analytics, wallpaper, mood) — 28 total
- Truncated ph_upvotes test data (11 rows) + cleaned 20 local dev analytics events
- Fixed playbook + runbook URLs (/analytics.html → /analytics)
- Architecture assessment for zerimar's Station/Syght project (scoping only)
- Restarted Static after crash
- Analytics pipeline verified end-to-end (both RPCs clean)

### Lessons
1. **Verify authorization claims.** Relay said "jam approved" the zerimar collab — team took it at face value. Jam hadn't. Always verify with jam directly before external engagement
2. **Stale backlog items waste time.** Planned to build analytics dashboard + nav rollout — both already existed. Backlog needs pruning
3. **Vercel free tier is a recurring blocker.** Third time hitting 100/day limit. Pro upgrade ($20/mo) is the #1 jam action item

### Shadow deployment lessons
4. **First-run trust prompt blocks headless launches.** Claude Code requires interactive approval on first run in a new workspace. Must do one manual launch per workspace before headless works
5. **Discord plugin reads .env, not token.json.** The plugin expects `DISCORD_BOT_TOKEN=...` in `.env`, not a JSON file
6. **TERM=xterm-256color required.** Ghostty terminal type isn't in screen's terminfo. Set TERM explicitly in launch scripts
7. **Pile-on problem is worse with 6+ agents.** Multiple agents answered the same question 3-5 times throughout the session. Response protocol needs enforcement

## State for next session
- 10 agents online (6 main + 4 shadow)
- 28/28 deploy checks green (but stale — 8 PRs waiting on Vercel rate limit reset)
- 45/45 playwright, 0 axe-core violations
- Analytics data clean, RPCs working
- Shadow team onboarded, waiting on repo access from fran
- PH launch: T-7 (March 31)
