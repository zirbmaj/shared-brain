# Launch Day Playbook — Tuesday PH Launch

## Timeline (CST)
- **Monday night:** jam submits PH listing with direct app link + UTM params
- **2:00am Tuesday:** PH listing goes live (midnight PT)
- **6:00am:** morning check — run verify-deploy.sh, check analytics for early traffic
- **8:00am-12:00pm:** PH morning browse window. peak discovery period
- **11:00am:** post reddit thread (r/ambientmusic first, r/productivity 2 hours later)
- **9:00pm-11:00pm:** evening wave. post X content. drift's natural peak hours

## Roles During Launch

### Claude (engineering)
- Monitor analytics in real time via Supabase queries
- Fix bugs immediately when reported (code lane)
- Post hourly traffic updates to #dev
- Respond to technical questions in Talk to Nowhere chat

### Claudia (creative direction)
- Respond to PH comments (voice of the brand)
- Post in reddit threads (helpful, not promotional)
- Fix CSS/design issues reported by users
- Update building page with launch-day milestones

### Static (QA)
- Run launch-monitor.sql queries every 30 minutes
- Post conversion funnel data to #dev
- Verify every page works under traffic
- Flag any performance degradation immediately

## Critical Links (with UTM)
- **PH:** `drift.nowherelabs.dev/app?mix=eyJyYWluIjo2MCwiY2FmZSI6NDUsInZpbnlsIjoyMH0=&utm_source=producthunt&utm_medium=launch`
- **Reddit:** `drift.nowherelabs.dev?utm_source=reddit&utm_medium=post`
- **X:** `drift.nowherelabs.dev?utm_source=twitter&utm_medium=social`

Note: using clean URLs (no .html) until cleanUrls revert deploys

## Metrics to Watch
1. **Events per minute** — is traffic real and growing?
2. **UTM source split** — PH vs reddit vs X vs organic
3. **Landing → app conversion** — are people clicking "Start Mixing"?
4. **App → interaction** — are they actually mixing?
5. **Session duration** — are they staying?
6. **Share/publish rate** — are they sharing?
7. **Return visitors** — does anyone come back? (userId tracking)

## If Things Break
- **Site down:** check Vercel dashboard, check Cloudflare, check Supabase status
- **Audio not playing:** likely browser autoplay restriction. nothing we can fix
- **Spotify not working:** third-party cookies or embed rate limit. show the timeout fallback message
- **Analytics not tracking:** check if track.js is loading (curl the live URL)
- **Chat not responding:** check monitor process (`ps aux | grep monitor`), restart if needed

## If Things Go Well
- Post milestone updates to X ("100 people mixed in the first hour")
- Update the building page shipped section with launch stats
- Engage genuinely in PH comments — answer every question
- Don't celebrate too early. keep building. the launch is the beginning, not the end

## What NOT to Do on Launch Day
- Don't push major code changes during peak traffic
- Don't restructure URLs or change configs
- Don't respond to negative feedback defensively
- Don't spam PH comments with links
- Don't stop monitoring after the first hour — the long tail matters
