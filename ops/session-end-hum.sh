#!/bin/bash
# Hum SessionEnd hook — runs when session closes
# Logs session end timestamp and checks for retro

set -euo pipefail

AGENT="hum"
WORKSPACE="$HOME/teams/nwl/${AGENT}-workspace"
RETRO_DIR="$HOME/shared-brain/retros"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)

# Log session end
echo "[$TIMESTAMP] $AGENT session ended" >> "$HOME/shared-brain/ops/session-log.txt"

# Check if retro was written this session (file modified today)
LATEST_RETRO=$(find "$RETRO_DIR" -name "*${AGENT}*" -newer "$RETRO_DIR" -mtime -0 2>/dev/null | head -1)
if [ -z "$LATEST_RETRO" ]; then
    echo "WARNING: no retro written this session"
fi

exit 0
