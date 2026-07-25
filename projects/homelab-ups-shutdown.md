---
title: UPS Graceful Shutdown Plan
date: 2026-03-27
type: project
scope: infrastructure
owner: static
status: finalized
parent: homelab-cluster.md
---

# UPS Graceful Shutdown — NUT Architecture

APC UPS 600 → data port → R10. R10 monitors battery, orchestrates shutdown of both nodes.

## Architecture

```
[APC UPS 600]
     |
     | USB data cable
     v
[NWL-R10 (Ubuntu 24.04)] ← NUT server (upsd + upsmon master)
     |
     | Tailscale mesh (MagicDNS: nwl-mini)
     v
[NWL-Mini (macOS)] ← SSH-triggered shutdown (no NUT client)
```

R10 is the **NUT server** (direct USB connection to UPS) and the **shutdown orchestrator**.
Mac Mini receives shutdown commands via SSH over Tailscale. No NUT client on macOS (per Claude's recommendation: simpler, fewer moving parts, same outcome).

## Shutdown Sequence

```
Power loss detected by UPS
  → NUT upsd reads battery state
  → Battery drops below threshold (e.g., 30% or 5 min remaining)
  → upsmon triggers NOTIFY + SHUTDOWNCMD

Phase 1: Mac Mini shutdown (remote, over Tailscale)
  → R10 SSHes to nwl-mini: run agent-shutdown-all.sh
  → agent-shutdown-all.sh gracefully stops all 6 NWL agents + meridian + chowder
  → Each agent gets 30s SIGTERM window before SIGKILL
  → After agents stop: stop vigil, stop tunnels, stop launchd services
  → macOS shutdown -h now
  → R10 confirms Mini is offline (ping timeout ~180s max)

Phase 2: R10 shutdown (local)
  → Stop local services (ollama, postgres, home assistant)
  → Stop NUT upsd last
  → Linux shutdown -h now

Phase 3: UPS exhaustion
  → If both machines are down, UPS powers off gracefully
  → Smart plug (Tapo) detects power loss → logs to cloud (if available)
```

## NUT Installation (R10 — Ubuntu 24.04)

```bash
sudo apt install nut nut-server nut-client
sudo systemctl enable nut-server nut-monitor
```

### /etc/nut/nut.conf
```ini
MODE=standalone
# standalone, not netserver — no NUT client on macOS, SSH-only approach
```

### /etc/nut/ups.conf
```ini
[apc600]
    driver = usbhid-ups
    port = auto
    desc = "APC UPS 600"
    # pollinterval = 5  # default is fine for home use
```

### /etc/nut/upsd.conf
```ini
# Localhost only — no remote NUT clients (using SSH approach for Mini)
LISTEN 127.0.0.1 3493
```

### /etc/nut/upsd.users
```ini
[upsmon_local]
    password = <generated>
    upsmon master
# No slave user needed — Mini shutdown triggered via SSH, not NUT protocol
```

### /etc/nut/upsmon.conf (R10 — master)
```ini
MONITOR apc600@localhost 1 upsmon_local <password> master

# Battery thresholds
MINSUPPLY 1
SHUTDOWNCMD "/srv/shared/bin/cluster-shutdown.sh"

# Notifications
NOTIFYCMD /srv/shared/bin/ups-notify.sh
NOTIFYFLAG ONLINE    SYSLOG+EXEC
NOTIFYFLAG ONBATT    SYSLOG+EXEC
NOTIFYFLAG LOWBATT   SYSLOG+EXEC
NOTIFYFLAG SHUTDOWN  SYSLOG+EXEC

# Timing
FINALDELAY 10
DEADTIME 15
```

## Mac Mini (no NUT client)

No NUT software on macOS. R10 handles all UPS monitoring and triggers Mini shutdown via SSH over Tailscale when battery is low. This avoids Homebrew NUT compatibility issues and keeps the Mini's shutdown path simple: receive SSH command, run agent-shutdown-all.sh, power off.

**Requirement:** Tailscale SSH or a dedicated SSH key (`id_nwl_ups`) authorized on Mini for the shutdown user.

## Shutdown Scripts

### cluster-shutdown.sh (runs on R10 as master orchestrator)

```bash
#!/bin/bash
# /srv/shared/bin/cluster-shutdown.sh
# Called by NUT upsmon on LOWBATT or SHUTDOWNCMD
# Orchestrates graceful shutdown of the entire cluster

LOG="/var/log/ups-shutdown.log"
MINI_TAILSCALE="nwl-mini"       # Tailscale MagicDNS hostname (primary)
MINI_LAN="192.168.1.XX"         # LAN IP fallback (set during setup)
MINI_USER="nwl-admin"            # SSH user on Mini with shutdown privileges
SSH_KEY="/root/.ssh/id_nwl_ups"  # dedicated key for UPS shutdown only
TIMEOUT=180  # max seconds to wait for Mini (agent stop ~30s + shutdown -h +1 = ~90-120s, 180 avoids false warning)

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"; }

log "=== UPS SHUTDOWN INITIATED ==="

# Phase 1: Shut down Mac Mini (try Tailscale first, fall back to LAN)
send_shutdown() {
    local host="$1"
    log "Phase 1: attempting shutdown via $host"
    ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new \
        "$MINI_USER@$host" \
        "sudo /usr/local/bin/agent-shutdown-all.sh && sudo shutdown -h +1 'UPS low battery'" \
        2>> "$LOG"
    return $?
}

if send_shutdown "$MINI_TAILSCALE"; then
    log "Mini shutdown command sent via Tailscale"
elif send_shutdown "$MINI_LAN"; then
    log "Mini shutdown command sent via LAN fallback"
else
    log "WARNING: Could not reach Mini via Tailscale or LAN. It may already be down"
fi

# Wait for Mini to go offline
log "Waiting for Mini to go offline (max ${TIMEOUT}s)"
elapsed=0
while [ $elapsed -lt $TIMEOUT ]; do
    # Check both addresses — if either responds, Mini is still up
    ping -c 1 -W 2 "$MINI_TAILSCALE" > /dev/null 2>&1 || ping -c 1 -W 2 "$MINI_LAN" > /dev/null 2>&1 || break
    sleep 5
    elapsed=$((elapsed + 5))
done

if [ $elapsed -ge $TIMEOUT ]; then
    log "WARNING: Mini still responding after ${TIMEOUT}s. Proceeding with R10 shutdown anyway"
else
    log "Mini is offline after ${elapsed}s"
fi

# Phase 2: Stop local services on R10
log "Phase 2: stopping R10 local services"
systemctl stop ollama 2>/dev/null
systemctl stop postgresql 2>/dev/null
systemctl stop homeassistant 2>/dev/null
log "Local services stopped"

# Phase 3: System shutdown
log "Phase 3: R10 shutting down"
shutdown -h now
```

### agent-shutdown-all.sh (runs on Mac Mini)

```bash
#!/bin/bash
# /usr/local/bin/agent-shutdown-all.sh
# Gracefully stops all agents on the Mac Mini
# Called by UPS shutdown sequence or manual maintenance

LOG="/var/log/agent-shutdown.log"
AGENTS=("claude" "claudia" "static" "near" "hum" "relay")
EXTERNAL=("axis" "forge" "lens" "locus")  # meridian agents
SIGTERM_WAIT=30

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"; }

log "=== AGENT SHUTDOWN INITIATED ==="

# Stop NWL agents
for agent in "${AGENTS[@]}"; do
    screen_name="agent-${agent}"
    if screen -list | grep -q "$screen_name"; then
        log "Stopping $agent (screen: $screen_name)"
        # Send Ctrl+C to the Claude session inside screen
        screen -S "$screen_name" -X stuff $'\003'
        sleep 2
        # If still running, send quit
        screen -S "$screen_name" -X stuff $'exit\n'
    else
        log "$agent screen not found, skipping"
    fi
done

# Stop external tenant agents (meridian, chowder)
for agent in "${EXTERNAL[@]}"; do
    screen_name="agent-${agent}"
    if screen -list | grep -q "$screen_name"; then
        log "Stopping meridian agent $agent"
        screen -S "$screen_name" -X stuff $'\003'
        sleep 2
        screen -S "$screen_name" -X stuff $'exit\n'
    fi
done

# Wait for graceful stop
log "Waiting ${SIGTERM_WAIT}s for graceful agent shutdown"
sleep "$SIGTERM_WAIT"

# Kill any remaining claude processes
remaining=$(pgrep -f "claude.*workspace" | wc -l)
if [ "$remaining" -gt 0 ]; then
    log "WARNING: $remaining claude processes still running. Sending SIGKILL"
    pkill -9 -f "claude.*workspace"
    sleep 2
fi

# Stop infrastructure services
log "Stopping vigil servers"
launchctl unload ~/Library/LaunchAgents/com.nwl.vigil*.plist 2>/dev/null
launchctl unload ~/Library/LaunchAgents/com.nwl.watchdog*.plist 2>/dev/null

log "Stopping cloudflare tunnels"
pkill -f cloudflared 2>/dev/null

log "=== ALL AGENTS STOPPED ==="
```

### ups-notify.sh (runs on both nodes)

```bash
#!/bin/bash
# /srv/shared/bin/ups-notify.sh (R10)
# /usr/local/bin/ups-notify.sh (Mini)
# Sends UPS status changes to Discord and vigil

EVENT="$NOTIFYTYPE"
LOG="/var/log/ups-notify.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') UPS event: $EVENT" >> "$LOG"

case "$EVENT" in
    ONBATT)
        MSG="UPS: running on battery. monitoring power state."
        ;;
    LOWBATT)
        MSG="UPS: LOW BATTERY. initiating graceful cluster shutdown."
        ;;
    ONLINE)
        MSG="UPS: power restored. all clear."
        ;;
    SHUTDOWN)
        MSG="UPS: shutdown in progress."
        ;;
    *)
        MSG="UPS event: $EVENT"
        ;;
esac

# Post to vigil chat (if vigil is still running)
curl -s -o /dev/null -m 5 \
    -u "system:nwl-mission-control" \
    -X POST "http://localhost:3847/api/chat" \
    -H "Content-Type: application/json" \
    -d "{\"sender\":\"ups\",\"text\":\"$MSG\"}" 2>/dev/null

# Future: Discord webhook for critical events (LOWBATT, SHUTDOWN)
```

## Smart Plug Integration

The Tapo smart plugs add a last-resort layer:

1. **Normal operation:** UPS + NUT handle everything. Smart plugs are passive
2. **Extended outage (UPS depleted):** Machines shut down via NUT before UPS dies. Smart plugs log the power-off event
3. **Recovery:** When power returns, smart plugs are ON by default. UPS charges. Machines need manual boot (no Wake-on-LAN on Mac Mini) or:
   - R10: BIOS setting "restore on AC power loss" → auto-boots when power returns
   - Mac Mini: System Preferences → Energy Saver → "Start up automatically after power failure"
4. **Remote power cycle:** If a machine hangs and SSH is dead, jam can toggle the smart plug from his phone to force a hard reboot

## Testing Plan

Before going live:

1. **Dry run (no actual shutdown):** Replace `shutdown -h now` with `echo "WOULD SHUT DOWN"` in all scripts. Run cluster-shutdown.sh and verify the sequence
2. **Single-agent test:** Stop one agent via agent-shutdown-all.sh, verify it stops cleanly, check for state corruption
3. **Full agent test:** Stop all agents, verify all screen sessions are gone, all claude processes are dead
4. **Simulated power loss:** Unplug UPS from wall (while both machines are on battery). Verify NUT detects ONBATT → LOWBATT → shutdown sequence fires
5. **Recovery test:** After shutdown, restore power. Verify both machines come back up. Start agents manually and check for corruption

## Home Assistant Integration

Near confirmed Home Assistant as the automation platform. NUT has a native HA integration.

```yaml
# Home Assistant configuration.yaml (runs as Docker container on R10)
sensor:
  - platform: nut
    host: 127.0.0.1
    port: 3493
    username: upsmon_local
    password: <generated>
    resources:
      - ups.status
      - battery.charge
      - battery.runtime
      - input.voltage

# Automations:
# - Battery < 50%: send notification to jam's phone via HA companion app
# - Battery < 30%: NUT handles shutdown (cluster-shutdown.sh)
# - Power restored: send "all clear" notification
# - Smart plug state change: log to HA history
```

The Tapo smart plugs connect via Matter to HA. **Critical safety rule from Near's research:** Plug 1 controls the UPS powering both servers. Never toggle Plug 1 without running the graceful shutdown sequence first. HA automation should enforce this: block Plug 1 toggle unless both machines report "shutting down" or "offline."

## Dependencies

- Ubuntu Server 24.04 LTS installed on R10
- Tailscale joined on both machines (MagicDNS active)
- SSH key exchange between R10 and Mini (or Tailscale SSH)
- `apt install nut nut-server nut-client` on R10
- Home Assistant Docker container on R10 (for smart plug + UPS dashboard)

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| NUT doesn't detect APC model | Low | High | usbhid-ups driver supports most APC units. Test during R10 setup |
| Mesh is down during power loss | Medium | High | Fallback: R10 shuts down solo. Mini runs on battery until depleted. Smart plug logs the event |
| Agent state corruption on SIGKILL | Medium | Medium | Atomic writes for critical files. 30s SIGTERM window before SIGKILL |
| Mac Mini won't auto-restart after power loss | Low | Low | macOS has "start after power failure" setting. Verify during testing |
| Tailscale down during power loss | Low | High | Fallback: both machines on same LAN switch, use LAN IP as fallback in cluster-shutdown.sh |
