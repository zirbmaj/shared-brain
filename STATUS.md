---
title: team status
date: 2026-03-24
type: log
scope: shared
summary: live products, analytics, team state, shipped items — updated each session
---

# Status — Last updated 2026-03-26 03:18 CST

*Full backlog at shared-brain/ops/consolidated-backlog.md — that's the source of truth, not this file.*

## Live Projects
| Project | URL | Status |
|---------|-----|--------|
| Focus Dashboard | https://nowherelabs.dev/dashboard/ | LIVE. polished, mood-tinted session picker |
| Drift | https://drift.nowherelabs.dev | Launch-ready. audio normalized, LFO fix, fade-in, funnel tracking |
| Static FM | https://static-fm.nowherelabs.dev | Shipped. floating chat, footer fix, audio clean |
| Pulse | https://pulse.nowherelabs.dev | Shipped. audio clean, no changes needed |
| Letters to Nowhere | https://letters.nowherelabs.dev | Shipped. 74 void thoughts |
| Nowhere Labs | https://nowherelabs.dev | Homepage + chat + launch day analytics dashboard |
| Discover Feed | https://drift.nowherelabs.dev/discover.html | 40 mixes, sort toggle |

## Key Pages
- Build in Public: https://nowherelabs.dev/building/
- Talk to Nowhere: https://nowherelabs.dev/chat.html
- Heartbeat: https://nowherelabs.dev/heartbeat.html
- X: https://x.com/Nowhere_labs

## Analytics: 2,927 total events (T-1 baseline, bot-filtered, UTM-tracked)
- Drift: 1,593 events (377 sessions, 19 users, CTA rate 2.2%)
- Nowhere Labs: 610 events (329 sessions, 40 users)
- Static FM: 468 events (132 sessions, 21 users)
- Dashboard: 76 events (26 sessions, 7 users)
- Pulse: 66 events (49 sessions, 3 users)
- Letters: 65 events (59 sessions, 4 users)
- Top layers: rain (93), fire (84), wind (72), snow (58), cafe (55)
- Share rate: 0.7% (5/734 activations) — viral loop not firing, post-launch optimization target
- T-1 baseline: shared-brain/reports/t1-analytics-baseline.md
- Launch monitor: tests/launch-day-monitor.mjs (T-1 baseline constants set)

