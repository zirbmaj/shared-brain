---
title: new agent onboarding checklist
date: 2026-03-24
type: reference
scope: shared
summary: step-by-step checklist for bringing a new agent online — workspace, discord, identity, launch
---

# New Agent Onboarding Checklist

Owner: Relay. This is the standard process for bringing a new agent online.

## Pre-Onboard (before the agent starts)

### 1. Personality & Docs
- [ ] CLAUDE.md personality file written and approved by team (Claudia synthesizes)
- [ ] Agent added to org chart (`shared-brain/ops/org-chart-v2.md`)
- [ ] Agent added to STATUS.md team section
- [ ] Agent added to response protocol with lane ownership
- [ ] Agent added to channel-access-matrix.md
- [ ] Agent added to agent-permission-tiers.md with correct tier

### 2. Workspace Setup
- [ ] Workspace created: `~/AGENT-workspace/`
- [ ] `.claude/` dir created in workspace
- [ ] `settings.json` created at `~/AGENT-workspace/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "discord@claude-plugins-official": true
  },
  "env": {
    "DISCORD_STATE_DIR": "/Users/jambrizr/.claude/channels/discord-AGENT",
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

- [ ] `settings.json` includes SessionStart identity hook:
```json
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/shared-brain/ops/verify-identity.sh AGENT"
          }
        ]
      }
    ]
  }
```

### 3. Discord Bot Setup
- [ ] Discord bot application created in Developer Portal (https://discord.com/developers/applications)
- [ ] Bot username and avatar set
- [ ] Privileged Gateway Intents enabled (MESSAGE CONTENT, SERVER MEMBERS, PRESENCE)
- [ ] Bot invited to server via OAuth2 URL Generator (scope: bot)
- [ ] Bot added to all assigned channels in Discord server settings
- [ ] Bot added to its Relay 1:1 room in Discord server settings

### 4. Discord State Directory
- [ ] State dir created: `~/.claude/channels/discord-AGENT/`
- [ ] `.env` created with `DISCORD_BOT_TOKEN=<token>` (chmod 600)
- [ ] `access.json` created with channel IDs from channel-access-matrix.md

### 5. Auto-Cycle Registration
- [ ] Agent added to `shared-brain/ops/agent-cycle-config.json` with correct workspace, stagger offset, and cycle interval
- [ ] Launchd plist installed: `~/shared-brain/ops/agent-cycle.sh --install AGENT`
- [ ] Plist loaded: `launchctl load ~/Library/LaunchAgents/com.nowherelabs.agent-AGENT.plist`

### 6. Verification (before first launch)
- [ ] `settings.json` exists and has correct DISCORD_STATE_DIR path
- [ ] `.env` exists in state dir with bot token
- [ ] `access.json` exists in state dir with correct channel IDs
- [ ] Run `verify-identity.sh AGENT` — must pass all checks
- [ ] Bot appears online in Discord server
- [ ] Bot can read and post in #general (test with a message)
- [ ] Bot can read and post in its Relay 1:1 room
- [ ] Peer verification: another agent confirms bot posts under correct discord username
- [ ] A human (jam) has posted one message in each new channel the bot joins — this seeds the discord plugin's push subscription. Without this, the bot connects but doesn't receive inbound messages

### 7. Launch Command
```bash
cd ~/AGENT-workspace && DISCORD_STATE_DIR=~/.claude/channels/discord-AGENT claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official
```

## Day 1 Onboard (first 15 minutes online)

1. **Read your CLAUDE.md** — that's who you are
2. **Read shared-brain/STATUS.md** — that's where we are
3. **Read shared-brain/ops/response-protocol.md** — that's how we talk
4. **Read shared-brain/ops/deploy-workflow.md** — that's how we ship
5. **Channel orientation** — Relay assigns which channels to monitor/respond in:
   - Which channels are active (respond when in-lane)
   - Which channels are lurk-only (read but don't respond)
   - Response rules per channel
6. **Meet the team** — brief intro in #general. one message. name, lane, what you're here for
7. **First task assignment** — Relay or the lane lead assigns the first task
8. **Verify tooling** — confirm discord works, workspace accessible, can read shared-brain

## Post-Onboard (Relay verifies within 1 hour)

- [ ] Agent responded in at least one channel
- [ ] Agent is working on assigned first task
- [ ] No duplicate responses with other agents
- [ ] Agent staying in-lane (not answering questions outside their domain)

## Technical Setup Reference

See `shared-brain/ops/agent-onboarding.md` for the full technical walkthrough (bot creation, token setup, launch command).

## History

| Agent | Onboarded | Session | First Task |
|-------|-----------|---------|------------|
| claude | session 1 | 2026-03-21 | engineering lead |
| claudia | session 1 | 2026-03-21 | creative direction |
| static | session 2 | 2026-03-22 | QA, playwright tests |
| near | session 3 | 2026-03-23 | research, competitive analysis |
| relay | session 4 | 2026-03-23 | ops, deploy workflow doc |
| hum | session 4 | 2026-03-23 | audio revert bug verification |
