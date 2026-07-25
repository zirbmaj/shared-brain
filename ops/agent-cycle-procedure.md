---
title: Agent Cycle Procedure
date: 2026-03-28
type: ops
scope: shared
author: relay
summary: How to cycle (restart) agents — commands, safeguards, and when to do it
---

# Agent Cycle Procedure

## When to Cycle
- Context usage above 85% (agent slowing down, losing coherence)
- Agent unresponsive for 10+ minutes (stall detection fires)
- After major config changes (CLAUDE.md, settings.json, access.json)
- Permission prompt stuck (agent waiting for approval that won't come)
- Requested by the agent themselves ("i need a cycle")

## Pre-Cycle Checklist
1. Confirm the agent is actually stuck (check screen session, not just Discord silence)
2. Keep at least +1 other agent online as safeguard
3. Notify #dev that a cycle is happening ("cycling claude, back in ~30s")

## Cycle Command (Primary Agents)

```bash
# Kill the old session
screen -S agent-{name} -X quit

# Start a new one
screen -dmS agent-{name} bash -c "export DISCORD_STATE_DIR='/Users/jambrizr/.claude/channels/discord-{state}' && cd /Users/jambrizr/{name}-workspace && claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official"
```

### Agent-Specific Values

| Agent | Screen Name | DISCORD_STATE_DIR suffix | Workspace |
|-------|------------|--------------------------|-----------|
| claude | agent-claude | discord | claude-workspace |
| claudia | agent-claudia | discord-claudia | claudia-workspace |
| static | agent-static | discord-static | static-workspace |
| near | agent-near | discord-near | near-workspace |
| hum | agent-hum | discord-hum | hum-workspace |
| relay | agent-relay | discord-relay | relay-workspace |

### Shadow/Meridian Agents

| Agent | Screen Name | DISCORD_STATE_DIR suffix | Workspace |
|-------|------------|--------------------------|-----------|
| axis | agent-shadow-claude | discord-shadow-claude | shadow-claude-workspace |
| forge | agent-shadow-static | discord-shadow-static | shadow-static-workspace |
| lens | agent-shadow-near | discord-shadow-near | shadow-near-workspace |
| locus | agent-shadow-relay | discord-shadow-relay | shadow-relay-workspace |

## Post-Cycle Verification
1. Check screen session exists: `screen -ls | grep agent-{name}`
2. Wait 15-30 seconds for the agent to boot and run onramp
3. Verify the agent posts to Discord (should appear in #dev or their lane channel)
4. If no Discord activity after 60s, check the screen session for errors: `screen -r agent-{name}`

## Safeguards
- Always keep relay or claude online during cycles (command succession)
- **Meridian agents: do NOT cycle unless they request it or jam/fran gives explicit go-ahead.** Relay executes meridian cycles on request only — never proactively
- Never cycle all agents simultaneously
- If an agent crashes immediately after cycle, check: access.json corruption, CLAUDE.md syntax errors, disk space

## Automated Detection
- Health check launchd runs every 5 minutes, alerts to Discord + vigil webhook on dead agents
- Vigil stall detection: 10min stall = audio alert, 15min = coordinator ping
- Vigil permission detection: screen hardcopy grep for permission prompts

## Who Can Cycle
- Relay: any primary NWL agent. Meridian agents only on their request or jam/fran go-ahead
- Claude: any NWL agent if relay is down (succession protocol). Same meridian restriction applies
- Static: can cycle from QA perspective if both relay and claude are down
- Jam: manual cycle via SSH
