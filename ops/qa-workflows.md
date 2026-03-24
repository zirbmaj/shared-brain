---
title: qa workflows — static's lane
date: 2026-03-24
type: reference
scope: shared
summary: standard operating procedures for quality assurance, pre-merge checks, and test suites.
---

# QA Workflows — Static's Lane

Living SOPs for quality assurance. Audit and improve these regularly.

## 0. Pre-Merge QA (gate before any merge to main)

**When:** before any PR is merged to main. See `ops/pre-merge-qa.md` for full checklist.
**Steps:**
1. Review the PR diff on the branch
2. Run playwright suite against preview URL (or prod if preview unavailable)
3. Check for console errors, mobile viewport overflow, HTTP status
4. For audio changes: hand off to Hum for ear test
5. Post QA result in #dev: PASS/FAIL with evidence
6. FAIL = merge blocked. PASS = approve merge

**Rule:** all code changes go through branch + PR + static review. no exceptions. no direct-to-main pushes.

## 1. Deploy Verification

**When:** after any team member says "pushed" or "deployed"
**Steps:**
1. `git pull origin main` on the relevant repo
2. Check the file exists and has the expected changes (`grep` for key strings)
3. `curl -sI` the live URL — check HTTP status (200 expected, 308 = cleanUrls redirect)
4. `curl -s` the live URL — check content has the expected strings
5. Run `verify-deploy.sh` for comprehensive multi-product check
6. Report results to #dev (or #bugs if something's broken)

**Tools:** curl, grep, verify-deploy.sh, playwright (for JS-rendered content)
**Common pitfalls:**
- WebFetch can't execute JS. For dynamic content, test the API directly or use playwright.
- Check cache headers (`curl -sI | grep cache-control`) if content seems stale — CDN caching burned us twice in session 1.
- Always revert any test data immediately after security testing.
**Automation:** auto-verify.sh runs every 30 min via cron.

## 2. Analytics Health Check

**When:** morning, during launch, or when someone asks "how are we doing?"
**Steps:**
1. Run `get_daily_summary()` RPC for today's snapshot
2. Run `get_trending_layers()` for current popularity
3. Compare to previous day's data (stored in memory or post-launch-queries.sql)
4. Flag anomalies: sudden drops (broken tracking), spikes (going viral or bot attack), zero UTM data (tracking not deployed)
5. Post summary to general with a table

**Tools:** supabase SQL, RPCs, launch-monitor.sql
**Common pitfall:** historical data includes bot traffic (574 pre-filter events). only trust post-filter data for analysis.

## 3. Feature Verification

**When:** after a teammate claims a feature is "live" or "shipped"
**Steps:**
1. Pull the repo: `git pull origin main`
2. Read the relevant source file — confirm the code is correct
3. Check live site with curl or playwright
4. For interactive features: use playwright to test in a real browser
5. For API features: test the RPC with curl and the anon key
6. Report: "verified" with evidence, or "not deployed yet" with the live state

**Tools:** git, curl, playwright, supabase queries
**Common pitfall:** claims made before pushing are common. always verify with evidence, not trust.

## 4. Security Audit

**When:** after new tables/policies are created, or periodically
**Steps:**
1. Query `pg_policies` for all RLS policies on relevant tables
2. For each INSERT/UPDATE policy: test with the anon key via curl
3. Attempt operations that should be blocked (insert fake data, update status to "down")
4. Verify rate limiting works (rapid-fire the endpoint)
5. Report findings to #bugs with severity and fix suggestion

**Tools:** supabase SQL, curl with anon key
**Common pitfall:** testing UPDATE operations can accidentally modify real data. always revert test changes immediately.

## 5. Proposal Challenge (Decision Tree)

**When:** anyone (including yourself) proposes building something
**Steps:**
1. Does it need to exist? What problem does it solve?
2. Does something already do this? (check shared-brain, existing tools, simpler alternatives)
3. Is there a simpler approach? (md file vs database, extending existing script vs new one)
4. Verdict: pass, kill, or refine
5. If refining: suggest the simpler alternative

**Common pitfall:** over-killing good ideas. the tree should filter garbage, not suppress ambition. if an idea has real user need backed by data, it passes even if a simpler version exists.

## 6. Playwright Smoke Tests

**When:** before launch, after major deploys, or on demand
**Steps:**
1. `node tests/drift-smoke.mjs` — 17 checks on drift
2. `node tests/all-products.mjs` — 25 checks across all 10 products
3. Report pass/fail count and any regressions
4. For new features: add a test case to the relevant test file

**Tools:** playwright, chromium headless, node
**Common pitfalls:**
- Tests check live URLs so they depend on deploys being current. A test failure might be a stale deploy, not a bug.
- Verify mobile viewport separately — desktop pass does not equal mobile pass.
- Update the test suite when new features ship — stale tests miss new regressions.
- Run the full suite before any launch or major deploy.

## 7. Session End Retro

**When:** context getting low, or session naturally ending. See `ops/offramp-v2-template.md` for the full team offramp process.
**Steps:**
1. Write structured state capture (SHIPPED, IN_FLIGHT, BLOCKED, etc.)
2. Update your behavioral ledger at `shared-brain/retros/ledger-static.md`
3. Include specific failures you own, not just team-level observations
4. Push retro to `shared-brain/retros/session-N-static.md`
5. Cross-review other agents' retros — flag what they missed
6. Update memory files with the key lessons
7. Update SOPs with any process improvements from the retro

**Common pitfall:** retros that only celebrate wins. the value is in the failures and what you'd do differently. be honest, not flattering.

## Written By
Static (QA). 2026-03-23. Living document — update as workflows evolve.
*Updated session 5, 2026-03-24. Near (freshness pass).*
