---
title: team status
date: 2026-04-30
type: log
scope: shared
summary: live products, analytics, team state, shipped items — updated each session
---

# Status — Last updated 2026-05-02 08:00 CST

*Full backlog at shared-brain/ops/consolidated-backlog.md — that's the source of truth, not this file.*

## Meridiem Team Status (updated 2026-05-02, trace s146)

### Active Sprint: Station Phase A → COMPLETE. Next: Option A IA spec.
| Item | Status | Notes |
|------|--------|-------|
| Item 1 (inbox Phase 1 migration) | merged | PR #232 merged |
| Item 2 (Mind graph region color refactor) | merged | PR #167 merged, AP#2 closed |
| Item 3 (L1→L2 dive-in transition) | merged | PR #168 merged |
| Item 4 (mission card surface migration) | merged | PR #169 merged |
| Item 5 (Mind graph L2 region content + drag-to-attach) | merged | PR #171 merged |
| Item 6 (3-zone Mission Workspace) | merged | PR #171 merged |
| Item 7 (Lifecycle State Colors) | merged | PR #171 merged |
| Item 8 (Cross-Region L2→L2 Transition) | merged | PR #172 merged 2026-04-30 |
| Item 9 (empty-state copy) | merged | PR #173 merged |
| Item 10 (Mind graph L1 empty state) | merged | PR #174 merged. **Phase A 10/10 COMPLETE.** |

### Fran Decisions (2026-04-30)
- **Option A locked** (dec 3f16415e): everything inside Syght. no satellite products. sygnals.chat / conclave naming retired. sygnals = a syght feature.
- **Account tier model** (dec 22248e61): free/pro/individual (user=org), team/business/enterprise. sygnals+agents scoped: shared (org) or personal (user).
- PRs #297/#298 closed (satellite product work). PRs #299-303 merged.

### Active Work (2026-05-02)
- **sygnals e2e LIVE** ✓ — Discord inbound → sygnals.messages → NOTIFY → adapter → Discord outbound. e2e tested 07:43Z. PRs #344+#345 merged (axis s196).
- **devops migration retry 2** — **COMPLETE** ✓ 6/6 checkpoints PASS. devops data now on meridiem (cilncaebmhrdixofypad). meridiem-db MCP live across 9 workspaces. phase 2 pending: signals tables + 2 cross-scope FKs.
- **PR #308 IA spec** — r5 pushed (channels clarification). locus r6 in progress (correcting 6-tab top-level: Dashboard·Library·Station·Sygnals·Mailbox·Marketplace). mira holding for bundle.
- **mira first-paint spec** — shipped: mira-workspace/design/sygnals-first-paint-spec-2026-05-01.md. 0.9 chrome confidence. A1/A2-agnostic.
- **screenshots** — complete: 11 auth surfaces + public set at ~/meridiem-shared-brain/design/syght-screenshots-2026-04-30/. PR #310.
- **routing bug** — non-axis agents cannot reach fran in axis-zerimar (membership guard). forge task 5dbbcc26, next cycle.
- **PostToolUse hook not firing** — recurring issue, hit axis s195 + axis s196. task 84427e84 queued for forge (audit all workspaces).

### Active Work (2026-05-07)
- **anvil: CF Worker repoint** (task 147f6d68) — lens PASS. PR #3 ready to merge + deploy. needs CF secrets set + wrangler deploy + live verify (email to locus@meridiem.dev). unblocks locus spike #2 phase 2.
- **anvil: agent avatars** (task 4e243010) — 13 PNGs deployed to nwl-mini vigil-meridian/avatars/. PR #390 open. pending: mira 24px acceptance + lens QA gate.
- **lens: PR #389 review** — sygnals-export contract spec (locus s218). spec review: consistency, 3 read modes, capability negotiation.
- **fran decision pending** (sig:be4f1e97) — agent_name UUID stability (§12 sygnals-export spec): add sygnals.agent_identities table before read-port ships?

### Queued Next
- **locus: IA rethink** (task cb808479) — channels + missions + stations + chat coexistence spec. fran: "may need to rethink how channels and missions and stations work with all of that."
- **locus: sygnals-export contract spec** (task f6035743) — **SHIPPED** ✓ branch locus/s218-sygnals-export-contract, file projects/specs/2026-05-07-sygnals-export-contract-spec.md. 14 sections + decision log. 2 storage invariant gaps flagged for forge: channel_members.left_at + agent_name stability.

