# ANR Tires — Catalog Enrichment Data Sources

**Author:** Near (Research Lead)
**Date:** 2026-05-27 (Session 17)
**Requested by:** Relay (forward flag, jam-delegated curation context)
**Scope:** research-only. Originally scoped to descriptions + UTQG + sidewall + max-load.

> **⚠️ SCOPE NARROWED (Static, live DOM extraction, 2026-05-27):** the portal *result cards* (not the
> search facets, which is what looked thin earlier) actually expose **UTQG, sidewall, max_load,
> load_index, treadwear-warranty, weight, tread-depth, FET, and a suggested-resale price** per tire.
> **Specs are NOT a gap.** The enrichment need collapses to **marketing descriptions only** (and
> optionally images). The spec-provider licensing question below is therefore mostly moot — keep it as
> a fallback reference, but the live recommendation is now the "descriptions" path. See revised verdict.

---

## TL;DR / Verdict (revised for narrowed scope)

Since the scrape now carries all factual specs, the enrichment need is **marketing descriptions** (and
optionally images) — and the answer is clean:

1. **Descriptions → LLM-generate, don't license or scrape.** Marketing prose is copyrightable, so
   scraping manufacturer/Tire Rack copy is an IP risk. The enrichment agent should **write original
   descriptions from the scraped factual specs** (size, UTQG, season, load_range, warranty) in ANR's
   brand voice. This is the lowest-provenance-risk option *and* free of per-record licensing — original
   generation from facts the storefront legitimately holds. **No spec-data provider needed.**
2. **Images → license or use manufacturer assets.** If product photos are wanted beyond the JDM
   placeholders, license from DriveRightData/RideStyler (they include images) or use manufacturer-supplied
   assets with permission. Never hotlink/scrape retailer images. Lower priority — Claudia's lit-wheel
   placeholders are launch-acceptable.
3. **Spec providers (table below) are now a fallback, not the plan** — only relevant if a future audit
   shows the scrape's specs are incomplete for some sizes.

**Recommended path:** enrichment agent = LLM-generated brand-voice descriptions keyed off the scraped
spec row. Defer any spec/image licensing spend unless a concrete gap appears.

Confidence: 0.7. The descriptions-only conclusion is robust; provider details below retained as reference.
All provider pricing is quote-based / not public (B2B norm).

---

## Ranked source comparison

| # | Source | Data it covers | Access | Cost | Licensing / provenance |
|---|--------|---------------|--------|------|------------------------|
| 1 | **DriveRightData** (Infopro Digital Automotive) | tire specs, **descriptions**, label info, **images**, EAN, full size data; 20+ yrs | **API** + optional flat files | Quote-based (not public) | **Explicitly licensed for ecom/website display.** Data owners control display rights — provenance-aware, the cleanest fit found |
| 2 | **Tire Guides / TGP Solutions** | fitment, sizing, **grading (UTQG)**, tread designs; industry standard since 1957 | DB license + e-catalog + PDF | Quote-based | Licenses **to tire-industry parties incl. retailers** → ANR eligible. Gold-standard provenance; restrictions limit to industry use |
| 3 | **RideStyler** | 480+ brands full specs/ratings/**images**, 78k-vehicle fitment catalog | API | Quote-based | Built for **customer-facing ecom** — terms support storefront display |
| 4 | **Wheel-Size API** (wheel-size.com) | OE/aftermarket sizes, rim dims, offset, bolt patterns; 60k+ vehicle mods | API | Tiered (some public plans) | Fitment-focused — **weak on UTQG/max-load/descriptions**; good for a fitment widget, not spec enrichment |
| 5 | **Tireweb Library / ESP** | "largest tire-info database" (surfaced in Kerridge research) | License via ESP (Sheila Waters, sheila@esprofessionals.com) | Quote-based | Industry data-license route; same contact as the supplier-feed question |
| 6 | **Manufacturer spec pages** (Michelin, Goodyear, etc.) | UTQG, sidewall, max-load, official descriptions/images | Per-brand site (no unified feed) | Free data, but fragmented | Facts are free to state; **prose/images need permission**. High effort (per-brand), clean if done right |
| 7 | **Scrape Tire Rack / competitor catalogs** | everything, compiled | scraping | "free" | ❌ **Not recommended** — ToS violation + DB rights + copyrighted prose/images. Provenance risk; don't |

---

## Key provenance rules (the part that bites)

- **A spec value is a fact** (UTQG 500 A A, max load 1709 lbs) — not copyrightable alone. Safe to display.
- **A compiled database of specs is protected** (license terms + database rights) — so the *source* matters
  even when the individual numbers are facts. License a provider; don't bulk-lift someone's catalog.
- **Descriptions and images are creative works** — copyrighted. Generate descriptions (LLM), license images.
- This mirrors the data-feed finding: the cheap-looking "just scrape it" path carries the real legal risk;
  a license is the durable answer.

## Recommendation for the enrichment agent

1. **License DriveRightData** (or Tire Guides/TGP) for factual specs keyed by MPN — joins to Static's scrape.
2. **LLM-generate descriptions** from those specs in ANR's brand voice — original prose, no IP exposure.
3. **Images:** from the same license, else manufacturer assets with permission.
4. Get **quotes** from DriveRightData + Tire Guides to price it — that's the one open number.

## Unknowns / to verify
- Pricing for every provider (all quote-based) — **the open question for jam/business.**
- Whether MPN keys from the Tire Solutions scrape map cleanly to a provider's product IDs (EAN/MPN match rate).

## Sources
- [DriveRightData — tire product data (licensed for ecom)](https://www.driveright-data.com/en/tire-product-data)
- [DriveRightData — retailers / API use](https://www.driveright-data.com/en/retailers)
- [Tire Guides Inc.](https://www.tireguides.com/) · [TGP Solutions (licensing)](https://tgp-solutions.com/about_us)
- [RideStyler tire data + API](https://www.ridestyler.com/data/tires/)
- [Wheel-Size fitment API](https://developer.wheel-size.com/)
- [UTQG explained (Tire Rack)](https://www.tirerack.com/upgrade-garage/what-are-the-uniform-tire-quality-grade-utqg-standards)
