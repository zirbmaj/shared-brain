#!/bin/bash
# Nowhere Labs — StatusLine Wrapper
# Wraps the HUD statusLine command to also export context window data.
#
# How it works:
#   1. stdin (from claude code) → tee → both HUD and context extractor
#   2. Context extractor writes /tmp/agent-monitor/{agent}-context.json
#   3. HUD's stdout passes through as the wrapper's stdout
#
# Install: replace the statusLine command in settings.json with this script.

MONITOR_DIR="/tmp/agent-monitor"
mkdir -p "$MONITOR_DIR"

# Detect agent from AGENT_NAME env var or workspace path
if [ -n "$AGENT_NAME" ]; then
    AGENT="$AGENT_NAME"
else
case "$(pwd)" in
    */claude-workspace*) AGENT="claude" ;;
    */claudia-workspace*) AGENT="claudia" ;;
    */static-workspace*) AGENT="static" ;;
    */near-workspace*) AGENT="near" ;;
    */hum-workspace*) AGENT="hum" ;;
    */relay-workspace*) AGENT="relay" ;;
    */shadow-claude-workspace*) AGENT="shadow-claude" ;;
    */shadow-static-workspace*) AGENT="shadow-static" ;;
    */shadow-near-workspace*) AGENT="shadow-near" ;;
    */shadow-relay-workspace*) AGENT="shadow-relay" ;;
    *) AGENT="unknown" ;;
esac
fi

CONTEXT_FILE="$MONITOR_DIR/${AGENT}-context.json"

# Find the HUD plugin (same logic as the original statusLine command)
plugin_dir=$(ls -d "$HOME"/.claude/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null \
    | awk -F/ '{ print $(NF-1) "\t" $0 }' \
    | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n \
    | tail -1 | cut -f2-)
HUD_CMD="/opt/homebrew/bin/node ${plugin_dir}dist/index.js"

# Context extractor: reads JSON lines, writes context % to file
# Runs as a background process consuming from a named pipe
FIFO="$MONITOR_DIR/${AGENT}-stdin-fifo"
rm -f "$FIFO"
mkfifo "$FIFO"

# Background: read from FIFO, extract context data
python3 -c "
import json, sys, os, tempfile

monitor_dir = '$MONITOR_DIR'
context_file = '$CONTEXT_FILE'
agent = '$AGENT'

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        data = json.loads(line)
        cw = data.get('context_window', {})
        pct = cw.get('used_percentage')
        if pct is not None:
            from datetime import datetime, timezone
            out = {
                'agent': agent,
                'used_percentage': pct,
                'context_window_size': cw.get('context_window_size', 0),
                'input_tokens': cw.get('current_usage', {}).get('input_tokens', 0),
                'cache_read': cw.get('current_usage', {}).get('cache_read_input_tokens', 0),
                'updated_at': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
            }
            # Atomic write
            fd, tmp = tempfile.mkstemp(dir=monitor_dir, suffix='.tmp')
            with os.fdopen(fd, 'w') as f:
                json.dump(out, f)
            os.rename(tmp, context_file)
    except (json.JSONDecodeError, KeyError, TypeError):
        pass
" < "$FIFO" &
EXTRACTOR_PID=$!

# Cleanup on exit
cleanup() {
    kill "$EXTRACTOR_PID" 2>/dev/null
    rm -f "$FIFO"
}
trap cleanup EXIT

# Main: tee stdin to both the FIFO (extractor) and the HUD
tee "$FIFO" | $HUD_CMD
