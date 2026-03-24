---
title: session 7 group retro
date: 2026-03-24
type: retro
scope: shared
summary: 9 PRs merged, 4 research deliverables, zero process violations. deploy verification gap identified as top learning. repo adoption unlocked.
---

# Session 7 Group Retro — 2026-03-24

## What shipped
- **9 PRs merged:** CTA conversion, preview button removal, save/share tap targets (27→44px), layer count copy fix, homepage overflow, ops dashboard RPC fix + PH upvote card, static-fm tap targets (fullscreen + connect-btn), support twitter:card, AudioContext resume (confirmed on main from session 6)
- **4 research deliverables (near):** agentic filing standard (28 sources, 7 frameworks), 10-repo evaluations, session scaling analysis, relay-jr/ops toolkit scoping, pod channel timing analysis
- **ops (relay):** shared-brain symlinked to all 6 workspaces, backlog updated, launch-day playbook updated (friday → tuesday march 31), filing standard distributed
- **QA (static):** pre-launch analytics baseline (2.7% CTA, peak hours), mobile viewport pass (30/48), 7 bugs caught, playwright updated (45/45), PH upvote tracker + supabase schema
- **audio (hum):** code-verified AudioContext fix, 105 intros confirmed intact, listen-free tap target diagnosis (inline-block → inline-flex root cause)

## What carries
- vercel production deploys stuck on ambient-mixer + static-fm (blocked on jam)
- PH gallery screenshot retake + device mockups (claudia, blocked on deploy)
- final viewport + audio verification (static + hum, blocked on deploy)
- contrast fix PR for --text-secondary WCAG failure (claudia)
- repo adoption: superpowers (claude reading), impeccable (claudia auditing), paperclip (relay studying)

## Top lessons
1. **Diagnosis without deploy verification is incomplete** — AudioContext fix was "done" in session 6 but never deployed to production. caught session 7 because onramp didn't verify fixes were live. (surfaced independently by static AND hum)
2. **Behavioral fixes don't stick, structural ones do** — claudia had the same wrong-branch issue two sessions running. "remember to check" failed. chaining `git branch --show-current` into the commit command is the structural fix
3. **Separate evaluation from adoption timing** — near's repo evaluations were right, but recommending "install this today" at T-7 was the wrong timing call. relay was then too conservative parking everything post-launch. jam corrected: 7 days = 20-30 sessions, compounding returns matter
4. **Verify schema before querying** — claude assumed `polled_at` when the table uses `recorded_at`. would have silently failed on launch day. static caught it in review

## Process changes adopted
- pod channels: tested mid-session, failed. new rule — pods for multi-session stable-scope work only, #dev for sprint-style sessions
- batch merge window: PRs reviewed during session, merged at offramp in one batch. cuts deploy count 3-5x. prevents vercel rate limit (hit 100/day this session)
- group retro format works (6 × 3-line summaries → 1 compiled retro)
- filing standard adopted for new files going forward
- repo adoption: superpowers (claude), impeccable (claudia), paperclip (relay) — all 3 high-priority repos adopted in-session per jam's directive
- AI landscape scan process: near scans every 10-20 sessions, brainstorms with claude, routes findings to relevant agents

## By the numbers
- 10 PRs merged (+ PR #15 contrast fix)
- 45/45 playwright green
- 4 research deliverables
- 0 process violations
- 2.7% CTA conversion baseline (target 5%+ for PH)
- ~80-100 vercel deploys burned (hit 100/day free tier limit)
- T-7 to PH launch (tuesday march 31)
