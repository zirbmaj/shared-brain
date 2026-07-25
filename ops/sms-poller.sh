#!/bin/bash
# SMS Gateway Poller — monitors incoming SMS and posts to Discord
# Polls the SMSGate API on the Flip 7 for new incoming messages
# Run via cron every minute or as a background loop
#
# Usage: bash sms-poller.sh

set -euo pipefail

source ~/.config/sms-gateway.env

STATE_FILE="/tmp/sms-poller-last-check"
CONTACTS_FILE="$HOME/.config/sms-contacts.json"
LOG_FILE="/tmp/sms-poller.log"

log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"; }

# Resolve phone number to contact name
resolve_contact() {
    local phone="$1"
    if [ -f "$CONTACTS_FILE" ]; then
        local name
        name=$(python3 -c "
import json
with open('$CONTACTS_FILE') as f:
    contacts = json.load(f)
for name, number in contacts.items():
    if number.replace('+1','').replace('-','').replace(' ','') == '$phone'.replace('+1','').replace('-','').replace(' ',''):
        print(name.title())
        break
else:
    print('')
" 2>/dev/null || echo "")
        if [ -n "$name" ]; then
            echo "$name"
            return
        fi
    fi
    echo "$phone"
}

# Get incoming messages from SMSGate
incoming=$(curl -s --max-time 10 -u "$SMS_API_USER:$SMS_API_PASS" \
    "$SMS_API_URL/inbox" 2>/dev/null || echo "[]")

if [ "$incoming" = "[]" ] || [ -z "$incoming" ]; then
    exit 0
fi

# Get last check timestamp
last_check=""
if [ -f "$STATE_FILE" ]; then
    last_check=$(cat "$STATE_FILE")
fi

# Process new messages
echo "$incoming" | python3 -c "
import json, sys, subprocess, os

try:
    messages = json.load(sys.stdin)
except:
    sys.exit(0)

if not isinstance(messages, list):
    sys.exit(0)

last_check = '$last_check'
webhook_url = '$SMS_WEBHOOK_URL'
new_count = 0

for msg in messages:
    msg_time = msg.get('receivedAt', msg.get('timestamp', ''))
    if last_check and msg_time <= last_check:
        continue

    phone = msg.get('phoneNumber', msg.get('from', 'unknown'))
    text = msg.get('body', msg.get('message', ''))

    if not text:
        continue

    # Post to Discord via webhook
    payload = json.dumps({
        'username': 'SMS Gateway',
        'content': f'📱 **From: {phone}**\n> {text}'
    })

    subprocess.run([
        'curl', '-s', '-X', 'POST', webhook_url,
        '-H', 'Content-Type: application/json',
        '-d', payload
    ], capture_output=True, timeout=10)

    new_count += 1
    last_check = msg_time

if new_count > 0 and last_check:
    with open('$STATE_FILE', 'w') as f:
        f.write(last_check)
    print(f'{new_count} new messages posted to Discord')
" 2>/dev/null

log "poll complete"
