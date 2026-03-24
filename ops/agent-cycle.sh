#!/bin/bash
# Nowhere Labs — Agent Cycle Manager
# Handles kill + restart of Claude Code agents
#
# Usage:
#   ./agent-cycle.sh <agent-name>          # cycle one agent
#   ./agent-cycle.sh --status              # show all agent statuses
#   ./agent-cycle.sh --install <agent>     # install launchd plist for agent
#
# Flow:
#   1. Post discord webhook warning (60s, if configured)
#   2. Git stash uncommitted work
#   3. SIGTERM (5s for SessionEnd hook)
#   4. SIGKILL fallback
#   5. Restart in screen session

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/agent-cycle-config.json"
SENTINEL_DIR="/tmp"
LOG_DIR="/tmp"

# --- Helpers ---

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_DIR/agent-cycle.log"
}

get_config() {
    python3 -c "
import json, sys
with open('$CONFIG_FILE') as f:
    config = json.load(f)
agent = [a for a in config['agents'] if a['name'] == '$1']
if not agent:
    print('NOT_FOUND', file=sys.stderr)
    sys.exit(1)
a = agent[0]
print(f\"{a['workspace']}|{a['process_pattern']}|{a['stagger_offset']}|{a['discord_channel']}|{a['host']}\")
"
}

get_global() {
    python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
print(config.get('$1', ''))
"
}

find_agent_pid() {
    # Find the claude process running in the agent's workspace
    # Uses lsof to match by working directory since workspace path
    # isn't in the command args
    local workspace="$1"
    local expanded_ws
    expanded_ws=$(eval echo "$workspace")
    # Get all claude PIDs, then find the one whose cwd matches the workspace
    for pid in $(pgrep -f "claude.*--dangerously-skip-permissions" 2>/dev/null); do
        local cwd
        cwd=$(lsof -p "$pid" 2>/dev/null | grep cwd | awk '{print $NF}')
        if [ "$cwd" = "$expanded_ws" ]; then
            echo "$pid"
            return
        fi
    done
    echo ""
}

# --- Commands ---

cycle_agent() {
    local agent_name="$1"

    # Lock guard: prevent double-fires from launchd
    local lockfile="$SENTINEL_DIR/agent-${agent_name}-cycling.lock"
    if [ -f "$lockfile" ]; then
        local lock_age
        lock_age=$(( $(date +%s) - $(stat -f %m "$lockfile" 2>/dev/null || echo 0) ))
        if [ "$lock_age" -lt 300 ]; then
            log "SKIPPED: $agent_name cycle already in progress (lock age: ${lock_age}s). aborting to prevent double-fire"
            return
        else
            log "stale lock found for $agent_name (age: ${lock_age}s), removing"
            rm -f "$lockfile"
        fi
    fi
    touch "$lockfile"
    # Ensure lock is removed on exit (normal or error)
    trap "rm -f '$lockfile'" RETURN

    local config_line
    config_line=$(get_config "$agent_name") || { log "ERROR: agent '$agent_name' not found in config"; exit 1; }

    IFS='|' read -r workspace process_pattern stagger_offset discord_channel host <<< "$config_line"
    local expanded_ws
    expanded_ws=$(eval echo "$workspace")

    local pid
    pid=$(find_agent_pid "$workspace")

    if [ -z "$pid" ]; then
        log "WARNING: no running process found for $agent_name in $workspace"
        log "attempting restart without shutdown..."
        restart_agent "$agent_name" "$workspace"
        return
    fi

    log "cycling $agent_name (pid $pid, workspace $workspace)"

    # Step 1: Post warning via discord webhook (if configured)
    local webhook
    webhook=$(get_global "discord_webhook")
    if [ -n "$webhook" ] && [ "$webhook" != "null" ] && [ "$webhook" != "None" ] && [ "$webhook" != "" ]; then
        curl -s -X POST "$webhook" \
            -H "Content-Type: application/json" \
            -d "{\"content\": \"⚠️ **auto-cycle:** $agent_name session ending in 60 seconds. save state now.\"}" \
            > /dev/null 2>&1 || true
        log "posted 60s warning to discord for $agent_name"
        sleep 60
    else
        log "no discord webhook configured — skipping warning"
    fi

    # Step 2: Git stash any uncommitted work in the workspace (safety net)
    # Only stash the workspace itself, NOT subdirectories (shared-brain is a
    # symlink to a shared git repo — stashing it wipes everyone's uncommitted files)
    log "stashing uncommitted work in $expanded_ws"
    (cd "$expanded_ws" && git stash --include-untracked -m "auto-cycle-session-$(date +%Y%m%d-%H%M%S)" 2>/dev/null) || true

    # Step 3: Kill the process (SIGTERM first, gives SessionEnd hook a chance)
    log "sending SIGTERM to $agent_name (pid $pid)"
    kill -TERM "$pid" 2>/dev/null || true
    sleep 5
    # SIGKILL fallback if still alive after 5s
    if kill -0 "$pid" 2>/dev/null; then
        log "$agent_name still running after SIGTERM, sending SIGKILL"
        kill -9 "$pid" 2>/dev/null || true
        sleep 2
    fi

    # Step 4: Restart
    restart_agent "$agent_name" "$workspace"
    log "$agent_name cycle complete"

    # Step 5: Post completion to discord webhook
    if [ -n "$webhook" ] && [ "$webhook" != "null" ] && [ "$webhook" != "None" ] && [ "$webhook" != "" ]; then
        local new_pid
        new_pid=$(find_agent_pid "$workspace")
        local status_emoji="✅"
        local status_text="restarted (pid $new_pid)"
        if [ -z "$new_pid" ]; then
            status_emoji="❌"
            status_text="restart may have failed — no process found"
        fi
        curl -s -X POST "$webhook" \
            -H "Content-Type: application/json" \
            -d "{\"content\": \"$status_emoji **auto-cycle complete:** $agent_name $status_text\"}" \
            > /dev/null 2>&1 || true
    fi
}

restart_agent() {
    local agent_name="$1"
    local workspace="$2"
    local expanded_ws
    expanded_ws=$(eval echo "$workspace")

    log "restarting $agent_name in $expanded_ws"

    # Kill any existing screen session for this agent
    # First verify the session actually exists before trying to quit it
    if screen -ls 2>/dev/null | grep -q "agent-${agent_name}"; then
        screen -S "agent-${agent_name}" -X quit 2>/dev/null || true
        sleep 5  # bumped from 1s — screen needs time to fully terminate
    fi

    # Determine the correct discord state directory per agent.
    # The discord plugin reads DISCORD_STATE_DIR to find the bot token.
    # claude uses the default 'discord/', all others use 'discord-{agent}/'.
    local discord_state_dir="$HOME/.claude/channels/discord"
    if [ "$agent_name" != "claude" ]; then
        discord_state_dir="$HOME/.claude/channels/discord-${agent_name}"
    fi

    # Start new claude process in a screen session (claude code needs a pty)
    screen -dmS "agent-${agent_name}" bash -c "export DISCORD_STATE_DIR='${discord_state_dir}' && cd '$expanded_ws' && claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official"

    sleep 8  # bumped from 2s — claude code needs time to initialize before PID is detectable
    local new_pid
    new_pid=$(find_agent_pid "$workspace")

    # Retry once if PID not found (initialization can be slow)
    if [ -z "$new_pid" ]; then
        log "PID not found after 8s, retrying in 5s..."
        sleep 5
        new_pid=$(find_agent_pid "$workspace")
    fi

    if [ -n "$new_pid" ]; then
        log "$agent_name restarted with pid $new_pid (screen session: agent-${agent_name}, discord_state: $discord_state_dir)"
        # Verify the discord state dir exists and has a token
        if [ ! -f "${discord_state_dir}/.env" ]; then
            log "WARNING: no .env found at ${discord_state_dir} — $agent_name may post under wrong discord identity"
            echo "[$(date)] ALERT: $agent_name has no discord token at $discord_state_dir" >> "$LOG_DIR/agent-cycle-alerts.log"
        fi
    else
        log "WARNING: $agent_name restart may have failed — no process found in $expanded_ws"
        echo "[$(date)] ALERT: $agent_name restart failed. Manual intervention needed." >> "$LOG_DIR/agent-cycle-alerts.log"
    fi
}

show_status() {
    echo "=== Agent Cycle Status ==="
    echo ""

    local agents
    agents=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
for a in config['agents']:
    print(a['name'] + '|' + a['workspace'] + '|' + a['host'])
")

    while IFS='|' read -r name workspace host; do
        local expanded_ws
        expanded_ws=$(eval echo "$workspace")
        local pid
        pid=$(find_agent_pid "$workspace")
        local sentinel="$SENTINEL_DIR/agent-${name}-offramp-complete"

        if [ -n "$pid" ]; then
            local uptime
            uptime=$(ps -o etime= -p "$pid" 2>/dev/null | xargs || echo "unknown")
            echo "  $name: RUNNING (pid $pid, uptime $uptime, host $host)"
        else
            echo "  $name: STOPPED (host $host)"
        fi

        if [ -f "$sentinel" ]; then
            echo "    ⚠ stale sentinel file exists"
        fi
    done <<< "$agents"

    echo ""

    # Show recent alerts
    if [ -f "$LOG_DIR/agent-cycle-alerts.log" ]; then
        echo "=== Recent Alerts ==="
        tail -5 "$LOG_DIR/agent-cycle-alerts.log"
    fi
}

install_plist() {
    local agent_name="$1"
    local config_line
    config_line=$(get_config "$agent_name") || { echo "ERROR: agent '$agent_name' not found"; exit 1; }

    IFS='|' read -r workspace process_pattern stagger_offset discord_channel host <<< "$config_line"

    # Get per-agent cycle interval, fall back to global default
    local interval_hours
    interval_hours=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
agent = [a for a in config['agents'] if a['name'] == '$agent_name'][0]
print(agent.get('cycle_interval_hours', config.get('cycle_interval_hours', 5)))
")
    local interval_seconds=$((interval_hours * 3600))

    local plist_path="$HOME/Library/LaunchAgents/com.nowherelabs.agent-${agent_name}.plist"
    local script_path
    script_path="$(cd "$(dirname "$0")" && pwd)/agent-cycle.sh"

    cat > "$plist_path" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.nowherelabs.agent-${agent_name}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${script_path}</string>
        <string>${agent_name}</string>
    </array>
    <key>StartInterval</key>
    <integer>${interval_seconds}</integer>
    <key>InitialDelay</key>
    <integer>$((stagger_offset * 60))</integer>
    <key>StandardOutPath</key>
    <string>/tmp/agent-${agent_name}-cycle.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/agent-${agent_name}-cycle.log</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
PLIST

    echo "installed: $plist_path"
    echo "to load:   launchctl load $plist_path"
    echo "to unload: launchctl unload $plist_path"
}

# --- Main ---

case "${1:-}" in
    --status)
        show_status
        ;;
    --install)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 --install <agent-name>"
            exit 1
        fi
        install_plist "$2"
        ;;
    --help|-h|"")
        echo "Usage:"
        echo "  $0 <agent-name>          # cycle one agent"
        echo "  $0 --status              # show all agent statuses"
        echo "  $0 --install <agent>     # install launchd plist"
        echo ""
        echo "Agents: claude, claudia, static, near, hum, relay"
        ;;
    *)
        cycle_agent "$1"
        ;;
esac
