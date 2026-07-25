---
title: Proposed Docs Cleanup — Phase 1 Audit Results
date: 2026-03-28
type: proposal
scope: shared
author: relay
status: awaiting jam's review
---

# Proposed Docs Cleanup

Audit date: 2026-03-28. 216 files inventoried across 13 directories.
**No changes will be made without jam's sign-off per item.**

## 1. Terminology: shadow → meridian

**STATUS: FROZEN.** Axis confirmed (2026-03-28) that meridian still uses shadow-* operationally (workspaces, screen sessions, configs). Rename approved by fran but not yet executed on their side. Both teams will update simultaneously when meridian initiates. No changes until then.

### Files identified (for when rename is coordinated)
- 10 filenames use "shadow"
- 9 files reference "shadow" in content
- Retros left as historical records regardless

## 2. Staleness — Proposed Updates

| File | Issue | Proposed Action |
|------|-------|-----------------|
| STATUS.md | Last updated 2026-03-26, missing sessions 13-13.2 | Update with session 13 shipped items + current T-3 status |
| GOALS.md | "week of 2026-03-22" — 6 days old | Refresh for launch week (2026-03-28 through 04-04) |
| ops/agent-status.json | Last updated 2026-03-24 | Update or remove — may be superseded by health API |
| ops/analytics-baseline-t7.md | Superseded by reports/t1-analytics-baseline.md | Archive |
| ops/rag-schema.md | References vector(1536) but ollama uses 768-dim | Verify with claude, correct if wrong |

## 3. Duplicates — Proposed Resolution

| Files | Proposed Action |
|-------|-----------------|
| ops/ph-comment-triage.md + ops/ph-comment-triage-framework.md | Merge into one, archive the other |
| ops/session-handoff.md + ops/session-offramp.md | Merge — handoff is the broader doc, offramp is a subset |
| projects/zerimar-phase-a-implementation-plan.md + references/zerimar-implementation-plan.md (60KB each) | Confirm if identical, keep one, archive the other |

## 4. Gaps — Proposed New Docs

| Topic | Why | Who drafts |
|-------|-----|-----------|
| Agent cycling procedures | No doc for how/when to cycle agents, the commands, the safeguards | relay |
| Discord plugin setup/troubleshooting | Common failure modes (access.json corruption, bot token rotation) undocumented | relay |
| Hook configuration guide | SessionStart hooks, settings.json patterns, no central reference | relay + claude |
| Vigil setup/operation | Two vigil servers, no setup or troubleshooting doc | claude |
| Sandbox limitations + workarounds | crontab blocked, other restrictions — agents need to know what they can't do | relay |

## 5. Proposed Onramp Changes

Current state: every agent loads the same CLAUDE.md + shared-brain + memory on boot. Context grows with every session.

Proposed: lane-specific onramp hooks that load only what's relevant.

| Agent | Loads on boot | Skips |
|-------|--------------|-------|
| claude | git status, test results, open PRs, deploy status, active carries | audio architecture, competitive analysis, ops process docs |
| claudia | deploy status, visual QA results, design system state, active carries | DB schema, engineering workflows, audio details |
| static | test results, deploy status, service health, "since last offramp" diff, active carries | audio architecture, competitive analysis, design system |
| near | research queue, landscape scan status, active carries | test results, deploy pipeline, audio details |
| hum | audio file inventory, service health (ollama), active carries | deploy pipeline, competitive analysis, design system |
| relay | all agent status, deploy health, process compliance, doc freshness, active carries | audio architecture, design system details |

**This is a proposal.** Jam reviews before any changes to onramp hooks.
