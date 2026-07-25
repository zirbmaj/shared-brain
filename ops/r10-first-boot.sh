#!/bin/bash
# =============================================================================
# NWL-R10 First Boot Setup Script
# Run this after Ubuntu Server 24.04 LTS is installed.
# Usage: sudo bash r10-first-boot.sh
#
# This script is idempotent — safe to re-run if interrupted.
# Each section checks if work is already done before proceeding.
# =============================================================================

set -euo pipefail

LOG="/var/log/nwl-first-boot.log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "Run as root: sudo bash r10-first-boot.sh"
    exit 1
fi

log "=== NWL-R10 FIRST BOOT SETUP ==="

# ----- Step 1: System basics -----
log "Step 1: System update and hostname"

apt update && apt upgrade -y

hostnamectl set-hostname nwl-r10
if ! grep -q "nwl-r10" /etc/hosts; then
    echo "127.0.1.1 nwl-r10" >> /etc/hosts
fi

log "Step 1 complete: hostname set to nwl-r10"

# ----- Step 1a: DNS fix -----
# Jam's router (192.168.0.1) intercepts outbound DNS (port 53) and blocks
# external resolvers like 8.8.8.8. All DNS must go through the router.
# systemd-resolved has been disabled; we use a static resolv.conf.
log "Step 1a: Ensuring DNS is configured"

if ! ping -c 1 -W 2 google.com &>/dev/null; then
    log "  DNS not working, writing static resolv.conf"
    systemctl stop systemd-resolved 2>/dev/null || true
    systemctl disable systemd-resolved 2>/dev/null || true
    echo "nameserver 192.168.0.1" > /etc/resolv.conf
    log "  DNS set to router (192.168.0.1)"
else
    log "  DNS already working, skipping"
fi

log "Step 1a complete"

# ----- Step 1b: Timezone and NTP -----
log "Step 1b: Configuring timezone and NTP"

timedatectl set-timezone America/Chicago

mkdir -p /etc/systemd/timesyncd.conf.d
cat > /etc/systemd/timesyncd.conf.d/nwl.conf << 'TIMECFG'
[Time]
NTP=ntp.ubuntu.com
FallbackNTP=time.nist.gov time.google.com pool.ntp.org
PollIntervalMinSec=64
PollIntervalMaxSec=2048
TIMECFG

systemctl enable systemd-timesyncd
systemctl restart systemd-timesyncd

log "Step 1b complete: timezone CST, NTP enabled"

# ----- Step 2: Essential packages -----
log "Step 2: Installing essential packages"

apt install -y \
    curl \
    git \
    htop \
    tmux \
    unzip \
    jq \
    python3-pip \
    python3-venv \
    ffmpeg \
    sox \
    nut \
    nut-client \
    nut-server

log "Step 2 complete: essential packages installed"

# ----- Step 3: Python audio/science stack (hum's tools) -----
log "Step 3: Installing Python audio/science stack"

python3 -m venv /srv/shared/venv
/srv/shared/venv/bin/pip install \
    librosa \
    scipy \
    numpy \
    matplotlib

log "Step 3 complete: Python stack installed in /srv/shared/venv"

# ----- Step 4: Tenant users -----
log "Step 4: Creating tenant users"

# NWL service account
if ! id "nwl-svc" &>/dev/null; then
    useradd -r -m -d /srv/nwl -s /bin/bash nwl-svc
    log "Created nwl-svc"
fi

# Meridian service account (near-admin, not throttled)
if ! id "meridian-svc" &>/dev/null; then
    useradd -r -m -d /srv/meridian -s /bin/bash meridian-svc
    log "Created meridian-svc"
fi

# Chowder service account (standard, restricted)
if ! id "chowder-svc" &>/dev/null; then
    useradd -r -m -d /srv/chowder -s /usr/sbin/nologin chowder-svc
    log "Created chowder-svc"
fi

# Shared read-only group
if ! getent group shared-ro &>/dev/null; then
    groupadd shared-ro
    usermod -aG shared-ro nwl-svc
    usermod -aG shared-ro meridian-svc
    usermod -aG shared-ro chowder-svc
fi

# Directory structure
mkdir -p /srv/nwl /srv/meridian /srv/chowder /srv/shared/bin /srv/shared/models
chmod 700 /srv/nwl /srv/meridian /srv/chowder
chown nwl-svc:nwl-svc /srv/nwl
chown meridian-svc:meridian-svc /srv/meridian
chown chowder-svc:chowder-svc /srv/chowder
chown root:shared-ro /srv/shared
chmod 750 /srv/shared

