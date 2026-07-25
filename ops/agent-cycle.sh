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
    # Find the CLI process running inside the agent's screen session.
    # Previous approach matched by cwd via lsof, but screen parent processes
    # inherit cwd from the cycle script — not from the cd inside bash -c.
    # This caused cross-contamination (session 12: found static's PID for claude).
    #
    # New approach: walk the process tree from the named screen session.
    local agent_name="$1"

    # Get the screen session PID for this agent
    local screen_pid
    # Use \b word boundary to prevent agent-claude matching agent-claudia
    screen_pid=$(screen -ls 2>/dev/null | grep -E "agent-${agent_name}\b" | awk '{print $1}' | cut -d. -f1 | head -1)
    if [ -z "$screen_pid" ]; then
        echo ""
        return
    fi

    # Find claude/codex process that is a descendant of this screen session.
    # Walk: screen -> bash/login -> agent CLI
    for child in $(pgrep -P "$screen_pid" 2>/dev/null); do
        # Check direct child (bash -c wrapper)
        local agent_pid
        agent_pid=$(pgrep -P "$child" -f "claude|codex" 2>/dev/null | head -1)
        if [ -n "$agent_pid" ]; then
            echo "$agent_pid"
            return
        fi
        # The child itself might be the agent CLI (if no bash wrapper)
        if ps -p "$child" -o args= 2>/dev/null | grep -Eq "claude|codex"; then
            echo "$child"
            return
        fi
    done
    echo ""
}

