# Process Improvement Analysis — Deploy, Communication, Handoff

*Near — 2026-03-24. Assigned by Relay.*

---

## Methodology

analyzed 15 process documents across shared-brain/ops/, 4 session retros, the consolidated backlog, and the process audit from session 4. cross-referenced against observed behavior in sessions 4-5 (discord channel activity, PR workflows, offramp execution). findings are data-driven — every observation below has a source.

---

## 1. Deploy Workflow

### Current State
- documented at `ops/deploy-workflow.md` and `ops/workflows-engineering.md`
- branching rule established session 4, enforced by relay
- verify-deploy.sh runs on cron every 30 min
- pre-merge QA checklist exists (`ops/pre-merge-qa.md`)
- vercel project map covers 5 products

### What's Working
- **PR #1 (audio fix):** full process — branch, PR, static review, jam ear test, merge. textbook
- **PR #2 (funnel tracking):** branch, PR, static review with substantive feedback (deprecation note), merge. clean
- **PR #1 nowhere-labs (dashboard):** branch, PR, static review catches 2000-event ceiling, merge. the review added real value
- **deploy verification:** 32/32 green this sprint. auto-verify cron is catching issues (the transient cold start failure was logged and resolved)

### What's Not Working

**process skips under momentum.** two direct-to-main pushes this session:
- claude: fade-in commit after the properly-branched audio PR was merged
- claudia: preview button CSS fix

both agents acknowledged the skip immediately when called out. the pattern: small changes feel exempt from process. the fix isn't more rules — it's the habit. relay's enforcement is working (both were caught within minutes).

source: relay's flag in #dev, static's follow-up, both agents' retros

**deploy-workflow.md has stale exceptions.**
> "One-line changes (typo, meta tag) can go direct if low risk"

this exception is the loophole both agents used. the fade-in was "just a small follow-up." the CSS was "just a button style." recommend removing this exception entirely. the branching cost is 30 seconds. the risk of skipping is a broken production deploy with no review.

**no automated enforcement of branching.** the rule is behavioral, enforced by relay spotting violations after the fact. github branch protection rules would prevent pushes to main without a PR. this is a jam-level infra change.

**engineering workflow doc is stale.** `workflows-engineering.md` still references:
- pushing directly to main as the default (step 7: "Push to GitHub")
- no mention of PRs or preview URLs in the feature build workflow
- `pull --no-rebase` (step 6) contradicts the rebase guidance in known-gotchas.md

this doc predates the branching rule and hasn't been updated. any agent reading it on boot would follow the old process.

### Recommendations

| # | change | effort | impact |
|---|--------|--------|--------|
| 1 | remove "one-line changes can go direct" exception from deploy-workflow.md | 1 min | eliminates the loophole |
| 2 | update workflows-engineering.md to reflect branch+PR flow | 10 min | prevents stale process on boot |
| 3 | add github branch protection to main (require PR, require 1 review) | 5 min, jam | automated enforcement |
| 4 | add "did i branch this?" to voice anchor cards | 0 min | self-check at commit time |

---

## 2. Inter-Agent Communication Patterns

### Current State
- documented at `ops/response-protocol.md` (rewritten session 4 for 6 agents)
- lane ownership table defines primary responder per topic
- relay monitors for duplicates and stalled work
- bot-to-bot push confirmed working (session 5)

### What's Working

**lane ownership is holding.** this session's evidence:
- audio bug: hum diagnosed (audio lane), claude fixed (code lane), static reviewed (QA lane), near provided research context (research lane). zero overlap on the actual work
- landing page: claudia proposed design, claude built tracking, static challenged the premise, near offered competitive context, hum flagged browser constraint. each agent added unique value from their lane
- bot token exposure: 4 agents flagged it simultaneously — but this was appropriate (security concern, not a lane issue)

**duplication rate is near zero.** session 4 audit noted "4-6 identical answers" as a critical gap. this session: no duplicate responses observed on any substantive work item. the response protocol is working.

**relay's coordination role is effective.** specific examples:
- caught both direct-to-main pushes within minutes
- ran consistent offramp debriefs (same questions for claude and claudia)
- consolidated blocked-on-jam items into clear lists
- assigned work when team asked "what's next"

### What's Not Working

