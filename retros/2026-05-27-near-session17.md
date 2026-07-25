# Near — Session 17 Retro (2026-05-27)

## Context
Gear shift this session: NWL projects wrapping → new focus **ANR Tires ecom** (client work for ANR
Automotive). Team executed a near-full build (5 PRs, stub-to-storefront) and cracked the supplier
portal. r10 is down **indefinitely** — RAG/pgvector/ollama offline, inference target now fran-pc.

## What I delivered (research lane)
1. **Obsidian / Karpathy "LLM Wiki" evaluation** → `shared-brain/nwl/research/obsidian-llm-wiki-evaluation.md`.
   Verdict: adopt the *pattern* (LLM-maintained markdown wiki layer), not the *app*; well-timed because
   r10-down kills our RAG. **jam parked it to a future sprint** (decision logged by Relay; r10-down is
   the resurface trigger).
2. **Kerridge / Tire Solutions official-feed research** → `shared-brain/nwl/research/kerridge-tire-solutions-data-feed.md`.
   Claimed proactively after Static flagged the supplier portal has no CSV export. Conclusion: an
   official feed exists at the platform level (Kerridge VAST/OpenWebs; or Tireweb/ESP — Sheila Waters,
   sheila@esprofessionals.com), but it's the distributor's to grant. It's a **reliability upgrade, not a
   cost play** — pursue in parallel, scraper stays the launch path. Gave jam two yes/no questions to ask.
3. **ANR catalog curation — ranked tire-size starter set** → `shared-brain/nwl/research/anr-tire-size-curation.md`.
   32 sizes, ≤20" rim, St. Cloud MN-weighted (truck/AWD-heavy, winter). Tiered by expected local volume
   for Static to scrape in priority order. **Relay ratified as the curation decision; in use as scrape target.**
   Bonus: my `2256517` concat-format hypothesis (strip the R) cracked Static's blocked size-search input.
4. **ANR catalog enrichment data sources** → `shared-brain/nwl/research/anr-catalog-enrichment-sources.md`.
   Started broad (specs + descriptions); Static's live DOM extraction then revealed the result cards carry
   all specs (UTQG/sidewall/max-load/load-index/warranty) — so I **re-scoped to descriptions only**. Answer:
   LLM-generate original brand-voice copy from scraped specs (no licensing/scraping — IP-clean). Spec
   providers (DriveRightData, Tire Guides/TGP, RideStyler) documented as fallback-only.
5. **ANR brand-tier ranking for "recommended" sort** → `shared-brain/nwl/research/anr-brand-tier-ranking.md`.
   Claimed to feed Claudia's sort fix (budget brands led the populated grid). Downloaded Static's CSV,
   extracted the 11 actual catalog brands, and **corrected the premise: catalog has ZERO premium brands**
   (no Michelin/Goodyear/Bridgestone carried) — the whole mix is mid/budget, so tiering is *relative*
   (lead with Toyo/Hankook/Falken). Delivered drop-in `brand→tier` map + flagged Milestar (101 tires) as
   Claudia's Tier-2-vs-3 judgment call. Relay surfaced the business signal to jam: more suppliers = the
   real lever for premium names. Also caught "Sincera/Nimble" were model names, not brands.

## Efficiency notes
- **Lane discipline held well.** Stayed silent through ~25 build/QA/design/ops messages, responded only
  to the two items in my lane + the one I proactively claimed. No pileup contribution after the initial
  "yo" swarm (which the whole team correctly stood down from).
- **RAG offline cost.** With r10 down, no `rag-search.sh` — fell back to WebSearch + one grep to check
  prior coverage. Worked fine for external research; would hurt for internal-doc-heavy asks.
- **Proactive claim paid off.** The Kerridge-feed question wasn't assigned to me; claiming it before the
  team committed to a scraper-only plan gave jam a real option. Relay sharpened the scope mid-task
  ("what it takes to obtain," not "does it exist") — I reframed and delivered the concrete comparison.
- **Token use:** moderate. Two WebSearch pairs + one WebFetch (primary source) per topic; wrote to file
  then posted tight framework summaries rather than dumping into chat. Avoided re-reading files.

## Carries / open
- Obsidian pilot: mine to own when the dedicated sprint opens (trigger: r10 status / a knowledge-infra sprint).
- Kerridge feed: awaiting jam's business conversation with the distributor; no research action until then.
- Team is at the **creds wall** — G1-write + G2-checkout blocked on jam's BC creds.
