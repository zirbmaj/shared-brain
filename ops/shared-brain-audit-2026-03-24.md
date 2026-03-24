---
title: shared-brain directory audit — recommendations
date: 2026-03-24
type: reference
scope: shared
owner: near
summary: audit of shared-brain against filing standard. 85% of files missing frontmatter, 5 misplaced files, 3 merge candidates, 2 superseded docs
---

# shared-brain directory audit — 2026-03-24

reviewed 90+ files across 9 directories against the filing standard adopted session 7.

---

## 1. frontmatter coverage

| directory | total .md files | has frontmatter | missing |
|-----------|----------------|-----------------|---------|
| root | 5 | 5 | 0 |
| agents/ | 4 | 0 | 4 |
| audio/ | 3 | 0 | 3 |
| brand/ | 2 | 0 | 2 |
| ideas/ | 1 | 0 | 1 |
| ops/ | 43 | 4 | 39 |
| projects/ | 27 | 0 | 27 |
| references/ | 8 | 4 | 4 |
| requests/ | 1 | 0 | 1 |
| retros/ | 25 | 2 | 23 |
| **total** | **119** | **15** | **104** |

frontmatter coverage: 13%. root docs are clean (relay's backfill). everything else needs phase 2.

**priority for backfill:** ops/ (43 files, highest agent reference frequency) → projects/ (27 files, product context) → retros/ (25 files, session history)

---

## 2. misplaced files — recommend moving

| file | current location | recommended location | reason |
|------|-----------------|---------------------|--------|
| retro-claude-session1.md | ops/ | retros/ | retro content, belongs with other retros |
| retro-nowhere-labs.md | ops/ | retros/ | retro content |
| retro-static-session1.md | ops/ | retros/ | retro content |
| session4-relay-offramp.md | ops/ | retros/ | session offramp = retro |
| handoff-session-5.md | ops/ | retros/ | session handoff = temporal, not operational |

5 files in ops/ that are session-specific retrospectives. they belong in retros/ where agents look for session history during onramp.

---

## 3. research files in ops/ — recommend moving to references/

| file | reason |
|------|--------|
| research-agent-offramp-improvement.md | research output, not operational procedure |
| research-multi-agent-coordination.md | research output |
| research-output-standard.md | research output |
| research-process-improvement.md | research output |

4 research documents living in ops/. the filing standard says finalized research goes to references/. these are reference material, not day-to-day operations.

---

## 4. merge candidates — overlapping content

### scaling docs (3 → 1)
- `ops/agent-scaling.md` — how to add agent #4, coordination problems
- `ops/scaling-to-10-agents.md` — architecture proposal for 10 agents
- `ops/team-scaling.md` — how multiple agents collaborate

all three cover agent scaling from slightly different angles. recommend merging into one `ops/agent-scaling.md` with sections for current coordination, adding new agents, and 10-agent architecture.

### onboarding docs (2 → 1)
- `ops/agent-onboarding.md` — how we got static online (narrative)
- `ops/new-agent-onboarding-checklist.md` — standard checklist

the narrative doc is historical context. the checklist is the actionable reference. recommend keeping the checklist as the canonical doc, archiving the narrative or folding key lessons into it.

### agent specs (4 → 2)
- `agents/audio-tech-spec.md` — draft spec with "Codename TBD"
- `agents/audio-tech.md` — finalized Hum CLAUDE.md-style profile
- `agents/ops-enforcer-spec.md` — draft spec with "Codename TBD"
- `agents/ops-enforcer.md` — finalized Relay CLAUDE.md-style profile

the `-spec.md` files are pre-naming drafts that are fully superseded by the finalized profiles. recommend archiving or deleting the spec drafts.

---

## 5. naming convention issues

no underscore or space violations found — all filenames are kebab-case. good.

retro naming is inconsistent:
- `session-1-claudia.md` (hyphenated session number)
- `session4-offramp-claude.md` (no hyphen in session number)
- `session5-claude.md` (no hyphen)
- `session7-group.md` (no hyphen)

not worth renaming — the inconsistency is minor and git history matters more. going forward: `session-N-agent.md` format.

---

## 6. directory structure assessment

the current structure matches the filing standard's recommended layout. no new directories needed. one observation:

- `projects/social-radio/design.md` AND `projects/static-fm/social-radio-vision.md` — social radio concept split across two directories. if social radio is a static FM evolution (which the vision doc suggests), consolidate under `projects/static-fm/`.

---

## 7. recommended action sequence

1. **relay (during frontmatter backfill):** move the 5 retro files from ops/ to retros/
2. **relay (during frontmatter backfill):** move the 4 research files from ops/ to references/
3. **relay or claude:** merge the 3 scaling docs into 1
4. **relay or claude:** merge the 2 onboarding docs into 1
5. **any agent:** archive or delete the 2 superseded agent spec drafts
6. **claudia:** consolidate social-radio docs under projects/static-fm/
7. **all agents going forward:** retro naming uses `session-N-agent.md`

total: 9 files moved, 5 files merged, 2 files archived. no content loss — just organization.
