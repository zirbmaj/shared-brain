# Status — Last updated 2026-03-22 19:15

## Live Projects
| Project | URL | Status |
|---------|-----|--------|
| Nowhere Labs | https://nowherelabs.dev | Shipped, polished |
| Drift | https://drift.nowherelabs.dev | Launch-ready, polished, real audio |
| Static FM | https://static-fm.nowherelabs.dev | Shipped, polished, API hardened |
| Letters to Nowhere | https://letters.nowherelabs.dev | Shipped, polished |
| Pulse | https://pulse.nowherelabs.dev | Shipped, polished |
| Talk to Nowhere | https://nowherelabs.dev/chat.html | Live, linked in footers |

## Infrastructure
- **Domain:** nowherelabs.dev (Cloudflare DNS, API access)
- **Email:** hello@nowherelabs.dev (Google Workspace)
- **X/Twitter:** @nowhere_labs (first thread posted, 9 days of content queued)
- **Supabase:** nowhere-labs project (analytics + chat)
- **Analytics:** live on all sites, custom events, ~500 total pageviews
- **Image Generation:** Kie API (nano-banana-2)
- **Product Hunt:** account created, API keys saved, listing copy ready
- **Shared Brain:** github.com/zirbmaj/shared-brain
- **Credentials:** ~/.env.nowherelabs (local, never committed)
- **Discord:** main, requests (Claude), links (Claudia), bugs (Claude)

## Today's Sprint (Day 2)
### Shipped
- Real audio samples (10 files, hybrid engine: HTML5 Audio + Web Audio API)
- Waveform sliders with AnalyserNode (real audio visualization on synthesis layers)
- Bobbing slider thumb (rides wave when idle, snaps on hover)
- 16 unique waveform patterns per layer
- Progressive disclosure (6 featured layers, expand to 16)
- Slider state persistence across view toggles
- CSS polish on ALL 5 products (gradient cards, softer borders, premium feel)
- Landing page: animated hero waveform, hover lifts, mobile responsive
- "Talk to Nowhere" live chat feature (supabase-backed)
- Snow SEO page (data-driven, #1 layer)
- AI-generated brand assets (pfp, banner, OG image, 6 SEO hero images)
- X account live with first thread posted
- Spotify API hardened (rate limit, origin check, generic errors)
- All product footers linked with "talk to us" and "feedback"
- Sitemaps and robots.txt on all sites
- Roadmap, PH screenshots spec, launch day X thread, reddit posts drafted

### Analytics Snapshot
- Drift: 294 pageviews, 373 layer activations, 44 preset loads, 5 mix shares
- Nowhere Labs: 101 pageviews
- Static FM: 37 pageviews, 24 weather switches
- Letters: 32 pageviews
- Pulse: 27 pageviews, 7 timer starts
- Total: ~493 pageviews

## Plan: Now → Tuesday
1. Reddit post (r/ambientmusic today/tomorrow, jam posts)
2. X daily content from queue
3. Iterate on user feedback
4. Final end-to-end walkthrough Monday night
5. PH screenshots Monday
6. PH launch Tuesday 12:01am PST

## Waiting on Jam
- [ ] Post reddit draft to r/ambientmusic
- [ ] Rotate Spotify client secret
- [ ] Submit sitemaps in GSC

## Key Docs
- Roadmap: ROADMAP.md
- PH copy: projects/drift/ph-copy.md
- PH screenshots spec: projects/drift/ph-screenshots.md
- PH launch thread: projects/drift/ph-launch-thread.md
- Reddit posts: projects/drift/reddit-post.md
- X content queue: projects/x-content-queue.md
- Audio architecture: projects/drift/audio-architecture.md
- Sample test plan: projects/drift/sample-test-plan.md
- Pre-launch checklist: projects/drift/pre-launch-checklist.md
- iOS investigation: projects/drift/ios-audio-investigation.md
- Brand voice: brand/voice.md
- Session handoff: ops/session-handoff.md
