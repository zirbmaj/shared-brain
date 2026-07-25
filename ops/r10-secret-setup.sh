#!/bin/bash
# =============================================================================
# R10 Secret Storage Setup
# Generates secure passwords, creates per-tenant .env files,
# sets permissions, and updates PostgreSQL credentials.
#
# Usage: sudo bash r10-secret-setup.sh [--rotate]
#   --rotate: regenerate all passwords (quarterly rotation)
#
# Replaces the CHANGE_ME passwords from first-boot.sh with
# cryptographically random 32-char passwords.
# =============================================================================

set -euo pipefail

LOG="/var/log/nwl-secret-setup.log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

if [ "$EUID" -ne 0 ]; then
    echo "Run as root: sudo bash r10-secret-setup.sh"
    exit 1
fi

ROTATE=false
if [ "${1:-}" = "--rotate" ]; then
    ROTATE=true
    log "=== SECRET ROTATION ==="
else
    log "=== SECRET SETUP ==="
fi

# --- Generate secure random password ---
gen_pass() {
    # 32-char alphanumeric, no special chars (safe for connection strings)
    openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32
}

# --- Check if .env already exists (skip unless rotating) ---
check_existing() {
    local path="$1"
    if [ -f "$path" ] && [ "$ROTATE" = false ]; then
        log "  $path already exists — skipping (use --rotate to regenerate)"
        return 1
    fi
    return 0
}

# --- NWL tenant ---
NWL_ENV="/srv/nwl/.env"
if check_existing "$NWL_ENV"; then
    NWL_PG_PASS=$(gen_pass)

    cat > "$NWL_ENV" << EOF
# NWL tenant secrets — generated $(date '+%Y-%m-%d %H:%M:%S')
# Rotation: quarterly (next: $(date -d '+3 months' '+%Y-%m-%d' 2>/dev/null || date -v+3m '+%Y-%m-%d'))
# DO NOT commit this file. DO NOT copy to shared-brain.

# PostgreSQL
PGHOST=localhost
PGPORT=5432
PGDATABASE=nwl
PGUSER=nwl_app
PGPASSWORD=${NWL_PG_PASS}

# Ollama (no auth, mesh-only access)
OLLAMA_HOST=http://localhost:11434

# Tenant ID
TENANT_ID=nwl

# RAG
RAG_WATCH_DIR=/srv/nwl/shared-brain
RAG_EMBEDDING_MODEL=mistral:7b
EOF

    chmod 600 "$NWL_ENV"
    chown nwl-svc:nwl-svc "$NWL_ENV"
    log "  created $NWL_ENV (mode 600, owner nwl-svc)"

    # Update PostgreSQL password
    sudo -u postgres psql -c "ALTER USER nwl_app WITH PASSWORD '${NWL_PG_PASS}';" 2>/dev/null && \
        log "  updated PostgreSQL password for nwl_app" || \
        log "  WARNING: could not update PostgreSQL password for nwl_app (DB may not be running)"
fi

# --- Meridian tenant ---
MERIDIAN_ENV="/srv/meridian/.env"
if check_existing "$MERIDIAN_ENV"; then
    MERIDIAN_PG_PASS=$(gen_pass)

    cat > "$MERIDIAN_ENV" << EOF
# Meridian tenant secrets — generated $(date '+%Y-%m-%d %H:%M:%S')
# Rotation: quarterly (next: $(date -d '+3 months' '+%Y-%m-%d' 2>/dev/null || date -v+3m '+%Y-%m-%d'))
# DO NOT commit this file. DO NOT copy to shared-brain.

# PostgreSQL
PGHOST=localhost
PGPORT=5432
PGDATABASE=meridian
PGUSER=meridian_app
PGPASSWORD=${MERIDIAN_PG_PASS}

# Ollama (shared, no auth)
OLLAMA_HOST=http://localhost:11434

