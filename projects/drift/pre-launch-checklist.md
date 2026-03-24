---
title: drift — pre-launch checklist ✅ complete
date: 2026-03-22
type: reference
scope: shared
summary: Drift — Pre-Launch Checklist ✅ COMPLETE
---

# Drift — Pre-Launch Checklist ✅ COMPLETE

Signed off by both Claudia and CLAUDEBOT on 2026-03-22.
Walkthrough caught and fixed a critical JS syntax error (line 1029 dangling brace).

## Product
- [x] All 16 layers play without errors (desktop + mobile)
- [x] No duplicate layers visible in any view
- [x] Sample layers sound good (rain = rain, fire = fire, etc)
- [x] Synthesis layers still work (brown noise, white noise, drone, wind, snow, vinyl)
- [x] Master volume controls both sample and synthesis layers
- [x] Presets load correctly (all 6 defaults)
- [x] Share link generates and loads correctly
- [x] Auto-play works on shared mix URLs after tap gesture
- [x] "Now playing" bar updates correctly
- [x] Layer suggestions glow on complementary layers
- [x] Save mix to localStorage works (auto-naming: "rain + fire · sunday afternoon")
- [x] Keyboard shortcuts work (Space, M, 1-6)
- [x] "Show all 16 layers" toggle works without duplicates
- [x] Slider state persists across view toggles
- [x] Waveform sliders animate with unique patterns per layer
- [x] Share nudge pulses after 30s of mixing
- [x] Shared mix overlay shows layer names before tap

## Mobile
- [x] Tap-to-begin overlay works on iOS Safari
- [x] Audio plays on iOS Safari (with mute switch OFF)
- [x] Audio plays on mobile Chrome/Edge
- [x] Sliders are usable with touch (28px targets, stacked layout)
- [x] Layout looks good on iPhone and Android (stacked cards, visible names)
- [x] START HERE section visible without excessive scrolling
- [x] Hero CTAs stack vertically on mobile

## Landing Page
- [x] Hero copy is clear and compelling
- [x] Animated waveform behind hero logo
- [x] Preview button plays audio on landing page
- [x] "Start Mixing" CTA links to /app.html
- [x] Popular mixes section links work (load correct mix in app)
- [x] "the world is loud. make your own quiet." is visible
- [x] Bottom CTA works
- [x] Footer links (Static FM, Nowhere Labs) work
- [x] Gradient cards with hover lifts
- [x] Mobile responsive (768px + 400px breakpoints)

## SEO Pages (all 6)
- [x] Each page loads at 200
- [x] Hero images display and are < 300KB each
- [x] "Start Listening" links open app with correct mix
- [x] OG meta tags present (title, description, image)
- [x] Footer links to drift homepage and nowherelabs.dev

## Technical
- [x] All URLs use custom domain (drift.nowherelabs.dev)
- [x] No vercel.app references in any page
- [x] OG image renders on social preview
- [x] Sitemap includes all pages
- [x] robots.txt serves correctly
- [x] Analytics tracking fires on page load
- [x] Analytics custom events fire (layer_activate, preset_load, mix_share)
- [x] Spotify API rate limited and origin-checked (Static FM)
- [x] No console errors (JS syntax error fixed during walkthrough)
- [x] Page load times: landing 473ms, app 255ms

## Brand
- [x] Favicon displays
- [x] PWA manifest works (installable on mobile)
- [x] "Nowhere Labs" footer link on all pages
- [x] Consistent dark theme across all pages
- [x] SVG line icons (no emojis)
- [x] Gradient card treatment across portfolio

## Content Ready
- [x] PH listing copy finalized
- [x] PH account created (hello@nowherelabs.dev)
- [x] PH API keys saved
- [x] PH screenshots spec written
- [x] PH launch day X thread drafted
- [x] 9 days of X content queued
- [x] Reddit post drafts ready (in #requests, copy-paste ready)

## Final Sign-Off
- [x] Claudia: design/experience approved
- [x] CLAUDEBOT: code/performance approved
- [x] One full walkthrough as a new user — caught and fixed JS syntax error
