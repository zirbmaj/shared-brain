---
title: PH Launch Day Competitor Check — Playbook
date: 2026-03-31
author: near
type: playbook
scope: nwl
target_date: 2026-04-07
---

# PH Launch Day Competitor Check — April 7, 2026

## Purpose
Execute a rapid competitive scan on launch morning to confirm the category is still clear and identify any same-day threats to visibility. Findings feed directly to jam for go/no-go and positioning adjustments.

## Pre-Launch (T-1 to T-3) — Near executes

### 1. Category Scan
- [ ] Search PH "upcoming" for ambient/sound/focus products scheduled April 5-9
- [ ] Check PH "coming soon" pages for any ambient/soundscape entries
- [ ] Search Twitter/X for "#producthunt april 7" to see what's teasing
- [ ] Check r/ProductHunt for scheduled launch threads

### 2. Competitor Pulse Check
- [ ] Brain.fm — any new features, pricing changes, or PH activity
- [ ] Noisli — status check (was declining in March scan)
- [ ] Endel — any launches, partnerships, or PH plans
- [ ] myNoise — any major updates
- [ ] Moodist — growth trajectory, any PH plans (identified as rising in March)
- [ ] Any new entrants found in weekly scans

### 3. PH Climate Assessment
- [ ] What category is dominating PH this week? (AI tools, dev tools, other)
- [ ] Average upvotes for Top 5 products in the last 7 days
- [ ] Any "Product of the Week" patterns that suggest favorable/unfavorable timing

## Launch Morning (T-0, ~5:00 AM PT) — Near executes

### 4. Same-Day Threat Scan (15-min execution)
- [ ] Check PH homepage for all products launching today
- [ ] Identify any product with >50 upvotes in first hour (potential #1 threat)
- [ ] Flag any audio/wellness/focus products launching same day
- [ ] Check if any well-funded startup or known brand is launching

### 5. Positioning Report (deliver to jam by 5:30 AM PT)
Format:
```
## April 7 Launch Morning — Competitive Brief
- Category status: [CLEAR / CONTESTED / CROWDED]
- Same-day threats: [list or "none"]
- Top competitor today: [name, category, early traction]
- Upvote benchmark: [number needed for Top 5 based on recent data]
- Recommendation: [go / go with positioning adjustment / delay]
```

## Post-Launch (T+1 to T+3) — Near monitors

### 6. Performance Tracking
- [ ] Drift's upvote count at +1h, +4h, +8h, +24h
- [ ] Ranking position at same intervals
- [ ] Any competitor response (copycat launches, feature announcements)
- [ ] Social mentions and sentiment

### 7. Debrief Report (T+3)
- What worked in the launch positioning
- What the competitive landscape looked like on the day
- Lessons for future launches
- Category trends observed

## Decision Framework

| Scenario | Action |
|----------|--------|
| No ambient products, normal PH day | GO — standard launch |
| No ambient products, major AI launch dominating | GO — we're the non-AI differentiation |
| Direct competitor launching same day | ESCALATE to jam — may need positioning pivot |
| PH is down or having issues | DELAY — notify jam immediately |
| Upvote benchmark suggests >500 needed for Top 5 | GO but set realistic expectations |

## Dependencies
- Near: executes all scans and delivers reports
- Jam: final go/no-go based on brief
- Claude: ready to deploy any last-minute positioning changes
- Static: launch-day monitor running (tests/launch-day-monitor.mjs)
- Claudia: PH gallery shots current

## Data Sources
- Product Hunt homepage + upcoming page
- Twitter/X search (#producthunt, competitor handles)
- r/ProductHunt subreddit
- Competitor websites directly
- Google News (ambient sound app, focus music)
- Previous scans: shared-brain/reports/t1-competitive-scan.md
