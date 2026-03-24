---
title: launch day playbook — tuesday ph launch
date: 2026-03-24
type: reference
scope: shared
summary: timeline, roles, and checklists for the product hunt launch on march 31, 2026.
---

# Launch Day Playbook — Tuesday PH Launch (March 31, 2026)
*Updated session 7: launch moved to tuesday march 31 per near's competitive research — 0% friday top-5 rate, no PH newsletter on fridays. tuesday has highest success rate.*

## Timeline (CST)
- **Monday night (march 30):** jam submits PH listing with direct app link + UTM params
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

### Static (QA / CTO)
- Run launch-monitor.sql queries every 15 minutes during peak (8am-noon CST), every 30 minutes otherwise
- Post conversion funnel data to #dev
- Verify every page works under traffic
- Flag any performance degradation immediately

### Relay (ops)
- Pre-launch verification: run full checklist morning of, confirm all items pass
- Monitor team coordination — one voice per PH comment thread, no duplicate responses
- Track deploy count against Vercel free tier limit (100/day). no unnecessary pushes on launch day
- Enforce code freeze during peak traffic (8am-noon). hotfixes only, no features
- Post process status updates to #dev every hour
- Escalate to jam via DM if anything breaks that the team can't fix

### Near (research)
- Monitor PH comments for competitive mentions and user sentiment
- Track PH ranking position throughout the day
- Watch reddit threads for engagement patterns
- Post insights to #dev — what's resonating, what's not

### Hum (audio)
- Monitor for audio-related user complaints in PH comments and chat
- Verify audio quality is consistent under traffic
- Be ready to hot-swap audio assets if quality issues are reported

## PH Comment Triage Protocol (added session 8)
*Three agents independently flagged this gap. Here's the ownership model.*

**Flow:** PH comment → Near reads + categorizes → routes to lane owner → owner responds/fixes

| Comment Type | First Responder | Backup |
|-------------|-----------------|--------|
| "How is this different from X?" | Claudia (brand voice) | Near (competitive data) |
| Bug report / "X doesn't work" | Claude (diagnose + fix) | Static (verify) |
| Audio complaint | Hum (diagnose) | Claude (fix) |
| Feature request | Near (log + synthesize) | Claudia (acknowledge) |
| "How was this built?" / AI questions | Claudia (story) | Claude (technical details) |
| Pricing / business model | Claudia | jam (escalate if needed) |
| Generic praise | Claudia (thank + engage) | — |

**Rules:**
- One response per comment thread. No pile-ons
- Respond within 15 minutes during peak (8am-noon CST)
- Near posts sentiment summary to #dev every hour
- Log all feature requests to shared-brain/projects/user-feedback/
- Jam responds to the maker first comment thread personally

## Session 5 Additions
- **Launch day analytics dashboard** at nowherelabs.dev/analytics.html — real-time unique visitors, PH referral tracking, landing funnel, 15s auto-refresh. this is the view to watch march 31
- **Landing funnel tracking** — `landing_conversion` events fire on CTA/quickstart clicks with `previewed: true/false`. query supabase for preview→conversion correlation
- **Audio normalized** — 36.5 LUFS spread fixed, LFO zero-volume bug fixed, fade-in on all layers. audio is clean for launch
- **Discord plugin fork** ready — if bot filter breaks during launch, we have a fallback
- **Process docs current** — all 5 stale docs updated for 6-agent team. on-ramp/offramp v2 in place

## Critical Links (with UTM)
- **PH:** `drift.nowherelabs.dev/app.html?mix=eyJyYWluIjo2MCwiY2FmZSI6NDUsInZpbnlsIjoyMH0=&utm_source=producthunt&utm_medium=launch`
- **Reddit:** `drift.nowherelabs.dev?utm_source=reddit&utm_medium=post`
- **X:** `drift.nowherelabs.dev?utm_source=twitter&utm_medium=social`

Note: all internal links use .html extensions (cleanUrls reverted after the 308 incident)

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
