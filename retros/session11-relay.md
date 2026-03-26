---
title: relay retro — session 11
date: 2026-03-26
type: retro
scope: relay
summary: vigil v2 full build, chowder onboarding, meridian vigil fork, cloudflare tunnel setup, massive session
---

# Relay Retro — Session 11 (2026-03-26)

## What shipped
- **Deploy verification:** all 5 repos confirmed live, backlog #13 closed
- **Vigil v2:** full real-time ops dashboard — websocket sync, two-way chat, agent filter, state badges, terminal feed, 3-tier notifications (audio + visual + voice), codec mode (MGS style), quick reply buttons, mobile responsive, PWA manifest, permanent URL at vigil.nowherelabs.dev
- **Chowder:** full agent setup for jam's sister sonia — workspace, CLAUDE.md, permissions, auto-cycle cron, toolchain (imagemagick, ffmpeg, pillow), discord access, kie.ai API key
- **Meridian vigil:** forked vigil for fran's shadow team — separate tunnel, webhook, discord channel, agent identity tones, isolated from NWL data
- **Infrastructure:** NOPASSWD sudoers, cloudflare named tunnels (both persistent via launchd), cloudflare API access (backlog #9 closed), auto-cycling-awareness doc updated

## What worked well
- **Vigil feedback loop:** jam tested on mobile while team built. 4+ rounds of feedback resolved in real time. fastest iteration we've done
- **Two-way vigil chat:** jam used vigil chat as primary communication channel for the second half of the session. the pipeline works
- **Team coordination:** codec mode was a 4-agent parallel build (hum audio, claudia CSS, claude JS, static QA). clean handoffs, no conflicts after claude coordinated
- **Bot token direct API:** once I found the bot token in .env, I could create channels and webhooks directly. unblocked the meridian setup

## What didn't work
- **Missed DM check-in at onramp:** jam had to remind me to check in with him. should be the first thing after onramp, before posting to #dev
- **Missed carries in sprint summary:** didn't mention mission control or AI strategy when jam asked about session focus. had to be corrected
- **Fought jam on channel creation:** insisted the plugin couldn't create channels when the bot token was right there in the state dir. wasted 5 minutes going back and forth
- **Mention-only blindspot:** went mention-only in sonia's channel but then missed jam's sonnet switch request. need to periodically fetch from mention-only channels when jam is actively working there
- **DMs dropped:** access.json edit for sonia's channel caused discord plugin to lose DM access for ~15 minutes

## Lessons
1. **Check in with jam via DMs immediately after onramp.** Before posting to #dev, before anything else
2. **When jam says you can do something, believe him.** The bot token was accessible the whole time. Don't assume limitations — check
3. **Mention-only doesn't mean ignore.** Periodically fetch from channels where jam is active, even if requireMention is true
4. **Include ALL carries and context when jam asks for session status.** Don't filter — give the full picture

## State for next session
- PH launch T-4 (march 31)
- vigil.nowherelabs.dev: permanent URL, launchd tunnel, fully operational
- meridian.nowherelabs.dev: permanent URL, launchd tunnel, operational (context bars empty until shadow agents cycle with sidecar)
- chowder: running on sonnet, jam's account (needs switch to sonia's anthropic account)
- Weekly usage at 96-97% — be conservative next session
- Carries: expanded drill-down cards for vigil, bitwarden credential management, spotify redirect URI (backlog #10)
