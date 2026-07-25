---
title: Break-Glass Recovery Procedures
date: 2026-03-28
owner: relay
scope: ops
---

# Break-Glass Recovery — NWL Rack

When Tailscale, networking, or remote access fails, use these procedures to recover.

## R10 (Alienware R10, Ubuntu)

### Physical Access
- **Location:** rack shelf, below Mac Mini
- **Monitor:** HDMI port on rear panel (GPU output)
- **Keyboard/mouse:** USB ports on front panel
- **Power:** smart plug controllable via Home Assistant, or manual press (front button)

### BIOS Access
- Power on → press **F2** repeatedly during Dell logo
- Boot menu: **F12** during Dell logo
- Default BIOS password: none (unless set during install)

### Network Recovery
1. Plug in monitor + keyboard
2. Log in as `jam` (or `root` if user login fails)
3. Check network: `ip addr show` — look for `eth0` or `enp*` with an IP
4. If no IP: `sudo dhclient eth0` (or the correct interface name)
5. Check tailscale: `sudo tailscale status`
6. If tailscale down: `sudo systemctl restart tailscaled && sudo tailscale up`
7. Verify mesh: `ping nwl-mini` (tailscale hostname)

### Service Recovery
```bash
# Check all services
sudo systemctl status postgresql ollama syncthing@nwl-svc

# Restart a service
sudo systemctl restart postgresql

# Check logs
journalctl -u postgresql --since "10 minutes ago"
journalctl -u ollama --since "10 minutes ago"

# Full service restart (ordered)
sudo systemctl restart tailscaled
sudo systemctl restart postgresql
sudo systemctl restart ollama
sudo systemctl restart syncthing@nwl-svc
```

### USB Recovery Installer
- **Location:** labeled USB drive in desk drawer
- **Contents:** Ubuntu Server 24.04 LTS installer
- **After reinstall:** run `/srv/nwl/shared-brain/ops/r10-first-boot.sh`
- Syncthing will re-sync shared-brain from Mini after pairing

## Mac Mini (macOS, Agent Host)

### Physical Access
- **Location:** rack shelf, above R10
- **Monitor:** HDMI or USB-C to HDMI
- **Keyboard/mouse:** Bluetooth or USB
- **Power:** smart plug or manual unplug/replug

### Network Recovery
1. Plug in monitor + keyboard
2. Check wifi or ethernet in System Settings → Network
3. Check tailscale: menu bar icon or `tailscale status`
4. If tailscale down: open Tailscale app or `brew services restart tailscale`

### Agent Recovery
```bash
# Check running agents
screen -ls

# Restart all agents
bash ~/relay-workspace/shared-brain/ops/agent-cycle.sh claude
bash ~/relay-workspace/shared-brain/ops/agent-cycle.sh static
# ... repeat for each agent

# Check vigil
curl -s http://localhost:3847/health
```

## Reference

| Item | Value |
|------|-------|
| R10 hostname | `nwl-r10` |
| R10 tailscale name | `nwl-r10` |
| R10 local IP | check router DHCP table or `ip addr` on R10 |
| Mini hostname | `Jams-Mac-mini` |
| Mini tailscale name | `nwl-mini` |
| Mini local IP | check router or `ifconfig` on Mini |
| Router admin | 192.168.1.1 (check label on router) |
| UPS model | APC 600 |
| USB installer | desk drawer, labeled "Ubuntu 24.04" |

## When to Use Break-Glass

1. Tailscale is down on both nodes and you can't SSH
2. R10 is unresponsive to network requests
3. Mini is unresponsive and agents are offline
4. After a power event where UPS shutdown didn't clean up properly
5. After a failed OS update or driver change

## What NOT to Do

- Don't reinstall Ubuntu unless the disk is corrupted — first-boot.sh is idempotent
- Don't reset the router unless you've tried restarting tailscale first
- Don't delete syncthing config — re-pairing is more work than restarting
