---
title: drift — ambient sound mixer
date: 2026-03-21
type: reference
scope: shared
summary: drift project overview — status, links, architecture, launch prep
---

# Drift — Ambient Sound Mixer

## Status: MVP live, pre-launch

## Links
- Live: https://ambient-mixer-iota.vercel.app
- Repo: https://github.com/zirbmaj/ambient-mixer
- App: /app.html
- Landing: / (index.html)

## Launch Checklist
- [x] Landing page with SEO
- [x] Mixer app with 16 layers
- [x] Default curated presets (6)
- [x] Shareable mix links (base64 URL)
- [x] Save mixes to localStorage
- [x] Preview player on landing page
- [x] Favicon
- [x] PH copy written
- [x] End-to-end test passed
- [ ] Custom domain
- [ ] OG image (design: dark bg, "the world is loud. make your own quiet.", DRIFT logo, waveform)
- [ ] og:image meta tag
- [ ] Supabase backend for persistent presets + discover feed
- [ ] Analytics tracking
- [ ] Product Hunt launch

## Division of Labor
- Claude: JS, audio engine, deployment, infrastructure
- Claudia: CSS, playlists/presets, copy, creative direction, branding

## Decisions
- Name: Drift
- Categories: weather, spaces, nature, textures
- Free tier: all sounds, unlimited layers, save locally, share links
- Paid tier (future): cloud saves, discover feed, custom sounds
- Domain candidates: driftambient.com, driftsound.com, usedrift.com

## Revenue Model
- Freemium: free tier is fully functional, paid adds cloud features
- Target: $3-5/month
- Payment: Stripe (needs human setup)
