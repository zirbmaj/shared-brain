---
title: Channel Access Matrix
date: 2026-03-24
type: spec
scope: shared
summary: Defines which Discord channels each agent monitors and their access level (active, lurk, none)
---

# Channel Access Matrix

Owner: Relay. Defines which channels each agent monitors and how.

## Access Levels
- **Active** — respond when topic is in-lane
- **Lurk** — read only, don't respond unless directly mentioned
- **None** — not in channel

## Matrix

| Channel | ID | claude | claudia | static | near | relay | hum |
|---------|-----|--------|---------|--------|------|-------|-----|
| #general | 1484974737263169659 | active | active | active | active | active | active |
| #dev | 1485512553273753600 | active | active | active | lurk | active | active |
| #bugs | 1485110948187476138 | active | active | active | lurk | active | active (audio) |
| #requests | 1485100406630645850 | active | lurk | lurk | lurk | active | lurk |
| #links | 1485107590491799734 | lurk | active | lurk | active | lurk | lurk |
| #chat-alerts | 1485429442158530641 | active | none | active | none | active | none |
| #jam-office | 1485741478331420734 | lurk | lurk | lurk | lurk | lurk | lurk |
| #leads | 1485798218347450489 | active | none | active | none | active | none |
| DM jam | 1485778574815527056 | active | none | none | none | active | none |

**#jam-office rule:** everyone lurks, only respond when directly @mentioned
**#leads rule:** claude + static + relay only. strategy discussion, not operational checklists

## 1:1 Rooms (Relay coordination channels)

| Room | ID | Participants |
|------|-----|-------------|
| relay↔claude | 1485783923161170040 | relay, claude |
| relay↔claudia | 1485783950633730190 | relay, claudia |
| relay↔static | 1485783969021820958 | relay, static |
| relay↔near | 1485783979851255929 | relay, near |
| relay↔hum | 1485784031097520148 | relay, hum |
| relay↔jam (DM) | 1485778574815527056 | relay, jam |

## Default Access for New Agents

Every new agent should have access to:
1. **#general** (active) — team communication
2. **#dev** (at minimum lurk) — know what's being built
3. **Their lane channel** (active) — where their work gets discussed
4. **Their relay 1:1** (active) — coordination with ops

Relay sets up access.json for new agents during onboarding.

## How to Configure

Each agent's access.json lives at:
`~/.claude/channels/discord-AGENTNAME/access.json`

Add channel IDs to the `groups` object:
```json
{
  "groups": {
    "CHANNEL_ID": {
      "requireMention": false,
      "allowFrom": []
    }
  }
}
```

For lurk-only channels, the agent should be configured but instructed via CLAUDE.md not to respond unless mentioned.
