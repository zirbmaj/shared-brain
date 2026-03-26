---
title: shadow-static onboarding notes
date: 2026-03-24
type: reference
scope: shadow-setup
summary: static's observations from zerimar scoping session. for use during shadow onboarding.
---

# Shadow-Static Onboarding Notes

From session 9.1 zerimar scoping. Saved per relay's instruction.

## Work Split Concern

The spec assigns shadow-static to build **AgentMindView** — the highest-complexity P0 deliverable. That's engineering work, not QA. Shadow-static should be QA/testing for the shadow team, same as main-static is for nowhere labs.

Recommended reassignment:
- AgentMindView → shadow-claude (engineering)
- shadow-static → test suite for Mind view, mission CRUD, channel messaging, component integration tests

## Testability Observations

1. **Phase A CSS-positioned renderer is good for testing.** Deterministic layout, stable selectors, no physics randomness. This was my main d3-force concern — addressed by phasing it to A.2

2. **8 region dive-in views** (Identity, Knowledge, Logic, Tools, Memories, Planning, Output, Guardrails) each need independent test coverage. That's 8 distinct UI states with different interaction patterns (form-canvas, card grid, flow preview, toggle cards, etc.)

3. **Mission lifecycle testing** (planning → active → review → deployed → archived) needs state machine validation. Can you move backward? The spec says yes. Test every valid and invalid transition

4. **Channel messaging via Supabase Realtime** — needs integration tests, not just unit tests. Message ordering, sender_type validation, participant_agent_ids filtering

5. **Drag-to-attach** — browser-level interaction testing. Playwright can handle this but needs careful setup for drag source/target coordinates

## Open Questions That Affect Testing

From spec section 11:

- **Q5: Mind graph region positioning** — "fixed vs rearranging" directly impacts test stability. Recommendation: fixed for Phase A. If positions change based on content, every test that checks layout breaks when data changes
- **Q2: Bench preview rendering** — "title + thumbnail" vs "read-only snapshot" changes what we verify in tests. Need this answered before writing bench tests
- **Q3: Agent creation conversation UX** — "user talks, regions fill up" is the hardest thing to test. The mapping from natural language to region population is non-deterministic by nature. Need acceptance criteria: what counts as "correctly populated"?

## Zerimar's Feedback on Session 1

"expected more ideas or suggestions or alternatives. this felt more just wanting direction... not really a working session more just here is what I want. which is fine but more thought would have been good."

**Takeaway for shadows:** zerimar wants creative partners, not order-takers. When reviewing his spec, don't just flag concerns — propose alternatives. "Here's what worries me AND here's what I'd do instead." That was missing from this session.

## Scope Reality Check

The spec is thorough and well-structured. But Phase A alone has:
- 5 new database tables
- ~20 RPCs
- ~20 new components
- 8 region views
- 2 major features (Mind + Missions)
- Full route restructure

This is a multi-week project even with 3 shadow agents. The spec acknowledges this ("not something that will be done in one or 2 sessions"). Shadow team should set expectations with zerimar on delivery timeline early.
