#!/bin/bash
# Nowhere Labs — Agent Health Monitor
# Monitors agent health. Read-only by default — never cycles agents
# unless explicitly armed.
#
# Usage:
#   ./agent-health-monitor.sh                       # one-shot report (read-only)
#   ./agent-health-monitor.sh --agent claude         # check one agent (read-only)
#   ./agent-health-monitor.sh --watch                # continuous monitoring (read-only)
#   ./agent-health-monitor.sh --watch --auto-cycle   # continuous + armed (will cycle agents)
#
# SAFETY: one-shot and --watch modes are REPORT ONLY.
# Auto-cycling requires the explicit --auto-cycle flag.
#
# Context estimation:
#   Prefers precise data from statusLine sidecar (/tmp/agent-monitor/{agent}-context.json).
#   Falls back to JSONL session log size as rough proxy.

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/agent-cycle-config.json"
MONITOR_DIR="/tmp/agent-monitor"
CYCLE_SCRIPT="$(dirname "$0")/agent-cycle.sh"
SESSIONS_BASE="$HOME/.claude/projects"
AUTO_CYCLE_ARMED=false  # only set to true with --auto-cycle flag
MAX_CYCLES_PER_DAY=2
CHECK_INTERVAL=300  # 5 minutes

# Context thresholds (JSONL file size in bytes)
# Conservative estimates: autocompact fires at ~83.5% of 1M tokens
# 1M tokens ~ 4MB JSONL (observed from session logs)
# JSONL size is a rough proxy — inflated by tool outputs, file reads, etc.
# These are intentionally wide bands since JSONL ≠ actual context usage.
# Prefer precise sidecar data when available.
WARN_SIZE=$((2 * 1024 * 1024))        # 2MB ~ rough 75% estimate
PREPARE_SIZE=$((3 * 1024 * 1024))     # 3MB ~ rough 85% estimate
FORCE_SIZE=$((4 * 1024 * 1024))       # 4MB ~ rough 92% estimate

# Session age thresholds (seconds)
MAX_SESSION_AGE=$((6 * 3600))         # 6 hours — even healthy sessions degrade

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

mkdir -p "$MONITOR_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MONITOR_DIR/monitor.log"
}

