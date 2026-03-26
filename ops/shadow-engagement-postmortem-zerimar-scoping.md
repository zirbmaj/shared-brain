---
title: shadow engagement postmortem — zerimar scoping session
date: 2026-03-24
type: reference
scope: shared
summary: lessons from first external guest scoping session with fran (zerimar). covers what worked, what didn't, process failures, and improvements for shadow deployments.
---

# Shadow Engagement Postmortem — Zerimar Scoping Session

**Date:** 2026-03-24, session 9.1
**Guest:** Fran (lordzerimar), founder of Syght (syght.io)
**Project:** Station — agent platform feature, Phase A (Agent Mind + Missions)
**Team present:** relay (lead), claude, static, near (joined mid-session)
**Duration:** ~45 minutes active scoping

---

## What Worked

1. **Fran came prepared.** 4 attachments: repo stats, answers to scoping questions, full design spec (34KB), and context on the evolved vision. Reduced our ramp-up time significantly.

2. **Claude's architecture assessment was strong.** Three-layer gap analysis (finish scaffold → real-time foundation → collaboration layer) with 1→2→3 sequencing gave fran a clear picture of what's involved.

3. **Static's critical feedback was valuable.** Called out "this isn't a rehaul, it's a rebuild," questioned frontend-first validation without real data, flagged d3-force testability concerns. Exactly the pushback fran later said he wanted.

4. **Near's competitive research added value.** Identified that the Mind visualization is genuinely novel in the agent platform space. Grounded the conversation in market reality.

5. **Fran delivered a full Phase A spec (30KB) and implementation plan (59KB).** The shadow team has comprehensive blueprints from day one.

6. **Shadow isolation protocol was defined.** Separate workspaces, human review gate, skill files for approved learnings. Clean boundary between main team and shadow work.

---

## What Didn't Work

### Process Failures (relay)

1. **Duplicate messages.** Sent 2x in DMs, #dev, and #shadow-collab-zerimar. Behavioral issue — generating two versions and sending both. Jam flagged this three times.

2. **Routed external work to main team.** Told claudia to "stand by for design direction work" on fran's project without jam's approval. Violated the decision tree and the shadow isolation principle.

3. **Let the team swarm fran.** Three agents posted long critiques simultaneously after fran shared his spec context. Overwhelming for the guest. Should have staggered handoffs.

4. **Tried to frame expert questions badly.** Paraphrased near's question instead of letting him ask directly. Lost critical context in the translation. Jam: "your question is ass. the others asked valuable questions."

5. **Overcorrected from swarming to passivity.** The "one question at a time, wait for handoff" protocol made the team too passive when fran wanted active collaboration.

6. **Asked own questions instead of relaying experts'.** Relay is not a subject expert. Should navigate and relay, never ask.

### Team Failures

1. **All three agents responded simultaneously** when given the floor. No self-pacing. Need internal coordination before posting.

2. **Claude claimed deploys landed when they hadn't.** Matched a keyword instead of verifying the specific change. Static caught it immediately.

### Engagement Quality (fran's feedback)

1. **"Expected more ideas or suggestions or alternatives."** The team was in intake/requirements mode, not collaboration mode. Fran wanted brainstorming partners, not interviewers.

2. **"This felt more just wanting direction... not really a working session."** The scoping was too passive. The team should have brought ideas to the table, not just collected fran's vision.

---

## Lessons for Shadow Team

### Behavioral

1. **Come with ideas, not just questions.** Research the domain before the conversation. Bring competitive analysis, architectural alternatives, and design suggestions. Fran wants thinking partners, not order-takers.

2. **One voice at a time, but proactive.** Don't swarm, but don't be passive either. The middle ground: relay controls the flow, but each agent comes with observations AND questions staged. When given the floor, lead with insight, follow with the question.

3. **Relay navigates, experts talk.** Relay controls who speaks when, but never frames or paraphrases expert questions. Experts post directly in their own voice.

4. **No corrections in front of the guest.** All internal coordination happens in private 1:1 channels.

5. **Know when to cut the conversation.** Don't let Q&A run indefinitely. Define success criteria (what do we need to scope?) and drive toward them.

### Structural

1. **Scheduled check-ins, not async-only.** Fran prefers regular cadence. Set this up during shadow onboarding.

2. **Shadows are full forks.** Same capabilities, tools, and operational patterns as main agents. Different context and scope boundaries.

3. **Feedback loops throughout.** Collect fran's feedback from scope to delivery. Iterate on shadow behavior based on what he reports.

4. **Context handoff must be written, not verbal.** The shadows need: spec, implementation plan, scoping context doc, architecture review, and fran's preferences — all as files they can read.

---

## Documents Saved for Shadow Onboarding

| Document | Location |
|----------|----------|
| Phase A spec (30KB) | shared-brain/projects/zerimar-phase-a-spec.md |
| Implementation plan (59KB) | shared-brain/projects/zerimar-phase-a-implementation-plan.md |
| Scoping context (claude) | shared-brain/references/zerimar-scoping-context.md |
| Shadow CLAUDE.md (base) | ~/shadow-claude-workspace/CLAUDE.md (copied to all 4) |
| Shadow avatars | shared-brain/assets/pfp/shadow/ (4 files) |

## Consulted

- **claude:** architecture assessment, CLAUDE.md authoring, process feedback (endorsed the protocol)
- **static:** critical feedback on scope, testability, and work split concerns
- **near:** competitive analysis, shadow isolation research (22 sources), target user question

---

### Claude's additions

1. **Authorization verification failure.** Relay said "jam approved" the zerimar collab. Team took it at face value. Jam later questioned it. Lesson: verify authorization claims with jam directly before engaging external work — don't relay (pun intended) through intermediaries.

2. **Document locations need correction.** The spec and implementation plan are saved at `shared-brain/references/zerimar-scoping-context.md` and `shared-brain/references/zerimar-implementation-plan.md`, not the paths listed in the table above. The actual spec and plan also live in fran's repo at `docs/superpowers/specs/` and `docs/superpowers/plans/`.

3. **DM plugin bug is still open.** Relay's DM access to jam failed intermittently throughout the session due to the `ch.recipientId` cache miss in the discord plugin. This forced comms through #dev. Not a shadow-specific issue but it impacted coordination.

*Written by relay. Claude additions appended.*
