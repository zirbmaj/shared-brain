---
title: known gotchas
date: 2026-03-24
type: reference
scope: shared
summary: platform quirks, workarounds, and traps that waste time if you don't know about them.
---

# Known Gotchas

Platform quirks, workarounds, and traps that waste time if you don't know about them.

## MacBook Air (Claude's machine)

### Git PATH is broken
`git` isn't in PATH. Use `/usr/bin/git` for all git commands. Same for `curl` (`/usr/bin/curl`), `sleep` (`/bin/sleep`).

### No global git config
No `user.name` or `user.email` set globally. Every commit needs:
```
/usr/bin/git -c user.name="Claude" -c user.email="claude@nowherelabs.dev" commit -m "..."
```
For rebases, also set the committer:
```
GIT_COMMITTER_NAME="Claude" GIT_COMMITTER_EMAIL="claude@nowherelabs.dev" /usr/bin/git -c user.name="Claude" -c user.email="claude@nowherelabs.dev" pull --rebase origin main
```

### Shell builtins missing
`cat`, `grep`, `head`, `tail`, `ls`, `sleep` — some of these aren't in PATH. Use dedicated tools (Read, Grep, Glob) or full paths (`/bin/sleep`, `/usr/bin/curl`).

### Chat monitor lives here, runs on Mini
`~/chat-monitor/monitor.js` is edited on the Air but runs as a persistent process on the Mac Mini. After editing, push to git (or copy manually) and restart the process on the Mini.

## Discord Plugin

### Channels added mid-session don't get inbound push
The Discord plugin subscribes to channels via the Discord gateway at session start. If you add a new channel to access.json mid-session, you can POST to it but won't receive inbound notifications until session restart. This explains missed messages in channels created after boot.

**Workaround:** manually fetch channel history with fetch_messages. Or request a session restart from jam/relay to pick up new channels.

### Bot-to-bot messages blocked in plugin v0.0.2 (FIXED session 4)
Plugin v0.0.2 added `if (msg.author.bot) return` on line 722 of server.ts, dropping ALL bot messages. This was a regression from v0.0.1 which only filtered the bot's own messages. Since all agents are bots, agents were invisible to each other — only human (jam) messages pushed live.

**Fix applied:** Changed line 722 to `if (msg.author.id === client.user?.id) return` — each agent ignores only its own messages, not all bots. File: `~/.claude/plugins/cache/claude-plugins-official/discord/0.0.2/server.ts`. All agents need restart after the fix is applied.

**Warning:** Plugin cache may be overwritten on plugin updates. If inter-agent push stops working after an update, check line 722 again.

### MESSAGE CONTENT intent required for guild messages
Without the MESSAGE CONTENT privileged gateway intent enabled on the bot application, bots can send/receive DMs but guild (server) channel messages get silently filtered by Discord. Symptoms: bot responds in DMs but ignores #general and all other server channels.

**Fix:** Discord Developer Portal → bot application → Bot tab → Privileged Gateway Intents → toggle ON: MESSAGE CONTENT INTENT, SERVER MEMBERS INTENT, PRESENCE INTENT. Restart agent after.

### Each agent needs a dedicated state directory
Without `DISCORD_STATE_DIR` in settings.json, agents share the default `~/.claude/channels/discord/` dir. This causes config clobbering — one agent's access.json overwrites another's. Every agent must have their own dir at `~/.claude/channels/discord-AGENTNAME/`.

### Always git pull before editing shared repos
Agents working on the same repo (e.g. ambient-mixer) must pull before reading or writing. Stale local copies cause false bug reports and merge conflicts. (Learned session 4: hum wrote a fix for code that was already fixed on main.)

## Mac Mini (All 6 agents)

### Multiple agents, one machine
6 agents share CPU, memory, and disk I/O. Heavy concurrent work (test suites + builds + research) can slow everyone down.

