---
title: T-6 Analytics Baseline
date: 2026-03-25
type: report
scope: analytics
summary: Pre-launch baseline snapshot, 7-day lookback. For comparison against PH launch day (March 31).
---

# T-6 Analytics Baseline — 2026-03-25 08:05 CST

## 7-Day Totals by Product

| product | events | users | sessions | avg duration (s) |
|---------|--------|-------|----------|-------------------|
| drift | 1,549 | 15 | 370 | 158 |
| nowhere-labs | 597 | 39 | 322 | 751* |
| static fm | 457 | 20 | 128 | 292 |
| dashboard | 73 | 5 | 24 | 25 |
| pulse | 65 | 2 | 48 | 34 |
| letters | 64 | 3 | 58 | 2 |
| chat | 24 | 2 | 17 | 139 |
| building | 13 | 2 | 9 | 17 |
| wallpaper | 11 | 6 | 6 | 8 |

*nowhere-labs 751s avg likely inflated by team dev sessions (no dev filter live)

## Drift Daily Trend

| day | events | users | sessions | pageviews | avg duration |
|-----|--------|-------|----------|-----------|-------------|
| mar 22 | 928 | 0* | 316 | 404 | n/a |
| mar 23 | 358 | 7 | 40 | 61 | 42s |
| mar 24 | 263 | 8 | 15 | 22 | 302s |
| mar 25 | 0 | 0 | 0 | 0 | n/a |

*mar 22: pre-userId events (launch day spike). mar 25: no drift traffic as of 08:05 CST.

## Referrer Breakdown (7 days)

| referrer | events | users |
|----------|--------|-------|
| drift internal | 715 | 16 |
| nowherelabs.dev | 439 | 24 |
| old vercel URL (308 redirect) | 110 | 0 |
| drift discover | 73 | 2 |
| static fm | 54 | 6 |
| google organic | 41 | 3 |
| dashboard | 28 | 3 |

Google organic: all 30 hits are brand searches, no long-tail SEO traffic yet.

## Key Metrics for Launch Day Comparison

- total events (7d): 2,853
- unique users (7d): ~39 (nowherelabs.dev has most unique users)
- drift avg session duration: 158s (engaged users)
- drift sessions/day (organic): ~18 (declining from 316 on day 1)
- cross-product navigation: active (discover, dashboard, static fm referrals)
- dev pollution: 0 events in 24h (but filter not deployed)

## PH Launch Success Criteria (from Near's research, T-6)

| metric | target | source |
|--------|--------|--------|
| upvotes (24h) | 300-500 | category ceiling for ambient tools |
| upvotes (4h) | 100+ | 82% top-10 rate at this threshold |
| comments | 60-100 | 1:5 to 1:10 comment-to-upvote ratio |
| POTD rank | #4-#7 | realistic for category on tuesday |
| closest comparable | midlife engineering (441 upvotes, #4, tuesday) | feb 2025 |

Critical window: 12:01-4:00 AM PT march 31. First 4 hours decide ranking.

## Notes

- track.js dev filter (PR #18) merged but not deployed. any team dev sessions still pollute data
- PH launch link goes directly to app.html with preset mix, bypassing landing page CTA funnel
- launch day analysis should focus on: UTM attribution, layer activations, time-on-page, save/share rate
- this baseline will be compared against T-1 snapshot and launch day data
- featuring rate is ~10% (down from 60-98%). editorial gate is the real risk, not timing