### Blockers (awaiting fran)
- **A1/A2 Sygnals IA verdict** — PR #308 r6 pending. two open design items: role-pill suppression rule + channel-creation routing model (0.7 confidence).
- **DIRECT_DB_URL** — discord-adapter on Hetzner broken; LISTEN always fails (tasks e8c5998b, be8c6555, 78aa9ef8)
- **channel_messages per-user state** — per-column vs junction table decision (task d3878da1)
- **freak animation scroll-parallax count** — 4 assigned, rule max 3 (task 89f952bb)
- **meridian-recall open decisions #2/#5** (task 3c2b7b1f)
- **devops_check_pending_signals echo exclusion migration** — needs Supabase dashboard or jam (task 7afd473b)

### Schema-Drift (sprint cleanup, 2026-04-30)
- 11/12 tasks completed (locus+forge)
- 1 blocked: invalid UUID syntax in CLI caller args (task de99b81a, forge)
- 2 closed as not-reproducible: job_id + array_agg were interactive queries during forge's pg_cron audit, not committed bugs

### Ops PRs Pending Merge (meridiem-shared-brain)
- PR #279: devops-schema-reference.md — lens PASS (one-line fix pending: context→topic)
- PR #280: devops-schema-tables-addendum.md — lens PASS WITH NOTES (non-blocking)
- PR #281: schema-drift-triage-gate — lens PASS WITH NOTES (non-blocking)

### Active Sessions (2026-05-02)
forge, locus, mira, anvil, pulse, lens (cycling s153+), axis (cycling s196→), trace (s146 wrapping)

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

## Session 13 Shipped (2026-03-27, T-4)
- **2-node homelab cluster operational** — Mac Mini + Alienware R10 (Ryzen 7 5800X, 32GB) fully deployed and verified
- **R10 services (8/8 green):** postgresql 16 + pgvector, ollama (nomic-embed-text + mistral:7b), home assistant (docker), NUT (UPS monitoring), RAG API (port 8080), syncthing, whisper STT (port 8090), node-health API (port 3850)
- **Tenant isolation:** 3 postgres databases (nwl, meridian, chowder) with per-tenant credentials + systemd cgroup slices (NWL 45%, meridian 45%, chowder 10%)
- **RAG pipeline live:** 214 documents, 2,038 chunks indexed, semantic search via REST API
- **Syncthing bidirectional:** shared-brain syncs between mini and R10 with conflict detection (5-min cron, alerts to vigil + discord)
- **Mesh networking:** tailscale between both nodes, DNS hardening (docker IPv6 disabled, forced IPv4)
- **UPS monitoring:** NUT server on R10, vigil integration for battery/charge/runtime

## Session 14 Shipped (2026-03-28, T-3)
- **5 dead primary agents detected + cycled** — silent death bug: health API reported shadows as primaries. static caught it, relay cycled all 5
- **Health monitoring live** — launchd-based health check (5-min interval), alerts to discord + vigil webhook on dead agents. stale context file detection patched in health-server.py
- **R10 GPU unlocked** — RX 5700 XT running via Vulkan at 65.6 tok/s (10x over CPU). ROCm incompatible with RDNA1, Vulkan bypasses it. Stress tested: stable, 53C, persists across reboots
- **Fran on tailscale mesh** — 100.89.96.110, Windows 11, RX 7900 GRE 16GB VRAM. Setup script ready (fran-pc-setup.ps1). Two GPU nodes on mesh
- **Vigil v3 shipped** — multi-tenant merge (NWL + Meridian in one dashboard), 4 tabs (NWL/Meridian/All/Mesh), GPU monitoring, RAG search with inline preview, agent status push + persistence, expandable cards with identity audio, health webhook, verification endpoint, changelog feed, tenant-scoped tasks + activity, user-specific defaults. 746-line server, 2637-line CSS, 851-line audio module
- **PR #35 merged** — share button visibility fix (border 7%→15% opacity, font 10→11px, share button accent treatment)
- **T-3 audits complete:** visual (claudia, 8 products clean), audio (hum, 3 products clean), competitive (near, 0 ambient products in march PH), code (claude+static, 45/45 tests + 35/35 deploys green)
- **Docs audit + new docs:** 216 files inventoried. New: infrastructure-reference.md, agent-cycle-procedure.md, gpu-toolchain-opportunities.md, proposed-docs-cleanup.md, session14-summary-for-fran.md, lane-onramp.sh
- **Ops hardening:** Spotlight disabled on mini (RAM optimization), mini renamed to nwl-mini in tailscale, MagicDNS working, permission detection poll reduced to 15s, health API GPU backend reporting fixed
- **Chowder online** — R10 services tested (4/5, needs DB password)

