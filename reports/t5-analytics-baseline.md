---
title: T-5 Analytics Baseline
date: 2026-03-26
type: report
scope: analytics
summary: Pre-launch baseline snapshot at T-5, compared against T-6. For tracking trend into PH launch (March 31).
---

# T-5 Analytics Baseline — 2026-03-26 ~01:30 CST

## 7-Day Totals by Product

| product | events | users | sessions | avg duration (s) | T-6 events | delta |
|---------|--------|-------|----------|-------------------|------------|-------|
| drift | 1,497 | 20 | 249 | 135 | 1,549 | -3.4% |
| nowhere-labs | 515 | 42 | 232 | 721* | 597 | -13.7% |
| static fm | 450 | 21 | 104 | 256 | 457 | -1.5% |
| dashboard | 76 | 7 | 26 | 23 | 73 | +4.1% |
| pulse | 59 | 3 | 37 | 22 | 65 | -9.2% |
| letters | 54 | 5 | 44 | 2 | 64 | -15.6% |
| chat | 24 | 2 | 17 | 139 | 24 | 0% |
| wallpaper | 12 | 7 | 7 | 8 | 11 | +9.1% |
| building | 12 | 2 | 8 | 17 | 13 | -7.7% |

*nowhere-labs 721s avg still inflated by dev sessions (track.js dev filter merged but not deployed)

**Total events (7d): 2,699** (down from 2,853 at T-6, -5.4%)

Expected: the 7-day window is rolling, so the big mar 22 spike is aging out. Organic daily traffic is stable at 79-87 drift events/day.

## Drift Daily Trend

| day | events | users | sessions | pageviews | avg duration (s) |
|-----|--------|-------|----------|-----------|-------------------|
| mar 21 | 418 | 0* | 110 | 151 | n/a |
| mar 22 | 585 | 0* | 227 | 281 | n/a |
| mar 23 | 457 | 12 | 24 | 41 | 91 |
| mar 24 | 87 | 5 | 11 | 12 | 320 |
| mar 25 | 79 | 6 | 10 | 14 | 59 |

*pre-userId events. mar 21-22 are the initial launch spike.

Post-spike stabilization: ~80 events/day, 5-6 users/day, 10-11 sessions/day. This is the organic baseline. PH should spike this 10-50x if we hit 300+ upvotes.

## Today (T-5, March 25)

| product | events | users | sessions |
|---------|--------|-------|----------|
| drift | 79 | 6 | 10 |
| nowhere-labs | 31 | 12 | 14 |
| static fm | 22 | 2 | 5 |
| pulse | 7 | 2 | 2 |
| letters | 6 | 2 | 2 |
| dashboard | 3 | 2 | 2 |
| wallpaper | 1 | 1 | 1 |

## Referrer Breakdown (7 days)

| source | events | users |
|--------|--------|-------|
| direct | 1,220 | 76 |
| drift internal | 926 | 17 |
| nowherelabs.dev | 606 | 30 |
| old vercel URL (308 redirect) | 110 | 0 |
| google organic | 41 | 3 |
| static fm | 31 | 1 |
| old drift vercel URL | 26 | 2 |
| vercel.com | 7 | 1 |
| t.co (X/Twitter) | 3 | 0 |

New since T-6: t.co referrals appearing (3 events). X content queue is generating some traffic. Google organic still all brand searches (41 hits, 3 users).

## Layer Popularity (7 days, 749 total activations)

| rank | layer | activations | % of total |
|------|-------|-------------|------------|
| 1 | rain | 94 | 12.5% |
| 2 | fire | 84 | 11.2% |
| 3 | wind | 72 | 9.6% |
| 4 | snow | 58 | 7.7% |
| 5 | cafe | 55 | 7.3% |
| 6 | vinyl | 51 | 6.8% |
| 7 | train | 49 | 6.5% |
| 8 | drone | 47 | 6.3% |
| 9 | leaves | 37 | 4.9% |
| 10 | brown-noise | 36 | 4.8% |
| 11 | birds | 31 | 4.1% |
| 12 | heavy-rain | 28 | 3.7% |
| 13 | thunder | 27 | 3.6% |
| 14 | crickets | 25 | 3.3% |
| 15 | waves | 22 | 2.9% |
| 16 | white-noise | 16 | 2.1% |
| 17 | binaural | 9 | 1.2% |
| 18-22 | new layers* | 8 | 1.1% |

*keyboard (3), wind-chimes (2), distant-traffic (1), gentle-thunder (1), creek (1). PR #30 layers just deployed, very early data.

Top 5 (rain/fire/wind/snow/cafe) account for 48.3% of all activations. Stable since T-6.

## Event Funnel (7 days)

| event | count | notes |
|-------|-------|-------|
| pageview | 1,191 | top of funnel |
| layer_activate | 749 | 62.9% activation rate |
| page_exit | 327 | tracked sessions |
| scroll_depth | 264 | mostly landing/homepage |
| preset_load | 135 | quick-start usage |
| weather_switch | 128 | static fm engagement |
| outbound_click | 73 | leaving the ecosystem |
| cta_click | 11 | 0.9% CTA rate |
| mix_share | 5 | 0.4% share rate |
| landing_conversion | 5 | landing -> app conversion |
| save_mix | 2 | |
| mix_publish | 1 | |

**Viral loop: still not firing.** 5 shares / 1,191 pageviews = 0.4% share rate. Zero shared_mix_view events means no one is clicking shared links. This is the #1 post-launch optimization target.

**CTA rate dropped:** 0.9% (11/1,191) vs 2.2% at T-6. Landing page CTA is underperforming. Most users come direct to app.html (PH link bypasses landing), so this metric is less important for launch day.

## Key Comparison: T-6 vs T-5

| metric | T-6 | T-5 | trend |
|--------|-----|-----|-------|
| total events (7d) | 2,853 | 2,699 | declining (spike aging out) |
| drift events/day (organic) | ~18 sessions | ~10 sessions | stabilizing lower |
| unique users (7d) | ~39 | ~42 (nowherelabs) | slight growth |
| layer activations | not measured | 749 | new baseline |
| share rate | 0.7% | 0.4% | declining (low sample) |
| google organic | 41 brand | 41 brand | flat |
| X referrals | 0 | 3 | new signal |

## Verified Carries

- [x] track.js dev filter: PR #18 merged to main, **NOT deployed to production**. Live track.js has zero localhost filtering. Dev sessions still pollute data
- [x] seamless audio: all 5 new files return 200 (keyboard, creek, wind-chimes, gentle-thunder, distant-traffic). Hum independently verified byte-for-byte match
- [x] mobile viewport: 47/48 (up from 44/48 at T-6). Homepage 13px overflow remains — PR #17 merged but not deployed
- [x] deploy status: 25/25 green, 45/45 playwright

## Remaining Deploy Gap

Two PRs merged to main but not live on production:
1. **PR #17** — homepage 13px mobile overflow fix
2. **PR #18** — track.js dev filter (localhost/file:// skip)

Both need vercel to pick up the latest main commit. Not blocking launch but should be verified before March 31.

## Notes for T-1 Snapshot (March 30)

Compare against these T-5 numbers:
- drift organic: ~80 events/day, ~10 sessions, ~6 users
- total 7d events: ~2,700
- share rate: 0.4%
- layer activation rate: 62.9%
- top layers: rain > fire > wind > snow > cafe
- CTA rate: 0.9%
- new layer adoption: watch keyboard/creek/wind-chimes growth
