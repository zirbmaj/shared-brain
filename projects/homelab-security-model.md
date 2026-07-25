---
title: Homelab Security & Isolation Model
date: 2026-03-27
type: project
scope: infrastructure
owner: static
status: finalized
parent: homelab-cluster.md
---

# Homelab Security & Isolation Model

Security architecture for the 2-node NWL cluster. Three tenants (NWL, Meridian, Chowder) sharing hardware with strict isolation.

## Principles

1. **Least privilege by default.** No tenant can read, write, or execute another tenant's data without explicit grant
2. **Observation must never mutate state.** Monitoring/health checks are read-only (lesson from session 9.2 auto-cycle incident)
3. **Defense in depth.** Unix permissions are the floor, not the ceiling. Each layer adds isolation
4. **Graceful degradation.** Power loss, network failure, and agent crashes must not corrupt state or leak across tenants

## Tenant Isolation — R10 (Linux)

### Layer 1: Unix Users + Groups

```
# Permission tiers:
#   admin      — full sudo, shared resource access (NWL + meridian)
#   standard   — no sudo, own workspace only (chowder)
# Per jam's directive: meridian gets double admin, not throttled

nwl-svc        # NWL service account (admin tier)
meridian-svc   # Meridian service account (admin tier, same privileges as NWL)
chowder-svc    # Chowder service account (standard: no sudo, workspace only)

# Shared group for cross-tenant read (opt-in only)
shared-ro      # Members can read shared resources (e.g., shared LLM endpoint)

# Admin
nwl-admin      # jam's account, full sudo, owns the machine

# Meridian sudoers (admin tier, same as NWL):
# meridian-svc ALL=(ALL) NOPASSWD: ALL
# Hard boundary: workspace isolation only. Meridian cannot read /srv/nwl/, NWL cannot read /srv/meridian/
```

### Layer 2: Filesystem ACLs

```
# Tenant workspaces — owner-only, no cross-read
/srv/nwl/           owner: nwl-svc,     mode: 0700
/srv/meridian/      owner: meridian-svc, mode: 0700
/srv/chowder/       owner: chowder-svc,  mode: 0700

# Shared resources — read-only for tenants, write for admin
/srv/shared/        owner: nwl-admin, group: shared-ro, mode: 0750
/srv/shared/models/ # ollama model cache, shared across tenants
/srv/shared/bin/    # shared utilities (NUT client, mesh tools)

# Secrets — per-tenant, no group access
/srv/nwl/.env           mode: 0600, owner: nwl-svc
/srv/meridian/.env      mode: 0600, owner: meridian-svc
/srv/chowder/.env       mode: 0600, owner: chowder-svc

# Logs — per-tenant write, admin read-all
/var/log/nwl/           owner: nwl-svc, mode: 0750
/var/log/meridian/      owner: meridian-svc, mode: 0750
/var/log/chowder/       owner: chowder-svc, mode: 0750
```

### Layer 3: Process Isolation

