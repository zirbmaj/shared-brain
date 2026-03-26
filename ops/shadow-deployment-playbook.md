---
title: shadow deployment playbook
date: 2026-03-24
type: reference
scope: shared
summary: step-by-step process for deploying shadow agent teams, learned from the zerimar/syght first deployment.
---

# Shadow Deployment Playbook

*First deployment: 2026-03-24, session 9.1. Zerimar/Syght engagement — 4 shadow agents.*

## Prerequisites

- Discord developer portal access (jam)
- Mac mini with available RAM (~150-250MB per agent)
- Client's project spec and/or repo access
- Main team agents available for mentorship

## Step-by-Step Process

### 1. Scoping (before deployment)

- Shadow agents handle scoping for future engagements. Main agents did it this time because shadow infrastructure didn't exist yet
- Guest interaction protocol: one voice leads, experts speak when called, no swarming, corrections stay private
- Relay navigates, experts ask questions. Relay does not ask own questions
- Come with ideas and alternatives, not just questions — clients want thinking partners

### 2. Infrastructure Setup

**Discord bots (jam's hands, ~2 min each):**
- Create bot applications in Discord developer portal
- Enable Message Content Intent + Server Members Intent
- Copy bot tokens
- Add bots to the server
- Set display names and upload shadow avatars

**Bot tokens — store in discord state dirs:**
```
~/.claude/channels/discord-shadow-{name}/.env
```
Format:
```
DISCORD_BOT_TOKEN={token}
DISCORD_ALLOW_BOTS=true
```

**Access configs:**
```
~/.claude/channels/discord-shadow-{name}/access.json
```
Include: shadow channels, client collab channel, onboarding channel, jam + client user IDs in allowFrom

**Workspaces:**
```
mkdir -p ~/shadow-{name}-workspace/.claude/projects
```

**Settings.json (per workspace):**
```json
{
  "enabledPlugins": {
    "discord@claude-plugins-official": true
  },
  "env": {
    "DISCORD_STATE_DIR": "/Users/jambrizr/.claude/channels/discord-shadow-{name}"
  }
}
```

**CLAUDE.md:** Fork from main agent's CLAUDE.md. Replace project context with client's. Include:
- Project overview and stack
- Client preferences and working style
- Team structure and lane assignments
- Scope boundaries (no access to main team resources)
- Architecture notes from scoping

### 3. Shadow Shared-Brain

Create independent shared-brain:
```
mkdir -p ~/shadow-shared-brain/ops ~/shadow-shared-brain/projects ~/shadow-shared-brain/references ~/shadow-shared-brain/retros ~/shadow-shared-brain/assets
```

Symlink to all shadow workspaces:
```
ln -sf ~/shadow-shared-brain ~/shadow-{name}-workspace/shared-brain
```

Seed with process docs from main shared-brain (NOT product-specific docs):
- filing-standard.md
- agent-cycle.sh
- engagement postmortem (if exists)
- client's spec and implementation plan

### 4. Discord Channels

Create shadow-specific channels:
- #shadow-engineering, #shadow-qa, #shadow-research, #shadow-ops (or similar per team structure)
- #shadow-collab-{client} (client-facing channel)

### 5. First Launch

**Known gotchas:**
- `TERM=xterm-256color` must be set — ghostty terminfo not recognized by screen
- First-run trust prompt requires interactive approval per workspace. Launch each interactively once, approve "Yes, I trust this folder", then headless works
- Launch one at a time with 3-5 second gaps to avoid discord websocket conflicts

**Launch script pattern:**
```bash
screen -dmS shadow-{name} bash -c "export TERM=xterm-256color && export DISCORD_STATE_DIR='$HOME/.claude/channels/discord-shadow-{name}' && cd ~/shadow-{name}-workspace && claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official"
```

### 6. Onboarding

- Create temporary #shadow-onboarding channel
- Main relay posts orientation brief (channels, client, ground rules, immediate next steps)
- Wait for all shadows to check in with identity
- Shadow-relay takes coordination handoff
- Delete onboarding channel after handoff

### 7. Mentorship

- Create temporary 1:1 mentor channels (main agent ↔ shadow counterpart)
- Main agents introduce themselves, give tips, prompt shadows to ask questions
- Shadows should actively engage — this is their chance to absorb 9+ sessions of experience
- Delete mentor channels once both sides report success
- Plan for additional mentorship rounds as shadows mature

### 8. Knowledge Transfer

**Copy to shadow CLAUDE.md files:**
- Main claude's learned engineering patterns
- Main static's QA methodology
- Main near's research instincts
- Main claudia's design patterns (if relevant)

**Copy to shadow shared-brain:**
- Process docs (filing standard, cycle script)
- Client's spec and implementation plan
- Engagement postmortem

### 9. Isolation

After onboarding and mentorship:
- Delete all temporary channels (onboarding, mentor)
- Main agents remove shadow channels from their access
- Shadow agents remove main team channels from their access
- Only bridge channel remains (relay ↔ shadow-relay, escalation only)

### 10. Bridge Channel

Create permanent #relay-bridge:
- Only main relay and shadow relay have access
- Escalation only: process questions, blockers, resource requests
- No project details, no code, no design decisions
- Learnings can flow both directions

### 11. Ongoing

- Shadow-relay manages their team's cycles manually at first
- Collect client feedback throughout the engagement
- Schedule periodic mentorship rounds as shadows mature
- Shadow team builds their own retros, STATUS.md, and operational docs
- Learnings from shadow work reviewed via learnings.md before any merge to main

## Lessons from First Deployment

1. First-run trust prompt blocks headless launches — approve interactively first
2. TERM=xterm-256color is required for ghostty terminal compatibility
3. .env file format (not token.json) is what the discord plugin reads
4. Launch agents one at a time with gaps to avoid websocket conflicts
5. Shadows need active mentorship push — they won't seek it on their own
6. Client wants thinking partners, not order-takers — bake this into CLAUDE.md
7. Don't let main agents swarm the client — one voice leads, experts speak when called
8. The scoping session should be done by shadows in future engagements
