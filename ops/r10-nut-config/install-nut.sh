#!/bin/bash
# install-nut.sh — Install and configure NUT on R10
# Run after Ubuntu install + Tailscale join
# Owner: static
# Prereq: APC UPS connected via USB

set -euo pipefail

LOG="/var/log/nut-install.log"
NUT_CONFIG_DIR="/etc/nut"
SHARED_BIN="/srv/shared/bin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG"; }

log "=== NUT INSTALLATION ==="

# 1. Install NUT
log "Installing NUT packages..."
sudo apt install -y nut nut-server nut-client

# 2. Generate a random password for NUT
NUT_PASS=$(openssl rand -base64 16 | tr -d '=+/')
log "Generated NUT password (stored in $LOG only for reference)"

# 3. Copy config files
log "Copying NUT config files..."
sudo cp "$SCRIPT_DIR/nut.conf" "$NUT_CONFIG_DIR/"
sudo cp "$SCRIPT_DIR/ups.conf" "$NUT_CONFIG_DIR/"
sudo cp "$SCRIPT_DIR/upsd.conf" "$NUT_CONFIG_DIR/"

# Replace placeholder passwords with generated one
sudo sed "s/CHANGEME_GENERATE_RANDOM/$NUT_PASS/g" "$SCRIPT_DIR/upsd.users" | sudo tee "$NUT_CONFIG_DIR/upsd.users" > /dev/null
sudo sed "s/CHANGEME_GENERATE_RANDOM/$NUT_PASS/g" "$SCRIPT_DIR/upsmon.conf" | sudo tee "$NUT_CONFIG_DIR/upsmon.conf" > /dev/null

# 4. Set correct ownership and permissions
sudo chown root:nut "$NUT_CONFIG_DIR"/*.conf "$NUT_CONFIG_DIR"/upsd.users
sudo chmod 640 "$NUT_CONFIG_DIR"/*.conf "$NUT_CONFIG_DIR"/upsd.users

# 5. Create shared bin directory and copy shutdown scripts
log "Installing shutdown scripts..."
sudo mkdir -p "$SHARED_BIN"
sudo cp "$SCRIPT_DIR/cluster-shutdown.sh" "$SHARED_BIN/"
sudo cp "$SCRIPT_DIR/ups-notify.sh" "$SHARED_BIN/"
sudo chmod 755 "$SHARED_BIN/cluster-shutdown.sh"
sudo chmod 755 "$SHARED_BIN/ups-notify.sh"

# 6. Enable and start NUT services
log "Enabling NUT services..."
sudo systemctl enable nut-server nut-monitor
sudo systemctl restart nut-server nut-monitor

# 7. Verify UPS is detected
log "Checking UPS detection..."
sleep 3
if upsc apc600 > /dev/null 2>&1; then
    log "UPS detected successfully:"
    upsc apc600 2>/dev/null | grep -E "(battery|ups\.(status|load))" | tee -a "$LOG"
else
    log "WARNING: UPS not detected. Check USB connection and run: sudo upsdrvctl start"
    log "If the APC model isn't recognized, check: nut-scanner -U"
fi

log "=== NUT INSTALLATION COMPLETE ==="
echo ""
echo "NUT password: $NUT_PASS"
echo "Save this password — it's needed if you ever reconfigure NUT."
echo ""
echo "Next steps:"
echo "  1. Verify UPS status: upsc apc600"
echo "  2. Copy agent-shutdown-all.sh to Mac Mini:"
echo "     scp $SCRIPT_DIR/agent-shutdown-all.sh nwl-admin@nwl-mini:/usr/local/bin/"
echo "     ssh nwl-admin@nwl-mini 'chmod 755 /usr/local/bin/agent-shutdown-all.sh'"
echo "  3. Copy ups-notify.sh to Mac Mini:"
echo "     scp $SHARED_BIN/ups-notify.sh nwl-admin@nwl-mini:/usr/local/bin/"
echo "  4. Test the shutdown chain (dry run):"
echo "     sudo bash -c 'NOTIFYTYPE=ONBATT /srv/shared/bin/ups-notify.sh'"
echo "  5. Set MINI_LAN IP in cluster-shutdown.sh (line 9)"
