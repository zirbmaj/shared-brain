---
decision: ANR Tires pricing rules + shop service constraints
made_by: jam (owner input, relayed from Fernando/shop reality)
date: 2026-05-27
---

## Context
ANR Tires storefront needs real pricing logic. The Tire Solutions supplier feed gives dealer **cost** only (no retail), so retail must be derived. jam also specified the shop's physical service limits, which constrain both what we sell and the install offering.

## Decision
**Pricing:**
- **Retail markup:** flat **15%** per tire → `retail = cost × 1.15`. (Importer default changed from placeholder 1.35 → 1.15.) **CONFIRMED 2026-05-28** (jam, via Fernando): keep cost×1.15, did NOT switch to the supplier "resale" column that surfaced in the scrape. **FET resolved: $0** across all 661 curated rows (supplier passes no federal excise tax on this set) — the FET-handling decision is moot.
- **Install fee:** **$30 / tire** (mount + balance).
- **Disposal fee:** **$6 / tire** (was $4 in the seed data — corrected).
- **Sales tax:** **7.56%** — set on the BigCommerce store tax config, NOT hardcoded.

**Shop service constraints (ANR, St. Cloud MN):**
- Has a tire balancer + mount-and-balance machine.
- **Cannot service rims above 20"** → do not sell/offer install for >20" rim diameter; surface a "call us for 22"+" note before purchase.
- **No alignment machine (for now)** → remove all alignment service/copy (the install page had a stale "4-Wheel Alignment $89" line).

## Alternatives
- Keep placeholder 1.35 markup — rejected, jam set the real number.
- Per-tier / bundle pricing — not now; flat 15% to start (importer supports `--markup` override if this changes).

## Impact
- `bc:import` retail derivation default → 1.15; install/disposal ride as checkout custom line items ($30 + $6/tire).
- BigCommerce store tax → 7.56%.
- Curation is bounded by the ≤20" rim limit (see curation decision, pending Near's size research).
- Install page (`lib/install.ts` single source) + product buy-box + fitment/chat agent must all reflect ≤20" / no-alignment. Claudia owns install-page copy/UX; Claude owns catalog filtering + chat-agent rules.
- AI fitment agent must not suggest alignment or >20" install.
