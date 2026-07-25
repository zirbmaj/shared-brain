# ANR Tires — Curated Starter Size Set (catalog scope)

**Author:** Near (Research Lead)
**Date:** 2026-05-27 (Session 17)
**Requested by:** jam (delegated curation to team) via Relay
**Constraint:** ≤20" rim diameter only (ANR can't mount >20"); no alignment service.
**Market:** St. Cloud MN — cold-climate, truck/SUV/AWD-heavy, strong winter demand.
**Use:** ranked list for Static to scrape against the Tire Solutions portal (size-parameterized), not the whole book.

---

## TL;DR

A **32-size starter set** below, tiered by expected local volume. All ≤20" rim. Two structural facts
drive it: (1) **17" dominates** both passenger and light-truck replacement; (2) MN over-indexes on
**trucks + AWD crossovers** (Silverado is MN's #1 vehicle; RAV4/Subaru/F-150 all top sellers). Stock
Tier 1 deep, Tiers 2–3 moderate, Tier 4 (LT/off-road) selectively. **Winter is a tire *type*, not a
size** — these same sizes should be carried in winter/all-weather lines too, which matters more here
than nationally (national all-season share is ~45%; MN skews higher to winter/all-weather).

Confidence: 0.7. Volume rankings are cited; size→vehicle fitment mapping is general automotive
knowledge (supporting, not single-source). One cited stat (265/70R17 "84% LT share") looks
overstated by the secondary source — treated as "dominant LT size," not literal.

---

## Tier 1 — must-stock (highest volume, broad fitment)

| Rank | Size | Segment | Representative MN-popular vehicles |
|------|------|---------|-----------------------------------|
| 1 | **225/65R17** | compact/mid crossover | RAV4, CR-V, Equinox, Rogue, CX-5, Escape — **US #1 size, 5.8%** |
| 2 | **265/70R17** | full-size truck/SUV | F-150, Silverado, Tacoma, 4Runner, Tahoe — **dominant LT size** |
| 3 | **215/55R17** | midsize sedan | Camry, Accord, Malibu, Altima, Fusion — **US #3, 3.6%** |
| 4 | **235/65R17** | mid/large SUV | Highlander, Pilot, Pathfinder, Ascent |
| 5 | **235/60R18** | crossover/SUV | CR-V (hi-trim), Edge, Murano, Outback |
| 6 | **275/65R18** | full-size truck/SUV | F-150, Silverado/Sierra, Tahoe/Yukon |
| 7 | **275/60R20** | full-size truck (20" OE) | F-150, Silverado, Ram 1500 |
| 8 | **245/75R17** | full-size truck/SUV | F-150, Ram, Expedition |

## Tier 2 — high volume sedan / compact

| Size | Segment | Vehicles |
|------|---------|----------|
| **205/55R16** | compact | Civic, Corolla, Jetta, Cruze |
| **195/65R15** | economy compact | Corolla (older), Civic, Prius |
| **215/60R16** | midsize/compact | Camry/Accord (older), Sonata, Forte |
| **225/60R17** | crossover/sedan | Equinox, Malibu, CX-5 (base) |
| **235/55R18** | large sedan/CUV | Camry/Accord (hi-trim), Outback, Passat |
| **225/45R17** | sporty compact | Civic Si, Jetta GLI, Mazda3, Corolla hatch |
| **225/50R17** | midsize | Accord, Passat, Mazda6 |

## Tier 3 — SUV / CUV mid + AWD (MN-relevant)

| Size | Segment | Vehicles |
|------|---------|----------|
| **265/65R18** | midsize truck/SUV | Tacoma, 4Runner, Silverado |
| **255/70R16** | midsize truck | older Silverado/F-150, Tacoma |
| **255/65R18** | mid/large SUV | Grand Cherokee, Explorer |
| **245/60R18** | mid/large SUV | Highlander, Pilot, Explorer |
| **235/55R19** | crossover (19") | Edge, Nautilus, RX |
| **235/50R19** | compact crossover (19") | RAV4 (hi-trim), CX-5/CX-50 |
| **255/55R19** | large SUV (19") | Grand Cherokee, Durango |
| **245/50R20** | large SUV (20") | Grand Cherokee, larger CUV |
| **255/50R20** | large SUV/truck (20") | Durango, Grand Cherokee, Tahoe (hi-trim) |
| **275/55R20** | full-size SUV (20") | Tahoe, Yukon, Silverado |

## Tier 4 — light truck / off-road (MN 4x4 + work-truck demand)

| Size | Segment | Vehicles |
|------|---------|----------|
| **LT265/70R17** | (LT variant of #2) | F-150/Silverado work + off-road |
| **LT275/70R18** | HD truck | Ram, F-250 (½-ton overlap), HD |
| **LT285/70R17** | off-road | F-150/Tacoma off-road, 4Runner TRD |
| **LT245/75R17** | full-size 4x4 | F-150, Ram |
| **LT265/75R16** | midsize/older 4x4 | Tacoma, older HD, Jeep |
| **LT245/70R17** | midsize 4x4 | Colorado, Tacoma |
| **285/70R17** | off-road (P-metric) | 4x4 upsize |

**Excluded by constraint:** anything 22"+ (e.g. 285/45R22, 275/50R22, 305/40R22 — common on
luxury-SUV/lifted-truck upgrades). ANR can't mount these; don't list install for them. The portal
search is size-parameterized, so simply don't query >20".

---

## Notes for the build (Claude / Static)

- **Scrape order = this rank** — Tier 1 first so the catalog has the highest-traffic sizes even if
  the run is interrupted.
- **Winter coverage:** carry Tier 1–2 sizes in winter/all-weather lines too — MN demand. Type, not size.
- **load_range matters here:** LT and many truck sizes carry E/D ratings — Static's `load_range`
  field (not numeric load_index) is the right signal, per the earlier contract.
- This is a *starter* set for launch curation, not a permanent catalog — expand by observed demand.

## Sources
- [Performance Plus — most popular tire sizes (225/65R17 #1 @5.8%, 215/55R17 #3 @3.6%)](https://www.performanceplustire.com/Blog/what-tire-size-is-the-most-popular)
- [Modern Tire Dealer — 17" dominates passenger + LT segments](https://www.moderntiredealer.com/retail/article/33003048/17-inch-tires-continue-to-dominate-passenger-lt-segments)
- [Accio — best-selling tire sizes / all-season ~45% share](https://www.accio.com/business/best_selling_tire_sizes)
- [KDHL — most popular car brands in MN 2024 (Chevy #1, Ford #2, Toyota #3)](https://kdhlradio.com/ixp/719/p/most-popular-car-brands-minnesota-2024/)
- [Visual Capitalist — best-selling vehicle by state (Silverado #1 in MN)](https://www.visualcapitalist.com/the-best-selling-vehicle-in-america-by-state/)
