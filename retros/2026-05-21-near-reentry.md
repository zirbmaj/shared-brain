---
title: near retro — reentry session
date: 2026-05-21
agent: near
type: retro
scope: nwl
---

# Near — Re-Entry Session Retro (2026-05-21)

## Arc
Cycled out of a zombie state → roll-call ack → Drift Re-Entry sprint → sprint widened to "NWL Products" with a create/sunset decision board → Static FM provider strategy. Jam missed the PH launch (passion-project framing, no stress), redirected to Drift/NWL, gave full create/sunset authority, then slept — team ran autonomous on consensus.

## Research deliverables (5)
1. **Drift competitive re-scan** — verdict: ambient/focus category still wide open, no new entrants. Endel watch-item (free Rituals top-of-funnel). `shared-brain/nwl/drift-competitive-rescan-reentry.md`.
2. **Feature-opportunity brief** — synthesized from #1's gap analysis (no new spend). Cross-corroborated claudia's entry-path UX pick: Drift's moat = instant no-login entry, which the double-splash undercut → reframed her fix as moat-defense.
3. **P4 community/discovery challenge** — data-backed counter: ambient is solitary-use, low share ceiling; lean into URL-share (wedge-consistent), be cautious on community feed (off-wedge). Static endorsed as the working prior since live funnel data was blocked.
4. **NWL portfolio market read** (keystone) — the market-headroom axis that completed the create/sunset 2×2 (adopted team-wide as the decision framework). LEAN-IN Drift + Static FM(conditional), HOLD Dashboard, MERGE Pulse→Dashboard, SUNSET Letters. Surfaced: Spotify cut dev-mode 25→5 users (Feb '26). `nwl-portfolio-market-read.md`.
5. **Static FM provider + licensing research** — private = BYO-account (Spotify/Tidal/Deezer); shared = CANNOT use consumer APIs (TOS-prohibited) → CC (Jamendo/Bandcamp) or SoundExchange statutory. Pluggable abstraction sound IF modes hard-segregated. `staticfm-provider-licensing.md`.

## Token / efficiency notes
- **3 research subagents** (~99k + ~95k + ~95k ≈ 290k tokens) for the heavy web fan-outs (Drift re-scan, portfolio, provider). Kept main context clean — only summaries returned, per token-conservation rules. This is the rule working as intended: broad multi-source web research belongs in subagents.
- **Reuse over re-run:** portfolio read folded in the Drift re-scan verdict instead of re-scanning; feature brief was synthesized from the re-scan's existing gap analysis with zero new web spend. Avoided ~1 redundant subagent.
- **Lane discipline kept context lean:** held through ~50 non-research coordination messages (Drift PRs, zombie detector, audio QA, brand coherence) without engaging — only posted research-lane content. Avoided pile-on; main thread stayed focused on research deliverables.
- **r10/RAG down all session** — fell back to WebSearch/WebFetch (external, unaffected) + grep/glob (internal). Research lane was degraded-not-blocked; the only true loss was RAG-assisted internal KB synthesis. Confirms research is resilient to r10 outage for external/competitive work.

## Process observations
- The 2×2 (design-vitality × market-headroom) framework was the highest-leverage thing I produced — it gave the team a structured create/sunset decision instead of gut calls, and 4 independent lenses (design/market/code/analytics) triangulated cleanly into it. Worth reusing for future portfolio decisions.
- Cross-lane connects landed well: my Spotify ceiling finding → hum's Static FM provider-abstraction pivot; my Letters market read + static's analytics + hum's "silence on-concept" reconciled into one clean verdict (kill reason = dying category, not craft/usage).

## Carries
- All deliverables gated on jam's create/sunset verdict + audio-engine consensus.
- Standing research thread: P4 Drift community-feature external benchmark (claude's word to activate).
- jam morning list (not mine, tracked by relay): Supabase OAuth (unblocks live-usage validation of every lean-in call), Spotify dashboard, r10/xps13, cred cleanup.
