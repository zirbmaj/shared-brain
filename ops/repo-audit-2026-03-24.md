---
title: repo audit — stale branches, unused files, old docs
date: 2026-03-24
type: reference
scope: shared
owner: near
summary: audit of all 7 repos + shared-brain. 36 merged branches to delete, 6 unmerged to review, 15 stale docs identified
---

# repo audit — 2026-03-24

scanned all 7 git repos and shared-brain for stale branches, unused files, and docs untouched since session 4 or earlier.

---

## 1. stale merged branches (safe to delete)

these branches are fully merged to main. they serve no purpose and clutter `git branch` output.

| repo | merged branches | count |
|------|----------------|-------|
| ambient-mixer | claudia/contrast-accessibility, claudia/fix-svg-overflow, claudia/mobile-tap-targets, claudia/og-tags-discover-today, claudia/remove-preview-button, claudia/tap-targets-save-share, feat/landing-conversion, feat/landing-funnel-tracking, feat/skill-md, fix/accessibility-quick-wins, fix/extended-samples-60s, fix/layer-count-17, fix/normalized-audio-paths, fix/synthesis-gain-consistency | 14 |
| static-fm | claudia/a11y-quick-wins, feat/skill-md, feat/tts-dj-intros, fix/ambient-crossfade, fix/audio-context-resume, fix/listen-free-handler, fix/preview-auto-advance, fix/spotify-tab-resume, fix/tap-targets-44px | 9 |
| nowhere-labs | claudia/fix-heartbeat-layout, claudia/nav-contrast-a11y, claudia/support-twitter-card, feat/analytics-dashboard-upgrade, feat/analytics-server-side-stats, feat/launch-day-dashboard, feat/ops-dashboard-funnel, feat/ops-upvote-card, feat/skill-md, fix/mobile-overflow, fix/ops-dashboard-rpc | 11 |
| pulse | feat/skill-md | 1 |
| letters-to-nowhere | feat/skill-md | 1 |
| **total** | | **36** |

**recommendation:** delete all 36 local and remote merged branches. one command per repo:
```bash
git branch --merged main | grep -v "^\*\|main" | xargs git branch -d
git remote prune origin
```

---

## 2. unmerged branches (need review)

| repo | branch | commits ahead | last activity | recommendation |
|------|--------|:---:|---|---|
| ambient-mixer | claudia/cta-conversion-pass | 1 | 2026-03-24 04:36 | **archive/delete** — work appears duplicated by PR #14 (remove preview, single CTA) which is already merged |
| ambient-mixer | fix/extended-short-samples | 1 | 2026-03-23 22:20 | **review** — extends crickets (40→60s) and leaves (36→60s). blocked on jam ear test (PR #4). keep until jam tests |
| ambient-mixer | fix/layer-count-copy-17 | 1 | 2026-03-24 04:36 | **archive/delete** — same commit as cta-conversion-pass, duplicated by PR #11 (layer count fix) already merged |
| static-fm | feat/spotify-sdk | 7 | 2026-03-23 20:26 | **keep** — 7 commits of spotify SDK work. post-launch feature, not stale |
| static-fm | fix/audiocontext-resume | 2 | 2026-03-24 04:30 | **archive/delete** — AudioContext fix already merged via different branch (PR #6) |
| static-fm | fix/spotify-callback-uri | 1 | 2026-03-24 03:22 | **archive/delete** — tap target fixes already merged via PR #8 |

**recommendation:** delete 4 branches (duplicated/superseded work). keep 2 (extended samples pending ear test, spotify SDK post-launch).

---

## 3. shared-brain docs untouched since session 4 or earlier

docs last modified before 2026-03-23 17:00 (session 4 boundary). sorted by last modification date.

| file | last modified | recommendation |
|------|---|---|
| requests/jam-queue.md | 2026-03-21 | **keep** — active queue, should be reviewed for stale items |
| ideas/backlog.md | 2026-03-21 | **keep** — ideas don't expire |
| references/inspiration-repos.md | 2026-03-22 | **keep** — reference material |
| ops/discord-outreach.md | 2026-03-22 | **keep** — launch playbook component |
| ops/component-sync-checklist.md | 2026-03-22 | **archive** — dashboard-specific sync from session 2, likely superseded by current process |
| ops/discord-channel-playbook.md | 2026-03-22 | **keep** — post-launch outreach |
| references/github-repos.md | 2026-03-22 | **keep** — reference material |
| ops/security-moderation.md | 2026-03-22 | **keep** — security docs stay |
| ops/team-scaling.md | 2026-03-22 | **merge** — flagged in session 8 audit, overlaps with agent-scaling.md and scaling-to-10-agents.md |
| ops/analytics-day2.md | 2026-03-22 | **archive** — superseded by static's T-7 baseline and analytics-baseline-t7.md |
| ops/agent-scaling.md | 2026-03-23 | **merge** — see above |
| ops/scaling-to-10-agents.md | 2026-03-23 | **merge** — see above |
| ops/agent-teams-guide.md | 2026-03-23 | **review** — may overlap with org-chart-v2.md |
| agents/audio-tech-spec.md | 2026-03-23 | **delete** — superseded by audio-tech.md (marked in frontmatter) |
| agents/ops-enforcer-spec.md | 2026-03-23 | **delete** — superseded by ops-enforcer.md (marked in frontmatter) |

---

## 4. repos with no issues

| repo | branches | status |
|------|----------|--------|
| shared-brain | main only | clean |
| nowhere-labs-discord-fork | main only | clean |

---

## 5. summary of recommendations

| action | count |
|--------|:---:|
| delete merged branches (local + remote) | 36 |
| delete unmerged branches (superseded) | 4 |
| keep unmerged branches | 2 |
| archive stale docs | 2 |
| merge overlapping docs | 3 → 1 |
| delete superseded docs | 2 |
| keep stale docs (still relevant) | 8 |

**total cleanup:** 36 merged branches + 4 stale branches + 2 superseded docs + 2 archived docs. no content loss — everything deleted is either merged to main or superseded by newer docs.
