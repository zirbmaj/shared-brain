#!/bin/bash
# Discord message dedup failsafe
# Prevents duplicate messages by hashing channel_id + first 80 chars of content
# Exit 1 (block) if duplicate detected within WINDOW seconds
# Used as a PreToolUse hook for mcp__plugin_discord_discord__reply
#
# Input: tool call JSON on stdin (has chat_id and text fields)

set -euo pipefail

WINDOW=30
HASH_LOG="/tmp/discord-dedup-${AGENT_NAME:-unknown}.log"

# Read the tool input from stdin
INPUT=$(cat)

# Extract chat_id and first 80 chars of text
CHAT_ID=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin).get('tool_input',{}); print(d.get('chat_id',''))" 2>/dev/null || echo "")
TEXT_PREFIX=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin).get('tool_input',{}); print(d.get('text','')[:80])" 2>/dev/null || echo "")

# If we can't parse, allow the message through
if [ -z "$CHAT_ID" ] || [ -z "$TEXT_PREFIX" ]; then
    exit 0
fi

# Create hash of channel + content prefix
HASH=$(echo -n "${CHAT_ID}:${TEXT_PREFIX}" | shasum -a 256 | cut -d' ' -f1)
NOW=$(date +%s)

# Create log file if it doesn't exist
touch "$HASH_LOG"

# Clean old entries (older than WINDOW seconds)
TEMP=$(mktemp)
while IFS='|' read -r ts hash; do
    if [ -n "$ts" ] && [ $((NOW - ts)) -lt $WINDOW ]; then
        echo "${ts}|${hash}" >> "$TEMP"
    fi
done < "$HASH_LOG"
mv "$TEMP" "$HASH_LOG"

# Check for duplicate
if grep -q "|${HASH}$" "$HASH_LOG" 2>/dev/null; then
    echo "BLOCKED: duplicate message detected (same channel + content within ${WINDOW}s). skipping send."
    exit 1
fi

# Log this message hash
echo "${NOW}|${HASH}" >> "$HASH_LOG"
exit 0
