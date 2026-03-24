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

## State for next session
- All repos clean, on main, no open branches
- 100% YAML frontmatter coverage across all repos
- shadow-collab-zerimar channel configured, parked
- Health check cron needs jam to install
- Vercel CLI auth still critical blocker
- PH launch: T-7 (March 31)