# Record one successful cycle against the agent's daily counter. Called only AFTER a
# restart actually succeeds, so failed attempts don't consume the daily cap. The per-agent
# cycling.lock already serializes a given agent's cycles, but we still take the counter lock
# to stay consistent with the read side.
record_successful_cycle() {
    local agent_name="$1"
    local counter_file="/tmp/agent-monitor/${agent_name}-cycle-count"
    local counter_lock="/tmp/agent-monitor/${agent_name}-cycle-count.lock"
    local today
    today=$(date +%Y-%m-%d)
    mkdir -p /tmp/agent-monitor
    local acquired=false
    for _a in 1 2 3 4 5; do
        if mkdir "$counter_lock" 2>/dev/null; then acquired=true; break; fi
        if [ -d "$counter_lock" ]; then
            local age
            age=$(( $(date +%s) - $(stat -f %m "$counter_lock" 2>/dev/null || stat -c %Y "$counter_lock" 2>/dev/null || echo "0") ))
            if [ "$age" -gt 60 ]; then rmdir "$counter_lock" 2>/dev/null; continue; fi
        fi
        sleep 1
    done
    local count=0
    if [ -f "$counter_file" ] && [ "$(head -1 "$counter_file" 2>/dev/null)" = "$today" ]; then
        count=$(tail -1 "$counter_file" 2>/dev/null || echo "0")
    fi
    echo "$today" > "$counter_file"
    echo "$((count + 1))" >> "$counter_file"
    [ "$acquired" = true ] && rmdir "$counter_lock" 2>/dev/null || true
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

    # Daily cycle cap: prevent runaway cycling (session 9 incident)
    # Uses mkdir-based lock to prevent race condition where two processes both read count=0
    # and both approve a cycle, bypassing the cap (locus audit, session 15; flock→mkdir, session 16)
    local MAX_CYCLES_PER_DAY=2
    mkdir -p /tmp/agent-monitor
    local counter_file="/tmp/agent-monitor/${agent_name}-cycle-count"
    local counter_lock="/tmp/agent-monitor/${agent_name}-cycle-count.lock"
    local today
    today=$(date +%Y-%m-%d)

    # Atomic read-check-increment using mkdir lock (works on macOS + Linux)
    # mkdir is atomic on all POSIX systems — replaces flock which is Linux-only
    local cycle_count=0
    local lock_acquired=false
    for _attempt in 1 2 3 4 5; do
        if mkdir "$counter_lock" 2>/dev/null; then
            lock_acquired=true
            break
        fi
        # Check for stale lock (older than 60s)
        if [ -d "$counter_lock" ]; then
            local lock_age
            lock_age=$(( $(date +%s) - $(stat -f %m "$counter_lock" 2>/dev/null || stat -c %Y "$counter_lock" 2>/dev/null || echo "0") ))
            if [ "$lock_age" -gt 60 ]; then
                rmdir "$counter_lock" 2>/dev/null
                continue
            fi
        fi
        sleep 1
    done

    if [ "$lock_acquired" = true ]; then
        if [ -f "$counter_file" ]; then
            local file_date
            file_date=$(head -1 "$counter_file" 2>/dev/null || echo "")
            if [ "$file_date" = "$today" ]; then
                cycle_count=$(tail -1 "$counter_file" 2>/dev/null || echo "0")
            fi
        fi
        if [ "$cycle_count" -ge "$MAX_CYCLES_PER_DAY" ]; then
            echo "BLOCKED" > /tmp/agent-monitor/${agent_name}-cycle-result
        else
            # NOTE: counter is NOT incremented here — only the check happens. The cycle is
            # counted once the restart actually succeeds (record_successful_cycle), so failed
            # attempts don't burn the daily cap. Bug found 2026-05-27: failed restarts ate all
            # 2/2 cycles and left the whole team unrevivable until the date rolled over.
            echo "OK:$((cycle_count + 1))" > /tmp/agent-monitor/${agent_name}-cycle-result
        fi
        rmdir "$counter_lock" 2>/dev/null
    else
        log "ERROR: could not acquire cycle counter lock for $agent_name"
        echo "ERROR" > /tmp/agent-monitor/${agent_name}-cycle-result
    fi

    local cycle_result
    cycle_result=$(cat /tmp/agent-monitor/${agent_name}-cycle-result 2>/dev/null || echo "ERROR")
    rm -f /tmp/agent-monitor/${agent_name}-cycle-result

    if [ "$cycle_result" = "BLOCKED" ]; then
        log "BLOCKED: $agent_name has hit daily cycle cap ($MAX_CYCLES_PER_DAY/$MAX_CYCLES_PER_DAY). skipping cycle."
        echo "[$(date)] ALERT: $agent_name cycle blocked — daily cap reached ($MAX_CYCLES_PER_DAY/$MAX_CYCLES_PER_DAY)" >> "$LOG_DIR/agent-cycle-alerts.log"
        return
    elif [[ "$cycle_result" == OK:* ]]; then
        cycle_count="${cycle_result#OK:}"
        log "$agent_name cycle $cycle_count/$MAX_CYCLES_PER_DAY today"
    else
        log "ERROR: cycle counter check failed for $agent_name"
        return
    fi

    local config_line
    config_line=$(get_config "$agent_name") || { log "ERROR: agent '$agent_name' not found in config"; exit 1; }

    IFS='|' read -r workspace process_pattern stagger_offset discord_channel host <<< "$config_line"
    local expanded_ws
    expanded_ws="${workspace/#\~/$HOME}"

    local pid
    pid=$(find_agent_pid "$agent_name")

    if [ -z "$pid" ]; then
        log "WARNING: no running process found for $agent_name in $workspace"
        log "attempting restart without shutdown..."
        if restart_agent "$agent_name" "$workspace"; then
            record_successful_cycle "$agent_name"
        else
            log "ERROR: restart failed for $agent_name — not counting against daily cap"
        fi
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

    # Step 3: Kill the process (SIGTERM first, gives SessionEnd hooks time to complete)
    # SessionEnd hook chains can include network calls (supabase writes) and
    # long-running tasks (ollama skill extraction, 180s timeout). Poll for
    # graceful exit up to 60s before resorting to SIGKILL (axis audit, session 20).
    log "sending SIGTERM to $agent_name (pid $pid)"
    kill -TERM "$pid" 2>/dev/null || true
    local waited=0
    while [ "$waited" -lt 60 ]; do
        if ! kill -0 "$pid" 2>/dev/null; then
            log "$agent_name exited gracefully after ${waited}s"
            break
        fi
        sleep 1
        waited=$((waited + 1))
    done
    # SIGKILL fallback if still alive after 60s
    if kill -0 "$pid" 2>/dev/null; then
        log "$agent_name still running after 60s, sending SIGKILL"
        kill -9 "$pid" 2>/dev/null || true
        sleep 2
    fi

    # Step 4: Restart (count only on success — see record_successful_cycle)
    if restart_agent "$agent_name" "$workspace"; then
        record_successful_cycle "$agent_name"
        log "$agent_name cycle complete"
    else
        log "ERROR: restart failed for $agent_name — not counting against daily cap"
    fi

    # Step 5: Post completion to discord webhook
    if [ -n "$webhook" ] && [ "$webhook" != "null" ] && [ "$webhook" != "None" ] && [ "$webhook" != "" ]; then
        local new_pid
        new_pid=$(find_agent_pid "$agent_name")
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
    expanded_ws="${workspace/#\~/$HOME}"

    log "restarting $agent_name in $expanded_ws"

    # Kill ALL existing instances of this agent before relaunching — every screen
    # socket matching the name plus the claude process inside each. The previous
    # code quit a single ambiguous `-S agent-X` session and ignored extras, so any
    # pre-existing duplicate (or orphan from a prior failed retry) survived and
    # accumulated (8-9 dupes/agent observed 2026-05-21). Word-boundary match so
    # agent-claude never catches agent-claudia.
    local _sids _sid _child _gc
    # `|| true` is load-bearing: under `set -euo pipefail`, grep exits 1 when no
    # matching screen exists (i.e. the agent is fully DOWN), which aborts restart_agent
    # before the relaunch below — making cold-start of a dead agent impossible. The whole
    # NWL team deadlocked this way once all sessions dropped (diagnosed 2026-05-27).
    _sids=$(screen -ls 2>/dev/null | grep -oE "[0-9]+\.agent-${agent_name}\b" || true)
    for _sid in $_sids; do
        for _child in $(pgrep -P "${_sid%%.*}" 2>/dev/null); do
            for _gc in $(pgrep -P "$_child" 2>/dev/null); do kill "$_gc" 2>/dev/null || true; done
        done
        screen -S "$_sid" -X quit 2>/dev/null || true
    done
    [ -n "$_sids" ] && sleep 5  # screen needs time to fully terminate

    # Determine the correct discord state directory per agent.
    # The discord plugin reads DISCORD_STATE_DIR to find the bot token.
    # claude uses the default 'discord/', all others use 'discord-{agent}/'.
    local discord_state_dir="$HOME/.claude/channels/discord"
    if [ "$agent_name" != "claude" ]; then
        discord_state_dir="$HOME/.claude/channels/discord-${agent_name}"
    fi

    local launch_command="claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official"
    if [ "$agent_name" = "claude" ] || [ "$agent_name" = "relay" ]; then
        launch_command="codex --dangerously-bypass-approvals-and-sandbox -C '$expanded_ws'"
    fi

    # Start new agent process in a screen session (interactive CLIs need a pty)
    # TERM=xterm-256color is required — ghostty's terminfo (xterm-ghostty) isn't
    # recognized by screen, causing silent initialization failures (session 9.3 root cause)
    # Use `exec` — piping through tee breaks stdin, causing interactive agents to fail.
    # Stderr goes to a log file for post-mortem debugging.
    screen -dmS "agent-${agent_name}" bash -c "export TERM=xterm-256color && export PATH=\"/Users/jambrizr/.local/bin:\$PATH\" && export AGENT_NAME='${agent_name}' && export NWL_AGENT_NAME='${agent_name}' && export DISCORD_STATE_DIR='${discord_state_dir}' && cd '$expanded_ws' && exec ${launch_command} 2>>/tmp/agent-${agent_name}-stderr.log"

    sleep 8  # bumped from 2s — claude code needs time to initialize before PID is detectable
    local new_pid
    new_pid=$(find_agent_pid "$agent_name")

    # Retry once if PID not found (initialization can be slow)
    if [ -z "$new_pid" ]; then
        log "PID not found after 8s, retrying in 5s..."
        sleep 5
        new_pid=$(find_agent_pid "$agent_name")
    fi

    # 4-step post-restart validation
    local validation_passed=true

    # Step 1: PID exists
    if [ -z "$new_pid" ]; then
        log "VALIDATION FAILED [1/4]: no PID found for $agent_name"
        echo "[$(date)] ALERT: $agent_name restart failed — no process. Manual intervention needed." >> "$LOG_DIR/agent-cycle-alerts.log"
        return 1
    fi
    log "VALIDATION [1/4]: PID $new_pid found"

    # Step 2: Screen session responds (blocking — retry up to 3 times)
    local screen_found=false
    for attempt in 1 2 3; do
        # A claude PID descended from the named screen session (step 1) is the
        # authoritative signal — if it's alive, the screen session exists by definition.
        # `screen -ls` is only a proxy and races freshly-spawned sessions, which previously
        # false-FATAL'd healthy instances and got them killed (bug found 2026-05-27).
        if [ -n "$new_pid" ] && kill -0 "$new_pid" 2>/dev/null; then
            screen_found=true
            log "VALIDATION [2/4]: agent-${agent_name} confirmed up (pid $new_pid alive)"
            break
        fi
        # PID gone — re-detect in case claude was mid-init when step 1 sampled it
        new_pid=$(find_agent_pid "$agent_name")
        if [ -n "$new_pid" ] && kill -0 "$new_pid" 2>/dev/null; then
            screen_found=true
            log "VALIDATION [2/4]: agent-${agent_name} confirmed up (re-detected pid $new_pid)"
            break
        fi
        log "VALIDATION [2/4]: agent-${agent_name} process not alive (attempt $attempt/3)"
        if [ "$attempt" -lt 3 ]; then
            sleep 5
        fi
    done
    if [ "$screen_found" = false ]; then
        log "VALIDATION FAILED [2/4]: screen session agent-${agent_name} not found after 3 attempts — cleaning up stale instance, then restarting"
        echo "[$(date)] ALERT: $agent_name screen session missing after restart. Retrying restart." >> "$LOG_DIR/agent-cycle-alerts.log"
        # CRITICAL FIX (2026-05-21): kill the unconfirmed instance BEFORE relaunching.
        # Step 1 already found a live PID, so a screen+claude IS running — the
        # `screen -ls` check above just raced (intermittent visibility). Spawning
        # again without this kill stacks a duplicate; repeated over days this is
        # how 8-9 live instances per agent accumulated.
        [ -n "$new_pid" ] && kill -9 "$new_pid" 2>/dev/null || true
        for _sid in $(screen -ls 2>/dev/null | grep -oE "[0-9]+\.agent-${agent_name}\b"); do
            screen -S "$_sid" -X quit 2>/dev/null || true
        done
        sleep 5
        # Relaunch exactly one clean instance
        screen -dmS "agent-${agent_name}" bash -c "export TERM=xterm-256color && export PATH=\"/Users/jambrizr/.local/bin:\$PATH\" && export AGENT_NAME='${agent_name}' && export NWL_AGENT_NAME='${agent_name}' && export DISCORD_STATE_DIR='${discord_state_dir}' && cd '$expanded_ws' && exec ${launch_command} 2>>/tmp/agent-${agent_name}-stderr.log"
        sleep 10
        if ! screen -ls 2>/dev/null | grep -q "agent-${agent_name}"; then
            log "VALIDATION FATAL [2/4]: screen session still missing after retry. Manual intervention needed."
            echo "[$(date)] FATAL: $agent_name screen session failed twice. Manual restart required." >> "$LOG_DIR/agent-cycle-alerts.log"
            return 1
        fi
        log "VALIDATION [2/4]: screen session agent-${agent_name} exists (on retry)"
        # Re-detect PID after retry restart
        new_pid=$(find_agent_pid "$agent_name")
    fi

    # Step 3: Discord state files exist and are valid
    if [ ! -f "${discord_state_dir}/.env" ]; then
        log "VALIDATION FAILED [3/4]: no .env at ${discord_state_dir}"
        echo "[$(date)] ALERT: $agent_name has no discord token at $discord_state_dir" >> "$LOG_DIR/agent-cycle-alerts.log"
        validation_passed=false
    else
        log "VALIDATION [3/4]: discord .env exists"
    fi

    # Check access.json integrity
    local access_json="${discord_state_dir}/access.json"
    if [ -f "$access_json" ]; then
        if ! python3 -c "import json; json.load(open('$access_json'))" 2>/dev/null; then
            log "VALIDATION FAILED [3b/4]: access.json is invalid JSON — attempting restore from backup"
            # Try to restore from backup
            local backup="${access_json}.bak"
            if [ -f "$backup" ] && python3 -c "import json; json.load(open('$backup'))" 2>/dev/null; then
                cp "$backup" "$access_json"
                log "RESTORED access.json from backup"
            else
                echo "[$(date)] ALERT: $agent_name access.json corrupt, no valid backup. Agent may be deaf." >> "$LOG_DIR/agent-cycle-alerts.log"
                validation_passed=false
            fi
        else
            log "VALIDATION [3b/4]: access.json is valid JSON"
        fi
    fi

    # Step 4: Agent check-in (logged, not blocking — check-in happens async via discord)
    log "VALIDATION [4/4]: awaiting discord check-in from $agent_name (async)"

    if [ "$validation_passed" = true ]; then
        log "$agent_name restarted successfully — pid $new_pid, screen agent-${agent_name}, discord_state $discord_state_dir"
    else
        log "WARNING: $agent_name restarted with validation issues — check alerts log"
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
        expanded_ws="${workspace/#\~/$HOME}"
        local pid
        pid=$(find_agent_pid "$name")
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
