#!/bin/bash
# agent-shutdown-all.sh — Gracefully stops all agents on the Mac Mini
# Called by UPS shutdown sequence or manual maintenance
# Location on Mini: /usr/local/bin/agent-shutdown-all.sh
# Owner: static

set -uo pipefail

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
