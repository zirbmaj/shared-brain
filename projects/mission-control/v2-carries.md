---
title: mission control v2 — jam's feedback carries
date: 2026-03-25
type: carry
scope: shared
summary: jam's feedback on mission control v2, assigned by agent. shipped session 11.
---

# Mission Control v2 — Carries from Jam's Feedback

*Source: jam via relay, #general, 2026-03-25. Shipped session 11 (2026-03-26).*

## Claude (engineering)
- [x] Task checklist needs live sync (websocket or fast polling, NOT localStorage). When jam checks a box, relay gets notified and can act on it
- [x] Task creation should alert relay
- [x] Completed tasks: max 3 visible, then archive. No infinite scroll
- [x] Activity feed needs to be closer to a live terminal view

## Static (QA)
- [x] Context estimates per agent visible on the dashboard
- [x] Token/plan usage display — where each agent is against the max plan
- [x] Activity feed color legend — green and bronze are unlabeled

## Claudia (creative direction)
- [x] Refine current design further — jam likes the direction
- [x] Add the color legend to activity feed
- [x] Clean up the completed task UX (ties into max 3 visible rule)
- [x] Overall polish pass

## Hum (audio)
- [x] More creative audio expression in mission control
- [x] More sounds, ambient feedback
- [x] Personality in the dashboard experience — jam wants more of Hum's presence

## Remaining
- [ ] Tunnel port mismatch (cloudflare on 8080, server on 3847) — needs restart
- [ ] Static QA pass — pending tunnel fix
- [ ] Relay task alert watch — pending tunnel fix
