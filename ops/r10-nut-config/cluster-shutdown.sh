#!/bin/bash
# cluster-shutdown.sh — Orchestrates graceful shutdown of the entire NWL rack
# Triggered by NUT upsmon on LOWBATT
# Location on R10: /srv/shared/bin/cluster-shutdown.sh
# Owner: static

set -uo pipefail

LOG="/var/log/ups-shutdown.log"
MINI_TAILSCALE="nwl-mini"
MINI_LAN="192.168.1.XX"         # Set during setup
MINI_USER="nwl-admin"
SSH_KEY="/root/.ssh/id_nwl_ups"
TIMEOUT=180

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
