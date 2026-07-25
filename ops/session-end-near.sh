#!/bin/bash
# Near SessionEnd hook — runs when session closes
# Logs session end timestamp and checks for retro

set -euo pipefail

AGENT="near"
WORKSPACE="$HOME/teams/nwl/${AGENT}-workspace"
RETRO_DIR="$HOME/shared-brain/retros"
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)

# Log session end
echo "[$TIMESTAMP] $AGENT session ended" >> "$HOME/shared-brain/ops/session-log.txt"

# Check for uncommitted changes in workspace
if cd "$WORKSPACE" && [ -d .git ]; then
    DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$DIRTY" -gt 0 ]; then
        echo "WARNING: $DIRTY uncommitted changes in $WORKSPACE"
    fi
fi

# Check if retro was written this session
LATEST_RETRO=$(find "$RETRO_DIR" -name "*${AGENT}*" -newer "$RETRO_DIR" -mtime -0 2>/dev/null | head -1)
if [ -z "$LATEST_RETRO" ]; then
    echo "WARNING: no retro written this session"
fi

exit 0
