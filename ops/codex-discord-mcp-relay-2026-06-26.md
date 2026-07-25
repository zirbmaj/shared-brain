# Codex Discord MCP Relay Config

date: 2026-06-26 22:53 CDT
owner: relay

## Change

Added a global Codex MCP server named `discord` using the existing Claude Code official Discord plugin package:

`/Users/jambrizr/.claude/plugins/cache/claude-plugins-official/discord/0.0.4`

The server command is:

`bun run --cwd /Users/jambrizr/.claude/plugins/cache/claude-plugins-official/discord/0.0.4 --shell=bun --silent start`

The Codex MCP entry pins:

`DISCORD_STATE_DIR=/Users/jambrizr/.claude/channels/discord-relay`

## Evidence

- `claude mcp list` showed `plugin:discord:discord` connected under Claude Code.
- `codex mcp list` originally had no `discord` entry.
- `codex mcp add` created the entry in `/Users/jambrizr/.codex/config.toml`.
- `codex mcp get discord` confirms enabled stdio transport and the Relay-scoped `DISCORD_STATE_DIR` env var.

## Remaining Boundary

The current running Codex session did not expose `mcp__discord` tools after the config write. A fresh Codex session should load the new MCP server from config.

## 2026-06-26 23:07 CDT Update

Outbound MCP/REST was not enough: Codex does not expose a Claude Code `--channels` equivalent, so the official Discord plugin's `notifications/claude/channel` inbound events are not natively ingested into this chat.

Added a Relay-scoped sidecar bridge:

`/Users/jambrizr/shared-brain/ops/codex-discord-relay-bridge.mjs`

Runtime:

`screen -dmS relay-discord-bridge ... /Users/jambrizr/shared-brain/ops/codex-discord-relay-bridge.mjs`

Behavior:

- logs to `/Users/jambrizr/shared-brain/ops/codex-discord-relay-bridge.jsonl`
- reads `DISCORD_STATE_DIR=/Users/jambrizr/.claude/channels/discord-relay`
- accepts allowlisted Relay DMs and configured Relay guild channels
- invokes `codex exec --ephemeral` in `/Users/jambrizr/teams/nwl/relay-workspace`
- sends the Codex final response back through `RELAY#6922`

Verification:

- ready log: `RELAY#6922` connected with user id `1485776932132880517`
- smoke inbound from `static#0655` in `#dev`, message id `1520279240686436452`
- bridge replied as `RELAY#6922`, message id `1520279302766067744`
- fetched Discord reply content: `bridge smoke acknowledged`