## Session 10 Shipped (2026-03-25, T-6)
- **PR conflict resolved:** static-fm #17 merged, #18 closed, #19 created clean (weather hint + listener count)
- **5 missing audio files:** keyboard, creek, wind-chimes, gentle-thunder, distant-traffic committed (PR #30)
- **Landing CTA + productive cafe:** PR #29 merged
- **SVG viewport fix:** PR #31 merged (48/48 mobile viewport target)
- **track.js dev filter:** already on main (more complete version, filters localhost + vercel previews)
- **Launch infra verified:** get_launch_day_stats RPC tested, ph_upvotes clean, correlation view ready
- **Mission control:** tunnel live, auth working
- **22-layer copy sweep:** all customer-facing references updated from 17 to 22 (Claudia)
- **PH gallery:** 5 shots retaken from localhost with all merged PRs (Claudia)
- **PH competitive analysis:** no ambient products in march 2026 top 50, category wide open (Near)
- **T-1 analytics baseline:** written to shared-brain/reports/ (Static)
- **Meridian consulting:** SessionStart hook walkthrough delivered, forge built onramp script, plugin bug confirmed + patched
- **AI roadmap consensus:** 4-tier invisible AI plan (mix recommendations → spectral mixing → adaptive programming → session intelligence). Team-wide agreement: AI invisible except in dashboard. Do not touch: letters, pulse, chat, sound generation, DJ voice
- **Nav bug fix:** today.html nav spacing (PR #32, Claudia)
- **All code-complete. All deploy-blocked on vercel.**

## Afternoon Session Shipped (verification mode)
- Shared mix landing: visual level bars + shared_mix_view tracking
- Auto-restore: returning users get last mix from localStorage
- Discover: sort toggle (recent/popular), mix count, 40 seeded mixes
- UTM passthrough: landing page carries attribution to app.html
- Homepage: broken link fixes (.html extensions on sleep, today, support)
- Landing copy: updated for auto-restore feature
- Analytics: viral loop + UTM attribution SQL queries added
- Mobile nav: fixed 10-link wrap to 5-link single line (Claudia)
- Visual QA: full pass on all 10 products (Claudia)
- Interactive testing: deep user flow verification (Static, in progress)
- Team: switched to verification mode, then back to fixing after jam's product feedback

## Jam's Product Feedback (afternoon session, addressed in <20 min)
- Contrast too low across all products — bumped variables on dashboard, drift, static fm, nav
- Dual audio bug: sliding to 0 left synth playing under killed sample — fixed, both engines killed
- Muted state: layers at 0 now show dashed border + "muted" label vs never-touched
- Mood page removed from nav — stays as landing page only
- Static FM chat: moved from bottom-center overlay to bottom-right widget
- Music volume slider added to Static FM (ATMOSPHERE + MUSIC, matching dashboard)
- Spotify login hint added to dashboard ("30s preview · log into spotify for full tracks")
- Sticky nav with backdrop blur on scrollable pages, auto-detected
- Nav link contrast improved (0.15→0.25 opacity)
- Fixed remaining broken .html links (support on drift + static fm)
- Roadmapped: user-hosted stations, multi-platform music, personal vs live mode, dashboard overhaul
- Product direction: discover needs music/beats to be valuable, dashboard is the premium bet

## Analytics Pipeline (launch-ready)
- Bot filtering (headless, vercel screenshots, crawlers)
- Persistent user IDs via localStorage
- Session IDs via sessionStorage
- First-touch UTM attribution (source, medium, campaign)
- 5 community RPC functions: mixers today, mix of the day, active listeners, trending layers, daily summary
- 9 post-launch SQL queries prepped (added viral loop + UTM attribution)

## Night 3 Shipped (static's first shift)
- Team: Static (QA agent) online, full first session
- Security: RLS audit, heartbeat/shipped/published_mixes hardened against anon abuse
- Analytics: bot filter, persistent userId, UTM attribution, 5 community RPC functions
- Drift: cold start default mix (visual-only, audio-safe), discover button in controls, hero quick-start presets, preview glow, SEO cross-links, social proof ("X people mixed today"), mix of the day, trending layers, 15 new discover mixes, time-based easter eggs, custom 404
- Static FM: floating chat (letters-to-nowhere style), layout clipping fixes (overflow + min-height), chat toggle repositioning, spotify hint cleanup, active listener count, 13 new DJ intros
- Dashboard: BETA→LIVE, mood-tinted session picker, fingerprint dots colored by mood, keyboard shortcut hint, mobile tab transitions, master canvas waveform, 3 new sessions
- Letters: void count seeded to 74, input placeholder animation, nowhere labs attribution
- Pulse: cross-product CTA to drift during break phase, custom 404
- Homepage: project card copy sharpened, chat presence flash fix ("checking who's around...")
- Nowhere Labs: OG tags on all products, X content queue UTM-tagged, reddit posts UTM-tagged, PH copy corrected (offline claim removed)
- New products: Ambient Wallpaper (nowherelabs.dev/wallpaper.html), Drift Off sleep timer (drift.nowherelabs.dev/sleep.html), Today on Drift community page (drift.nowherelabs.dev/today.html)
- Docs: community-strategy.md, verify-deploy.sh expanded to 19 checks, response protocol v3, channel usage guide, morning checklist for jam

## Team (6 agents + jam)
- Members: Claude (engineering), Claudia (creative direction), Static (QA), Near (research), Relay (ops/process), Hum (audio engineering), jam (human)
- New hires session 4: Relay and Hum onboarded 2026-03-23
- Philosophy: "if you notice the app, we failed." Community first, money later.
- North star metric: session completion rate
- Products: 9 (drift, static fm, pulse, letters, dashboard, chat, heartbeat, wallpaper, drift off)
- Discover: 40 seeded mixes with sort toggle (recent/popular)

## Day 3 Shipped (the fun zone)
- Chat: typing indicator + presence awareness (supabase chat_presence table)
- Drift: easter eggs (10 combo messages + 4 solo), wind/snow audio differentiation, sound fingerprints on discover cards, play counts
- Static FM: rare time-based DJ intros (10 across all weather modes, 30% trigger chance), CSS polish (@property color transitions), sidebar toggle fix
- Letters: void count ("X thoughts have existed here"), release animation (fade-out before materialize)
- Pulse: tab title timer countdown, idle ring breathing animation
- Dashboard: session picker ambient glow, time-aware completion messages, custom timer persistence
- Homepage: ambient particle drift, presence hint on "talk to us", "built by" tooltip + link
- New pages: heartbeat (vital signs), custom 404 ("you wandered somewhere that doesn't exist yet")
- Building page: auto-populates from supabase `shipped` table
- Infrastructure: letter_count table + RPC, heartbeat tables, shipped table
- Team: Static (QA) joining as third agent

## Session 12 Shipped (2026-03-26, T-5)
- **Stall + permission detection** — server-side mtime polling + screen hardcopy grep, broadcasts to vigil clients. 10min stall → audio + red glow, 15min → spoken cue + coordinator ping. Permission prompt → bronze glow + knock sound
- **Cycling audio** — 3 states (offline, cycling, online) × 6 agents with identity tones. Each agent has unique frequency + waveform
- **Cookie auth** — session cookies on both vigils, no more re-login on tab switch (30-day expiry)
- **Launchd hardening** — both vigil servers as launchd services (auto-restart on crash, start on boot). Watchdog cron every 2 min
- **Meridian vigil fixes** — agent name mapping (axis/forge/lens/locus → shadow-* sidecars), correct websocket token, dynamic X/4 online count, NWL activity data removed
- **"Is back" false positive bugfix** — context-update websocket events were creating partial state, triggering false agent-online sounds on first refresh
- **Claudia access.json fix** — root cause of 4 crashes: corrupted access.json, restored from backup
- **Cache-busting** — app.js + CSS served with no-cache headers + version query params
- **Near restarted** — agent session had died during cycle chain

## Next Actions
- [ ] **Bank account + Lemon Squeezy** — payment infra setup (jam)
- [ ] **PH listing submission** — Monday night March 30 (backlog #7, jam)
- [ ] **PH env vars** — PH_API_TOKEN, PH_POST_SLUG, PH_WEBHOOK_URL (after submission, jam)
- [ ] **PH launch** — Tuesday 2026-03-31. Near: morning-of competitor check
- [ ] **Spotify redirect URI** — backlog #10 (jam)
- [ ] **Chowder auth switch** — switch to sonia's anthropic account (jam)
- [ ] **Vercel pro upgrade** — prevent deploy limit during PH launch day (jam)
- [x] **Vercel deploy** — all 5 repos deployed to production (2026-03-26). backlog #13 done
- [x] **Vigil v2** — real-time ops dashboard with stall/permission detection, 23 audio events, cookie auth, launchd services
- [ ] **Mix recommendations** — post-launch week 1, after 200+ session threshold (claude + static)
- [ ] **Spectral conflict map** — hum measures 231 layer pairs (post-PH)
- [ ] Reddit post (in #requests, ready to paste, jam posts when he parks)
- [ ] X daily content (9+ days queued in shared-brain)

## Day 2 Shipped
- Focus Dashboard: session picker, conductor, UI sounds, phase color shift, tab title timer, graceful session end, session sharing, mobile tabs, 5 default sessions
- Drift: real audio samples (10 MP3s), dual engine, SVG icons, waveform visualization (AnalyserNode), per-layer patterns, slider thumb bob, auto-name saves, share nudge, collapsed mixer with persistence, publish to discover, UI sounds, error boundaries, mix preview overlay
- Discover Feed: published_mixes table, publish button, browse page, 5 seeded mixes, auto-refresh
- Static FM: 15 fresh tracks, 12 new DJ intros, Spotify API hardened
- All Products: CSS polish (4+ passes), mobile layout overhaul, compressed images, READMEs
- Infrastructure: build-in-public page, PHILOSOPHY.md, discord outreach playbook, X content queue (11 days)

## Key Docs
| Doc | Path |
|-----|------|
| Philosophy | PHILOSOPHY.md |
| Roadmap | ROADMAP.md |
| Goals | GOALS.md |
| Audio Architecture | projects/drift/audio-architecture.md |
| Pre-Launch Checklist | projects/drift/pre-launch-checklist.md |
| PH Copy | projects/drift/ph-copy.md |
| Reddit Post | projects/drift/reddit-post.md |
| X Content Queue | projects/x-content-queue.md |
| Discord Outreach | ops/discord-outreach.md |
| Dashboard Wireframe | projects/dashboard-wireframe.md |

## Team
- Name: Nowhere Labs
- Domain: nowherelabs.dev
- Email: hello@nowherelabs.dev
- X: @nowhere_labs
- Credentials: ~/.env.nowherelabs
- Members: Claude (engineering), Claudia (creative direction), Static (QA)
- Philosophy: "if you notice the app, we failed"
- North star metric: session completion rate
