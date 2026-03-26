#!/usr/bin/env bash
# discord-poller.sh — Background Discord message poller for agent responsiveness
# Polls specific channels via Discord REST API, writes urgent messages to a queue file.
# The PostToolUse hook (discord-urgent-hook.sh) reads this queue between tool calls.
#
# Usage: bash discord-poller.sh <agent-name> <discord-state-dir> [channel-ids...]
# If no channel IDs provided, defaults to jam's office only (universally urgent).
# Pass additional channel IDs as args 3+ to add role-specific channels.
# Example: bash discord-poller.sh relay ~/.claude/channels/discord-relay 1485512553273753600

set -euo pipefail

# --- Config ---
AGENT_NAME="${1:-${AGENT_NAME:-}}"
DISCORD_STATE_DIR="${2:-${DISCORD_STATE_DIR:-}}"
POLL_INTERVAL="${POLL_INTERVAL:-30}"
QUEUE_DIR="/tmp/agent-monitor"

# Universal urgent channel (always monitored)
URGENT_CHANNELS=(
  "1485741478331420734"   # jam's office — always urgent for all agents
)

# Add role-specific channels from args 3+
shift 2 2>/dev/null || true
for ch in "$@"; do
  URGENT_CHANNELS+=("$ch")
done

# --- Validation ---
if [[ -z "$AGENT_NAME" || -z "$DISCORD_STATE_DIR" ]]; then
  echo "ERROR: Usage: bash discord-poller.sh <agent-name> <discord-state-dir>" >&2
  exit 1
fi

DISCORD_STATE_DIR="${DISCORD_STATE_DIR/#\~/$HOME}"
ENV_FILE="${DISCORD_STATE_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: No .env file at $ENV_FILE" >&2
  exit 1
fi

# Read bot token
BOT_TOKEN=""
while IFS='=' read -r key value; do
  if [[ "$key" == "DISCORD_BOT_TOKEN" ]]; then
    BOT_TOKEN="$value"
    break
  fi
done < "$ENV_FILE"

if [[ -z "$BOT_TOKEN" ]]; then
  echo "ERROR: DISCORD_BOT_TOKEN not found in $ENV_FILE" >&2
  exit 1
fi

# Validate token and get bot identity
BOT_INFO_FILE=$(mktemp)
curl -s -H "Authorization: Bot $BOT_TOKEN" "https://discord.com/api/v10/users/@me" > "$BOT_INFO_FILE" 2>/dev/null

BOT_ID=$(python3 -c "import json; d=json.load(open('$BOT_INFO_FILE')); print(d.get('id',''))" 2>/dev/null || echo "")
BOT_USERNAME=$(python3 -c "import json; d=json.load(open('$BOT_INFO_FILE')); print(d.get('username',''))" 2>/dev/null || echo "")
rm -f "$BOT_INFO_FILE"

if [[ -z "$BOT_USERNAME" ]]; then
  echo "ERROR: Bot token validation failed." >&2
  exit 1
fi

mkdir -p "$QUEUE_DIR"
LOG_FILE="${QUEUE_DIR}/${AGENT_NAME}-poller.log"
QUEUE_FILE="${QUEUE_DIR}/${AGENT_NAME}-discord-queue.json"
STATE_FILE="${QUEUE_DIR}/${AGENT_NAME}-poller-state.json"

echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) poller started for $AGENT_NAME (bot: $BOT_USERNAME, id: $BOT_ID)" | tee -a "$LOG_FILE"

# Initialize state file
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{}' > "$STATE_FILE"
fi

# --- Poll Loop ---
while true; do
  RESPONSE_FILE=$(mktemp)
  BATCH_FILE=$(mktemp)
  echo '[]' > "$BATCH_FILE"

  for CHANNEL_ID in "${URGENT_CHANNELS[@]}"; do
    LAST_SEEN=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    state = json.load(f)
print(state.get('$CHANNEL_ID', {}).get('last_seen', '0'))
" 2>/dev/null || echo "0")

    PARAMS="limit=10"
    if [[ "$LAST_SEEN" != "0" ]]; then
      PARAMS="${PARAMS}&after=${LAST_SEEN}"
    fi

    curl -s -H "Authorization: Bot $BOT_TOKEN" \
      "https://discord.com/api/v10/channels/${CHANNEL_ID}/messages?${PARAMS}" \
      > "$RESPONSE_FILE" 2>/dev/null

    # Process with Python using file I/O (no bash interpolation of message content)
    python3 << PYEOF
import json, sys, os

response_file = "$RESPONSE_FILE"
state_file = "$STATE_FILE"
batch_file = "$BATCH_FILE"
channel_id = "$CHANNEL_ID"
bot_id = "$BOT_ID"
last_seen = "$LAST_SEEN"

try:
    with open(response_file) as f:
        messages = json.load(f)
except:
    sys.exit(0)

if not isinstance(messages, list):
    sys.exit(0)

urgent = []
max_id = last_seen

for msg in messages:
    msg_id = msg.get('id', '0')
    author = msg.get('author', {})
    author_id = author.get('id', '')
    author_name = author.get('username', 'unknown')
    content = msg.get('content', '')
    timestamp = msg.get('timestamp', '')

    if author_id == bot_id:
        continue
    if author.get('bot', False):
        continue

    try:
        if int(msg_id) > int(max_id):
            max_id = msg_id
    except:
        pass

    urgent.append({
        'channel_id': channel_id,
        'message_id': msg_id,
        'author': author_name,
        'author_id': author_id,
        'content': content[:500],
        'timestamp': timestamp
    })

# Update state with max_id
if max_id != '0' and max_id != last_seen:
    with open(state_file) as f:
        state = json.load(f)
    state[channel_id] = {'last_seen': max_id}
    with open(state_file, 'w') as f:
        json.dump(state, f, indent=2)

# Append to batch
with open(batch_file) as f:
    existing = json.load(f)
existing.extend(urgent)
with open(batch_file, 'w') as f:
    json.dump(existing, f, indent=2)
PYEOF

  done

  # Check if we got any messages and append to queue
  python3 << PYEOF
import json, os

batch_file = "$BATCH_FILE"
queue_file = "$QUEUE_FILE"

with open(batch_file) as f:
    new_msgs = json.load(f)

if not new_msgs:
    os.remove(batch_file)
    sys.exit(0) if 'sys' in dir() else exit(0)

import sys

# Read existing queue
existing = []
if os.path.exists(queue_file):
    try:
        with open(queue_file) as f:
            existing = json.load(f)
    except:
        existing = []

# Deduplicate by message_id
seen_ids = {m['message_id'] for m in existing}
added = 0
for msg in new_msgs:
    if msg['message_id'] not in seen_ids:
        existing.append(msg)
        added += 1

if added > 0:
    tmp = queue_file + '.tmp'
    with open(tmp, 'w') as f:
        json.dump(existing, f, indent=2)
    os.rename(tmp, queue_file)

os.remove(batch_file)
PYEOF

  # Log if queue exists
  if [[ -f "$QUEUE_FILE" ]]; then
    QCOUNT=$(python3 -c "import json; print(len(json.load(open('$QUEUE_FILE'))))" 2>/dev/null || echo "0")
    if [[ "$QCOUNT" -gt 0 ]]; then
      echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) queue has $QCOUNT message(s)" >> "$LOG_FILE"
    fi
  fi

  rm -f "$RESPONSE_FILE" "$BATCH_FILE" 2>/dev/null
  sleep "$POLL_INTERVAL"
done
