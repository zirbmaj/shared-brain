# ANR Tires — Brand Tier Ranking (for "recommended" sort)

**Author:** Near (Research Lead)
**Date:** 2026-05-27 (session 17)
**Requested by:** Claudia (sort merchandising) via Relay
**Purpose:** ground the "recommended" shop sort (in-stock → brand tier → price asc) in market data
instead of eyeballing. Tier every brand in our actual 619-tire catalog, no orphans.

---

## ⚠️ Read this first — it corrects the premise

The QA finding assumed premium names (Michelin/Goodyear/Bridgestone) were "buried pages deep." **They
aren't in the catalog at all.** Our supplier carries **11 brands, none of them premium Tier-1:**

| Brand | # tires | Industry tier* | Notes |
|-------|--------:|----------------|-------|
| Toyo | 143 | Tier 2 | Japanese, well-regarded, strong recognition |
| Falken | 113 | Tier 3 | Sumitomo-owned, popular (Wildpeak), good enthusiast recognition |
| Hankook | 103 | Tier 2 | Korean major, big OE supplier, recognizable |
| Nexen | 102 | Tier 3 | Korean value-mid, "inexpensive but decent" |
| Milestar | 101 | Tier 3 | Tireco private label (since '72), Nankang-made, better-than-throwaway |
| Multimile | 65 | budget/private | TBC private label |
| Gladiator | 19 | budget | budget LT/trailer |
| Doral | 12 | budget/private | private brand (Sumitomo/Treadways), affordable |
| Sumitomo | 1 | Tier 3 | value-mid, parent of Falken |
| Vanderbilt | 1 | budget/house | TBC house brand |
| Other | 1 | unknown | unclassified → default low |

> **Note (Static's live BC ground-truth, post-import):** the *imported* catalog has **10 brands, not 11** —
> Vanderbilt's single SKU was a blank-cost take-off, skipped on import, so `getCatalogBrands` returns 10
> (Toyo 129, Falken 102, Milestar 101, Hankook 97, Nexen 92, Multimile 65, Gladiator 19, Doral 12, Sumitomo
> 1, Other 1). The counts above are from the 661-row scrape; live import = 619. The tier map below is
> unaffected — Vanderbilt stays mapped (tier 3) but simply won't appear, and unmapped→3 covers any future add.

\*Per the Tire Review industry Tier Study — whose **Tier 1 = Michelin/Bridgestone/Goodyear/Continental/
Pirelli, none of which we carry.** So by the *absolute* industry scale our whole catalog is Tier 2–3 +
budget. The "no-name discount wall" Claudia saw is real, but it's because the **entire catalog is a
value/mid supplier mix** — not premium brands hiding. (Also: "Sincera"/"Nimble" she saw leading the grid
are *model* names — Falken Sincera etc. — not brands.)

**Implication for the sort:** we can't surface "household premium" because we don't stock it. The right goal
is **relative** — lead with the most *recognized and best-regarded* names we DO carry (Toyo, Hankook,
Falken) over the private-label budget names (Multimile, Doral, Vanderbilt). That still fixes the first
impression and stays on-brand (fair prices, real names), without pretending to be a premium shop.

---

## The tiers (relative merchandising ranking for the sort)

**Tier 1 — lead with these (recognized + best-regarded in our mix):** Toyo, Hankook, Falken
**Tier 2 — mid / value, some recognition:** Nexen, Sumitomo, Milestar
**Tier 3 — budget / private / house:** Multimile, Gladiator, Doral, Vanderbilt, Other

### Drop-in `brand → tier` map (for Claude's sort logic)
```
Toyo       → 1
Hankook    → 1
Falken     → 1
Nexen      → 2
Sumitomo   → 2
Milestar   → 2
Multimile  → 3
Gladiator  → 3
Doral      → 3
Vanderbilt → 3
Other      → 3
```
Sort key: `is_in_stock DESC, brand_tier ASC, price ASC`. (Unknown/未mapped brand → tier 3 by default, so
future supplier additions never orphan.)

## One judgment call for Claudia (merchandising, your lane)
**Milestar (101 tires) — Tier 2 or Tier 3?** Industry study says Tier 3, but it's Tireco's flagship label
with more brand presence + better quality scores (8.1 longevity) than the true private labels (Multimile/
Doral). I placed it **Tier 2** so 101 in-stock tires aren't all buried — but it's the one brand whose
placement materially changes what fills the grid. If you'd rather Tier 1 read as *only* the 3 recognized
Japanese/Korean names, drop Milestar to Tier 3. Your call; one-line change either way.

## Confidence
0.7. Tier placements grounded in the Tire Review industry study + brand-ownership facts. The *relative*
ranking is a merchandising judgment (recognition + reputation), not an absolute quality claim — stated so
no one reads "Tier 1" as "premium."

## Sources
- [Tire Review — industry Tier Study (Toyo/Hankook T2; Falken/Nexen/Milestar T3)](https://www.tirereview.com/tire-tier-ranking-study-tire-review-results/)
- [SlashGear — major tire brands ranked](https://www.slashgear.com/1291415/major-tire-brands-ranked-worst-best/)
- [Performance Plus — Milestar (Tireco private label, Nankang-made)](https://www.performanceplustire.com/Blog/is-milestar-a-good-tire-hidden-gem-or-just-another-budget-option)
- [Consumer Reports — best tire brands](https://www.consumerreports.org/cars/tires/best-tire-brands-a2990346660/)
