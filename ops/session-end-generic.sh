#!/bin/bash
# Generic SessionEnd hook for any agent
# Usage: bash session-end-generic.sh <agent-name>

AGENT_NAME="${1:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_LOG="$HOME/shared-brain/ops/session-log.txt"
RETROS_DIR="$HOME/shared-brain/retros"

# Log session end
echo "[$TIMESTAMP] $AGENT_NAME session ended" >> "$SESSION_LOG"

# Check if a retro was written today
RETRO_COUNT=$(find "$RETROS_DIR" -name "*${AGENT_NAME}*" -newer "$RETROS_DIR" -mtime -1 2>/dev/null | wc -l)

if [ "$RETRO_COUNT" -eq 0 ]; then
  echo "{\"systemMessage\": \"WARNING: No ${AGENT_NAME} retro written this session. Write one before closing.\"}"
else
  echo "{\"systemMessage\": \"Session ended. Retro found.\"}"
fi
