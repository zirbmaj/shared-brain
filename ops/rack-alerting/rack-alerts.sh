#!/bin/bash
# rack-alerts.sh — Periodic health check + alerting for the NWL rack
# Runs via cron every 2 minutes on the R10: */2 * * * * /srv/shared/bin/rack-alerts.sh
# Alerts route to: vigil chat + discord #bugs webhook
#
# Owner: relay
# Created: 2026-03-28

set -euo pipefail

LOG="/var/log/rack-alerts.log"
STATE_DIR="/var/run/rack-alerts"
mkdir -p "$STATE_DIR"

# --- Config ---
VIGIL_URL="${VIGIL_URL:-http://localhost:3847/api/chat}"
VIGIL_AUTH="${VIGIL_AUTH:-system:nwl-mission-control}"
DISCORD_BUGS_WEBHOOK="${DISCORD_BUGS_WEBHOOK:-}"

DISK_WARN_PCT=80
DISK_CRIT_PCT=90
CPU_TEMP_WARN=75
CPU_TEMP_CRIT=85

# --- Helpers ---

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"
}

send_alert() {
    local severity="$1"  # warn | crit
    local source="$2"
    local msg="$3"
    local state_key="$4"
    local state_file="$STATE_DIR/$state_key"

    # Deduplicate: don't re-alert if same state within 30 minutes
    if [ -f "$state_file" ]; then
        local age=$(( $(date +%s) - $(stat -c %Y "$state_file" 2>/dev/null || stat -f %m "$state_file" 2>/dev/null) ))
        if [ "$age" -lt 1800 ]; then
            return
        fi
    fi

    touch "$state_file"
    log "ALERT [$severity] $source: $msg"

    local prefix=""
    if [ "$severity" = "crit" ]; then
        prefix="CRITICAL: "
    fi

    # Post to vigil chat
    curl -s -o /dev/null -m 5 \
        -u "$VIGIL_AUTH" \
        -X POST "$VIGIL_URL" \
        -H "Content-Type: application/json" \
        -d "{\"sender\":\"rack-alerts\",\"text\":\"${prefix}${msg}\"}" 2>/dev/null || true

    # Post to discord #bugs if webhook is set
    if [ -n "$DISCORD_BUGS_WEBHOOK" ]; then
        curl -s -o /dev/null -m 5 \
            -X POST "$DISCORD_BUGS_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"content\":\"**rack-alert [${severity}]** ${msg}\"}" 2>/dev/null || true
    fi
}

clear_alert() {
    local state_key="$1"
    local state_file="$STATE_DIR/$state_key"
    if [ -f "$state_file" ]; then
        rm -f "$state_file"
        log "CLEARED: $state_key"
    fi
}

# --- Checks ---

check_disk() {
    # Check all mounted filesystems
    df -h --output=pcent,target 2>/dev/null | tail -n +2 | while read -r pct mount; do
        pct_num="${pct%%%}"
        if [ "$pct_num" -ge "$DISK_CRIT_PCT" ]; then
            send_alert "crit" "disk" "disk ${pct} full on ${mount}" "disk-crit-${mount//\//-}"
        elif [ "$pct_num" -ge "$DISK_WARN_PCT" ]; then
            send_alert "warn" "disk" "disk ${pct} on ${mount} — approaching full" "disk-warn-${mount//\//-}"
        else
            clear_alert "disk-crit-${mount//\//-}"
            clear_alert "disk-warn-${mount//\//-}"
        fi
    done
}

