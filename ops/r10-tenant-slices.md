---
title: R10 Tenant Resource Limits (systemd slices)
date: 2026-03-28
type: ops
scope: infrastructure
owner: static
status: ready-to-deploy
parent: homelab-security-model.md
---

# R10 Tenant Resource Limits

cgroup v2 resource limits via systemd slices. enforces the allocations from the security model.

## Design

- limits are **weights**, not hard reservations. idle tenants' resources are available to others
- CPUWeight is relative: 450 + 450 + 100 = 1000 total. NWL gets 45%, Meridian 45%, Chowder 10%
- MemoryMax is a **hard cap** to prevent OOM cascading. set above expected usage, below total RAM
- R10 has 32GB RAM. allocations: NWL 14GB, Meridian 14GB, Chowder 4GB (total 32GB, no overcommit)
- IOWeight follows the same ratio as CPU

## Slice Files

### /etc/systemd/system/nwl.slice

```ini
[Unit]
Description=NWL Tenant Resource Slice
Before=slices.target

[Slice]
CPUWeight=450
MemoryMax=14G
MemoryHigh=12G
IOWeight=450
```

### /etc/systemd/system/meridian.slice

```ini
[Unit]
Description=Meridian Tenant Resource Slice
Before=slices.target

[Slice]
CPUWeight=450
MemoryMax=14G
MemoryHigh=12G
IOWeight=450
```

### /etc/systemd/system/chowder.slice

```ini
[Unit]
Description=Chowder Tenant Resource Slice
Before=slices.target

[Slice]
CPUWeight=100
MemoryMax=4G
MemoryHigh=3G
IOWeight=100
```

## Assigning Services to Slices

Every systemd unit for a tenant must include `Slice=` in the `[Service]` section.

```ini
# Example: NWL RAG indexer
[Service]
Slice=nwl.slice
User=nwl-svc
# ... rest of unit config
```

```ini
# Example: Meridian service
[Service]
Slice=meridian.slice
User=meridian-svc
```

```ini
# Example: Chowder bot
[Service]
Slice=chowder.slice
User=chowder-svc
```

Shared services (postgres, ollama) run in the default system slice. they serve all tenants and shouldn't be capped by a single tenant's limits.

## MemoryHigh vs MemoryMax

- **MemoryHigh** (soft limit): kernel starts reclaiming memory aggressively when exceeded. services slow down but don't die. set 2GB below MemoryMax
- **MemoryMax** (hard limit): OOM killer activates if exceeded. this is the blast radius cap. a runaway process in NWL's slice cannot starve Meridian

## Monitoring

check live cgroup stats:

```bash
# Per-slice resource usage
systemctl status nwl.slice
systemctl status meridian.slice
systemctl status chowder.slice

# Detailed cgroup stats
systemd-cgtop

# Memory pressure per slice
cat /sys/fs/cgroup/nwl.slice/memory.pressure
cat /sys/fs/cgroup/meridian.slice/memory.pressure
```

## Deployment

```bash
# 1. Copy slice files
sudo cp nwl.slice meridian.slice chowder.slice /etc/systemd/system/

# 2. Reload systemd
sudo systemctl daemon-reload

# 3. Start slices (they activate when dependent services start)
sudo systemctl start nwl.slice meridian.slice chowder.slice

# 4. Verify
systemctl status nwl.slice
systemd-cgtop
```

## Blast Radius Scenarios

| Scenario | Without slices | With slices |
|----------|---------------|-------------|
| Chowder bot memory leak | OOM kills random processes across all tenants | OOM kills only within chowder.slice (4GB cap) |
| NWL RAG indexer CPU spike during re-index | Starves meridian and chowder of CPU | NWL limited to 45% weight, others get fair share |
| Meridian batch job fills disk | All tenants affected (disk is shared) | Not cgroup-solvable. use per-tenant disk quotas (see below) |

## Disk Quotas (future, not cgroup)

cgroups don't limit disk usage. for per-tenant disk caps, use ext4/xfs project quotas:

```bash
# Enable quotas on /srv partition (requires remount)
# sudo mount -o remount,prjquota /srv
# sudo xfs_quota -x -c 'limit -p bhard=100g nwl_project' /srv

# Not implementing now — disk usage is low and monitored by retention cron.
# Add quotas if any tenant exceeds 50% of available disk.
```