# Audio workspace for hum
mkdir -p /srv/nwl/audio/{incoming,processed,spectrograms}
chown -R nwl-svc:nwl-svc /srv/nwl/audio

# Shared-brain directory (syncthing will populate this)
mkdir -p /srv/nwl/shared-brain
chown nwl-svc:nwl-svc /srv/nwl/shared-brain

log "Step 4 complete: tenant users and directories created"

# ----- Step 5: Docker -----
log "Step 5: Installing Docker"

if ! command -v docker &>/dev/null; then
    apt install -y docker.io docker-compose-v2
    systemctl enable docker
    systemctl start docker
    usermod -aG docker nwl-svc
    usermod -aG docker meridian-svc
    log "Docker installed"
else
    log "Docker already installed, skipping"
fi

log "Step 5 complete"

# ----- Step 6: Tailscale -----
log "Step 6: Installing Tailscale"

if ! command -v tailscale &>/dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
    log "Tailscale installed"
    echo ""
    echo "============================================"
    echo "  MANUAL STEP: Run 'sudo tailscale up'"
    echo "  Or use an auth key:"
    echo "  sudo tailscale up --authkey=<key>"
    echo "============================================"
    echo ""
else
    log "Tailscale already installed"
fi

log "Step 6 complete"

# ----- Step 7: PostgreSQL + pgvector -----
log "Step 7: Installing PostgreSQL + pgvector"

if ! command -v psql &>/dev/null; then
    apt install -y postgresql postgresql-16-pgvector
    systemctl enable postgresql
    systemctl start postgresql

    # Configure to listen on tailscale interface
    PG_CONF=$(find /etc/postgresql -name postgresql.conf | head -1)
    if [ -n "$PG_CONF" ]; then
        sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost,nwl-r10'/" "$PG_CONF"
    fi

    # Allow connections from tailscale subnet
    PG_HBA=$(find /etc/postgresql -name pg_hba.conf | head -1)
    if [ -n "$PG_HBA" ] && ! grep -q "100.64.0.0/10" "$PG_HBA"; then
        echo "# Tailscale mesh connections" >> "$PG_HBA"
        echo "host    all    all    100.64.0.0/10    scram-sha-256" >> "$PG_HBA"
    fi

    systemctl restart postgresql

    # Create tenant database users
    sudo -u postgres psql -c "CREATE USER nwl_app WITH PASSWORD 'CHANGE_ME_nwl';" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE USER meridian_app WITH PASSWORD 'CHANGE_ME_meridian';" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE DATABASE nwl OWNER nwl_app;" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE DATABASE meridian OWNER meridian_app;" 2>/dev/null || true

    # Enable pgvector
    sudo -u postgres psql -d nwl -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>/dev/null || true
    sudo -u postgres psql -d meridian -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>/dev/null || true

    log "PostgreSQL + pgvector installed and configured"
    echo ""
    echo "============================================"
    echo "  IMPORTANT: Change the default passwords!"
    echo "  sudo -u postgres psql"
    echo "  ALTER USER nwl_app WITH PASSWORD 'new_password';"
    echo "  ALTER USER meridian_app WITH PASSWORD 'new_password';"
    echo "============================================"
    echo ""
else
    log "PostgreSQL already installed, skipping"
fi

log "Step 7 complete"

# ----- Step 8: Ollama -----
log "Step 8: Installing Ollama"

if ! command -v ollama &>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh

    # Configure to listen on all interfaces (mesh-accessible)
    mkdir -p /etc/systemd/system/ollama.service.d
    cat > /etc/systemd/system/ollama.service.d/override.conf << 'OVERRIDE'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
OVERRIDE

    systemctl daemon-reload
    systemctl enable ollama
    systemctl restart ollama

    log "Ollama installed. Pull a model with: ollama pull mistral:7b"
else
    log "Ollama already installed, skipping"
fi

log "Step 8 complete"

# ----- Step 9: Syncthing -----
log "Step 9: Installing Syncthing"

if ! command -v syncthing &>/dev/null; then
    # Add official Syncthing repo for latest version
    curl -fsSL https://syncthing.net/release-key.gpg | gpg --dearmor -o /usr/share/keyrings/syncthing-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" > /etc/apt/sources.list.d/syncthing.list
    apt update
    apt install -y syncthing

    # Enable as nwl-svc user service
    systemctl enable syncthing@nwl-svc
    systemctl start syncthing@nwl-svc

    # Syncthing tuning (per near's conflict research)
    # Bump inotify limit for large shared-brain directories
    echo "fs.inotify.max_user_watches=65536" > /etc/sysctl.d/90-syncthing.conf
    sysctl -p /etc/sysctl.d/90-syncthing.conf

    log "Syncthing installed and running as nwl-svc"
    echo ""
    echo "============================================"
    echo "  Syncthing Web UI: http://localhost:8384"
    echo "  (only accessible locally on R10)"
    echo "  Pair with Mini to sync shared-brain"
    echo "  Post-pair: set maxConflicts=3,"
    echo "  fsWatcherDelayS=1, trashcan versioning 7d"
    echo "============================================"
    echo ""
