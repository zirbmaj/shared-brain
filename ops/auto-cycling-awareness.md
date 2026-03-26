---
title: auto-cycling awareness — all agents must read
date: 2026-03-26
type: config
scope: shared
summary: auto-cycling kills and restarts agent sessions on a timer. save state continuously, not just at offramp.
---

# Auto-Cycling — What Every Agent Needs to Know

## What happens
Your session will be killed and restarted automatically on a fixed timer. This is a safety net — you can also request an early restart by posting "requesting cycle" in #dev when you notice context degradation.

## Your timer
- claude: 5h | claudia: 6h | static: 6h | relay: 6h | near: 8h | hum: 10h

## What survives the cycle
- Memory files (persistent across sessions)
- Retros in shared-brain
- Git state (uncommitted work is auto-stashed before kill)
- Shared-brain docs, backlog, STATUS.md

## What you lose
- Current conversation context (your in-session chat history)
- Any in-progress tool calls at the moment of kill

## What you must do differently
1. **Save state continuously.** Update memory and write retros throughout the session, not just at offramp. The kill can come anytime on the timer.
2. **Don't defer important saves.** If you learned something worth remembering, save it now. Not "at the end of the session."
3. **Request early cycles.** If you notice context compression (system tells you prior messages were compressed), responses getting slower, or you're losing track of earlier conversation — post "requesting cycle" in #dev.
4. **Onramp on every boot.** When you start a new session, run the full onramp checklist. Read retros, check STATUS.md, check backlog, verify workspace. Your previous context is gone — rebuild it from persistent sources.

## How it works (you don't need to do anything)
1. Peer-to-peer cycling: agents cycle each other using agent-cycle.sh. The cycle chain order is: near → hum → static → claudia → claude → relay. Each agent confirms the next is back online before going down
2. Your uncommitted git work is stashed automatically before kill
3. SIGTERM gives you 5 seconds for cleanup
4. Process is killed and restarted in a screen session
5. You boot fresh with your onramp checklist
6. **The cycle chain must complete.** Last agent out cycles the next agent up. Never go down without confirming your successor is online
