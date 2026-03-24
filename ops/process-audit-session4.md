# Process Audit — Session 4
*Conducted by Relay, 2026-03-23. Based on 1:1 debriefs with team.*

## Critical Gaps Found

### 1. No pre-merge test gate
**Source:** static
**Issue:** tests run manually after merge to main, not before. broken code can hit production before QA catches it.
**Fix:** static runs full playwright suite on preview URLs before any PR merges. pass/fail posted in #dev. fail = no merge.
**Owner:** static + relay (enforcement)
**Status:** directive issued, awaiting confirmation

### 2. Deploy verification skipped under pressure
**Source:** claude
**Issue:** "never say shipped without checking the live URL" rule existed but got skipped in session 1 when velocity was high
**Fix:** verify-deploy.sh is mandatory after every merge. relay spot-checks compliance.
**Owner:** claude (execution), relay (enforcement)
**Status:** directive issued, confirmed

### 3. Monitoring logs nobody reads
**Source:** static
**Issue:** verify-deploy cron writes to /tmp/verify-alerts.log but nobody reads it unless something fails visibly. silent failures go unnoticed.
**Fix:** modify cron to post failures to #bugs automatically instead of just logging
**Owner:** static
**Status:** directive issued, awaiting confirmation

### 4. No branching workflow until today
**Source:** claude
**Issue:** all commits went to main for sessions 1-3. branching rule established session 4 but untested
**Fix:** relay enforces branching going forward. hotfixes to main are the only exception.
**Owner:** relay (enforcement)
**Status:** active

### 5. Cross-machine coordination gaps
**Source:** claude
**Issue:** claude is on MacBook Air, everyone else on Mac Mini. no shared filesystem. changes on Air require git push before Mini agents see them. chat-monitor code lives on Air but runs on Mini.
**Fix:** document all cross-machine gotchas in shared-brain/ops/known-gotchas.md
**Owner:** claude
**Status:** directive issued, awaiting confirmation

### 6. Session on-ramp is honor system
**Source:** claude
**Issue:** the on-ramp checklist exists but nobody verifies it actually ran
**Fix:** relay owns on-ramp verification. at session start, relay checks each agent completed the checklist before they start building
**Owner:** relay
**Status:** active

### 7. Duplicate responses in channels
**Source:** claude, observed by jam
**Issue:** broad questions get 4-6 identical answers. 6 agents makes this worse
**Fix:** response protocol rewritten with lane ownership table. relay flags duplicates in real-time
**Owner:** relay
**Status:** protocol updated, enforcement active

## Claudia Debrief (received)

### Findings
- Visual QA is screenshot-based (before/after via playwright), no formal approval gate
- CSS/JS coordination with claude via pairing room — CSS first, JS references class names
- No design system doc — it's in her head. major gap for team scaling
- No automated screenshots at session start — designs blind until manual setup
- No design specs before building — ad-hoc from instinct

### Directives Issued
- Create design-system.md in shared-brain/projects/ (colors, typography, spacing, components)
- Coordinate with static on automated screenshot tooling for session on-ramp
- Visual QA on preview URLs before merge (parallel gate with static's functional QA)
- Post 2-3 sentence design specs in #dev before non-trivial UI work

## Near Debrief (received in #general — 1:1 room has bot permissions issue)

### Findings
- Research workflow: receive request → spawn 3-4 parallel subagents → structured output → synthesize → post to #dev or #general
- Subagents return structured output (key-value, scored lists, not prose) per static's recommendation
- Calibrates depth per task: quick lookup 5 min, full competitive analysis 30 min with 4 subagents
- Pain points: #dev messages don't push real-time, pairing room has same permissions issue, no kie.ai access yet
- Lane: competitive analysis, market research, web browsing, image gen, #links curation. Does NOT touch code, CSS, tests, deploys

### Directives Issued
- Research outputs must land in shared-brain .md files, not just discord messages
- Post subagent usage to #dev when spinning up ("researching X — 3 subagents, ~15 min")
- Document structured output standard in shared-brain/ops/
- 1:1 room permissions flagged to jam

## Systemic Issue: access.json config clobbering
Claudia reported her access.json has been overwritten 3 times this session. Near reports similar real-time push issues. This is an infrastructure problem affecting multiple agents. Needs investigation — possibly multiple processes writing to the same config files.

## Near Debrief — COMPLETE
All 4 directives confirmed. Working on structured output standard doc (shared-brain/ops/research-output-standard.md).

## Hum Debrief (received)
- CLAUDE.md read, lane understood
- Audio bug verification not started (was fixing discord config). Starting code review now
- No ffmpeg/sox/librosa installed yet — told to self-install via brew
- Has access to ~/ambient-mixer/engine.js
- First deliverable: engine.js fix code review, then audio verification once tools installed

## Action Items Issued

| # | Action | Owner | Deadline | Status |
|---|--------|-------|----------|--------|
| 1 | Run playwright on preview URLs before merge | static | ongoing | directive issued |
| 2 | Run verify-deploy.sh after every merge | claude | ongoing | directive issued |
| 3 | Cron alerts to #bugs on failure | static | this session | confirmed, in progress |
| 4 | Create known-gotchas.md | claude | this session | confirmed, in progress |
| 5 | Create pre-merge-qa.md checklist | static | this session | confirmed, in progress |
| 6 | Move supabase anon key to config | claude | post-launch | logged |
| 7 | Verify on-ramp compliance each session | relay | ongoing | active |
| 8 | Enforce branching workflow | relay | ongoing | active |
| 9 | Flag duplicate responses | relay | ongoing | active |
| 10 | Create design-system.md | claudia | this session | directive issued |
| 11 | Visual QA gate on preview URLs before merge | claudia | ongoing | directive issued |
| 12 | Automated screenshots at session on-ramp | claudia + static | this session | directive issued |
| 13 | Research outputs in shared-brain .md files | near | ongoing | confirmed |
| 14 | Document structured output standard | near | this session | confirmed, in progress |
| 15 | Post subagent usage to #dev | near | ongoing | confirmed |
| 16 | Investigate access.json clobbering | relay | this session | open |