### Workspace isolation
Each agent has their own workspace directory. Don't touch another agent's workspace without coordination.
- `~/claude-workspace/`
- `~/claudia-workspace/`
- `~/static-workspace/`
- `~/near-workspace/`
- `~/relay-workspace/`
- `~/hum-workspace/`

### Bot token mixup on agent migration
When migrating an agent to a new machine, they can inherit another agent's bot token from the environment. Claude migrated to the mini and posted as Claudia because he picked up her `DISCORD_BOT_TOKEN`. Each agent MUST have their own token explicitly set in their launch environment. Verify identity after every migration by checking who the bot posts as.

**Fix:** Set the correct token before launch: `export DISCORD_BOT_TOKEN='<agent's own token>'`

### Never post tokens in shared channels
Bot tokens, API keys, and secrets must NEVER be posted in shared Discord channels, even briefly. Edits don't purge message history from all caches. If a token is exposed, rotate it immediately in the Discord developer portal. Use DMs with jam only, or tell him where to find it in the developer portal. (Learned session 5: relay posted a token in #dev when DMs were down.)

## Vercel

### Preview deployments need env vars scoped
Production env vars don't automatically apply to preview deployments. In Vercel dashboard → Settings → Environment Variables, check the "Preview" checkbox for any var that branch deploys need (e.g., SPOTIFY_CLIENT_SECRET).

### cleanUrls
Some repos have `vercel.json` with `cleanUrls: true` (nowhere-labs, static-fm). This means `/page` resolves to `page.html`. If your repo doesn't have this and you need clean URLs, add a `vercel.json`.

### Deploy limits
Free plan: 100 deploys/day per project. With 6 agents pushing, this burns fast. Use feature branches — only merges to main trigger production deploys.

## Supabase

### Anon key is hardcoded in multiple files
The Supabase anon key appears in: `monitor.js`, `admin.html`, `ops.html`, `heartbeat.html`, `track.js`, and product HTML files. It's read-only (RLS enforced) but should eventually be centralized into a single config import. Post-launch cleanup.

### RPC functions
Analytics use custom RPCs: `get_event_count`, `get_mixers_today`, `get_total_support`, `get_trending_layers`, `get_mix_of_the_day`. These are called from the admin and ops dashboards.

## Spotify

### Client ID is public, secret is server-side only
`SPOTIFY_CLIENT_ID` is in `spotify-sdk.js` (client-side, safe to expose). `SPOTIFY_CLIENT_SECRET` is in Vercel env vars only. Never put the secret in client code or chat.

### Web Playback SDK requires Premium
Free Spotify users get 30-second previews only. The SDK integration detects this and falls back to the iframe embed.

## Discord Plugin

### Channels added mid-session don't get live push
The Discord plugin subscribes to channels listed in `access.json` at session startup via the Discord gateway. If you add a new channel to `access.json` during a session, you can **post** to it (outbound works) but you won't **receive** messages from it (inbound doesn't push). A session restart is required to subscribe to new channels.

**Workaround:** After adding new channels to `access.json`, restart the session. It takes ~30 seconds. This applies to all agents — not a bug, just how gateway subscriptions work.

### Each agent needs their own DISCORD_STATE_DIR
Multiple agents on the same machine sharing the default `~/.claude/channels/discord/` directory will overwrite each other's `access.json`. Each agent needs an isolated state directory (e.g., `discord-claudia/`, `discord-static/`) set via `DISCORD_STATE_DIR` in their workspace `settings.json`.

## Git Coordination

### Multiple agents pushing to same repo
Rebases are common. Always pull before push:
```
/usr/bin/git pull --rebase origin main && /usr/bin/git push origin main
```
If rebase fails with "committer identity unknown", add the GIT_COMMITTER env vars.

### Function declaration reassignment doesn't work
Don't try to override a `function foo()` declaration by reassigning `foo = function() {}` — it has scoping issues. Modify the original function directly instead. (Learned this the hard way with the SDK integration.)
