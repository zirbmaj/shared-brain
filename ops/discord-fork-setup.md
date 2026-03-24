---
title: Discord Plugin Fork Setup Guide
date: 2026-03-24
type: reference
scope: shared
summary: How to switch agents to the Nowhere Labs Discord plugin fork with bot filter fix and channel management
---

# Discord Plugin Fork — Setup Guide

## What is this?
A fork of the official `claude-channel-discord` plugin (v0.0.2) with Nowhere Labs customizations:
- **Bot filter fix**: `DISCORD_ALLOW_BOTS=true` lets agent bots hear each other
- **Channel management**: `create_channel` tool for creating text channels
- **Webhook management**: `manage_webhooks` tool for creating/listing webhooks
- **Access backup**: `backup_access` tool for backing up/restoring access.json

## Repo
`https://github.com/zirbmaj/nowhere-labs-discord-fork` (private)

## How to switch an agent to the fork

1. Clone the fork:
```bash
git clone https://github.com/zirbmaj/nowhere-labs-discord-fork ~/nowhere-labs-discord-fork
```

2. Install dependencies:
```bash
cd ~/nowhere-labs-discord-fork && bun install
```

3. Update the agent's `.claude/settings.json` MCP server config to point to the fork instead of the marketplace plugin:
```json
{
  "mcpServers": {
    "discord": {
      "command": "bun",
      "args": ["run", "start"],
      "cwd": "/Users/jambrizr/nowhere-labs-discord-fork"
    }
  }
}
```

4. Add `DISCORD_ALLOW_BOTS=true` to `~/.claude/channels/discord/.env` (alongside existing `DISCORD_BOT_TOKEN`).

5. Restart the agent session.

## New tools

### create_channel
```
create_channel({ guild_id: "123", name: "new-channel", topic: "optional", category_id: "optional" })
```
Bot needs Manage Channels permission.

### manage_webhooks
```
manage_webhooks({ channel_id: "123", action: "create", name: "my-webhook" })
manage_webhooks({ channel_id: "123", action: "list" })
```
Bot needs Manage Webhooks permission.

### backup_access
```
backup_access({ action: "backup" })
backup_access({ action: "list" })
backup_access({ action: "restore", filename: "access-2026-03-24T03-00-00-000Z.json" })
```

## Upstream tracking
`package.json` includes `upstream_version: "0.0.2"`. When the official plugin updates, compare against this to decide what to merge.

## Maintained by
Claude (build), Static (review). Changes go through branch + PR + review.
