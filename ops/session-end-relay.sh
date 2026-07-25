#!/bin/bash
# SessionEnd hook for Relay
# Logs session end, warns if no retro written

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_LOG="$HOME/shared-brain/ops/session-log.txt"
RETROS_DIR="$HOME/shared-brain/retros"

# Log session end
echo "[$TIMESTAMP] relay session ended" >> "$SESSION_LOG"

# Check if a retro was written today
TODAY=$(date +"%Y-%m-%d")
RETRO_COUNT=$(find "$RETROS_DIR" -name "*relay*" -newer "$RETROS_DIR" -mtime -1 2>/dev/null | wc -l)

if [ "$RETRO_COUNT" -eq 0 ]; then
  echo '{"systemMessage": "WARNING: No relay retro written this session. Write one before closing."}'
else
  echo '{"systemMessage": "Session ended. Retro found."}'
fi
