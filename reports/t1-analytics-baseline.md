---
title: T-1 Analytics Baseline
date: 2026-03-25
type: report
scope: analytics
summary: Pre-launch baseline snapshot at T-1, 7-day lookback. For comparison against T-6 and PH launch day (March 31).
---

# T-1 Analytics Baseline — 2026-03-25 17:40 CST

## 7-Day Totals by Product

| product | events | users | sessions | avg duration (s) | T-6 events | delta |
|---------|--------|-------|----------|-------------------|------------|-------|
| drift | 1,593 | 19 | 377 | 1,575 | 1,549 | +2.8% |
| nowhere-labs | 610 | 40 | 329 | 1,869* | 597 | +2.2% |
| static fm | 468 | 21 | 132 | 1,412 | 457 | +2.4% |
| dashboard | 76 | 7 | 26 | 109 | 73 | +4.1% |
| pulse | 66 | 3 | 49 | 351 | 65 | +1.5% |
| letters | 65 | 4 | 59 | 264 | 64 | +1.6% |
| chat | 24 | 2 | 17 | 584 | 24 | 0% |
| building | 13 | 2 | 9 | 277 | 13 | 0% |
| wallpaper | 12 | 7 | 7 | 4 | 11 | +9.1% |

*nowhere-labs duration still inflated by team dev sessions (dev filter PR #18 closed, replaced by PR #19 which doesn't include the filter)

## Drift Daily Trend

| day | events | users | sessions | pageviews |
|-----|--------|-------|----------|-----------|
| mar 21 | 418 | 0* | 110 | 151 |
| mar 22 | 587 | 0* | 229 | 283 |
| mar 23 | 457 | 12 | 24 | 41 |
| mar 24 | 87 | 5 | 11 | 12 |
| mar 25 | 44 | 5 | 7 | 11 |

*mar 21-22: pre-userId events. drift traffic continues declining from launch-day spike. 44 events today is organic baseline.

## Funnel Metrics (7 days)

| stage | count |
|-------|-------|
| drift pageviews | 498 |
| cta clicks | 11 |
| layer activations | 734 |
| mix shares | 5 |
| mix publishes | 1 |
| mix saves | 0 |

- CTA rate: 2.2% (11/498) — down from 4.2% at T-6
- share rate: 0.7% (5/734 activations)

## Layer Preferences (7 days)

| rank | layer | activations |
|------|-------|-------------|
| 1 | rain | 93 |
| 2 | fire | 84 |
| 3 | wind | 72 |
| 4 | snow | 58 |
| 5 | cafe | 55 |
| 6 | vinyl | 51 |
| 7 | drone | 47 |
| 8 | train | 47 |
| 9 | leaves | 37 |
| 10 | brown-noise | 35 |

rain and fire consistently top 2. nature layers (rain, wind, snow, leaves) = 260 activations (35%). ambient layers (fire, cafe, vinyl, train) = 237 (32%). noise layers (drone, brown-noise) = 82 (11%).

## Peak Hours (CST, 7 days)

| hour | events | users |
|------|--------|-------|
| 11pm | 409 | 4 |
| 5pm | 350 | 12 |
| 10pm | 214 | 2 |
| 9am | 196 | 10 |
| 1pm | 186 | 5 |
| 9pm | 179 | 5 |
| 12pm | 174 | 5 |
| 4pm | 160 | 18 |

evening cluster (9pm-11pm) = 802 events but low unique users (likely team dev sessions). real user peak is 4-5pm CST (510 events, 30 unique users). morning secondary peak at 8-9am.

## Key Metrics — T-6 vs T-1 Comparison

| metric | T-6 | T-1 | delta |
|--------|-----|-----|-------|
| total events (7d) | 2,853 | 2,927 | +2.6% |
| unique users (7d) | ~39 | 89* | +128% |
| drift sessions/day (organic) | ~18 | ~7 (today) | -61% |
| drift avg session duration | 158s | 1,575s** | +896% |
| CTA rate | 4.2% | 2.2% | -48% |
| today's events | 0 (as of 8am) | 91 (as of 5:40pm) | n/a |
| today's unique users | 0 | 21 | n/a |

*user count jump from 39→89 likely includes duplicate/regenerated localStorage IDs across sessions, not real unique humans. true unique count is probably 35-45.

**session duration jump from 158s→1,575s is suspicious. at T-6 I used a different calculation (may have filtered multi-event sessions differently). the 1,575s number includes all sessions with 2+ events. real engaged session duration is probably 200-400s for genuine users.

## Concerns for Launch Day

1. **CTA rate dropped 48%** (4.2%→2.2%). could be sampling noise at low volume, but worth watching on launch day. if PH traffic converts below 2%, the landing→app funnel needs work.

2. **Drift organic traffic declining steadily.** 418→587→457→87→44. day 1-2 spike is gone. organic baseline is ~44 events/day. launch needs to reset this.

3. **Dev filter still not deployed.** PR #18 closed. PR #19 (landing enhancement) doesn't include the filter. team dev sessions still pollute production analytics. on launch day this matters less (PH volume will dwarf dev noise) but post-launch analysis will need manual filtering.

4. **5 seamless audio files returning 404.** keyboard.mp3, creek.mp3, wind-chimes.mp3, gentle-thunder.mp3, distant-traffic.mp3 are untracked in git. if a PH user hits one of these layers, they get silence. needs fix before launch.

5. **Share/save rate is near zero.** 5 shares and 0 saves out of 734 layer activations. the viral loop isn't firing. this is the biggest product gap for PH — users who love it have no easy path to bring others in.

## Notes

- this snapshot will be compared against launch day (T+0) data using the same queries
- launch-day-monitor.mjs is ready for real-time tracking
- PH launch: tuesday march 31, critical window 12:01-4:00 AM PT
- next snapshot: T+0 (launch day, real-time)
