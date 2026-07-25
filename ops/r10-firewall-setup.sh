#!/bin/bash
# r10-firewall-setup.sh — Run on NWL-R10 after Ubuntu install + Tailscale join
# Owner: static
# Prereq: tailscale must be up and running before this script

set -euo pipefail

LOG="/var/log/r10-firewall-setup.log"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG"; }

# Verify tailscale is running
if ! tailscale status > /dev/null 2>&1; then
    echo "ERROR: Tailscale is not running. Install and join the network first."
    echo "  curl -fsSL https://tailscale.com/install.sh | sh"
    echo "  sudo tailscale up --authkey=<key>"
    exit 1
fi

log "=== R10 FIREWALL SETUP ==="

# --- UFW Configuration ---
log "Configuring UFW..."

# Reset to clean state (non-interactive)
sudo ufw --force reset

# Default policies: deny inbound, allow outbound
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow all traffic on the Tailscale interface (mesh peers only)
sudo ufw allow in on tailscale0 comment "Tailscale mesh traffic"

# Allow SSH on all interfaces for initial setup (can restrict later)
# Remove this rule once Tailscale SSH is confirmed working
sudo ufw allow 22/tcp comment "SSH - remove after Tailscale SSH verified"

# Enable UFW
sudo ufw --force enable

log "UFW enabled. Rules:"
sudo ufw status verbose >> "$LOG"

# --- Verify Tailscale interface exists ---
if ip link show tailscale0 > /dev/null 2>&1; then
    log "tailscale0 interface confirmed"
else
    log "WARNING: tailscale0 interface not found. UFW rules may not take effect until Tailscale creates it"
fi

# --- Service port summary (for reference, enforced by UFW + Tailscale ACLs) ---
log "Service ports (mesh-only access via tailscale0):"
log "  5432  — PostgreSQL"
log "  11434 — Ollama"
log "  3493  — NUT (upsd)"
log "  3850  — Node health API"
log "  3860  — Chromium service"
log "  8123  — Home Assistant"
log "  22000 — Syncthing"

log "=== FIREWALL SETUP COMPLETE ==="
echo ""
echo "Next steps:"
echo "  1. Verify from nwl-mini: ssh nwl-admin@nwl-r10"
echo "  2. Verify services are reachable over Tailscale"
echo "  3. Once Tailscale SSH works, remove the direct SSH rule:"
echo "     sudo ufw delete allow 22/tcp"