get_agents() {
    python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
for a in config['agents']:
    print(f\"{a['name']}|{a['workspace']}|{a.get('discord_channel', '')}\")
"
}

find_agent_pid() {
    local workspace="$1"
    local expanded_ws
    expanded_ws=$(eval echo "$workspace")

    # Primary: check ~/.claude/sessions/*.json (most reliable)
    # Each file is named {pid}.json and contains {"cwd": "/path/to/workspace"}
    for f in "$HOME"/.claude/sessions/*.json; do
        [ -f "$f" ] || continue
        local pid
        pid=$(basename "$f" .json)
        # Check if process is still alive
        kill -0 "$pid" 2>/dev/null || continue
        # Check if cwd matches
        local cwd
        cwd=$(python3 -c "import json; print(json.load(open('$f')).get('cwd', ''))" 2>/dev/null || echo "")
        if [ "$cwd" = "$expanded_ws" ]; then
            echo "$pid"
            return
        fi
    done

    # Fallback: pgrep + lsof (for processes without session files)
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

get_session_jsonl() {
    # Find the active session JSONL for an agent's workspace
    local workspace="$1"
    local expanded_ws
    expanded_ws=$(eval echo "$workspace")

    # Map workspace to project path (claude uses the path-encoded format)
    local encoded_path
    encoded_path=$(echo "$expanded_ws" | sed 's|/|-|g; s|^-||')
    local project_dir="$SESSIONS_BASE/-${encoded_path}"

    if [ ! -d "$project_dir" ]; then
        # Try alternate encoding
        project_dir="$SESSIONS_BASE/${encoded_path}"
    fi

    if [ ! -d "$project_dir" ]; then
        echo ""
        return
    fi

    # Find the most recently modified JSONL file
    local newest
    newest=$(ls -t "$project_dir"/*.jsonl 2>/dev/null | head -1)
    echo "$newest"
}

get_session_age() {
    local pid="$1"
    if [ -z "$pid" ]; then
        echo "0"
        return
    fi
    # Get elapsed time in seconds
    local etime
    etime=$(ps -o etime= -p "$pid" 2>/dev/null | xargs || echo "0")
    # Parse etime format: [[dd-]hh:]mm:ss
    python3 -c "
import re, sys
t = '$etime'.strip()
if not t or t == '0':
    print(0)
    sys.exit()
# dd-hh:mm:ss or hh:mm:ss or mm:ss
parts = re.split('[-:]', t)
parts = [int(p) for p in parts]
if len(parts) == 4:
    print(parts[0]*86400 + parts[1]*3600 + parts[2]*60 + parts[3])
elif len(parts) == 3:
    print(parts[0]*3600 + parts[1]*60 + parts[2])
elif len(parts) == 2:
    print(parts[0]*60 + parts[1])
else:
    print(0)
" 2>/dev/null || echo "0"
}

get_cycle_count_today() {
    local agent_name="$1"
    local counter_file="$MONITOR_DIR/${agent_name}-cycle-count"
    local today
    today=$(date +%Y-%m-%d)

    if [ -f "$counter_file" ]; then
        local file_date count
        file_date=$(head -1 "$counter_file" 2>/dev/null || echo "")
        count=$(tail -1 "$counter_file" 2>/dev/null || echo "0")
        if [ "$file_date" = "$today" ]; then
            echo "$count"
            return
        fi
    fi
    echo "0"
}


check_agent() {
    local agent_name="$1"
    local workspace="$2"
    local discord_channel="$3"
    local expanded_ws
    expanded_ws=$(eval echo "$workspace")

    local status="healthy"
    local details=""
    local action="none"

    # 1. Check if process is running
    local pid
    pid=$(find_agent_pid "$workspace")

    if [ -z "$pid" ]; then
        status="dead"
        details="no process found"
        action="restart"
        echo "${status}|${details}|${action}|0|0|0"
        return
    fi

    # 2. Check session age
    local age
    age=$(get_session_age "$pid")
    local age_hours=$((age / 3600))

    # 3. Check JSONL file size (context proxy)
    local jsonl_file
    jsonl_file=$(get_session_jsonl "$workspace")
    local jsonl_size=0
    if [ -n "$jsonl_file" ] && [ -f "$jsonl_file" ]; then
        jsonl_size=$(stat -f %z "$jsonl_file" 2>/dev/null || echo "0")
    fi

    # 4. Check heartbeat (last JSONL modification)
    local last_active=0
    if [ -n "$jsonl_file" ] && [ -f "$jsonl_file" ]; then
        local mod_time
        mod_time=$(stat -f %m "$jsonl_file" 2>/dev/null || echo "0")
        local now
        now=$(date +%s)
        last_active=$((now - mod_time))
    fi

    # 5. Check precise context data from sidecar (if available)
    local context_pct=-1
    local sidecar_file="$MONITOR_DIR/${agent_name}-context.json"
    if [ -f "$sidecar_file" ]; then
        # Only trust if updated in last 5 minutes
        local sidecar_age
        sidecar_age=$(( $(date +%s) - $(stat -f %m "$sidecar_file" 2>/dev/null || echo 0) ))
        if [ "$sidecar_age" -lt 300 ]; then
            context_pct=$(python3 -c "
import json
with open('$sidecar_file') as f:
    print(int(json.load(f).get('used_percentage', -1)))
" 2>/dev/null || echo "-1")
        fi
    fi

    # 6. Evaluate health — prefer precise context %, fall back to JSONL size estimate
    if [ "$context_pct" -ge 0 ]; then
        # Precise context data available from sidecar
        if [ "$context_pct" -ge 92 ]; then
            status="critical"
            details="context ${context_pct}%, needs cycle"
            action="force-cycle"
        elif [ "$context_pct" -ge 85 ]; then
            status="degraded"
            details="context ${context_pct}%, prepare for cycle"
            action="warn-agent"
        elif [ "$context_pct" -ge 75 ]; then
            status="warning"
            details="context ${context_pct}%"
            action="monitor"
        fi
    else
        # Fallback: estimate from JSONL file size
        if [ "$jsonl_size" -ge "$FORCE_SIZE" ]; then
            status="critical"
            details="context ~92%+ (${jsonl_size} bytes est.), needs cycle"
            action="force-cycle"
        elif [ "$jsonl_size" -ge "$PREPARE_SIZE" ]; then
            status="degraded"
            details="context ~85%+ (${jsonl_size} bytes est.), prepare for cycle"
            action="warn-agent"
        elif [ "$jsonl_size" -ge "$WARN_SIZE" ]; then
            status="warning"
            details="context ~75%+ (${jsonl_size} bytes est.)"
            action="monitor"
        fi
    fi

    # Additional checks (apply regardless of context source)
    if [ "$status" = "healthy" ] && [ "$age" -ge "$MAX_SESSION_AGE" ]; then
        status="aged"
        details="session ${age_hours}h old, may benefit from cycle"
        action="suggest-cycle"
    fi
    if [ "$status" = "healthy" ] && [ "$last_active" -gt 600 ]; then
        status="idle"
        details="no activity for ${last_active}s"
        action="monitor"
    fi

    echo "${status}|${details}|${action}|${pid}|${jsonl_size}|${age}"
}

run_check() {
    local target_agent="${1:-}"
    local agents
    agents=$(get_agents)

    echo ""
    echo "=== Agent Health Monitor — $(date '+%Y-%m-%d %H:%M:%S CST') ==="
    echo ""

    printf "  %-10s %-10s %-8s %-10s %-6s %s\n" "AGENT" "STATUS" "PID" "CONTEXT" "AGE" "DETAILS"
    printf "  %-10s %-10s %-8s %-10s %-6s %s\n" "-----" "------" "---" "-------" "---" "-------"

    while IFS='|' read -r name workspace discord_channel; do
        if [ -n "$target_agent" ] && [ "$name" != "$target_agent" ]; then
            continue
        fi

        local result
        result=$(check_agent "$name" "$workspace" "$discord_channel")
        IFS='|' read -r status details action pid jsonl_size age <<< "$result"

        local age_hours=$((age / 3600))
        local age_display="${age_hours}h"
        # Show precise context % if available, otherwise JSONL size
        local context_display
        local sidecar_file="$MONITOR_DIR/${name}-context.json"
        if [ -f "$sidecar_file" ]; then
            local sidecar_age
            sidecar_age=$(( $(date +%s) - $(stat -f %m "$sidecar_file" 2>/dev/null || echo 0) ))
            if [ "$sidecar_age" -lt 300 ]; then
                local pct
                pct=$(python3 -c "import json; print(json.load(open('$sidecar_file')).get('used_percentage', '?'))" 2>/dev/null || echo "?")
                context_display="${pct}%"
            else
                context_display="stale"
            fi
        else
            # Fallback to JSONL size
            if [ "$jsonl_size" -gt $((1024 * 1024)) ]; then
                context_display="~$((jsonl_size / 1024 / 1024))MB"
            elif [ "$jsonl_size" -gt 1024 ]; then
                context_display="~$((jsonl_size / 1024))KB"
            else
                context_display="~${jsonl_size}B"
            fi
        fi

        local color="$GREEN"
        case "$status" in
            critical) color="$RED" ;;
            degraded|dead) color="$RED" ;;
            warning|aged) color="$YELLOW" ;;
            idle) color="$CYAN" ;;
        esac

        printf "  %-10s ${color}%-10s${NC} %-8s %-10s %-6s %s\n" \
            "$name" "$status" "${pid:-none}" "$context_display" "$age_display" "$details"

        # Take action if needed (only when armed)
        if [ "$action" = "force-cycle" ] || [ "$action" = "restart" ]; then
            if [ "$AUTO_CYCLE_ARMED" = true ]; then
                local cycle_count
                cycle_count=$(get_cycle_count_today "$name")
                if [ "$cycle_count" -ge "$MAX_CYCLES_PER_DAY" ]; then
                    log "BLOCKED: $name needs cycle but hit daily cap ($cycle_count/$MAX_CYCLES_PER_DAY). manual intervention needed."
                    echo -e "  ${RED}  ^ BLOCKED: daily cycle cap reached ($cycle_count/$MAX_CYCLES_PER_DAY)${NC}"
                else
                    log "ACTION: cycling $name — $details (cycle $((cycle_count + 1))/$MAX_CYCLES_PER_DAY today)"
                    # Note: cycle script handles its own counter increment — don't double-count here
                    if [ -x "$CYCLE_SCRIPT" ]; then
                        "$CYCLE_SCRIPT" "$name" &
                        echo -e "  ${YELLOW}  ^ CYCLING in background${NC}"
                    else
                        echo -e "  ${RED}  ^ cycle script not found at $CYCLE_SCRIPT${NC}"
                    fi
                fi
            else
                echo -e "  ${YELLOW}  ^ WOULD CYCLE (run with --auto-cycle to arm)${NC}"
            fi
        fi

        # Write status to per-agent file for external consumption
        echo "{\"agent\":\"$name\",\"status\":\"$status\",\"pid\":\"${pid:-}\",\"context_bytes\":$jsonl_size,\"session_age\":$age,\"action\":\"$action\",\"checked_at\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > "$MONITOR_DIR/${name}-status.json"

    done <<< "$agents"

    echo ""
}

# --- Main ---

# Parse flags
WATCH_MODE=false
TARGET_AGENT=""

while [ $# -gt 0 ]; do
    case "$1" in
        --watch)
            WATCH_MODE=true
            shift
            ;;
        --auto-cycle)
            AUTO_CYCLE_ARMED=true
            shift
            ;;
        --agent)
            TARGET_AGENT="${2:-}"
            if [ -z "$TARGET_AGENT" ]; then
                echo "Usage: $0 --agent <agent-name>"
                exit 1
            fi
            shift 2
            ;;
        --help|-h)
            echo "Usage:"
            echo "  $0                              # one-shot report (read-only)"
            echo "  $0 --agent <name>               # check one agent (read-only)"
            echo "  $0 --watch                      # continuous monitoring (read-only)"
            echo "  $0 --watch --auto-cycle          # continuous + armed (will cycle)"
            echo ""
            echo "SAFETY: all modes are read-only by default."
            echo "--auto-cycle must be explicitly passed to enable cycling."
            echo ""
            echo "Thresholds:"
            echo "  warn:    ${WARN_SIZE} bytes (~75% context)"
            echo "  prepare: ${PREPARE_SIZE} bytes (~85% context)"
            echo "  force:   ${FORCE_SIZE} bytes (~92% context)"
            echo "  max age: $((MAX_SESSION_AGE / 3600))h"
            echo "  max cycles/day: $MAX_CYCLES_PER_DAY"
            exit 0
            ;;
        *)
            echo "Unknown option: $1. Use --help for usage."
            exit 1
            ;;
    esac
done

if [ "$WATCH_MODE" = true ]; then
    if [ "$AUTO_CYCLE_ARMED" = true ]; then
        log "starting continuous monitoring (${CHECK_INTERVAL}s interval) — AUTO-CYCLE ARMED"
    else
        log "starting continuous monitoring (${CHECK_INTERVAL}s interval) — read-only mode"
    fi
    while true; do
        run_check "$TARGET_AGENT"
        sleep "$CHECK_INTERVAL"
    done
else
    run_check "$TARGET_AGENT"
fi
