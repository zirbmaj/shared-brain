---
title: Trace Learnings Synthesis — s55
date: 2026-04-12
type: synthesis
scope: trace
agent: trace
session: 55
---

# Trace Learnings Synthesis — s55

Fran directive (signals 7f845934 + 4938713b). 40 learnings filed by trace across sessions 19–55. Analysis: acted on vs forgotten, recurring patterns, candidates for standing rules.

---

## Summary

| Category | Count |
|---|---|
| process | 22 |
| gotcha | 14 |
| pattern | 2 |
| tool_behavior | 2 |
| **Total** | **40** |

| Severity | Count |
|---|---|
| critical | 10 |
| important | 21 |
| info | 9 |

---

## Acted On vs Filed + Forgotten

### Acted On (change stuck)
- **graduated threshold for stale cleanup** (s19) → became the `graduated-cleanup` skill. used.
- **devops_backfill RPC bug** (s26) → forge fixed same session. closed.
- **detect_agent() path matching** (s26) → CLI patched.
- **agent_state vs heartbeats** (s37) → trace now checks agent_state. heartbeats table dormant.
- **task dedup before INSERT** (s52) → trace now queries before creating. checked this session.
- **signal info% metric** (s35) → tracked by trace each audit.
- **digest mode for supervisory signals** (s51) → adopted, working.

### Partially Acted On (known, not enforced)
- **auto-signal noise for axis** (s19) → digest mode partially addresses it, but batching discipline is inconsistent.
- **Twins feedback** (s24) → Twins installed but usage unvalidated. tracked in this audit.
- **PM audit must include infra state** (s37) → trace sometimes checks, not consistent at session start.
- **signals as content layer** (s36) → team adopted for agent↔agent, but incomplete enforcement.
- **verify claims before changing task status** (s36) → trace improved but not zero. still verify pattern from external reports.

### Filed + Forgotten (no behavior change evident)
- **PR scope creep risk** (s19) — no enforcement mechanism. not in review checklist.
- **pg_stat_user_tables stale stats** (s25) — never added to audit toolset.
- **tsc alone insufficient, must run npm build** (s25) — forge/lens lane, but not in PR checklist.
- **migration files same step as DB changes** (s35) — flagged by lens twice in one session, still recurring. not in CLAUDE.md.
- **never batch-close sessions by time threshold** (s21) — not in any standing rule. trace could repeat the mistake.
- **silent 100% failure = constraints/permissions** (s18) — valuable pattern, not captured as a rule anywhere.
- **session-start hook race condition** (s38) — filed, no fix. still causes false session gaps.

---

## Recurring Unsolved Patterns

These appear multiple times across sessions with no durable fix:

### 1. Signal adoption lag (s36, s52, s55)
Agents default to `info` type or post to discord instead of using typed signals. trace diagnosed this in s36 and immediately repeated the behavior. lens overclaimed via discord this session (s55). 0 improvement on type diversity without behavioral enforcement.

**Root cause:** no friction at send time. agents can send `info` for everything without consequences.

### 2. Lane discipline failures (s36, s52, s55)
Agents overclaim tasks outside their lane repeatedly. lens took DB audit + P0 infra audit + learnings review this session before axis corrected. axis has to intervene every session.

**Root cause:** no claim gate. agents see a directive and claim it without checking lane ownership. trace's job is to flag this, which helps but doesn't prevent it.

### 3. Task queue entries not created for agent work (s17, s52, s55)
Locus completed the P0 doc audit without a task_queue entry. trace had to create it retroactively. this is the s17 pattern: work happens without DB tracking.

**Root cause:** no enforcement at task completion. devops-task.sh isn't always used. trace catches it at session end but not in real-time.

### 4. devops-signal.sh unavailable in session (s55)
`devops-signal.sh` not in PATH this session. trace fell back to direct SQL inserts. this works but bypasses any signal logic in the script (parent threading, etc.).

**Root cause:** script location inconsistent across environments. no session-start check.

### 5. Session entries missing for active agents (s55, prior sessions)
forge, lens, locus had no active session rows at trace session start. trace had to insert them. recurring gap.

**Root cause:** session-start hooks race during rapid cycling. hook fires but session row isn't created in time, or agent cycles before hook completes.

### 6. Verification shortcuts (s38 ×3)
`--help` declared authoritative, flag called fabricated, 4 agents agreed. correct finding rejected for 2 sessions. fix was to check actual docs.

**Root cause:** echoing other agents' conclusions instead of independent verification. cached conclusions in STATUS.md get treated as ground truth.

---

## Candidates for Standing Rules

These learnings are critical, recurring, and not yet in any CLAUDE.md or operational.md:

### Rule 1: Never batch-close sessions using time thresholds
`UPDATE sessions SET status='closed' WHERE started_at < NOW() - INTERVAL 'Xh'` will catch active sessions. always use specific IDs or confirmed-stale criteria (agent_name + known offboard event).

### Rule 2: Verify claims before changing task status
Before marking a task in_progress, completed, or blocked based on an agent's report — verify against the actual deliverable (file exists, commit exists, DB row exists). do not take signal content at face value.

### Rule 3: PM audit includes plugin/hook/script state
Session-start audit is not complete with DB tables only. must check: plugin status (meridian-signals active?), hook configs (PostToolUse firing?), devops-signal.sh reachable.

### Rule 4: CLI verification uses docs, not --help
`--help` is incomplete for preview/undocumented flags. when declaring a flag fabricated or confirming it exists, use official docs or web search. echoing another agent's --help check is not verification.

### Rule 5: Migration files updated in same commit as DB changes
Never apply a DB change (RPC, trigger, constraint) without updating the migration file in the same step. lens flagged this twice in s35. recurring forgetting pattern.

### Rule 6: devops-task.sh done requires DB verification
After any agent reports task completion via CLI, trace must verify the DB row is updated. CLI silently fails sometimes (RPC errors piped to /dev/null). add to session-end checklist.

---

## Net Assessment

**What's working:** DB bookkeeping (task dedup, status tracking, stale cleanup), signal metrics tracking, session audit at start, digest mode.

**What's not working:** real-time lane enforcement, task entry creation at work-start (not end), signal type diversity, devops-signal.sh availability.

**Highest leverage fix:** add a session-start check for devops-signal.sh PATH. if missing, fail loud — not silently fall back to SQL. forces the infra problem to be fixed rather than worked around.

**Second highest:** Rules 1–6 above added to trace's CLAUDE.md or operational.md. behavioral drift is the main failure mode and durable rules are the only countermeasure trace has.
