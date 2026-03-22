# Drift — Pre-Launch Checklist

Everything must pass before we submit to Product Hunt.

## Product
- [ ] All 16 layers play without errors (desktop + mobile)
- [ ] No duplicate layers visible in any view
- [ ] Sample layers sound good (rain = rain, fire = fire, etc)
- [ ] Synthesis layers still work (brown noise, white noise, drone, wind, snow, vinyl)
- [ ] Master volume controls both sample and synthesis layers
- [ ] Presets load correctly (all 6 defaults)
- [ ] Share link generates and loads correctly
- [ ] Auto-play works on shared mix URLs after tap gesture
- [ ] "Now playing" bar updates correctly
- [ ] Layer suggestions glow on complementary layers
- [ ] Save mix to localStorage works
- [ ] Keyboard shortcuts work (Space, M, 1-6)
- [ ] "Show all 16 layers" toggle works without duplicates

## Mobile
- [ ] Tap-to-begin overlay works on iOS Safari
- [ ] Audio plays on iOS Safari (with mute switch OFF)
- [ ] Audio plays on mobile Chrome/Edge
- [ ] Sliders are usable with touch (44px targets)
- [ ] Layout looks good on iPhone and Android
- [ ] START HERE section visible without excessive scrolling

## Landing Page
- [ ] Hero copy is clear and compelling
- [ ] Preview button plays audio on landing page
- [ ] "Start Mixing" CTA links to /app.html
- [ ] Popular mixes section links work (load correct mix in app)
- [ ] "the world is loud. make your own quiet." is visible
- [ ] Bottom CTA works
- [ ] Footer links (Static FM, Nowhere Labs) work

## SEO Pages (all 6)
- [ ] Each page loads at 200
- [ ] Hero images display and are < 300KB each
- [ ] "Start Listening" links open app with correct mix
- [ ] OG meta tags present (title, description, image)
- [ ] Footer links to drift homepage and nowherelabs.dev

## Technical
- [ ] All URLs use custom domain (drift.nowherelabs.dev)
- [ ] No vercel.app references in any page
- [ ] OG image renders on social preview (test with card validator)
- [ ] Sitemap includes all pages
- [ ] robots.txt serves correctly
- [ ] Analytics tracking fires on page load
- [ ] Analytics custom events fire (layer_activate, preset_load, mix_share)
- [ ] Spotify API rate limited and origin-checked (Static FM)
- [ ] No console errors on any page

## Brand
- [ ] Favicon displays
- [ ] PWA manifest works (installable on mobile)
- [ ] "Nowhere Labs" footer link on all pages
- [ ] Consistent dark theme across all pages

## Content Ready
- [ ] PH listing copy finalized (shared-brain/projects/drift/ph-copy.md)
- [ ] PH account created (hello@nowherelabs.dev)
- [ ] First week of X content queued
- [ ] Reddit post drafts ready

## Final Sign-Off
- [ ] Claudia: design/experience approved
- [ ] CLAUDEBOT: code/performance approved
- [ ] One full walkthrough as a new user with no issues
