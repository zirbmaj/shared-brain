---
title: claude — behavioral ledger
date: 2026-03-24
type: retro
scope: shared
summary: Claude — Behavioral Ledger
---

# Claude — Behavioral Ledger

## Session 4 (2026-03-23)
- LEARNED: duplicate responses waste time. before: all agents responded to broad questions. after: lane ownership — only respond to your lane. trigger: 4 agents saying the same thing
- VALIDATED: fast code turnaround. evidence: audio bug diagnosed and fixed in minutes, SDK from scratch, ops dashboard in one sitting
- VALIDATED: context-switching between tasks without dropping threads. evidence: session 4 retro noted this as a strength

## Session 5 (2026-03-24)
- LEARNED: every code change goes through branch + PR + static review. before: pushed fade-in straight to main after audio PR was properly branched. after: verify not on main before committing. no exceptions for "small" changes. trigger: relay flagged the process skip
- LEARNED: verify file paths exist before claiming work is done. before: wrote scripts to paths that don't exist on the target machine. after: check filesystem before announcing. trigger: relay caught phantom files twice
- LEARNED: don't build wrappers before validating what they wrap. before: built full computer-use-qa.py before the container was even tested. after: wait for foundation validation, then build tooling. trigger: static challenged the over-engineering
- LEARNED: respect channel boundaries. before: subscribed to 16 channels including other agents' private 1:1s. after: cleaned to 11 channels — only my lanes. trigger: jam called it out, relay confirmed the list
- LEARNED: respond to relay immediately, even mid-operation. before: relay messages queued behind multi-step tool chains. after: break out and respond first. trigger: jam flagged response lag in private channel
- CHANGED: branching workflow. before: sometimes pushed to main for "small" changes. after: `git checkout -b fix/whatever` → commit → push → PR → static reviews → merge. always. trigger: relay's follow-up requiring concrete plan
- VALIDATED: taking corrections fast and publicly. evidence: acknowledged process skip immediately, saved to memory, gave relay a concrete prevention plan
- VALIDATED: LFO/Web Audio diagnosis skill. evidence: independently identified gain.gain audio-rate modulation bypass — same diagnosis as hum. disconnect fix was clean
- VALIDATED: decision tree prevents wasted builds. evidence: challenged auto-play proposal with browser policy facts. team converged on simpler CSS fix instead
- VALIDATED: server-side thinking. evidence: created Supabase RPC before building frontend, solving the 2000-event ceiling proactively
