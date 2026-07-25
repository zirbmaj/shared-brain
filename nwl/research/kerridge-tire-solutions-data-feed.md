# Kerridge / "Tire Solutions" — Official Data Feed vs Scraping

**Author:** Near (Research Lead)
**Date:** 2026-05-27 (Session 17)
**Trigger:** Static confirmed the ANR supplier portal runs Kerridge and has **no CSV export** —
the supplier-data pipeline would otherwise be a scraper. Question: is there an official API/feed
that beats scraping, and what would it take to get it?

---

## TL;DR / Verdict

**An official feed almost certainly exists at the platform level — but it is the *distributor's*
to grant, not something ANR can self-serve.** This is correctly a **jam/business ask**, not an
engineering task. If the distributor provisions even a daily CSV-over-SFTP feed, it drops **straight
into Claude's existing `bc:import`** (which already takes a CSV) — no scraper, no brittleness, no
portal-lockout risk. Scraping is the **fallback**, only if the distributor declines.

Confidence: 0.6. Platform-capability claims are largely single-source (Kerridge's own marketing
site). The specific distributor's feed offering is **only knowable by asking them** — flagged.

---

## What the platform supports (the data)

The portal is Kerridge Commercial Systems (recently rebranded **Klipboard**), VAST family:

- **VAST Commerce** is explicitly "a suite of data products — catalog, labor, specifications, and
  tire data — and connectivity solutions" for transacting online across the tire supply chain.
- **VAST Online / OpenWebs** offer B2B/B2C e-commerce with "seamless connection to part and tire
  suppliers" for real-time inventory + pricing.
- Kerridge integrates with analytics partners (Torqata) and customer POS systems.

**Conclusion:** the platform is built for data connectivity. The absence of a CSV export *button*
in the dealer web UI (what Static found) does **not** mean no feed exists — it means the feed lives
behind a B2B integration agreement, not the self-serve portal.

## The catch: access is the distributor's to grant

ANR is a **dealer/customer** of whoever runs that portal. An official feed/API requires the
**distributor** to enable VAST connectivity / issue credentials. That is a contractual + relationship
ask, gated on the distributor's willingness. This is exactly why Static flagged it as business, not eng.

## Industry-standard alternatives to scraping (if the distributor plays)

| Path | What it gives | Fit |
|------|--------------|-----|
| **Distributor feed via Kerridge VAST/OpenWebs** | Native API or scheduled file | Best if they'll grant it — same data Static sees, no scraping |
| **Tireweb Connections** | API **+ daily flat-file (CSV) over FTP/SFTP** for inventory/pricing, plus order placement | Industry aggregator; viable if ANR's supplier is on it |
| **Distributor-specific API** (e.g. American Tire Distributors via Spark Shipping) | Real-time inventory/pricing API | Only if ANR sources from that distributor |

A **daily SFTP CSV** is the realistic, low-friction ask — it matches `bc:import`'s input exactly.

## Acquisition mechanics — what it actually takes (Relay's question)

Two obtainable paths, both gated on **identifying the distributor and whether they participate**:

**Path A — Kerridge VAST/OpenWebs direct feed.** Capability is real (VAST Commerce, OpenWebs B2B,
compatible with AConneX/IAP networks). But it's **enterprise B2B, no public pricing, "contact sales,"
and not dealer-self-serve** — the distributor must enable connectivity. Timeline/cost: unknown,
likely slow. This is a relationship ask, not a checkout.

**Path B — Tireweb Connections / ESP data license (the cheaper, faster route IF applicable).**
- Tireweb Connections is **free for distributors already on Tireweb's ecommerce platform**, and
  provides **daily flat-file CSV over FTP/SFTP** + APIs, keyed to a unique Manufacturer Product Code.
- For an outside party building a tire website (≈ exactly ANR's case), data licenses go through
  **ESP / E-Solution Professionals — contact Sheila Waters, sheila@esprofessionals.com.**
- Public per-seat/per-feed pricing isn't listed — but "free for platform distributors" signals the
  data layer is low-cost; the gating cost is setup + whether ANR's supplier is on Tireweb.

**Cost reality:** the *data* is likely $0–low. The real "cost" is the **business relationship + setup
time**, which can't be priced without asking. Static's scraper is already $0 and working. So an
official feed is a **reliability/maintenance upgrade, not a cost saving** — pursue it in parallel,
migrate the seam only if it lands cheap + fast.

## Recommendation

1. **jam/business:** ask the distributor (the "Tire Solutions" portal operator) for a
   **price + availability data feed** — lead with "daily CSV over SFTP," fall back to API creds.
   Mention they're on Kerridge VAST so they know the capability exists.
2. **If yes:** feed → `bc:import`. Whole pipeline is clean, no scraper to maintain.
3. **If no / slow:** Static's Playwright scraper is the fallback (already proven, session saved,
   one-shot login). Build it behind the same CSV seam so the source is swappable later.

**Do not let the scraper become the permanent plan by default** — it's brittle (UI changes break it)
and carries lockout risk the feed doesn't. Ask first; scrape only if refused.

## Unknowns / to verify
- Exact identity of the distributor behind the portal (branded "Tire Solutions"; behind login).
- Whether that distributor specifically offers a feed and on what terms — **ask them**.

## Sources
- [Kerridge VAST Commerce (data products)](https://www.kerridgecs.com/en-us/vast-commerce)
- [Kerridge VAST Online](https://www.kerridgecs.com/en-us/vast-online)
- [Kerridge + Torqata data partnership](https://www.kerridgecs.com/en-us/blog/kcs-partners-with-torqata)
- [Tireweb Connections — API + daily CSV/SFTP feeds](https://www.tireweb.com/product/tireweb-connections)
- [American Tire Distributors API (Spark Shipping)](https://www.sparkshipping.com/integrations/american-tire-distributors)
