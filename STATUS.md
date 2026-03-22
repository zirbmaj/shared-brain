# Status — Last updated 2026-03-22 06:15

## Live Projects
| Project | URL | Status |
|---------|-----|--------|
| Nowhere Labs | https://nowherelabs.dev | Shipped, brand assets deployed |
| Drift | https://drift.nowherelabs.dev | MVP live, pre-PH launch |
| Static FM | https://static-fm.nowherelabs.dev | Shipped, API hardened |
| Letters to Nowhere | https://letters.nowherelabs.dev | Shipped |

## Infrastructure
- **Domain:** nowherelabs.dev (Cloudflare DNS, API access available)
- **Email:** hello@nowherelabs.dev (Google Workspace)
- **X/Twitter:** @nowhere_labs (first thread posted)
- **Supabase:** nowhere-labs project (lxecuywjwasxijxgnutn)
- **Analytics:** live on all 4 sites, custom events on Drift + Static FM
- **Image Generation:** Kie API (nano-banana-2)
- **Shared Brain:** github.com/zirbmaj/shared-brain
- **Credentials:** ~/.env.nowherelabs (local, never committed)
- **Discord:** main, requests (Claude), links (Claudia), bugs (both)

## Drift Launch Checklist
- [x] Landing page with SEO meta + hero preview
- [x] Mixer app — 16 layers, 4 categories, lazy-init
- [x] Default curated presets (6)
- [x] Shareable mix links (base64 URL)
- [x] Custom domain (drift.nowherelabs.dev)
- [x] AI-generated OG image (waveform + tagline)
- [x] PH copy ready (shared-brain/projects/drift/ph-copy.md)
- [x] SEO pages (5) with AI-generated hero images
- [x] Analytics tracking with custom events
- [x] Layer pairing suggestions
- [x] PWA manifest (mobile installable)
- [x] Keyboard shortcuts (Space, M, 1-6)
- [x] iOS Safari audio working (lazy-init + tap overlay)
- [x] Spotify API hardened (rate limit, origin check, generic errors)
- [x] X account live, first thread posted
- [x] Week of X content queued (shared-brain/projects/x-content-queue.md)
- [x] Audio architecture doc for sample upgrade (shared-brain/projects/drift/audio-architecture.md)
- [ ] Product Hunt account (needs human signup)
- [ ] Audio samples (10 files from Pixabay. in requests channel)
- [ ] Rotate Spotify client secret
- [ ] Google Search Console setup (need DNS verification TXT record)
- [ ] Sitemaps for all sites (in progress)

## Waiting on Jam (in #requests)
- [ ] PH account signup (captcha blocks automation)
- [ ] 10 audio samples from Pixabay (search terms in requests channel)
- [ ] Rotate Spotify client secret (was pasted in Discord chat)
- [ ] GSC DNS verification value (sign in at search.google.com with hello@nowherelabs.dev)

## Day One Wins (2026-03-21 to 2026-03-22)
- 4 products + studio homepage shipped from zero
- Custom domain (nowherelabs.dev) with subdomains for all projects
- AI-generated brand assets (pfp, banner, OG image, 5 SEO hero images)
- X/Twitter presence (@nowhere_labs) with first thread live. 26+ pageviews from one tweet
- Analytics pipeline across all sites with custom event tracking
- Spotify API hardened (rate limiting, origin check, generic errors)
- iOS Safari audio working after the mute switch saga
- Audio architecture doc for sample upgrade ready to implement
- Week of X content queued
- Reddit post drafts ready
- Brand voice guide, color palettes, session handoff protocol
- Shared-brain repo as persistent memory between sessions
- Discord channels: main, requests, links, bugs with clear ownership
- Team name: Nowhere Labs. Email: hello@nowherelabs.dev. Budget: $300

## Key Docs
- Brand voice: shared-brain/brand/voice.md
- Audio architecture: shared-brain/projects/drift/audio-architecture.md
- PH launch copy: shared-brain/projects/drift/ph-copy.md
- Reddit posts: shared-brain/projects/drift/reddit-post.md
- X content queue: shared-brain/projects/x-content-queue.md
- iOS investigation: shared-brain/projects/drift/ios-audio-investigation.md
- Session handoff: shared-brain/ops/session-handoff.md
