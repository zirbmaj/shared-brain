#!/bin/bash
# =============================================================================
# R10 Time Sync Configuration
# Sets timezone to CST, configures NTP via systemd-timesyncd,
# and verifies cross-node clock consistency.
#
# Usage: sudo bash r10-time-sync.sh [--verify-only]
# =============================================================================

set -euo pipefail

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

verify_only=false
if [ "${1:-}" = "--verify-only" ]; then
    verify_only=true
fi

# --- Configure timezone ---
if [ "$verify_only" = false ]; then
    if [ "$EUID" -ne 0 ]; then
        echo "Run as root: sudo bash r10-time-sync.sh"
        exit 1
    fi

    log "Setting timezone to America/Chicago (CST/CDT)"
    timedatectl set-timezone America/Chicago

    # Enable and configure systemd-timesyncd
    # Ubuntu 24.04 includes timesyncd by default
    log "Configuring NTP via systemd-timesyncd"

    mkdir -p /etc/systemd/timesyncd.conf.d
    cat > /etc/systemd/timesyncd.conf.d/nwl.conf << 'EOF'
[Time]
# Primary: Ubuntu's default NTP pool
NTP=ntp.ubuntu.com
# Fallback: NIST and Google NTP
FallbackNTP=time.nist.gov time.google.com pool.ntp.org
# Poll intervals: min 64s, max 2048s
PollIntervalMinSec=64
PollIntervalMaxSec=2048
EOF

    systemctl enable systemd-timesyncd
    systemctl restart systemd-timesyncd

    # Wait for sync
    log "Waiting for NTP sync..."
    for i in $(seq 1 10); do
        if timedatectl show --property=NTPSynchronized --value 2>/dev/null | grep -q "yes"; then
            log "NTP synchronized"
            break
        fi
        sleep 2
    done

    log "Timezone and NTP configured"
fi

# --- Verify time configuration ---
echo ""
echo "=== Time Sync Verification ==="
echo ""

echo "Timezone:"
timedatectl | grep "Time zone" | sed 's/^/  /'

echo ""
echo "NTP status:"
timedatectl | grep -E "NTP|synchronized" | sed 's/^/  /'

echo ""
echo "Timesyncd status:"
timedatectl timesync-status 2>/dev/null | sed 's/^/  /' || echo "  (timesyncd status not available)"

echo ""
echo "Current time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "UTC time:     $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# --- Cross-node clock check ---
echo ""
echo "=== Cross-Node Clock Consistency ==="

# Check if Mini is reachable via Tailscale
if command -v tailscale &>/dev/null && tailscale status 2>/dev/null | grep -q "nwl-mini"; then
    echo "Checking nwl-mini clock..."

    LOCAL_EPOCH=$(date +%s)
    REMOTE_EPOCH=$(ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new nwl-mini "date +%s" 2>/dev/null || echo "")

    if [ -n "$REMOTE_EPOCH" ]; then
        DRIFT=$((LOCAL_EPOCH - REMOTE_EPOCH))
        ABS_DRIFT=${DRIFT#-}

        echo "  R10 epoch:  $LOCAL_EPOCH"
        echo "  Mini epoch: $REMOTE_EPOCH"
        echo "  Drift:      ${DRIFT}s"

        if [ "$ABS_DRIFT" -le 2 ]; then
            echo "  ✓ Clocks are in sync (drift ≤ 2s)"
        elif [ "$ABS_DRIFT" -le 10 ]; then
            echo "  ! Warning: clock drift is ${ABS_DRIFT}s (acceptable but monitor)"
        else
            echo "  ✗ ERROR: clock drift is ${ABS_DRIFT}s — check NTP on both nodes"
            exit 1
        fi
    else
        echo "  Could not SSH to nwl-mini — skipping cross-node check"
        echo "  (ensure UPS SSH key is deployed and accepted)"
    fi
else
    echo "  Tailscale not connected to nwl-mini — skipping cross-node check"
fi

echo ""
echo "=== Done ==="