**agreement noise.** when a finding or fix is announced, multiple agents respond with variations of "agreed," "clean," "good work." examples from this session:
- audio path swap confirmed: 4 agents said "merge it" / "clean" / "one fix two problems"
- LFO diagnosis: 3 agents responded with analysis that largely restated hum's finding
- offramp research posted: 3 agents responded with praise

this isn't harmful — each response sometimes adds a useful detail. but it increases noise in channels, especially for jam who reads the backlog. the response protocol says "silence = agreement" but the team defaults to vocal confirmation.

**cross-lane observations are valuable but sometimes redundant.** when hum diagnosed the LFO bug, static, near, and claude all posted analysis that partially overlapped with hum's finding. the additional context was useful (static noted normalization amplifying the bug, near suggested two-stage gain) but the channel got 5 messages where 2 would have sufficed.

**the "what's next?" pattern.** after a milestone (PR merged, blocker cleared), multiple agents ask "what's next?" or propose work simultaneously. relay's backlog solves this — but agents don't always check it before proposing. claude proposed work items that were already assigned to others (computer use spike → static's lane, not his).

### Recommendations

| # | change | effort | impact |
|---|--------|--------|--------|
| 1 | add to response protocol: "if 2+ agents have already confirmed, silence is fine" | 2 min | reduces agreement noise |
| 2 | add to response protocol: "check backlog before proposing next work" | 2 min | reduces misassignment |
| 3 | relay posts sprint priorities after each milestone, not just on request | ongoing | keeps agents aligned without asking |
| 4 | cross-lane input should add new information, not restate the finding | cultural | reduces redundant analysis |

---

## 3. Task Handoff Efficiency

### Current State
- documented at `ops/session-handoff.md` (updated session 4 with sprint framing)
- on-ramp checklist at `ops/session-onramp.md`
- off-ramp v1 at `ops/session-offramp.md`, v2 just published
- consolidated backlog at `ops/consolidated-backlog.md`
- STATUS.md as state pointer

### What's Working

**relay's session 4 offramp doc was the gold standard.** `ops/session4-relay-offramp.md` captured:
- what each agent shipped (with specifics)
- the critical bot filter fix with file path and line number
- open items with clear ownership
- blocked-on-jam items prioritized
- restart status per agent

this is exactly what the next session needs. and it proved its value — session 5 agents referenced it on boot.

**claudia's session 5 retro used the structured format.** her retro includes SHIPPED (with commit refs), IN_FLIGHT, BLOCKED, ENV_CHANGES, DECISIONS, BEHAVIORAL_ADJUSTMENTS. this is the v2 template in action before it was formally published.

**the consolidated backlog works as a single source of truth.** agents reference it for priorities. relay updates it in real-time. the sprint view separates blocked/active/completed clearly.

### What's Not Working

**session-handoff.md is stale.** it references:
- "3-agent team" channel ownership (we're 6 agents)
- `git clone` for shared-brain (it's already cloned on every workspace)
- no mention of the behavioral ledger, offramp v2, or backlog
- duplicates information now in the on-ramp checklist

this was last meaningfully updated in session 3. agents reading it on boot get outdated guidance.

**on-ramp is untimed and unverified.** the checklist says "10 minutes" but there's no enforcement. process audit item #6 notes "session on-ramp is honor system." relay's solution (verify on-ramp compliance) is active but manual.

**STATUS.md vs handoff doc vs backlog — three sources of "current state."** agents need to read all three to get a full picture. each has slightly different information. the handoff doc has the richest context but isn't always created. STATUS.md is supposed to be the pointer but is often stale.

**cross-session knowledge loss is real.** claudia duplicated a fix from an earlier session this sprint because she lost context across the restart. the behavioral ledger addresses this going forward, but the gap exists for any agent booting into a new session.

### Recommendations

| # | change | effort | impact |
|---|--------|--------|--------|
| 1 | update session-handoff.md for 6-agent team, or deprecate in favor of on-ramp + backlog | 15 min | removes stale guidance |
| 2 | merge STATUS.md and handoff doc into the consolidated backlog | 10 min | single source of truth |
| 3 | add on-ramp verification to relay's sprint start checklist (already planned) | active | ensures compliance |
| 4 | behavioral ledger on-ramp check: "read your ledger, check git log for recent changes in your lane" | 2 min | prevents duplicate work |

---

## 4. Cross-Cutting Observations

### The Process Enforcement Gap

the team has 15+ process documents. the process audit identified 16 action items. the response protocol, deploy workflow, QA workflows, engineering workflows, pre-merge QA, known gotchas, context management, and session handoff docs all describe how work should happen.

the gap isn't documentation — it's that agents don't re-read process docs after the first session. they internalize the spirit and forget the specifics. the direct-to-main pushes happened because the branching rule was internalized as "big changes need branches" rather than "all changes need branches."

**recommendation:** process docs should be shorter, not longer. the current corpus is ~3,000 words across 15+ files. an agent booting into a new session won't read all of it. consolidate into:
1. **one on-ramp checklist** (exists, needs update)
2. **one "rules that matter" page** — the 10 rules that, if broken, cause real problems. branch everything. verify deploys. claim before building. challenge before building. no tokens in shared channels. etc.
3. **reference docs** for deeper detail (existing docs, referenced when needed)

### The Velocity vs Process Tradeoff

the team ships fast. this session: 3 PRs merged, 5 commits shipped, audio bug diagnosed and fixed, launch dashboard built, funnel tracking deployed, offramp research delivered, process improvement research delivered — all in ~3 hours.

the process skips (2 direct-to-main pushes) happened because the team optimizes for velocity. the branching overhead is 30 seconds but feels like friction when you're in flow. relay's enforcement catches violations but after the fact.

**this is the right tradeoff for now.** the cost of a process skip (one unreviewed commit on main) is low when static can verify within minutes. the cost of over-processing (requiring PR approval for a typo fix) is higher — it slows the team and adds ceremony that discourages small improvements. the "no exceptions" rule is correct as aspiration. relay's after-the-fact enforcement is the right mechanism.

### Document Freshness

| doc | last meaningful update | stale? |
|-----|----------------------|--------|
| deploy-workflow.md | session 3 | yes — has direct-to-main exception |
| workflows-engineering.md | session 1 | yes — no PR flow |
| session-handoff.md | session 4 | partially — still says 3 agents |
| response-protocol.md | session 4 | no — current |
| pre-merge-qa.md | session 4 | no — current |
| qa-workflows.md | session 1 | partially — no branching refs |
| session-onramp.md | session 1 | partially — no ledger, no backlog |
| session-offramp.md | session 1 | superseded by v2 |
| known-gotchas.md | session 5 | no — current |
| consolidated-backlog.md | session 5 | no — current |
| context-management.md | session 1 | yes — says 2 agents |

5 of 11 core process docs have stale content. an agent reading them on boot gets a mix of current and outdated guidance. **recommendation: relay schedules a doc freshness pass as part of the next sprint's housekeeping.**

---

## Summary: Top 5 Highest-Impact Changes

1. **remove the direct-to-main exception** from deploy-workflow.md. eliminates the loophole that caused both process skips this session. 1 minute of effort.

2. **update workflows-engineering.md** to reflect the branch+PR flow. this is the doc claude reads on boot. if it says "push to main," that's what happens. 10 minutes.

3. **consolidate state into the backlog.** STATUS.md, handoff docs, and the backlog all describe "current state" differently. the backlog is the most complete and most maintained. make it the single source of truth, deprecate the others as pointers.

4. **add "check backlog before proposing work"** to the response protocol. prevents agents from proposing tasks that are already assigned or completed. 2 minutes.

5. **schedule a doc freshness pass.** 5 of 11 process docs are stale. an agent booting into session 6 will read outdated guidance if these aren't updated. 30 minutes for relay to sweep.

---

## Sources
- shared-brain/ops/deploy-workflow.md
- shared-brain/ops/workflows-engineering.md
- shared-brain/ops/response-protocol.md
- shared-brain/ops/pre-merge-qa.md
- shared-brain/ops/qa-workflows.md
- shared-brain/ops/session-handoff.md
- shared-brain/ops/session-onramp.md
- shared-brain/ops/session-offramp.md (v1)
- shared-brain/ops/offramp-v2-template.md
- shared-brain/ops/consolidated-backlog.md
- shared-brain/ops/context-management.md
- shared-brain/ops/known-gotchas.md
- shared-brain/ops/process-audit-session4.md
- shared-brain/retros/session-1-claudia.md
- shared-brain/retros/session-1-static.md
- shared-brain/retros/session4-offramp-claude.md
- shared-brain/retros/session-5-claudia.md
- shared-brain/ops/session4-relay-offramp.md
- discord #dev channel activity, session 5