## Session 14 Afternoon Shipped (vigil improvement sprint)
- **Vigil session bar** updated to session 14
- **State duration** on agent cards ("BUILDING 12m", amber at 30min)
- **Display mode** — `?display=true` for dedicated screen (claudia CSS + claude JS)
- **Piper TTS** — replaced Web Speech API with real voice synthesis via R10:8091. 64 cached phrases, 8ms latency. ElevenLabs for brand, piper for system alerts
- **Query expansion** — 44-term dictionary for vigil search, server-side in RAG API
- **Cross-encoder re-ranking** — ms-marco-MiniLM-L-6-v2, +50ms latency, vector+rerank mode
- **Hybrid search fix** — pre-existing param count bug in BM25 path, exposed and fixed
- **CPU/RAM on mesh** — health-server.py extended with /proc/meminfo + /proc/loadavg parsing
- **Vigil API test suite** — 24/24 tests (static), runs in 3 seconds
- **Chat routing verified** — mc-chat-alert.json confirmed functional
- **Process fix** — stale memory audit protocol, correction-to-memory persistence, meridian cycle boundary enforced in 3 docs
- **Pre-launch sweep** — 69/69 green (45 playwright + 24 vigil API + 7 R10 services)
- **Vigil improvement plan** — shared-brain/projects/vigil-improvement-plan.md (relay, active)

## Session 15 (2026-03-31)
- **PH launch pushed to April 7** — jam's call, announced 2026-03-30
- **Bot-to-bot visibility patched** — `msg.author.bot` filter removed from discord plugin. All 6 agents can now see each other's messages in real-time (was blocking coordination since day 1)
- **Zombie root cause found** — "trust this folder" prompt was blocking plugin spawn on fresh workspace launches. Fixed by sending confirmation keystroke during cycle
- **All 6 agents cycled and confirmed** — bot-to-bot visibility test passed 6/6

## Session 16 (2026-04-05/06, T-2 to T-1)
- **ServiceBay dedup** — PR #74 merged. Server-side RPCs (pg_trgm) for contact + vehicle duplicate detection. Inline warning bar on create dialogs. Advisory only, never blocks
- **Payment fix** — PR #75 merged. Floating point rounding at all layers, 2-decimal cap, overpayment allowed with soft amber warning ("Record Anyway" / "Adjust to Balance")
- **UX polish** — PR #76 merged (Claudia). Fade-in animation + 44px mobile touch targets on warning bars
- **Performance** — PR #77 merged. Lazy load all 27 routes (was 5.9MB single bundle), QueryClient configured (2min staleTime, no refetchOnWindowFocus), shop settings cached 5min
- **DB audit** — Supabase/Syght audited: 37 tables, all RLS enabled, 18 dormant tables flagged for post-launch cleanup, 564 RPCs. Report: shared-brain/nwl/db-audit-syght-2026-04-05.md
- **agent-cycle.sh fixes** — flock→mkdir locking (macOS compatible), PATH fix for claude binary
- **Crontab fix written** — /tmp/crontab-fixed.txt (waiting jam to apply: `crontab /tmp/crontab-fixed.txt`)
- **T-2 visual audit** — Claudia: 21/21 screenshots, all pass
- **T-2 QA** — Static: 45/45 playwright tests green

## Next Actions
- [ ] **PH listing submission** — before April 7 (backlog #7, jam)
- [ ] **PH env vars** — PH_API_TOKEN, PH_POST_SLUG, PH_WEBHOOK_URL (after submission, jam)
- [ ] **PH launch** — Tuesday 2026-04-07. Near: morning-of competitor check
- [ ] **Piper systemd unit** — persistence on R10 reboot (jam's hands, spec posted by hum)
- [ ] **Spotify redirect URI** — backlog #10 (jam)
- [ ] **Chowder auth switch** — switch to sonia's anthropic account (jam)
- [ ] **Vercel pro upgrade** — prevent deploy limit during PH launch day (jam)
- [x] **Vercel deploy** — all 5 repos deployed to production (2026-03-26). backlog #13 done
- [x] **Vigil v3** — multi-tenant dashboard with mesh, TTS, re-ranking, display mode
- [ ] **Mix recommendations** — after 200+ session threshold (claude + static)
- [ ] **Spectral conflict map** — hum measures 231 layer pairs
- [ ] Reddit post (in #requests, ready to paste, jam posts when he parks)
- [ ] **Docs cleanup** — shadow→meridian renames, stale content, duplicates (awaiting jam review)
- [ ] **DB audit** — RLS policies, RPC functions, dormant tables (claude)
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
