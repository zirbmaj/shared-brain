#!/bin/bash
# Vigil Watchdog — checks servers + tunnels, auto-restarts on failure
# Run via cron every 2 minutes:
#   */2 * * * * /Users/jambrizr/shared-brain/ops/vigil-watchdog.sh >> /tmp/vigil-watchdog.log 2>&1

set -euo pipefail

DISCORD_WEBHOOK="${DISCORD_DEV_WEBHOOK:-}"
LOG_PREFIX="[$(date '+%H:%M:%S')]"

log() { echo "$LOG_PREFIX $1"; }

alert() {
    log "ALERT: $1"
    if [ -n "$DISCORD_WEBHOOK" ]; then
        curl -s -X POST "$DISCORD_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"username\":\"watchdog\",\"content\":\"⚠️ **vigil watchdog:** $1\"}" > /dev/null 2>&1
    fi
}

# --- Check NWL vigil server ---
NWL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:3847/ -u jam:nwl-mission-control 2>/dev/null || echo "000")
if [ "$NWL_STATUS" != "200" ]; then
    alert "NWL vigil down (HTTP $NWL_STATUS). restarting via launchd."
    # Kill any orphaned process on port 3847
    lsof -ti:3847 2>/dev/null | xargs kill -9 2>/dev/null || true
    sleep 1
    launchctl kickstart -k gui/$(id -u)/com.nowherelabs.vigil 2>/dev/null || \
        launchctl start com.nowherelabs.vigil 2>/dev/null || true
    sleep 3
    RETRY=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:3847/ -u jam:nwl-mission-control 2>/dev/null || echo "000")
    if [ "$RETRY" = "200" ]; then
        log "NWL vigil recovered."
    else
        alert "NWL vigil failed to recover after restart. manual intervention needed."
    fi
else
    log "NWL vigil: OK"
fi

# --- Check meridian vigil server ---
MER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:3849/ -u fran:meridian-vigil 2>/dev/null || echo "000")
if [ "$MER_STATUS" != "200" ]; then
    alert "Meridian vigil down (HTTP $MER_STATUS). restarting via launchd."
    lsof -ti:3849 2>/dev/null | xargs kill -9 2>/dev/null || true
    sleep 1
    launchctl kickstart -k gui/$(id -u)/com.nowherelabs.vigil-meridian 2>/dev/null || \
        launchctl start com.nowherelabs.vigil-meridian 2>/dev/null || true
    sleep 3
    RETRY=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:3849/ -u fran:meridian-vigil 2>/dev/null || echo "000")
    if [ "$RETRY" = "200" ]; then
        log "Meridian vigil recovered."
    else
        alert "Meridian vigil failed to recover after restart. manual intervention needed."
    fi
else
    log "Meridian vigil: OK"
fi

# --- Check NWL cloudflare tunnel ---
NWL_TUNNEL=$(launchctl list 2>/dev/null | grep com.cloudflare.cloudflared | awk '{print $1}')
if [ -z "$NWL_TUNNEL" ] || [ "$NWL_TUNNEL" = "-" ]; then
    alert "NWL cloudflare tunnel down. restarting."
    launchctl start com.cloudflare.cloudflared 2>/dev/null || true
    sleep 3
    log "NWL tunnel restart attempted."
else
    log "NWL tunnel: OK (pid $NWL_TUNNEL)"
fi

# --- Check meridian cloudflare tunnel ---
MER_TUNNEL=$(launchctl list 2>/dev/null | grep com.cloudflare.meridian-tunnel | awk '{print $1}')
if [ -z "$MER_TUNNEL" ] || [ "$MER_TUNNEL" = "-" ]; then
    alert "Meridian cloudflare tunnel down. restarting."
    launchctl start com.cloudflare.meridian-tunnel 2>/dev/null || true
    sleep 3
    log "Meridian tunnel restart attempted."
else
    log "Meridian tunnel: OK (pid $MER_TUNNEL)"
fi

log "watchdog check complete."
