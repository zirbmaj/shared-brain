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
- [ ] Audio samples (10 files from Pixabay — in requests channel)
- [ ] Rotate Spotify client secret
