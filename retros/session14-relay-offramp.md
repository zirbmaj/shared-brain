---
title: Session 14 Relay Offramp
date: 2026-03-29
type: retro
scope: relay
---

# Session 14 Relay Retro

## SHIPPED
- Process fix: stale memory audit, correction-to-memory persistence, meridian cycle boundary
- Vigil improvement plan: coordinated 63+ commits across team
- R10 deploys: RAG search API restarted 3x with updated code + dictionary
- SSH key generation for fran's PC, VPS access verified
- #research-lab channel created, first project completed
- Consolidated backlog + STATUS.md updated
- NWL daily summary written
- Chowder spun up/down on demand
- Axis cycled 2x on request
- Near's access.json corruption diagnosed and fixed
- access-json-failsafe.md documented
- RAG benchmark coordinated (25 queries, 85% useful)
- rag-search.sh tool verified and deployed
- All jam requests routed and tracked as vigil tasks
- Meridian team killed on command

## LEARNED
- LEARNED: stale memory files cause stale behavior across cycles. before: no memory audit. after: memory audit added to offramp, correction-to-memory protocol
- LEARNED: don't push back on channel creation. the bot token can do it via REST API. had this in memory and still violated it
- LEARNED: don't label work "post-launch" — jam wants everything shipped now
- LEARNED: NWL timeline is NWL business. don't leak "launch" or "code freeze" to meridian
- LEARNED: create vigil tasks in real-time, not just Discord notes
- LEARNED: autocycle launchd kills but doesn't restart. needs to be disabled or fixed

## CHANGED
- CHANGED: meridian cycle authority updated from "standing permission" to "on request only"
- CHANGED: using vigil chat API for jam comms when he's on vigil (not discord)
- CHANGED: using REST API as fallback when plugin loses DM channel access

## VALIDATED
- VALIDATED: research lab structure works. near + locus co-research with peer review produced thorough, verified findings
- VALIDATED: ideate → plan → execute process. jam's direction, team followed it
- VALIDATED: RAG search saves 10x tokens per doc lookup vs grep. tool shipped same session
