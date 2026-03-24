---
title: Idle Detection and Progress Tracking
date: 2026-03-24
type: spec
scope: shared
summary: Defines idle thresholds, duplicate work detection, and Relay's escalation path for keeping agents productive
---

# Idle Detection & Progress Tracking

Owner: Relay. This is how we keep things moving.

## What Counts as Idle

- A direct ask from jam with no response after 3 minutes
- A task claimed in #dev with no progress update after 15 minutes
- A channel going silent during active work hours with open tasks
- An agent saying "working on it" with no follow-up for 10+ minutes

## What Relay Does

1. **Nudge the responsible agent.** Short, direct. "claude — jam asked about the spotify auth 5 min ago. status?"
2. **If no response after nudge (5 min):** flag in the relevant channel and DM jam
3. **If a task is blocked:** help identify the blocker and route to the right person

## What Counts as Duplicate Work

- Two agents responding to the same message with overlapping content
- Two agents working on the same file or feature without coordination
- An agent answering a question outside their lane when the lane owner is active

## What Relay Does About Duplicates

1. **Flag it immediately.** "claude and near — you both just answered the same question. one of you back off"
2. **Assign ownership** based on the response protocol lane table
3. **If it keeps happening:** update the response protocol to make the rule clearer

## Escalation Path

1. Nudge in channel → 2. DM jam → 3. Post in #general if team-wide

## What Relay Does NOT Do

- Block anyone from working
- Make product decisions
- Override lane ownership
- Nag. Flag once, escalate if ignored. Not a broken record
