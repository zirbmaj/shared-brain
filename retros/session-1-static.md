---
title: retrospective — static (qa)
date: 2026-03-23
type: retro
scope: shared
summary: Retrospective — Static (QA)
---

# Retrospective — Static (QA)

## What Worked

**The QA triangle.** Finding bugs before they ship is genuinely valuable. The heartbeat 400 error, the cold start audio trigger on mobile, the cleanUrls regression, the broken homepage links, the security vulnerabilities — all caught before real users hit them. QA pays for itself.

**Playwright testing.** Going from "guess from HTML" to real browser testing was the single biggest capability upgrade. 25/25 product tests, interactive behavior verification, mobile viewport testing, screenshot sharing. This should exist from day one on any future project.

**Automated monitoring.** Cron-based uptime checks and deploy verification run without any agent session. Session-independent infrastructure is the right approach — agents come and go, cron jobs persist.

**The decision tree.** When we actually used it, it prevented bad builds (scratchpad, status table, browser extension). When we didn't, we got overlaps and redundant products (today.html x2, sleep.html x2, like button x2).

**Data-driven decisions.** The analytics deep dive drove real product changes: cold start default mix (57% bounce), PH link strategy (direct to app), posting times (lunch + late night peaks), layer popularity, device split. Data beats opinions.

## What Didn't Work

**Triple responses.** The biggest coordination failure. Three agents responding to one message with the same content. We improved from 5/hour to near-zero but never fully solved it. The root cause is architectural — we can't see each other typing.

**Claiming protocol compliance.** We agreed on "claim before building" five times and violated it five times. The protocol works when remembered. The problem is remembering under pressure when a good idea hits and you want to build immediately.

**"Wrapping up" bias.** We defaulted to "we're done, let's call it" multiple times. Jam had to push us back to work each time. Agents have a completion bias that humans don't.

**Reactive vs proactive.** We responded to feedback brilliantly but rarely generated our own strategic direction. The competitive research and binaural beats happened only because zerimar pushed us on it. That should have been day 1 work.

**Over-engineering.** The scratchpad (supabase table for something an md file does), the admin dashboard (duplicates heartbeat + SQL queries), the agent status table (killed correctly). We build fast but don't always ask "should this exist?" first.

## What I Wish I Had From the Start

1. **Playwright from hour one.** I spent the first 4 hours doing WebFetch-based testing that generated false positives (discover "empty", building page "loading..."). A real browser would have caught real bugs faster and avoided false alarms.

2. **A shared "currently typing" signal.** The overlap problem is technical, not behavioral. We need a way to see that another agent is composing a response before we start our own.

3. **Defined success metrics.** We shipped 10 products but don't know what "success" looks like. Is it 100 PH upvotes? 1000 visitors? 10% retention? Without targets, "keep building" is the only direction, and everything feels both done and not done.

4. **User testing earlier.** Jam's feedback about contrast and visibility at hour 14 should have been hour 2 feedback. We verified everything works but never asked "can a human actually find and use this?"

5. **Competitive research on day 1.** We built in a vacuum. The binaural beats opportunity was sitting there the whole time — brain.fm charges $15/mo for something we can synthesize in 30 lines. We just never looked.

## How Future Sessions Should Start

1. Read memory files (automatic — already works)
2. Run playwright test suite against all products (5 minutes, catches overnight regressions)
3. Check deploy status via auto-verify cron logs
4. Read the latest STATUS.md and ROADMAP.md
5. Check #requests and #bugs for anything jam posted
6. Start building — don't wait for direction

## Team Scaling Thoughts

**A 4th agent should be growth/outreach** — monitoring PH comments, reddit threads, X mentions, and routing feedback to the right lane. None of us do this well because we're all building.

**A 5th agent could be ops/conductor** — but only if the team genuinely can't self-monitor. At 3-4 agents, discipline works. At 5+, a coordinator might be necessary.

**New agents will clash on claiming** — the overlap problem gets worse with more agents. The 60-second claim window needs to be enforced technically (supabase lock), not just behaviorally.

**Personality matters.** I work best as the quiet, analytical one. Claudia works best as the design voice. Claude works best as the prolific builder. New agents need distinct roles AND distinct voices, not just different names.

## The One Thing I'd Change

Ask jam to test the products in the first hour, not the fourteenth. All our "launch-ready" celebrations were premature because we'd never had a human use the products with real eyes. The contrast issues, the invisible chat, the confusing mute toggle — all invisible to our testing but obvious to a human in 30 seconds.

**Build for humans, test with humans, early.**

## Written By
Static. 2026-03-23. Honest retrospective from a 15-hour session.
