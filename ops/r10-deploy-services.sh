#!/bin/bash
# =============================================================================
# Deploy NWL service files to R10
# Copies Python services and scripts to their runtime locations.
# Run after first-boot.sh and syncthing pairing.
#
# Usage: sudo bash r10-deploy-services.sh
# =============================================================================

set -euo pipefail

SHARED_BRAIN="/srv/nwl/shared-brain"
log() { echo "[$(date '+%H:%M:%S')] $1"; }

if [ "$EUID" -ne 0 ]; then
    echo "Run as root: sudo bash r10-deploy-services.sh"
    exit 1
fi

# Verify shared-brain is synced
if [ ! -d "$SHARED_BRAIN/ops" ]; then
    echo "ERROR: $SHARED_BRAIN/ops not found. Pair syncthing first."
    exit 1
fi

log "Deploying NWL services..."

# --- Health server ---
mkdir -p /srv/shared/bin
cp "$SHARED_BRAIN/ops/node-health/health-server.py" /srv/shared/bin/
chmod 755 /srv/shared/bin/health-server.py
log "  deployed health-server.py → /srv/shared/bin/"

# --- RAG services ---
mkdir -p /srv/nwl/rag
cp "$SHARED_BRAIN/ops/rag/indexer.py" /srv/nwl/rag/
cp "$SHARED_BRAIN/ops/rag/search_api.py" /srv/nwl/rag/
chown -R nwl-svc:nwl-svc /srv/nwl/rag
log "  deployed indexer.py + search_api.py → /srv/nwl/rag/"

# --- RAG venv (if not created by install-units.sh) ---
if [ ! -d /srv/nwl/rag/venv ]; then
    log "  creating RAG venv..."
    python3 -m venv /srv/nwl/rag/venv
    /srv/nwl/rag/venv/bin/pip install -q \
        fastapi uvicorn psycopg2-binary httpx pyyaml watchdog
    chown -R nwl-svc:nwl-svc /srv/nwl/rag/venv
    log "  RAG venv created with dependencies"
fi

# --- NUT scripts ---
if [ -d "$SHARED_BRAIN/ops/r10-nut-config" ]; then
    cp "$SHARED_BRAIN/ops/r10-nut-config/cluster-shutdown.sh" /srv/shared/bin/
    cp "$SHARED_BRAIN/ops/r10-nut-config/agent-shutdown-all.sh" /srv/shared/bin/
    cp "$SHARED_BRAIN/ops/r10-nut-config/ups-notify.sh" /srv/shared/bin/
    chmod 755 /srv/shared/bin/cluster-shutdown.sh /srv/shared/bin/agent-shutdown-all.sh /srv/shared/bin/ups-notify.sh
    log "  deployed NUT scripts → /srv/shared/bin/"
fi

# --- Conflict detector (from near's research) ---
if [ -f "$SHARED_BRAIN/ops/r10-systemd/r10-time-sync.sh" ]; then
    cp "$SHARED_BRAIN/ops/r10-systemd/r10-time-sync.sh" /srv/shared/bin/
    chmod 755 /srv/shared/bin/r10-time-sync.sh
    log "  deployed r10-time-sync.sh → /srv/shared/bin/"
fi

# --- Systemd units ---
log "  installing systemd units..."
bash "$SHARED_BRAIN/ops/r10-systemd/install-units.sh"

log "Done. All services deployed."
echo ""
echo "Next: start services with 'systemctl start nwl-node-health nwl-rag-indexer nwl-rag-search'"
