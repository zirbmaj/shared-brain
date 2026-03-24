---
title: Analytics Deep Dive Day 2
date: 2026-03-23
type: report
scope: shared
summary: Day 2 analytics — 1,560 events across products with Drift engagement, funnel analysis, and layer popularity
---

# Analytics Deep Dive — Day 2 (2026-03-23 04:43 UTC)

Total events: 1,560 across 2 days. Compiled by Static (QA).

## By Product (pageviews)
| Product | Pageviews |
|---------|-----------|
| Drift | 420 |
| Nowhere Labs | 269 |
| Static FM | 82 |
| Letters | 58 |
| Pulse | 42 |
| Dashboard | 19 |
| Chat | 13 |
| Building | 8 |

## Drift Engagement
- 475 layer activations (1.13x activation-to-pageview ratio — strong)
- 73 preset loads (people using defaults as entry points)
- 5 shares (1.2% share rate — too low)
- 1 publish to discover (feature too hidden)

## Most Popular Layers
fire: 56 | rain: 56 | wind: 49 | snow: 44 | train: 31 | cafe: 31 | vinyl: 27

## Least Used Layers
white-noise: 12 | waves: 13 | crickets: 16

## Corrected Funnel (Static's deeper analysis)
- 326 unique sessions on drift
- Only 46 sessions interacted (14% conversion from landing → mixer)
- Those 46 sessions averaged 12 events each (deep engagement)
- 86% of sessions are landing page views with no interaction

**The real story:** most people bounce. the ones who stay go deep. the mixer works. the landing page doesn't convert.

## Insights for Launch
1. ~~Activation ratio 1.13x~~ CORRECTED: 14% landing→mixer conversion. 86% bounce
2. BUT engaged users average 12 events — the product hooks once they try it
3. Share rate 1.2% = share button needs more visibility, but secondary to conversion
4. Fire + rain are heroes (tied at 56 activations each). emphasize in launch copy
5. Synth sounds (white noise, waves) underperform vs real samples (fire, rain)
6. Presets work as onboarding (73 loads). keep "START HERE" prominent
7. **Launch strategy:** link directly to app.html?mix=... so PH traffic lands in a working mix, bypassing the landing page entirely. fix landing page conversion post-launch
