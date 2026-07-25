---
decision: ANR Tires catalog curation — initial size set to scrape/list
made_by: team (jam delegated "whatever the team thinks best"); proposed by Near, ratified by relay
date: 2026-05-27
---

## Context
The Tire Solutions supplier feed is query-driven (no full export), so we must pick which sizes to scrape and list — also the curation jam wanted ("don't list the whole book"). Bounded by the shop constraint: **≤20" rim only** (ANR can't mount >20"). jam delegated the specific set to the team. Near researched a ranked set weighted to ANR's St. Cloud MN market (truck/SUV/AWD heavy, strong winter demand).

## Decision
Scrape + list **32 sizes**, queried in tier order (Tier 1 first so must-stock lands even if a run is cut). Full table + per-size vehicle mappings + sources: `shared-brain/nwl/research/anr-tire-size-curation.md`.

- **Tier 1 (must-stock):** 225/65R17, 265/70R17, 215/55R17, 235/65R17, 235/60R18, 275/65R18, 275/60R20, 245/75R17
- **Tier 2 (sedan/compact):** 205/55R16, 195/65R15, 215/60R16, 225/60R17, 235/55R18, 225/45R17, 225/50R17
- **Tier 3 (SUV/CUV + AWD):** 265/65R18, 255/70R16, 255/65R18, 245/60R18, 235/55R19, 235/50R19, 255/55R19, 245/50R20, 255/50R20, 275/55R20
- **Tier 4 (LT/off-road):** LT265/70R17, LT275/70R18, LT285/70R17, LT245/75R17, LT265/75R16, LT245/70R17, 285/70R17

**Excluded:** anything 22"+ (shop can't mount).

## Alternatives
- Scrape the whole supplier book — rejected (jam's "don't list the whole book"; also query-driven scraping makes a curated list natural).
- National-average size ranking — refined to MN-weighted (truck/AWD over-index locally).

## Impact
- Static scrapes in tier order; doubles as test inputs for the size-search format work.
- Winter is a *type* not a size — carry Tier 1–2 in winter/all-weather lines too (MN over-indexes vs national ~45% all-season).
- Tier 4 LT sizes rely on `load_range` (E/D) — the BC custom field already made first-class.
- Revisit/expand once real order data shows actual local demand.
- Confidence 0.7 (volume ranks cited; fitment mapping is automotive knowledge) — open to challenge if Claude/Static hit a fitment issue.
