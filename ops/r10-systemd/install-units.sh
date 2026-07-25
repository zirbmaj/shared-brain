#!/bin/bash
# =============================================================================
# Install NWL systemd units on R10
# Usage: sudo bash install-units.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEMD_DIR="/etc/systemd/system"

log() { echo "[$(date '+%H:%M:%S')] $1"; }

if [ "$EUID" -ne 0 ]; then
    echo "Run as root: sudo bash install-units.sh"
    exit 1
fi

log "Installing NWL systemd units..."

# --- Custom service units ---
for unit in "$SCRIPT_DIR"/nwl-*.service; do
    name=$(basename "$unit")
    cp "$unit" "$SYSTEMD_DIR/$name"
    log "  installed $name"
done

# --- Override directories ---
mkdir -p "$SYSTEMD_DIR/postgresql.service.d"
mkdir -p "$SYSTEMD_DIR/ollama.service.d"
mkdir -p "$SYSTEMD_DIR/syncthing@.service.d"

cp "$SCRIPT_DIR/overrides/postgresql.conf" "$SYSTEMD_DIR/postgresql.service.d/nwl-dependency.conf"
cp "$SCRIPT_DIR/overrides/ollama.conf" "$SYSTEMD_DIR/ollama.service.d/nwl-dependency.conf"
cp "$SCRIPT_DIR/overrides/syncthing.conf" "$SYSTEMD_DIR/syncthing@.service.d/nwl-dependency.conf"

log "  installed overrides for postgresql, ollama, syncthing"

# --- Create required directories ---
mkdir -p /var/log/nwl /var/log/meridian /var/log/chowder
chown nwl-svc:nwl-svc /var/log/nwl
chown meridian-svc:meridian-svc /var/log/meridian 2>/dev/null || true
chown chowder-svc:chowder-svc /var/log/chowder 2>/dev/null || true

log "  created log directories"

# --- Create RAG venv if it doesn't exist ---
if [ ! -d /srv/nwl/rag/venv ]; then
    log "  creating RAG Python venv..."
    python3 -m venv /srv/nwl/rag/venv
    /srv/nwl/rag/venv/bin/pip install -q fastapi uvicorn psycopg2-binary httpx
    chown -R nwl-svc:nwl-svc /srv/nwl/rag/venv
fi

# --- Reload and enable ---
systemctl daemon-reload
log "  daemon-reload complete"

systemctl enable nwl-node-health nwl-rag-indexer nwl-rag-search nwl-homeassistant nwl-browser
log "  enabled all NWL services"

log "Done. Run boot-test.sh to verify the dependency chain."
