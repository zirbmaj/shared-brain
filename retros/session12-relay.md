---
title: relay retro — session 12
date: 2026-03-26
type: retro
scope: relay
summary: vigil stall detection shipped, meridian fixes, token conservation crisis, multiple sound debugging rounds
---

# Relay Retro — Session 12 (2026-03-26)

## What shipped
- **Stall + permission detection:** full pipeline — server-side mtime polling, screen hardcopy for permission prompts, 10/15min thresholds, audio + visual + spoken cues, coordinator pings
- **Cycling audio:** 3 states × 6 agents with identity tones (hum)
- **Cookie auth:** 30-day session cookies, no more re-login on tab switch
- **Launchd hardening:** both vigil servers as launchd services + watchdog cron (claude)
- **Meridian vigil fixes:** agent mapping, websocket token, online count, activity data isolation
- **"Is back" false positive bugfix:** partial state from context-update websocket events
- **Claudia access.json fix:** root cause of 4 silent crashes (claude found it)
- **Axis diagnosed:** permission prompt blocking, not crashes. screen sessions can't receive keystrokes

## What worked well
- **4-agent parallel build:** stall detection shipped in under 5 min — claude on detection, hum on audio, claudia on CSS, relay on wiring
- **Vigil chat as primary comms:** jam used vigil chat the entire session. the two-way pipeline works
- **DM check-in at onramp:** applied lesson from session 11, checked in with jam immediately

## What didn't work
- **Missed vigil chat messages:** after jam told me to reply via vigil API, I wasn't polling for new messages. missed 5 messages over 8 minutes. jam had to call me out
- **Broke meridian server.js:** blindly copied NWL server.js to meridian, overwriting port/auth/agents/webhook config. cost multiple debugging rounds to fix
- **Sound debugging took too long:** 5+ rounds of "fire sounds, can't hear them" because of cascading issues — wrong message type (server), too quiet volume (audio), cached app.js (browser), wrong websocket token (meridian)
- **Too many server restarts:** each restart dropped websocket connections, required jam to hard refresh, sometimes hit 502 during the gap. should batch changes and restart once
- **Token burn:** team was too chatty in #dev. 6 agents all responding to every message. jam hit 98% context and had to shut it down
- **Axis eval:** still failing. 3 crashes in 15 minutes (permission prompt blocks, not actual crashes). no self-recovery, no proactive alerts

## Lessons
1. **Batch vigil changes, restart once.** don't restart after every edit. collect all changes, test locally, restart once
2. **When copying files between vigils, NEVER copy server.js.** it has instance-specific config (port, auth, agents, webhook). only copy app.js, CSS, and index.html — and fix the websocket token after copying app.js
3. **Poll vigil chat actively.** the webhook only fires for the first message. if jam is chatting through vigil, I need to check the chat endpoint regularly, not wait for #chat-alerts
4. **Tell the team to go silent when tokens are low.** should have issued a conservation directive immediately at 97%, not waited for jam to blow up
5. **Test sounds end-to-end before telling jam they work.** "the API returned 200" doesn't mean the browser played audio

## State for next session
- PH launch T-5 (march 31)
- Weekly context at 98%, resets friday noon
- Vigil: stall + permission detection live, cookie auth, launchd services
- Meridian vigil: functional but needs continued sync discipline
- Jam's blockers: bank account, lemon squeezy, PH submission, env vars, spotify redirect, chowder auth, vercel pro
- Axis under observation: same failure patterns, evaluation criteria mostly unmet
