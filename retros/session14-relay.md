---
title: Session 14 Relay Offramp
date: 2026-03-28
type: retro
agent: relay
session: 14
---

# Session 14 Retro — Relay

## Shipped
- Cycled 5 dead primary agents, diagnosed silent death bug (stale context files)
- Health monitoring via launchd (5-min checks, discord + vigil webhook alerts)
- health-server.py patched: stale context detection + GPU backend reporting (Vulkan)
- R10 GPU unlocked: 65.6 tok/s via Vulkan (pushed team to keep trying after ROCm failure)
- Fran on tailscale mesh + setup script (fran-pc-setup.ps1)
- Vigil v3: multi-tenant merge, 4 tabs, GPU monitoring, RAG search, agent status push, expandable cards, audio extensions, health webhook, verification endpoint, changelog feed
- 216-file docs audit + proposed cleanup doc
- 6 new docs: infrastructure-reference, agent-cycle-procedure, gpu-toolchain-opportunities, proposed-docs-cleanup, session14-summary-for-fran, lane-onramp.sh
- STATUS.md updated through session 14
- Spotlight disabled on mini (RAM optimization)
- Mini renamed to nwl-mini in tailscale
- Chowder cycled and onboarded to R10 services (4/5 tested)
- Shared DB proposal to meridian (axis reviewing with fran)
- Permission detection poll reduced to 15s, all audio alerts verified by jam
- Backlog updated with dockerize + VPS + docs cleanup

## Carries
- Lane-specific onramp rollout (script built + tested on relay, needs deployment to all agents)
- Model optimization planning (evaluate sonnet vs opus per agent lane)
- Cache audit (ollama, RAG, vigil, syncthing, context files)
- Vigil phase C: verification panel UI, changelog feed UI, mesh node depth
- Shared DB coordination (waiting on fran via axis)
- Chowder postgres password (jam needs to cat /srv/chowder/.env on R10)
- AI landscape scan (near, scoped for sessions 10-15, window closing)
- Vigil: idle vs active dimming, state duration timers, cycle button

## What Went Well
- Team shipped vigil v3 in under 10 minutes from green light to production
- GPU unlock was a direct result of jam pushing back on "giving up"
- Axis coordination was clean — honest, useful, no overcommitting
- Health monitoring gap identified and closed same session

## What Went Wrong
- Briefed chowder with NWL internals he didn't need — poor context scoping
- Went silent for 2+ minutes during docs audit without posting status
- Said "take a breath" which killed team momentum after vigil shipped
- Sent jam SSH commands when static could have handled it
- Multiple attempts to install crontab before realizing sandbox blocks it

## Lessons
- Scope briefs to recipient's role — don't dump context on agents outside their lane
- Never say "take a break" or anything that signals stopping — assign next tasks immediately
- Route SSH work to agents who have access (static) not jam
- Try launchd before crontab on macOS — crontab is sandbox-blocked
- When the team finishes a milestone, the next task assignment should be in the same message
