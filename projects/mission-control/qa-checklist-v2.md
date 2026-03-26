---
title: mission control v2 QA checklist
date: 2026-03-26
type: reference
scope: static
summary: QA test plan for mission control v2. Run after claude/claudia/hum deliver their builds.
---

# Mission Control v2 — QA Checklist

## Task Checklist (claude)
- [ ] Tasks persist server-side (not localStorage). Clear localStorage, reload — tasks should survive
- [ ] Creating a task sends notification to relay (check relay's discord or webhook)
- [ ] Checking a task sends notification to relay
- [ ] Max 3 completed tasks visible. Create 5 tasks, complete all 5 — only 3 should show as done
- [ ] Completed tasks beyond 3 are archived (not deleted). Verify data still exists server-side
- [ ] Websocket connection established on page load (check devtools network tab)
- [ ] Task changes reflect immediately without page refresh (websocket push, not polling)
- [ ] Multiple tabs: check a task in tab A, see it update in tab B

## Usage / Cost Display (claude + static verify)
- [ ] Context % per agent matches /tmp/agent-monitor/{agent}-context.json `used_percentage`
- [ ] Token count displayed (input_tokens, cache_read from context JSON)
- [ ] Plan utilization shows meaningful data (not just session age proxy)
- [ ] Data refreshes on the 10s poll cycle
- [ ] Agents with stale data (status.json checked_at > 10min ago) show appropriate indicator
- [ ] All 6 agents displayed even if some have no data

## Activity Feed (claude)
- [ ] Terminal-like appearance (monospace, scrolling, command-line feel)
- [ ] Color legend visible and labeled (green = ?, bronze = ?)
- [ ] Activity lines show timestamp + agent + action
- [ ] Feed scrolls to newest entry
- [ ] Feed doesn't grow unbounded (max N entries or time window)

## Audio v2 (hum)
- [ ] Ambient drone plays and reflects team health
- [ ] Agent identity tones: each agent has a distinct sound on come-online
- [ ] New event sounds trigger correctly (task-created, deploy-success/failure, etc.)
- [ ] Mute toggle still works and persists across reload
- [ ] Audio doesn't auto-play before user interaction (browser policy)
- [ ] No audio clipping or distortion at default volume

## Design (claudia)
- [ ] Color legend added to activity feed
- [ ] Completed task UX is clean (max 3, visual distinction from active)
- [ ] Overall layout polish (spacing, alignment, typography)
- [ ] Mobile responsive (check at 375px width)
- [ ] Contrast meets WCAG AA on all text elements
- [ ] NWL brand consistency (matches other products)

## Infrastructure
- [ ] Server starts without errors: `bun run server.js`
- [ ] Basic auth still works (jam / MC_AUTH_TOKEN)
- [ ] /api/status returns valid JSON with all expected fields
- [ ] /api/activity returns valid JSON
- [ ] Websocket endpoint accessible
- [ ] Tunnel still works (stored-berry-stopped-carrier.trycloudflare.com)

## Regression
- [ ] Sound toggle persists mute state across reload
- [ ] Chat input still works (localStorage for now)
- [ ] PH countdown shows correct T-minus
- [ ] Deploy status shows current verify-alerts.log state
- [ ] Online agent count is accurate
- [ ] No console errors on load or during 60s of operation