- Each tenant's services run under their own user via systemd units
- `ProtectHome=true`, `ProtectSystem=strict` in unit files
- `NoNewPrivileges=true` to prevent privilege escalation
- Resource limits via systemd slices (soft caps, only enforced under contention):
  - NWL: 45% CPU, 14GB RAM
  - Meridian: 45% CPU, 14GB RAM (equal priority per jam's directive)
  - Chowder: 10% CPU, 4GB RAM (PA bot, lightweight)
  - Note: these are weights, not reservations. When one tenant is idle, others use the full machine

### Layer 4: Network Isolation (phase 2, if needed)

- Docker/Podman containers per tenant with separate bridge networks
- Only needed if tenants run network services that could collide (port conflicts, broadcast traffic)
- For now, unix users + systemd isolation handles it. Revisit if tenants start running web servers or databases on R10

## Tenant Isolation — Mac Mini (macOS)

### Current State (pre-clean install)

Everything runs as jam's user. Agents are isolated by:
- Separate workspace directories (`~/[name]-workspace/`)
- Separate Discord state dirs (`~/.claude/channels/discord-[name]/`)
- Bot tokens per agent (chmod 600)
- SessionStart verify-identity.sh hook

### Post-PH Clean Install Target

```
# macOS users per tenant
nwl         # NWL agents (claude, claudia, static, near, hum, relay)
meridian    # Meridian agents (axis, forge, lens, locus)
chowder     # Chowder (sonia's PA bot)
jam         # Human account, admin

# Home directories
/Users/nwl/          # All NWL agent workspaces under one user
/Users/meridian/     # Meridian workspaces
/Users/chowder/      # Chowder workspace
/Users/jam/          # Jam's personal account
```

**Open question:** Do NWL agents need individual macOS users, or is one `nwl` user with per-agent subdirectories sufficient? Current verify-identity.sh already handles identity at the session level. Separate OS users per agent adds overhead with minimal security gain since they're all the same tenant.

**Recommendation:** One macOS user per tenant (not per agent). Agent isolation within NWL stays at the workspace/session level as it is today.

## Database Isolation (R10 PostgreSQL)

```sql
-- Separate database users per tenant
CREATE USER nwl_app WITH PASSWORD '...';
CREATE USER meridian_app WITH PASSWORD '...';
CREATE USER chowder_app WITH PASSWORD '...';

-- Schema-level isolation
CREATE SCHEMA nwl AUTHORIZATION nwl_app;
CREATE SCHEMA meridian AUTHORIZATION meridian_app;
CREATE SCHEMA chowder AUTHORIZATION chowder_app;

-- No cross-schema access by default
REVOKE ALL ON SCHEMA nwl FROM PUBLIC;
REVOKE ALL ON SCHEMA meridian FROM PUBLIC;
REVOKE ALL ON SCHEMA chowder FROM PUBLIC;

-- Shared schema for cross-tenant reads (embeddings, model cache metadata)
CREATE SCHEMA shared;
GRANT USAGE ON SCHEMA shared TO nwl_app, meridian_app, chowder_app;
GRANT SELECT ON ALL TABLES IN SCHEMA shared TO nwl_app, meridian_app, chowder_app;
-- Only admin can write to shared
```

## Mesh Network Security (Tailscale)

Tailscale confirmed as mesh solution. WireGuard kernel module on Ubuntu, MagicDNS for hostname resolution.

- **Per-machine keys.** NWL-Mini and NWL-R10 each have their own Tailscale identity. Auth keys for unattended headless operation on R10
- **Tailscale ACLs.** Configured in the Tailscale admin console:
  - `nwl-r10:11434` (Ollama) accepts connections only from `nwl-mini`
  - `nwl-r10:5432` (PostgreSQL) accepts connections only from `nwl-mini`
  - `nwl-r10:3493` (NUT) accepts connections only from `nwl-mini`
  - `nwl-r10:3860` (Chromium service) accepts connections only from `nwl-mini` (no human access)
  - `nwl-r10:8123` (Home Assistant) accepts connections from `nwl-mini` + jam's devices
- **Jam's devices (MBA, phone)** get Tailscale SSH access to both machines. Read-only monitoring endpoints. Full SSH for emergency maintenance
- **No port forwarding to public internet.** All inter-node traffic stays on the Tailscale overlay. LAN detection keeps same-subnet traffic local (zero relay overhead)
- **SSH keys per tenant.** If meridian agents on Mini need to reach R10, they use meridian-svc's key, not nwl's. Tailscale SSH is an alternative for jam's devices (keyless, identity-based)

### UFW Firewall (R10)

```bash
# Default deny inbound, allow outbound
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow Tailscale interface only (no direct LAN access to services)
sudo ufw allow in on tailscale0

# If we need to restrict further within Tailscale, use Tailscale ACLs (above)
sudo ufw enable
```

## Credential Management

| Secret | Location | Access |
|--------|----------|--------|
| Bot tokens | `~/.claude/channels/discord-[agent]/.env` | chmod 600, per-agent |
| Supabase keys | Per-product `.env` files | chmod 600, per-workspace |
| Tailscale auth | `/etc/tailscale/` + admin console | root only, auth keys for headless |
| PostgreSQL passwords | `/srv/[tenant]/.env` | chmod 600, tenant user |
| Ollama API | Localhost only, no auth (LAN trust) | Mesh ACL restricts to known IPs |
| UPS (NUT) | `/etc/nut/` | root + nut group |
| SSH keys | `~/.ssh/` per OS user | chmod 600, standard |

**Rule:** No shared credentials between tenants. No credentials in git. No credentials in Discord channels (incident: relay posted token in #dev, session 5).

## Agent SIGTERM Handling

Agents need to survive unclean shutdowns (UPS, crashes, cycles). Current gaps:

1. **access.json corruption** (session 12) — caused by manual edit, but unclean kills could cause the same thing
2. **No state persistence on SIGTERM** — agents lose in-flight work
3. **Screen session sleep** (macOS) — agents go to 0% CPU when terminal is backgrounded

### Proposed: Pre-shutdown Hook

```bash
#!/bin/bash
# /srv/shared/bin/agent-shutdown-hook.sh
# Called by NUT or systemd before system shutdown

WORKSPACE="$1"  # e.g., /Users/nwl/static-workspace

# Signal the Claude Code process gracefully
pkill -TERM -f "claude.*$WORKSPACE"

# Wait up to 30 seconds for clean exit
for i in $(seq 1 30); do
    pgrep -f "claude.*$WORKSPACE" > /dev/null || break
    sleep 1
done

# Force kill if still running after 30s
pkill -9 -f "claude.*$WORKSPACE" 2>/dev/null

echo "$(date): agent in $WORKSPACE stopped" >> /var/log/agent-shutdown.log
```

### Proposed: Atomic State Writes

All agent file writes that touch critical state (access.json, memory files, session state) should use the write-to-temp-then-rename pattern. The Discord plugin already does this for access.json. Extend to:
- Memory files in `.claude/projects/*/memory/`
- Any shared-brain writes during active sessions
- Session context dumps

## Audit & Monitoring

- **File access logging:** `auditd` on R10 for cross-tenant access attempts (alerts, not blocks — blocks are handled by permissions)
- **Login tracking:** `lastlog` + `auth.log` monitoring
- **Process monitoring:** Per-tenant systemd slice resource usage → reported to vigil
- **Network monitoring:** Mesh connection status → vigil dashboard
- **Credential rotation:** Quarterly bot token rotation (manual, jam-initiated)

## Implementation Priority

| Phase | What | When | Depends On |
|-------|------|------|-----------|
| 1 | Unix users + filesystem ACLs on R10 | During Ubuntu install | Ubuntu 24.04 LTS confirmed |
| 2 | UFW firewall + Tailscale ACLs | After Tailscale join | Tailscale confirmed |
| 3 | UPS graceful shutdown (NUT + hooks) | After Linux install | R10 online |
| 4 | Systemd service units per tenant | After users created | Phase 1 |
| 5 | PostgreSQL tenant isolation | After DB setup | Phase 1 |
| 6 | Mac Mini clean install + tenant users | Post-PH launch (after 2026-03-31) | Full backup verified |
| 7 | Docker/network isolation (if needed) | When justified | Phase 1-4 stable |
| 8 | auditd + monitoring | After phases 1-5 | Vigil integration |

## Shared Storage Security (Syncthing)

Syncthing confirmed for shared-brain sync between nodes.

- **Device auth:** Syncthing uses device IDs (Ed25519 keys) for mutual authentication. Only explicitly paired devices can sync
- **TLS 1.3** for all sync traffic by default. Even over Tailscale (already encrypted), defense in depth
- **Conflict handling:** `.sync-conflict` files prevent silent data loss. No tenant can silently overwrite another's changes
- **Per-tenant sync folders:** NWL shared-brain syncs to `/srv/nwl/shared-brain/` on R10. Meridian gets their own sync folder if they need one. No cross-tenant sync folders
- **Ignore patterns:** `.env`, `*.key`, `credentials.*` excluded from sync via `.stignore`

## Permission Tier Summary

| Tier | Tenant | Sudo | Shared Resources | Cross-Tenant | Notes |
|------|--------|------|-----------------|-------------|-------|
| Admin | NWL (nwl-admin) | Full | Read/Write | Cannot read /srv/meridian/ | Jam's account |
| Admin | Meridian | Full | Read/Write | Cannot read /srv/nwl/ | Equal privileges, per jam |
| Standard | Chowder | None | Read only | None | PA bot, minimal footprint |

Both admin tenants get:
- Full sudo on R10
- Own PostgreSQL schema with full DDL rights
- Write access to /srv/shared/ (shared models, shared bins)
- Separate Tailscale device identity
- Equal systemd slice priority (soft caps under contention only)

The only hard boundary: **workspace isolation.** NWL cannot read /srv/meridian/ and vice versa. This protects proprietary work without throttling capability

## Open Questions

1. Does Chowder need R10 access at all, or is Mac Mini sufficient for a PA bot?
2. Budget for hardware security (YubiKey for jam's admin account)?
3. Meridian's near-admin scope: should they get their own Syncthing folder or share NWL's shared-brain?