else
    log "Syncthing already installed, skipping"
fi

log "Step 9 complete"

# ----- Step 10: UFW Firewall -----
log "Step 10: Configuring UFW firewall"

# Firewall setup requires Tailscale to be running first.
# If Tailscale isn't up yet, skip and run r10-firewall-setup.sh manually after.
FIREWALL_SCRIPT="/srv/nwl/shared-brain/ops/r10-firewall-setup.sh"
if ! ufw status | grep -q "Status: active"; then
    if tailscale status &>/dev/null && [ -f "$FIREWALL_SCRIPT" ]; then
        bash "$FIREWALL_SCRIPT"
        log "UFW configured via r10-firewall-setup.sh"
    else
        # Minimal firewall: SSH only until Tailscale is up
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow ssh
        echo "y" | ufw enable
        log "Minimal UFW enabled (SSH only). Run r10-firewall-setup.sh after Tailscale is up"
    fi
else
    log "UFW already active, skipping"
fi

log "Step 10 complete"

# ----- Step 11: SSH key for UPS shutdown -----
log "Step 11: Generating UPS shutdown SSH key"

UPS_KEY="/root/.ssh/id_nwl_ups"
if [ ! -f "$UPS_KEY" ]; then
    mkdir -p /root/.ssh
    ssh-keygen -t ed25519 -f "$UPS_KEY" -N "" -C "nwl-ups-shutdown"
    log "UPS SSH key generated at $UPS_KEY"
    echo ""
    echo "============================================"
    echo "  MANUAL STEP: Copy this public key to the"
    echo "  Mac Mini's authorized_keys:"
    echo ""
    cat "${UPS_KEY}.pub"
    echo ""
    echo "  On Mini: echo '<key>' >> ~/.ssh/authorized_keys"
    echo "============================================"
    echo ""
else
    log "UPS SSH key already exists, skipping"
fi

log "Step 11 complete"

# ----- Step 12: Generate secrets -----
log "Step 12: Generating tenant secrets"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SECRET_SCRIPT="$SCRIPT_DIR/r10-secret-setup.sh"
if [ -f "$SECRET_SCRIPT" ]; then
    bash "$SECRET_SCRIPT"
    log "Step 12 complete: secrets generated"
else
    log "Step 12 skipped: r10-secret-setup.sh not found at $SECRET_SCRIPT"
fi

# ----- Step 13: Install systemd units -----
log "Step 13: Installing NWL systemd service units"

SYSTEMD_DIR="$SCRIPT_DIR/r10-systemd"
INSTALL_SCRIPT="$SYSTEMD_DIR/install-units.sh"
if [ -f "$INSTALL_SCRIPT" ]; then
    bash "$INSTALL_SCRIPT"
    log "Step 13 complete: systemd units installed"
else
    log "Step 13 skipped: install-units.sh not found at $INSTALL_SCRIPT"
fi

# ----- Summary -----
log "=== FIRST BOOT SETUP COMPLETE ==="

echo ""
echo "============================================"
echo "  NWL-R10 FIRST BOOT COMPLETE"
echo "============================================"
echo ""
echo "  Hostname:    nwl-r10"
echo "  Timezone:    America/Chicago (CST)"
echo "  NTP:         systemd-timesyncd (active)"
echo "  Tenants:     nwl-svc, meridian-svc, chowder-svc"
echo "  PostgreSQL:  running (port 5432)"
echo "  Ollama:      running (port 11434)"
echo "  Syncthing:   running (port 22000)"
echo "  UFW:         active"
echo "  Secrets:     /srv/{nwl,meridian,chowder}/.env"
echo ""
echo "  MANUAL STEPS REMAINING:"
echo "  1. Run 'sudo tailscale up' to join the mesh"
echo "  2. Copy UPS SSH key to Mac Mini"
echo "  3. Pair Syncthing with Mac Mini"
echo "  4. Pull an Ollama model: ollama pull mistral:7b"
echo "  5. Configure NUT (/etc/nut/) per UPS doc"
echo "  6. Plug in the Audient EVO 4 via USB"
echo "  7. Run boot-test.sh to verify dependency chain"
echo "  8. Run r10-time-sync.sh --verify-only for clock check"
echo ""
echo "  Logs: $LOG"
echo "============================================"
