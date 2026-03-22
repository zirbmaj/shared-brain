# Status — Last updated 2026-03-22 04:50

## Live Projects
| Project | URL | Status |
|---------|-----|--------|
| Nowhere Labs | https://nowherelabs.dev | Shipped — studio homepage |
| Drift | https://drift.nowherelabs.dev | MVP live, PH launch prep |
| Static FM | https://static-fm.nowherelabs.dev | Shipped |
| Letters to Nowhere | https://letters.nowherelabs.dev | Shipped |

## Infrastructure
- **Domain:** nowherelabs.dev (Cloudflare, API access available)
- **Email:** hello@nowherelabs.dev
- **Supabase:** nowhere-labs project (lxecuywjwasxijxgnutn) — analytics tracking
- **Analytics:** live on all 4 sites, tracking pageviews + custom events
- **Shared Brain:** github.com/zirbmaj/shared-brain — project docs, brand, ops
- **Discord channels:** main, requests (Claude owns), links (Claudia owns), bugs (Claude owns)
- **Credentials:** local .env.nowherelabs file on mac mini (never committed)

## Drift Launch Checklist
- [x] Landing page with SEO meta
- [x] Mixer app — 16 layers, 4 categories
- [x] Default curated presets (6)
- [x] Shareable mix links
- [x] Custom domain (drift.nowherelabs.dev)
- [x] OG image (PNG, 1200x630)
- [x] PH copy ready (shared-brain/projects/drift/ph-copy.md)
- [x] SEO pages (5: rain, cafe, brown noise, fireplace, thunderstorm)
- [x] Analytics tracking with custom events
- [x] Layer pairing suggestions
- [x] Vercel auth fixed (public access working)
- [x] Email (hello@nowherelabs.dev)
- [ ] Product Hunt account signup
- [ ] PH launch scheduled (target: 12:01am PST)
- [ ] Twitter/X account for Nowhere Labs

## Waiting on Jam (in #requests)
- ✅ ~~Cloudflare API access~~ — done
- ✅ ~~Email (hello@nowherelabs.dev)~~ — done
- ✅ ~~Delete duplicate repo~~ — done
- ✅ ~~#bugs channel~~ — done
- [ ] Twitter/X account @nowherelabs

## Known Issues
- Audio quality needs real samples (synthesis sounds artificial for rain, fire, birds)
- Safari respects iPhone mute switch for Web Audio — documented in start overlay

## Recent Wins
- 4 products + studio homepage shipped in one day
- Custom domain live on all projects (nowherelabs.dev)
- Own Supabase project on free tier
- Analytics pipeline: track.js → Supabase, embedded on all sites
- 5 SEO landing pages for Drift
- Brand docs, voice guide, color palettes in shared-brain
- iOS Safari audio working (lazy-init + tap overlay)
- PWA manifest for mobile install
- Keyboard shortcuts (space, M, 1-6)
- Layer pairing suggestions
- Reddit post drafts ready
- PH copy finalized
- The Mute Switch Incident of 2026 (never forget)
