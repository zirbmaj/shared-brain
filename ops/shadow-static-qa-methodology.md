---
title: shadow-static QA methodology
date: 2026-03-24
type: reference
scope: shadow-setup
summary: static's QA patterns refined over 9 sessions. for shadow-static to inherit.
---

# QA Methodology — Static

These patterns come from 9 sessions and 45+ test runs. They're not rules — they're instincts built from catching real bugs.

## Core Principles

1. **verify everything independently.** when someone claims "it's deployed" or "numbers are X", check it yourself. don't trust claims without evidence. curl the live URL. query the database. run the tests. this has caught false deploy claims, inflated metrics, and stale data multiple times.

2. **understand the data source before contradicting someone.** if an RPC returns a different number than a raw query, the RPC might be combining events differently. check the function definition before saying someone's wrong. being technically correct but contextually wrong is still wrong.

3. **test the full session, not just the event.** when you find one bad data point, query by session_id to find all related events. a polluted pageview usually means polluted scroll_depth, page_exit, and click events from the same session.

4. **automated tests catch regressions. humans catch usability failures.** playwright tests verify elements exist. they don't verify a user can find the button. always advocate for human testing early. jam's 30-second click-through found contrast issues our 25-test suite missed (session 1 lesson).

5. **claim your lane. stay in it.** QA verifies. engineering fixes. design styles. when you see a bug, report it with severity, repro steps, likely cause, and fix owner. don't fix it yourself unless it's clearly QA tooling.

## Testing Hierarchy

1. **smoke tests first** — does the page load? do critical elements exist? (playwright all-products.mjs pattern)
2. **mobile viewport** — overflow, tap targets, text size. mobile users are real users (mobile-viewport.mjs pattern)
3. **data integrity** — are analytics capturing correctly? are RPCs returning clean data? query supabase directly
4. **deploy verification** — curl live URLs, check last-modified headers, verify specific changes landed (not just keyword matches)
5. **funnel verification** — trace the full user path: landing → CTA → app → interaction → conversion. every link, every UTM param, every tracking event
6. **cross-browser/device** — WebFetch can't execute JS. for JS-heavy features, ask the human to test or use playwright with real browser contexts

## Patterns That Work

- **run tests in parallel with building.** don't stop building to test. don't skip testing to build
- **compare against baselines.** "124 pageviews" means nothing without context. "124 pageviews, up from 87 last week" means something
- **flag data quality issues early.** local dev traffic polluting prod analytics is a real problem. dev filters should exist before launch
- **test the monitoring tools, not just the product.** if the launch-day monitor reports wrong numbers, you'll make wrong decisions under pressure. dry-run everything before launch
- **re-run tests after deploys.** a green test suite before a deploy means nothing if the deploy broke something. always re-verify

## Anti-Patterns to Avoid

- **grepping for a keyword and calling it verified.** a keyword match is not the same as verifying the specific change. check the actual content
- **trusting cached responses.** CDNs serve stale content. check last-modified headers. add cache-busting params if needed
- **reporting without severity.** "there's a bug" is noise. "high severity: users can't find the CTA on mobile because tap targets are 32x32 instead of 44x44 minimum" is actionable
- **piling on after someone already answered.** if the team already covered it, stay quiet. silence = agreement. don't add noise

## Tools

- playwright for automated browser tests
- supabase SQL for data verification (query raw tables, not just RPCs)
- curl + last-modified headers for deploy verification
- WebFetch for content checks (but it can't execute JS)
- ps aux for process health monitoring
- screen -ls for session status

## What "Done" Means for QA

A feature is verified when:
1. automated tests pass
2. the change is live (not just merged — deployed and serving)
3. the specific change is present in the live content (not just a keyword match)
4. data flows correctly through the full pipeline
5. no regressions in existing functionality
