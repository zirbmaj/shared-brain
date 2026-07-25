#!/bin/bash
# =============================================================================
# NWL-R10 Data Retention Cron
# Install: sudo cp r10-retention-cron.sh /etc/cron.daily/nwl-retention
#          sudo chmod +x /etc/cron.daily/nwl-retention
#
# Cleans up large data directories that logrotate doesn't handle:
# - Backup dumps older than 7 days
# - Screenshots older than 30 days
# - Processed spectrograms older than 30 days
# - Ollama tmp/cache artifacts older than 7 days
# =============================================================================

set -euo pipefail

LOG="/var/log/nwl-retention.log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }

log "=== retention sweep start ==="

# Backup dumps (pg_dump output) — keep 7 days
PRUNED=$(find /var/backups/nwl -name "*.dump" -mtime +7 -delete -print 2>/dev/null | wc -l)
PRUNED_SHA=$(find /var/backups/nwl -name "*.sha256" -mtime +7 -delete -print 2>/dev/null | wc -l)
log "backups: pruned $PRUNED dumps, $PRUNED_SHA checksums"

# Screenshots (browser service output) — keep 30 days
if [ -d /srv/nwl/screenshots ]; then
    PRUNED=$(find /srv/nwl/screenshots -name "*.png" -mtime +30 -delete -print 2>/dev/null | wc -l)
    log "screenshots: pruned $PRUNED files"
fi

# Spectrograms (hum's audio analysis output) — keep 30 days
if [ -d /srv/nwl/audio/spectrograms ]; then
    PRUNED=$(find /srv/nwl/audio/spectrograms -type f -mtime +30 -delete -print 2>/dev/null | wc -l)
    log "spectrograms: pruned $PRUNED files"
fi

# Processed audio (intermediate files) — keep 14 days
if [ -d /srv/nwl/audio/processed ]; then
    PRUNED=$(find /srv/nwl/audio/processed -type f -mtime +14 -delete -print 2>/dev/null | wc -l)
    log "processed audio: pruned $PRUNED files"
fi

# Syncthing conflict files — keep 7 days, then alert if any existed
if [ -d /srv/nwl/shared-brain ]; then
    CONFLICTS=$(find /srv/nwl/shared-brain -name "*.sync-conflict-*" -mtime +7 2>/dev/null)
    if [ -n "$CONFLICTS" ]; then
        COUNT=$(echo "$CONFLICTS" | wc -l)
        log "WARNING: $COUNT stale syncthing conflicts older than 7 days. listing:"
        echo "$CONFLICTS" >> "$LOG"
        echo "$CONFLICTS" | xargs rm -f
        log "stale conflicts removed"
    fi
fi

# Disk usage summary
log "disk usage after sweep:"
for dir in /srv/nwl /srv/meridian /srv/chowder /srv/nwl/backups; do
    if [ -d "$dir" ]; then
        USAGE=$(du -sh "$dir" 2>/dev/null | cut -f1)
        log "  $dir: $USAGE"
    fi
done

log "=== retention sweep complete ==="