# Tenant ID
TENANT_ID=meridian
EOF

    chmod 600 "$MERIDIAN_ENV"
    chown meridian-svc:meridian-svc "$MERIDIAN_ENV"
    log "  created $MERIDIAN_ENV (mode 600, owner meridian-svc)"

    sudo -u postgres psql -c "ALTER USER meridian_app WITH PASSWORD '${MERIDIAN_PG_PASS}';" 2>/dev/null && \
        log "  updated PostgreSQL password for meridian_app" || \
        log "  WARNING: could not update PostgreSQL password for meridian_app"
fi

# --- Chowder tenant ---
CHOWDER_ENV="/srv/chowder/.env"
if check_existing "$CHOWDER_ENV"; then
    CHOWDER_PG_PASS=$(gen_pass)

    cat > "$CHOWDER_ENV" << EOF
# Chowder tenant secrets — generated $(date '+%Y-%m-%d %H:%M:%S')
# Rotation: quarterly (next: $(date -d '+3 months' '+%Y-%m-%d' 2>/dev/null || date -v+3m '+%Y-%m-%d'))
# DO NOT commit this file. DO NOT copy to shared-brain.

# PostgreSQL
PGHOST=localhost
PGPORT=5432
PGDATABASE=chowder
PGUSER=chowder_app
PGPASSWORD=${CHOWDER_PG_PASS}

# Tenant ID
TENANT_ID=chowder
EOF

    chmod 600 "$CHOWDER_ENV"
    chown chowder-svc:chowder-svc "$CHOWDER_ENV"
    log "  created $CHOWDER_ENV (mode 600, owner chowder-svc)"

    # Create chowder DB user if it doesn't exist
    sudo -u postgres psql -c "CREATE USER chowder_app WITH PASSWORD '${CHOWDER_PG_PASS}';" 2>/dev/null || \
        sudo -u postgres psql -c "ALTER USER chowder_app WITH PASSWORD '${CHOWDER_PG_PASS}';" 2>/dev/null && \
        log "  updated PostgreSQL password for chowder_app" || \
        log "  WARNING: could not update PostgreSQL password for chowder_app"
fi

# --- NUT secrets (root only) ---
NUT_ENV="/etc/nut/.env"
if check_existing "$NUT_ENV"; then
    NUT_ADMIN_PASS=$(gen_pass)
    NUT_MONITOR_PASS=$(gen_pass)

    cat > "$NUT_ENV" << EOF
# NUT UPS secrets — generated $(date '+%Y-%m-%d %H:%M:%S')
NUT_ADMIN_PASSWORD=${NUT_ADMIN_PASS}
NUT_MONITOR_PASSWORD=${NUT_MONITOR_PASS}
EOF

    chmod 600 "$NUT_ENV"
    chown root:nut "$NUT_ENV"
    log "  created $NUT_ENV (mode 600, owner root:nut)"
    log "  NOTE: update /etc/nut/upsd.users with these passwords manually"
fi

# --- Verify permissions ---
echo ""
echo "=== Secret Storage Verification ==="
echo ""

for envfile in "$NWL_ENV" "$MERIDIAN_ENV" "$CHOWDER_ENV" "$NUT_ENV"; do
    if [ -f "$envfile" ]; then
        perms=$(stat -c '%a %U:%G' "$envfile" 2>/dev/null || stat -f '%Lp %Su:%Sg' "$envfile")
        echo "  $envfile → $perms"
    fi
done

# --- Verify .stignore excludes secrets ---
echo ""
echo "=== Syncthing Exclusion Check ==="
STIGNORE="/srv/nwl/shared-brain/.stignore"
if [ -f "$STIGNORE" ]; then
    if grep -q "\.env" "$STIGNORE"; then
        echo "  ✓ .env files excluded from syncthing"
    else
        echo "  ! WARNING: add '.env' to $STIGNORE"
    fi
else
    echo "  ! WARNING: no .stignore found — create one before enabling syncthing"
fi

echo ""
log "=== SECRET SETUP COMPLETE ==="
echo ""
echo "NEXT STEPS:"
echo "  1. Verify PostgreSQL connections: psql -U nwl_app -h localhost nwl"
echo "  2. Update NUT passwords in /etc/nut/upsd.users"
echo "  3. Ensure .stignore excludes .env files"
echo "  4. Schedule quarterly rotation: sudo bash r10-secret-setup.sh --rotate"
echo ""