check_cpu_temp() {
    # Try sensors first, fall back to thermal zone
    local temp=""
    if command -v sensors &>/dev/null; then
        temp=$(sensors 2>/dev/null | grep -oP 'Package.*?\+\K[0-9]+' | head -1)
    fi
    if [ -z "$temp" ] && [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        local raw
        raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        temp=$(( raw / 1000 ))
    fi

    if [ -n "$temp" ]; then
        if [ "$temp" -ge "$CPU_TEMP_CRIT" ]; then
            send_alert "crit" "temp" "CPU temperature ${temp}C — thermal throttle risk" "cpu-temp-crit"
        elif [ "$temp" -ge "$CPU_TEMP_WARN" ]; then
            send_alert "warn" "temp" "CPU temperature ${temp}C — running hot" "cpu-temp-warn"
        else
            clear_alert "cpu-temp-crit"
            clear_alert "cpu-temp-warn"
        fi
    fi
}

check_postgres() {
    if ! pg_isready -q -h localhost -p 5432 2>/dev/null; then
        send_alert "crit" "postgres" "postgresql is not responding on port 5432" "postgres-down"
    else
        clear_alert "postgres-down"
    fi
}

check_ollama() {
    if ! curl -s -o /dev/null -m 3 http://localhost:11434/api/tags 2>/dev/null; then
        send_alert "warn" "ollama" "ollama is not responding on port 11434" "ollama-down"
    else
        clear_alert "ollama-down"
    fi
}

check_syncthing() {
    if ! curl -s -o /dev/null -m 3 http://localhost:22000 2>/dev/null; then
        send_alert "warn" "syncthing" "syncthing is not responding — shared-brain sync may be stalled" "syncthing-down"
    else
        clear_alert "syncthing-down"
    fi

    # Check for conflict files (syncthing creates .sync-conflict- files)
    local conflicts
    conflicts=$(find /srv/nwl/shared-brain -name "*.sync-conflict-*" 2>/dev/null | wc -l)
    if [ "$conflicts" -gt 0 ]; then
        send_alert "warn" "syncthing" "syncthing: ${conflicts} conflict file(s) in shared-brain" "syncthing-conflicts"
    else
        clear_alert "syncthing-conflicts"
    fi
}

check_rag_api() {
    if ! curl -s -o /dev/null -m 3 http://localhost:8080/health 2>/dev/null; then
        send_alert "warn" "rag" "RAG search API is not responding on port 8080" "rag-down"
    else
        clear_alert "rag-down"
    fi
}

check_ups() {
    # UPS has its own notify path via NUT, but we also poll here as a backup
    if command -v upsc &>/dev/null; then
        local status
        status=$(upsc apc600@localhost ups.status 2>/dev/null || echo "unknown")
        local charge
        charge=$(upsc apc600@localhost battery.charge 2>/dev/null || echo "0")

        if [[ "$status" == *"OB"* ]]; then
            send_alert "crit" "ups" "UPS on battery (charge: ${charge}%)" "ups-battery"
        else
            clear_alert "ups-battery"
        fi

        if [ "${charge%%.*}" -lt 30 ] 2>/dev/null; then
            send_alert "crit" "ups" "UPS battery low: ${charge}%" "ups-low-battery"
        else
            clear_alert "ups-low-battery"
        fi
    fi
}

check_backup_age() {
    # Alert if the most recent postgres backup is older than 25 hours
    local backup_dir="/srv/nwl/backups/postgres"
    if [ -d "$backup_dir" ]; then
        local newest
        newest=$(find "$backup_dir" -name "*.sql.gz" -type f -printf '%T@\n' 2>/dev/null | sort -rn | head -1)
        if [ -n "$newest" ]; then
            local age=$(( $(date +%s) - ${newest%%.*} ))
            if [ "$age" -gt 90000 ]; then  # 25 hours
                send_alert "warn" "backup" "postgres backup is $(( age / 3600 ))h old — expected daily" "backup-stale"
            else
                clear_alert "backup-stale"
            fi
        else
            send_alert "warn" "backup" "no postgres backups found in ${backup_dir}" "backup-missing"
        fi
    fi
}

# --- Main ---

log "health check started"

check_disk
check_cpu_temp
check_postgres
check_ollama
check_syncthing
check_rag_api
check_ups
check_backup_age

log "health check complete"
