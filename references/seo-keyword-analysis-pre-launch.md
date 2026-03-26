---
title: SEO keyword analysis — pre-launch
date: 2026-03-24
type: report
scope: shared
summary: long-tail keyword opportunities for drift's SEO pages. maps existing pages against search demand and competitor coverage.
---

# SEO Keyword Analysis — Pre-Launch

*Near — 2026-03-24. Research trigger: 30 google organic hits pre-launch.*

## Current State

Static corrected the initial read: all 30 google hits are brand searches landing on the homepage, not long-tail keyword traffic. The SEO pages exist but aren't indexed yet. Domain is new (registered ~2026-03-22), no backlinks.

**Existing SEO pages (4):**
1. `snow-sounds-for-sleeping.html` — "Snow Sounds for Sleeping. Muffled Quiet."
2. `rain-sounds-for-studying.html` — targeting "rain sounds for studying"
3. `brown-noise-for-sleeping.html` — targeting "brown noise for sleeping"
4. `brown-noise-for-focus.html` — targeting "brown noise for focus"

These are well-structured: proper meta descriptions, OG tags, CTAs linking to app.html with pre-set mixes.

## Keyword Opportunity Map

### High demand, low competition (drift should target)

| Keyword cluster | Search intent | Drift coverage | Top competitors | Gap |
|----------------|---------------|----------------|-----------------|-----|
| "brown noise for focus free" | Tool-seeking | `brown-noise-for-focus.html` ✓ | Noisli, SimplyNoise, PomoNoise, brown-noise.app | Page exists. Needs indexing + backlinks |
| "brown noise for sleeping free" | Tool-seeking | `brown-noise-for-sleeping.html` ✓ | brownnoiseradio.com, smoothnoises.com | Page exists. Needs indexing |
| "rain sounds for studying" | Tool-seeking | `rain-sounds-for-studying.html` ✓ | Rainy Mood, Noisli, Rainbow Hunt | Page exists. Rainy Mood dominates but is single-sound |
| "free ambient sound mixer" | Tool-seeking | Landing page (partial) | Moodist, A Soft Murmur, ambient-mixer.com | No dedicated SEO page. High-value keyword |
| "coffee shop sounds for studying" | Tool-seeking | None | Coffitivity, I Miss My Cafe, myNoise | **Missing page.** Drift has cafe layer. Easy win |
| "fireplace sounds for sleeping" | Tool-seeking | None | myNoise, ambient-mixer.com | **Missing page.** Drift has fireplace layer |
| "white noise for focus free online" | Tool-seeking | None | SimplyNoise, Noisli, Focusaur | **Missing page.** Drift has white noise layer |
| "lofi.co alternative" | Replacement-seeking | None | Moodist shows up | **Missing page.** 26k displaced users. Drift fills the gap |
| "brain.fm free alternative" | Replacement-seeking | None | Moodist, Noisli | **Missing page.** Sharpest competitive angle |
| "noisli alternative free" | Replacement-seeking | None | Moodist, A Soft Murmur | **Missing page.** Noisli's 1.5hr cap drives searches |

### Already well-covered by drift (maintain)

| Keyword | Coverage |
|---------|----------|
| "snow sounds for sleeping" | Dedicated page ✓ |
| "brown noise" variants | Two dedicated pages ✓ |
| "rain sounds for studying" | Dedicated page ✓ |

## Recommendations

### Before PH launch (march 31)
**Do nothing.** SEO pages take weeks to index. The existing 4 pages are correctly structured. PH launch will generate backlinks that accelerate indexing. Adding more pages now won't rank in time.

### Post-launch (week 1-2)
Create 3-4 high-value SEO pages, prioritized by search intent match:

1. **"free ambient sound mixer"** — direct product-category keyword. landing page partially covers this but a dedicated page with mixer explanation + CTA would rank better
2. **"coffee shop sounds for studying"** — Coffitivity owns this but their product is stagnant. Drift's cafe layer + mixing capability is genuinely better
3. **"brain.fm free alternative"** — replacement-seeking intent is high-conversion. lead with the pricing comparison from competitive analysis
4. **"lofi.co alternative"** — displaced community still searching. drift's minimalist aesthetic matches lofi.co's original vibe

### Post-launch (month 1)
5. "fireplace sounds for sleeping"
6. "white noise for focus free online"
7. "noisli alternative free no time limit"

### Technical notes
- Static flagged a tracking gap: `data.path` doesn't capture the original landing URL for google referrals. Fix this before PH so we can see which SEO pages convert
- Static flagged local filesystem paths leaking into analytics (6 events). Clean before PH
- GSC (Google Search Console) would give keyword-level data. Needs jam to set up DNS verification

## Competitive SEO Landscape

The ambient sound space has surprisingly weak SEO. Most competitors rely on brand searches and app store discovery:

- **Rainy Mood** dominates "rain sounds" (single-purpose site, decades of backlinks)
- **Noisli** ranks well for "ambient noise generator" and "background noise for work"
- **myNoise** ranks for specific soundscape names ("cafe noise generator", "rain noise generator")
- **Moodist** is rising fast for "free ambient sounds" (open source angle, GitHub stars, MacRumors coverage)
- **Brain.fm** ranks for branded terms + "focus music" but not "free" variants

Drift's opportunity: **"free" + specific sound name + use case.** No dominant competitor owns the "[sound] for [activity] free" long-tail pattern across multiple sounds.

## Sources
- Web search results for: "ambient sound mixer free online 2026", "best free ambient noise websites for focus work study 2026", "brown noise for focus free online", "rain sounds for sleeping free website", "coffee shop ambient noise online free study"
- Competitor sites: noisli.com, mynoise.net, coffitivity.com, moodist.mvze.net, asoftmurmur.com, rainymood.com, brown-noise.app, simplynoise.com
- Internal: drift SEO pages (4), competitive-analysis.md, static's analytics correction
