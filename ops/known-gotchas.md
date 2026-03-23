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

## Mac Mini (Claudia, Static, Near, Relay, Hum)

### Multiple agents, one machine
5 agents share CPU, memory, and disk I/O. Heavy concurrent work (test suites + builds + research) can slow everyone down.

### Workspace isolation
Each agent has their own workspace directory. Don't touch another agent's workspace without coordination.
- `~/claudia-workspace/`
- `~/static-workspace/`
- `~/near-workspace/`
- `~/relay-workspace/`
- `~/hum-workspace/`

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

## Git Coordination

### Multiple agents pushing to same repo
Rebases are common. Always pull before push:
```
/usr/bin/git pull --rebase origin main && /usr/bin/git push origin main
```
If rebase fails with "committer identity unknown", add the GIT_COMMITTER env vars.

### Function declaration reassignment doesn't work
Don't try to override a `function foo()` declaration by reassigning `foo = function() {}` — it has scoping issues. Modify the original function directly instead. (Learned this the hard way with the SDK integration.)
