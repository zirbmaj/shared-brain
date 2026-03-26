#!/usr/bin/env bash
# discord-urgent-hook.sh — PostToolUse hook for surfacing urgent Discord messages
# Reads the queue file written by discord-poller.sh and outputs urgent messages
# between tool calls. Silent when no messages (no context waste).
#
# Install as PostToolUse hook in .claude/settings.json:
# "PostToolUse": [{"hooks": [{"type": "command", "command": "bash ~/shared-brain/ops/discord-urgent-hook.sh <agent-name>"}]}]

set -euo pipefail

AGENT_NAME="${1:-${AGENT_NAME:-}}"
QUEUE_DIR="/tmp/agent-monitor"
QUEUE_FILE="${QUEUE_DIR}/${AGENT_NAME}-discord-queue.json"

# Silent exit if no agent name
if [[ -z "$AGENT_NAME" ]]; then
  exit 0
fi

# Silent exit if no queue file
if [[ ! -f "$QUEUE_FILE" ]]; then
  exit 0
fi

# Silent exit if queue is empty
MSG_COUNT=$(python3 -c "
import json, sys
try:
    with open('$QUEUE_FILE') as f:
        msgs = json.load(f)
    print(len(msgs))
except:
    print(0)
" 2>/dev/null || echo "0")

if [[ "$MSG_COUNT" == "0" ]]; then
  exit 0
fi

# Format and output urgent messages
python3 -c "
import json, os

queue_file = '$QUEUE_FILE'
agent_name = '$AGENT_NAME'

with open(queue_file) as f:
    messages = json.load(f)

if not messages:
    exit(0)

# Channel name mapping
channel_names = {
    '1485741478331420734': 'jams-office',
    '1485512553273753600': 'dev',
    '1485778574815527056': 'jam-dm',
}

print(f'⚡ URGENT: {len(messages)} message(s) from human while you were working:')
print()

for msg in messages:
    ch = channel_names.get(msg.get('channel_id', ''), 'unknown')
    author = msg.get('author', 'unknown')
    content = msg.get('content', '')
    ts = msg.get('timestamp', '')[:19]
    print(f'  [{ch}] {author} ({ts}): {content}')

print()
print('↑ Respond if urgent, or continue current task.')

# Clear the queue after surfacing
os.remove(queue_file)
" 2>/dev/null
