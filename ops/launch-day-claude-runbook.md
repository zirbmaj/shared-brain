---
title: claude launch day runbook
date: 2026-03-24
type: reference
scope: claude
summary: my specific commands and queries for PH launch day monitoring (march 31)
---

# Claude Launch Day Runbook — March 31

## My Role
- Monitor analytics in real time
- Fix bugs immediately when reported
- Post hourly traffic updates to #dev
- Respond to technical questions in Talk to Nowhere chat

## Quick Commands

### Check analytics (run every 15 min during peak)
```sql
-- via Supabase MCP
SELECT get_launch_day_stats(1);  -- last hour
SELECT get_launch_day_stats(24); -- full day
```

### Check product health
```bash
cd ~/static-workspace && node tests/all-products.mjs
```

### Check deploy status
```bash
cat /tmp/verify-alerts.log | tail -20
```

### Check chat monitor
```bash
ps aux | grep monitor.js | grep -v grep
```

### Hourly update template for #dev
```
**hour [N] update:**
- events: [X] (last hour) / [Y] (total today)
- unique visitors: [Z]
- PH referrals: [N]
- top layers: [list]
- issues: [none / description]
- PH engagement: [layer activations] / [saves] / [shares]
```
Note: PH visitors land directly in app.html (skip landing page), so CTA funnel
doesn't capture PH traffic. Track UTM attribution + in-app engagement instead.

## If Things Break

### Site down
1. Check deploy status: `cat /tmp/verify-alerts.log | tail -5`
2. Check heartbeat table via Supabase MCP
3. Flag in #dev immediately

### Audio not playing
- Browser autoplay restriction — can't fix remotely
- Check if AudioContext.resume() is firing (CDP if Hum's tool is ready)

### Analytics not tracking
```bash
curl -sL https://drift.nowherelabs.dev/app.html | grep -c 'track.js'
```
Then check Supabase for recent events:
```sql
SELECT COUNT(*) FROM analytics_events WHERE created_at > NOW() - interval '5 minutes';
```

### Chat monitor down
```bash
ps aux | grep monitor.js
# If not running:
# Ask jam to restart: node ~/chat-monitor/monitor.js
```

## Key URLs
- Ops dashboard: https://nowherelabs.dev/ops
- Analytics: https://nowherelabs.dev/analytics (15s auto-refresh, use TODAY/1H/15M buttons)
- PH link: drift.nowherelabs.dev/app.html?mix=eyJyYWluIjo2MCwiY2FmZSI6NDUsInZpbnlsIjoyMH0=&utm_source=producthunt&utm_medium=launch

## Code Freeze Rules
- 8am-noon CST: hotfixes only, no features
- All changes via branch + PR + Static review
- Pre-commit hook blocks direct-to-main
