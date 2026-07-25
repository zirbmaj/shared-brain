#!/bin/bash
# Static — SessionEnd hook
# Logs session end, warns if no retro written, saves last test results

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE=$(date '+%Y-%m-%d')
LOG_FILE="$HOME/shared-brain/ops/session-log.txt"
RETRO_DIR="$HOME/shared-brain/retros"

# Log session end
echo "[$TIMESTAMP] static session ended" >> "$LOG_FILE"

# Check if retro was written today
if ! ls "$RETRO_DIR"/*"$DATE"*static* 2>/dev/null | grep -q .; then
  echo "[$TIMESTAMP] WARNING: no static retro found for $DATE" >> "$LOG_FILE"
fi

# Save last test results if they exist
if [ -f /tmp/test-results/latest.json ]; then
  cp /tmp/test-results/latest.json "$HOME/shared-brain/nwl/test-results-latest.json" 2>/dev/null
fi

echo "static session end logged"
