#!/bin/bash
# Agent Health Check — monitors screen sessions for all 6 agents
# Posts to Discord #dev webhook if any agent is down
# Designed to run via cron every 5 minutes
#
# Usage:
#   agent-health-check.sh              # check and alert
#   agent-health-check.sh --quiet      # check only, no webhook
#   agent-health-check.sh --install    # install cron job

set -u
# Note: no -e or pipefail because screen -ls returns exit 1 even when sessions exist

AGENTS="claude claudia static near hum relay"
WEBHOOK_URL="${DISCORD_DEV_WEBHOOK:-}"
LOG_FILE="/tmp/agent-health-check.log"
ALERT_COOLDOWN_FILE="/tmp/agent-health-alert-sent"
COOLDOWN_MINUTES=10

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_agents() {
    local down_agents=""
    local all_ok=true

    for agent in $AGENTS; do
        local screen_name="agent-${agent}"
        if screen -ls 2>/dev/null | grep -q "${screen_name}"; then
            # Screen exists — check if the claude process inside is alive
            local workspace="$HOME/${agent}-workspace"
            local pid=""
            for p in $(pgrep -f "claude.*--dangerously-skip-permissions" 2>/dev/null); do
                local cwd
                cwd=$(lsof -p "$p" 2>/dev/null | grep cwd | awk '{print $NF}')
                if [ "$cwd" = "$workspace" ]; then
                    pid="$p"
                    break
                fi
            done
            if [ -z "$pid" ]; then
                down_agents="${down_agents} ${agent}(screen-alive-no-process)"
                all_ok=false
            fi
        else
            down_agents="${down_agents} ${agent}(no-screen)"
            all_ok=false
        fi
    done

    if $all_ok; then
        log "all agents healthy"
        # Clear cooldown on healthy check
        rm -f "$ALERT_COOLDOWN_FILE" 2>/dev/null
        return 0
    else
        log "DOWN:${down_agents}"
        echo "$down_agents"
        return 1
    fi
}

send_alert() {
    local down_agents="$1"

    # Check cooldown — don't spam alerts
    if [ -f "$ALERT_COOLDOWN_FILE" ]; then
        local last_alert
        last_alert=$(cat "$ALERT_COOLDOWN_FILE" 2>/dev/null || echo "0")
        local now
        now=$(date +%s)
        local diff=$(( (now - last_alert) / 60 ))
        if [ "$diff" -lt "$COOLDOWN_MINUTES" ]; then
            log "alert suppressed (cooldown: ${diff}m < ${COOLDOWN_MINUTES}m)"
            return
        fi
    fi

    if [ -n "$WEBHOOK_URL" ]; then
        curl -s -X POST "$WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{\"content\": \"**AGENT DOWN:**${down_agents}. manual restart needed: ~/shared-brain/ops/agent-cycle.sh <agent>\"}" \
            > /dev/null 2>&1
        log "alert sent to discord"
    else
        log "WARNING: no DISCORD_DEV_WEBHOOK set — alert not sent"
    fi

    date +%s > "$ALERT_COOLDOWN_FILE"
}

install_cron() {
    local script_path
    script_path="$(cd "$(dirname "$0")" && pwd)/agent-health-check.sh"

    # Get the webhook URL from agent-cycle-config.json
    local webhook
    webhook=$(python3 -c "
import json
with open('$HOME/shared-brain/ops/agent-cycle-config.json') as f:
    config = json.load(f)
print(config.get('discord_webhook', ''))
" 2>/dev/null || echo "")

    local cron_line="*/5 * * * * DISCORD_DEV_WEBHOOK=\"${webhook}\" ${script_path} >> /tmp/agent-health-check.log 2>&1"

    # Check if already installed
    if crontab -l 2>/dev/null | grep -q "agent-health-check"; then
        echo "health check cron already installed. removing old entry."
        crontab -l 2>/dev/null | grep -v "agent-health-check" | crontab -
    fi

    (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
    echo "installed: runs every 5 minutes"
    echo "cron line: $cron_line"
    echo "log: /tmp/agent-health-check.log"
}

# --- Main ---

case "${1:-}" in
    --quiet)
        if check_agents; then
            echo "all agents healthy"
        else
            echo "agents down: $(check_agents 2>/dev/null || true)"
        fi
        ;;
    --install)
        install_cron
        ;;
    *)
        down=$(check_agents 2>&1) || true
        if [ -n "$down" ]; then
            send_alert "$down"
        fi
        ;;
esac
