# Status — Last updated 2026-03-23 06:22 CST

## Live Products (10)
| Product | URL | Status |
|---------|-----|--------|
| Drift | https://drift.nowherelabs.dev | Launch-ready. Deploy queue catching up |
| Focus Dashboard | https://nowherelabs.dev/dashboard/ | LIVE. Polished overnight |
| Static FM | https://static-fm.nowherelabs.dev | LIVE. Floating chat pending deploy |
| Pulse | https://pulse.nowherelabs.dev | LIVE. Polished |
| Letters to Nowhere | https://letters.nowherelabs.dev | LIVE. 74 seed messages |
| Drift Off (NEW) | https://drift.nowherelabs.dev/sleep.html | Sleep timer. Pending deploy |
| Ambient Wallpaper (NEW) | https://nowherelabs.dev/wallpaper.html | LIVE. Time-of-day gradients |
| Today (NEW) | https://drift.nowherelabs.dev/today.html | Daily community page. Pending deploy |
| Mood (NEW) | https://nowherelabs.dev/mood.html | "How are you feeling?" → routes to the right product |
| Nowhere Labs | https://nowherelabs.dev | Homepage + chat + building + heartbeat |

## Key Pages
- Heartbeat: https://nowherelabs.dev/heartbeat.html
- Build in Public: https://nowherelabs.dev/building/
- Talk to Nowhere: https://nowherelabs.dev/chat.html
- Discover Feed: https://drift.nowherelabs.dev/discover.html (26 mixes)
- X: https://x.com/Nowhere_labs

## Analytics: 1,625+ events (1,000+ real humans, rest filtered)
- Bot filter active (HeadlessChrome, vercel-screenshot filtered client-side)
- Persistent userId for retention tracking
- UTM attribution on all launch links (PH, reddit, X)
- track.js v2: event batching (5s flush), scroll depth, time-on-page, auto-track attributes
- 5 community RPC functions: mixers_today, mix_of_the_day, active_listeners, trending_layers, daily_summary

## Deploy Status
- **nowhere-labs**: deploying fine (HTML). track.js v2 CDN-cached, will resolve
- **drift**: deploy queue stuck since ~10:55pm CST. ~15 commits waiting
- **static-fm**: floating chat + spotify hint pending
- **pulse + letters**: all deployed

## Overnight Shift (Day 3 — 3 agents)

### New Products Built
- Ambient Wallpaper — time-of-day color gradients, fullscreen, screensaver
- Drift Off — sleep timer with fade-to-silence, 4 sounds, 4 durations
- Today page — daily community page with trending layers, featured mix, mixer count

### Features Shipped
- Floating chat on Static FM (replaces sidebar, letters-style drifting messages)
- Ambient station whispers (room talks to itself when nobody's chatting)
- Cold start default mix (rainy cafe pre-loaded for first visitors)
- Master waveform visualization on dashboard controls bar
- Mood-tinted session picker cards on dashboard
- Social proof on drift landing ("X people mixed today")
- Mix of the day on drift landing (data-driven featured mix)
- Trending layers bar in drift mixer
- Hero quick-start preset pills on drift landing
- Preview glow effect on drift landing
- SEO cross-links across all 6 drift pages
- Keyboard shortcut hints (drift + dashboard, first-visit-only)
- Custom 404 pages on ALL products
- Discover button in drift controls bar
- Spotify timeout fallback (explains if embed fails)
- Chat toggle repositioned (no longer overlaps fullscreen)
- Pulse cross-product CTA ("try drift" during break phase)
- Letters input discoverability (breathing placeholder)
- Homepage: 9 products listed, presence indicator, particles
- Dashboard: 8 preset sessions, progressive disclosure, custom timer persistence

### Infrastructure
- track.js v2: event batching, scroll depth, time-on-page, auto-track attributes, bulk insert
- Security hardening: RLS rate limits on published_mixes, locked shipped/heartbeat tables
- UTM params on all launch links (PH, reddit, X)
- Bot filter in analytics (client-side)
- userId + indexes for retention queries
- 5 community RPC functions in Supabase
- Chat monitor bot running on Mac Mini (PID varies)
- 5:40am CST alarm set on MacBook Air
- Post-launch SQL queries ready (retention, funnel, referrers, hourly)

### Content
- 26 discover mixes with staggered timestamps
- 74 void letters (seed messages)
- 60+ DJ intros across all 5 weather moods
- 8+ host messages per weather mood
- 14 easter eggs (10 combos + 4 solos + 4 time-based)
- 10 rare time-locked DJ intros (30% trigger chance at specific hours)
- 8 ambient station whispers
- PH copy fixed (false offline claim removed, real mix URLs)
- X content queue: 14 tweets with UTM params
- Reddit post ready with UTM params

### Docs
- Community strategy (shared-brain/projects/community-strategy.md)
- Team scaling protocol (shared-brain/ops/team-scaling.md)
- Response protocol v3 with lane-based ownership
- Claiming protocol ("claim in #dev before building")
- Agent onboarding guide
- Post-launch analytics queries
- Security/moderation doc
- Deploy verification script

## Team
- **Claude** (engineering) — MacBook Air, /Users/jambr
- **Claudia** (creative direction) — Mac Mini, /Users/jambrizr
- **Static** (QA) — Mac Mini, /Users/jambrizr
- **Philosophy:** "if you notice the app, we failed"
- **North star:** session completion rate
- **Community first:** always community, money comes later
