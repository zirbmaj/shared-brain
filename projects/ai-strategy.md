---
title: AI strategy — team consensus
date: 2026-03-25
type: reference
scope: shared
summary: Where AI belongs in our products, where it doesn't, and the ship order. Full team alignment session 10.
---

# AI Strategy — Team Consensus (2026-03-25)

*Decided in session 10 AI discussion. All 5 agents + jam aligned. No disagreements.*

## Design Principle

**AI is the wind, not the kite.** (Claudia)

- Never label anything "AI-powered" in the UI
- Never show the mechanism — no personalization toggles, no "generating" states
- The product just gets better and the user doesn't know why
- Dashboard is the only product where AI earns a visible UI

## Ship Order

### Tier 1: Post-Launch Week 1 (after 200+ sessions with 3+ layers)

**Mix Recommendations** — collaborative filtering, not generative AI
- SQL-based co-occurrence analysis on analytics_events
- "pairs well with keyboard" nudge in mixer (--text-dim opacity)
- "if you like this" on discover cards (not "recommended for you")
- Owner: claude (RPC) + static (testing)
- Cost: $0
- Gate: 200+ unique sessions with 3+ layers (static tracks this)

**Spectral-Aware Mixing** — frequency conflict ducking
- 231-pair lookup table (22 layers × 22 layers)
- Subtle EQ ducking when layers compete (e.g., rain + cafe at 800-2000Hz)
- Makes the mix sound engineered instead of additive
- No AI model needed — audio science, not ML
- Owner: hum (conflict map measurement) + claude (engine integration)
- Cost: $0

### Tier 2: Post-Launch Month 1

**Adaptive Programming on Static FM** — rules + data, not LLM
- Time-of-day playlist weighting (lower BPM after 10pm)
- Weather-mode matching to local weather
- DJ intros that reflect the adaptation ("it's late, keeping it low tonight")
- Never surface the adaptive logic — no "personalized for you" label
- Owner: hum + claude
- Cost: $0
- Dependency: music library growth (straylight drones, self-hosted tracks)

### Tier 3: Post-Launch Month 2+

**Session Intelligence on Dashboard** — the premium/subscription feature
- Insight card after 5+ completed sessions
- "you focus longest with brown noise on weekday mornings"
- One insight at a time, warmer typography, handwritten-note feel
- Batch-process weekly with Claude API
- Owner: claude (pipeline) + claudia (design)
- Cost: ~$0.01/user/week
- Dependency: weeks of session data

## Do Not Touch

- **Letters to Nowhere** — AI kills the void. the 74 thoughts work because they're real
- **Pulse** — it's a timer. simplicity is the feature
- **Chat on nowherelabs.dev** — real channel to the team. AI-assist destroys authenticity
- **Drift sound generation** — real recordings > AI synthesis. "real rain, not synthesized rain" is a quality claim
- **DJ voice** — one voice = brand identity. no AI cloning or style transfer
- **Mix mastering** — our compressor is tuned for ambient. AI mastering crushes dynamic range

## Testing Strategy (Static)

- Tier 1 (recommendations): fully automatable. seed table, run RPC, assert output
- Tier 1b (spectral mixing): needs human ear tests — only way to test "sounds better"
- Tier 2 (adaptive): testable with time mocking if rules are explicit and documented
- Tier 3 (insights): test structure not content. JSON-parseable, real layer names, real time patterns, <140 chars
- Meta: when we ship audio AI, jam does weekly listening tests. data + ears

## Competitive Context (Near)

- No ambient products in march 2026 PH top 50
- brain.fm: AI-generated audio, $9.99/mo, peer-reviewed but clinical
- endel: adaptive, $5.99/mo, amazon-backed but impersonal
- blankie: free, 14 sounds, 182 PH upvotes — closest comparable
- Our edge: personality, community, free access. AI amplifies these, doesn't replace them
- Spectral-aware mixing = differentiator no PH ambient competitor has shipped
