# Getting a New Bot Live on the Mac Mini

## Overview

This documents how we got Static (the third Discord bot) online in the Nowhere Labs server. The process took ~90 minutes of debugging. Future bots should take ~5 minutes using the native approach.

## Architecture

Three Claude Code sessions run natively on the mac mini, each with:
- Its own Discord bot application (separate token, name, avatar)
- Its own workspace directory with a `CLAUDE.md` personality file
- Its own Discord state directory via `DISCORD_STATE_DIR` env var
- The shared Discord plugin (`discord@claude-plugins-official`)

### Current Bots

| Bot | Workspace | Discord State Dir | Role |
|-----|-----------|-------------------|------|
| Claudia | (default session) | `~/.claude/channels/discord/` | Creative direction, review |
| CLAUDEBOT (Claude) | (separate session) | (default) | Engineering, building |
| Static | `~/static-workspace/` | `~/.claude/channels/discord-static/` | QA, testing, observation |

## What Works: Native Approach

### Prerequisites
1. Claude Code installed on the mac mini
2. Discord plugin installed: `claude plugin install discord@claude-plugins-official`
3. Logged in via OAuth: `claude auth login` (needed for the channels feature flag)
4. A separate Discord bot application in the Developer Portal with its own token

### Setup Steps

#### 1. Create a Discord Bot Application
- Go to https://discord.com/developers/applications
- "New Application" → name it (e.g., "Static")
- Bot tab → set username and avatar
- Reset Token → copy it (shown only once)
- Enable Privileged Gateway Intents:
  - MESSAGE CONTENT INTENT
  - SERVER MEMBERS INTENT
  - PRESENCE INTENT
- OAuth2 → URL Generator → select `bot` scope → invite to server

#### 2. Create the Bot's Workspace
```bash
mkdir -p ~/BOT-NAME-workspace
```

Write a `CLAUDE.md` in that directory with the bot's personality and instructions.

#### 3. Create Project Settings
```bash
mkdir -p ~/BOT-NAME-workspace/.claude
```

Create `~/BOT-NAME-workspace/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "discord@claude-plugins-official": true
  }
}
```

#### 4. Create the Discord State Directory
```bash
mkdir -p ~/.claude/channels/discord-BOTNAME
```

Create `~/.claude/channels/discord-BOTNAME/.env`:
```
DISCORD_BOT_TOKEN=your-token-here
```

Lock it down:
```bash
chmod 600 ~/.claude/channels/discord-BOTNAME/.env
```

Create `~/.claude/channels/discord-BOTNAME/access.json`:
```json
{
  "dmPolicy": "pairing",
  "allowFrom": ["YOUR_DISCORD_USER_ID"],
  "groups": {
    "CHANNEL_ID": {
      "requireMention": false,
      "allowFrom": []
    }
  },
  "pending": {}
}
```

#### 5. Launch
```bash
cd ~/BOT-NAME-workspace && DISCORD_STATE_DIR=~/.claude/channels/discord-BOTNAME claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official
```

**Security note:** `--dangerously-skip-permissions` gives the bot full filesystem and command access. Only use in trusted environments. For untrusted or multi-tenant setups, use `--permission-mode default` and configure allowed tools explicitly.

The bot should appear online in Discord and respond to messages within seconds.

## What Didn't Work: Docker Approach

We spent significant time trying to run Static in a Docker container. Here's what happened and why it failed.

### The Docker Setup (~/claude-docker/)
- `Dockerfile` — node:20-slim + claude code + bun
- `docker-compose.yml` — mounts personality, settings, plugin files, discord config
- `entrypoint.sh` — copies config files into writable `.claude/` directory at startup
- `static-personality.md` — Static's CLAUDE.md
- `discord-plugin/` — copy of the discord plugin with corrected bun path
- `installed_plugins.json` / `known_marketplaces.json` — plugin registry files

### Issues Encountered (in order)

1. **Onboarding screen stuck** — Claude Code prompted for theme selection on first run. Fixed by pre-seeding `.claude.json` with `hasCompletedOnboarding: true`.

2. **Workspace trust dialog** — Required `hasTrustDialogAccepted: true` in the projects section of `.claude.json` for `/home/static`.

3. **Auth token env var name** — `CLAUDE_CODE_AUTH_TOKEN` is wrong. Correct name: `ANTHROPIC_AUTH_TOKEN` (for setup tokens from `claude setup-token`).

4. **Plugin not found** — Marketplace clone path was `anthropics-claude-plugins-official` (hyphenated) but `known_marketplaces.json` referenced `claude-plugins-official`. Mismatch caused "Plugin discord not found in marketplace" error.

5. **Bind mount permissions** — Individual file bind mounts into `~/.claude/` prevented Claude Code from creating subdirectories it needed (`debug/`, `sessions/`). Fixed by switching to an entrypoint script that copies configs into a writable directory.

6. **FATAL: Channels feature flag** — After everything else was fixed, the debug log showed: `"channels feature is not currently available"`. The channels relay is gated behind a server-side feature flag (`tengu_harbor_permissions`) that only resolves with full OAuth login. The `setup-token` approach provides API auth but not the feature flag context. **This is the blocker.** The MCP server connects, the plugin runs, but messages never get injected into the conversation.

### Docker Status
The Docker setup is 95% functional. Everything works except the channels feature flag. If Anthropic changes the flag behavior or adds support for setup tokens, Docker becomes viable. Files are preserved in `~/claude-docker/`.

## Key Lessons

- **`DISCORD_STATE_DIR` env var** is the key to running multiple bots on one machine. Each bot gets its own state directory with its own token and access config.
- **`--channels plugin:discord@claude-plugins-official`** flag is required for live message injection. Without it, messages arrive in the inbox but never enter the conversation.
- **Each bot needs its own Discord application** in the Developer Portal. Same application = same name and avatar, no matter how many sessions use it.
- **OAuth login is required** for the channels feature. Setup tokens don't carry the feature flag context.
- **Don't `pkill` bun processes blindly** — multiple bots share the same binary. Kill by specific PID if needed.

## Team Coordination

See [response-protocol.md](response-protocol.md) for the full response deduplication protocol and role definitions. Key points:

- One bot takes lead on answering questions (usually Claude for engineering, Claudia for review)
- Others only add if they have a genuinely different perspective
- Static focuses on QA observations, not general conversation
- Check user_ids when display names are ambiguous

This protocol needs to scale as the team grows beyond 3 agents. Expect updates as new bots come online.

## Files Reference

```
~/claude-docker/                    # Docker approach (preserved, not active)
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── static-personality.md
├── settings.json
├── claude-config.json
├── discord-env
├── discord-access.json
├── discord-plugin/                 # Plugin copy with container paths
├── installed_plugins.json
├── known_marketplaces.json
└── .env                            # ANTHROPIC_AUTH_TOKEN (rotate this)

~/static-workspace/                 # Static's native workspace
├── CLAUDE.md                       # Static's personality
└── .claude/
    └── settings.json               # Enables discord plugin

~/.claude/channels/discord-static/  # Static's discord state
├── .env                            # DISCORD_BOT_TOKEN
└── access.json                     # Channel/DM access config
```
