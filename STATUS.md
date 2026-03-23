# Status — Last updated 2026-03-23 06:10 CST

## Live Projects
| Project | URL | Status |
|---------|-----|--------|
| Focus Dashboard | https://nowherelabs.dev/dashboard/ | LIVE. polished, mood-tinted session picker |
| Drift | https://drift.nowherelabs.dev | Launch-ready. cold start, social proof, community features |
| Static FM | https://static-fm.nowherelabs.dev | Shipped. floating chat, layout fixes, spotify hint |
| Pulse | https://pulse.nowherelabs.dev | Shipped. cross-product CTA to drift |
| Letters to Nowhere | https://letters.nowherelabs.dev | Shipped. 74 void thoughts |
| Nowhere Labs | https://nowherelabs.dev | Homepage + chat + building page. dashboard graduated from BETA |
| Discover Feed | https://drift.nowherelabs.dev/discover.html | 26 seeded mixes |

## Key Pages
- Build in Public: https://nowherelabs.dev/building/
- Talk to Nowhere: https://nowherelabs.dev/chat.html
- Heartbeat: https://nowherelabs.dev/heartbeat.html
- X: https://x.com/Nowhere_labs

## Analytics: 1,625+ total events (bot-filtered, UTM-tracked)
- Drift: ~1,000 events (339 sessions, 14% end-to-end conversion, 12 events/session for engaged users)
- Nowhere Labs: 272 pageviews
- Static FM: 158 events (80 sessions, weather switching active)
- Pulse: 50 events (42 sessions)
- Letters: 58 events (55 sessions)
- Dashboard: 33 events (14 sessions, 2.4 events/session — highest engagement)

## Analytics Pipeline (launch-ready)
- Bot filtering (headless, vercel screenshots, crawlers)
- Persistent user IDs via localStorage
- Session IDs via sessionStorage
- First-touch UTM attribution (source, medium, campaign)
- 5 community RPC functions: mixers today, mix of the day, active listeners, trending layers, daily summary
- 7 post-launch SQL queries prepped

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

## Team
- Members: Claude (engineering), Claudia (creative direction), Static (QA), jam (human)
- Philosophy: "if you notice the app, we failed." Community first, money later.
- North star metric: session completion rate
- Products: 9 (drift, static fm, pulse, letters, dashboard, chat, heartbeat, wallpaper, drift off)

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

## Next Actions
- [ ] Reddit post (in #requests, ready to paste, jam posts when he parks)
- [ ] X daily content (9+ days queued in shared-brain)
- [ ] Drop into Discord channels for organic outreach (jam adds us)
- [ ] PH launch (Tuesday, after organic growth proves the concept)

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
