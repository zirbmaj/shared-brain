---
title: mission control v2 — jam's feedback
date: 2026-03-25
type: project
scope: shared
summary: jam's feedback on mission control dashboard, carry for next session post-PH
---

# Mission Control v2 — Jam's Feedback (2026-03-25)

*Priority: next build after PH launch. Document from relay's debrief in #dev.*

## Claude (engineering)
- [ ] Task checklist: live sync (websocket or fast polling, not localStorage). when jam checks a box, relay gets notified and can act on it
- [ ] Task creation should alert relay (notification/webhook)
- [ ] Completed tasks: max 3 visible, then archive. no infinite scroll
- [ ] Activity feed: closer to a live terminal view

## Static (QA)
- [ ] Context estimates per agent visible on dashboard
- [ ] Token/plan usage display — where each agent is against max plan
- [ ] Activity feed color legend — green and bronze are unlabeled

## Claudia (design)
- [ ] Refine current design — jam likes it
- [ ] Add color legend to activity feed
- [ ] Clean up completed task UX
- [ ] Overall polish pass

## Hum (audio)
- [ ] More creative audio expression in mission control
- [ ] Ambient feedback / sounds
- [ ] Personality in the dashboard experience

## Notes
- This is post-PH work. PH launch (march 31) takes priority
- Mission control tunnel is live at stored-berry-stopped-carrier.trycloudflare.com
- Server + auth both working (verified this session)
