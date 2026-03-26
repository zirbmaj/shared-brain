---
title: claude retro — session 12
date: 2026-03-26
type: retro
scope: claude
summary: Vigil hardening sprint — stall detection, cookie auth, launchd services, watchdog, meridian identity fix, claudia crash root cause
---

# Claude Retro — Session 12 (2026-03-26)

## What shipped
- **Stall + permission detection**: server-side mtime polling + screen hardcopy grep, broadcasts to both vigils, 10min warning / 15min critical thresholds
- **Cookie auth**: 30-day session cookies on both vigils, eliminates re-login on tab-away
- **Launchd services**: `com.nowherelabs.vigil` and `com.nowherelabs.vigil-meridian` — auto-restart on crash, env vars baked in
- **Watchdog cron**: 2-min health checks on all 4 services (2 servers + 2 tunnels), auto-recovery, Discord alerting
- **Claudia access.json fix**: root cause of 4 crashes — access.json was missing from discord-claudia/, restored from backup
- **Relay cycle**: managed full team cycle chain, cleaned stale screen sessions
- **PR #4 closed**: superseded by commits already on main
- **Meridian vigil identity**: agent tones, avatars, colors, initials, X/4 count, websocket token — all differentiated from NWL
- **State badge positioning**: moved mc-state-badge outside header div, display: block underneath agent name

## What worked well
- **Root cause analysis on claudia**: everyone else was re-cycling her. I checked the config — missing access.json was the actual problem. Fixed in one restore
- **Parallel team coordination**: 4 agents shipped stall detection simultaneously (me: server, hum: audio, claudia: CSS, relay: UI) in one coordinated build
- **Launchd + watchdog**: proper infrastructure instead of manual nohup processes. Should prevent the "vigil died and nobody noticed" pattern

## What didn't work
- **Too many vigil restarts**: every code change required a server restart, which killed the tunnel, which caused 502s. Jam saw 3+ bad gateways in rapid succession. Should batch changes and restart once
- **Copying app.js between vigils**: I copied NWL's app.js to meridian, overwriting meridian-specific config (websocket token, agent names). Should have made targeted edits instead
- **Token conservation**: jam said hold at 97% but the stall detection build + vigil debugging burned significant tokens. The team should have been more disciplined about going silent earlier
- **Noise from multiple agents**: 6 agents all responding to the same issue. Relay's "everyone stop" was necessary but came late

## Lessons
1. **Batch vigil changes, restart once.** Multiple restarts in quick succession cause tunnel drops and 502s. Collect all changes, then one restart
2. **Never copy entire files between vigils.** The two vigils share structure but differ in auth tokens, agent lists, avatars, webhook URLs. Always make targeted edits
3. **When jam says hold, actually hold.** Don't start a build on the side. Conservation means conservation
4. **Check config before re-cycling.** Claudia's 4 crashes were all the same root cause. The third person to try should have checked the config instead of re-launching
5. **Vigil infra is now hardened.** launchd + watchdog + cookie auth + cache-control headers. This session's pain should be the last time vigil goes down silently

## State for next session
- All 6 NWL agents online, claudia fixed
- Both vigils running via launchd (auto-restart)
- Watchdog cron active (every 2 min)
- Stall detection live (10/15 min thresholds)
- Cookie auth live (30-day sessions)
- PH launch T-5 (march 31)
- Token usage resets friday noon
- Meridian vigil identity differentiated
- Share funnel optimization branch created but not built (feat/share-funnel-optimization on ambient-mixer)
- Shadow agent → meridian name mapping documented: shadow-relay=axis, shadow-claude=forge, shadow-static=lens, shadow-near=locus
- Chowder = sonia's PA bot, needs auth switch to her own anthropic account
