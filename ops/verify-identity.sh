#!/bin/bash
# Identity verification — runs at agent startup
# Checks workspace, CLAUDE.md, and discord state dir all match
# Returns JSON for the session startup hook to parse
#
# Usage: verify-identity.sh [expected-agent-name]
# If no name provided, derives from workspace directory name

set -euo pipefail

WORKSPACE="$(pwd)"
AGENT_NAME="${1:-}"

# Derive agent name from workspace if not provided
if [ -z "$AGENT_NAME" ]; then
    AGENT_NAME=$(basename "$WORKSPACE" | sed 's/-workspace$//')
fi

ERRORS=()
WARNINGS=()

# Check 1: Workspace path matches agent name
EXPECTED_WS="$HOME/${AGENT_NAME}-workspace"
if [ "$WORKSPACE" != "$EXPECTED_WS" ]; then
    ERRORS+=("workspace mismatch: expected $EXPECTED_WS, got $WORKSPACE")
fi

# Check 2: CLAUDE.md exists and contains agent identity
if [ -f "$WORKSPACE/CLAUDE.md" ]; then
    # Check if the agent's name appears in the Identity section
    if ! grep -qi "you are ${AGENT_NAME}\|you ARE ${AGENT_NAME}\|# ${AGENT_NAME}" "$WORKSPACE/CLAUDE.md" 2>/dev/null; then
        ERRORS+=("CLAUDE.md does not contain identity for $AGENT_NAME")
    fi
else
    ERRORS+=("no CLAUDE.md found in $WORKSPACE")
fi

# Check 3: DISCORD_STATE_DIR matches agent
if [ "$AGENT_NAME" = "claude" ]; then
    EXPECTED_STATE="$HOME/.claude/channels/discord"
else
    EXPECTED_STATE="$HOME/.claude/channels/discord-${AGENT_NAME}"
fi

ACTUAL_STATE="${DISCORD_STATE_DIR:-not set}"
if [ "$ACTUAL_STATE" = "not set" ]; then
    WARNINGS+=("DISCORD_STATE_DIR not set — plugin will use default (claude's token)")
elif [ "$ACTUAL_STATE" != "$EXPECTED_STATE" ]; then
    ERRORS+=("DISCORD_STATE_DIR mismatch: expected $EXPECTED_STATE, got $ACTUAL_STATE")
fi

# Check 4: Bot token file exists in expected state dir
if [ -f "$EXPECTED_STATE/.env" ]; then
    if ! grep -q "DISCORD_BOT_TOKEN" "$EXPECTED_STATE/.env" 2>/dev/null; then
        ERRORS+=("no DISCORD_BOT_TOKEN in $EXPECTED_STATE/.env")
    fi
else
    ERRORS+=("no .env file at $EXPECTED_STATE — no bot token available")
fi

# Check 5: settings.json has correct DISCORD_STATE_DIR
if [ -f "$WORKSPACE/.claude/settings.json" ]; then
    SETTINGS_STATE=$(python3 -c "
import json
with open('$WORKSPACE/.claude/settings.json') as f:
    d = json.load(f)
print(d.get('env',{}).get('DISCORD_STATE_DIR','not set'))
" 2>/dev/null || echo "parse error")
    if [ "$SETTINGS_STATE" != "$EXPECTED_STATE" ]; then
        WARNINGS+=("settings.json DISCORD_STATE_DIR: $SETTINGS_STATE (expected $EXPECTED_STATE)")
    fi
else
    WARNINGS+=("no settings.json found — DISCORD_STATE_DIR not pinned in workspace config")
fi

# Output results
if [ ${#ERRORS[@]} -eq 0 ]; then
    echo "IDENTITY VERIFIED: $AGENT_NAME"
    echo "  workspace: $WORKSPACE"
    echo "  discord_state: $ACTUAL_STATE"
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        for w in "${WARNINGS[@]}"; do
            echo "  warning: $w"
        done
    fi
    exit 0
else
    echo "IDENTITY VERIFICATION FAILED: $AGENT_NAME"
    for e in "${ERRORS[@]}"; do
        echo "  ERROR: $e"
    done
    for w in "${WARNINGS[@]}"; do
        echo "  WARNING: $w"
    done
    echo ""
    echo "DO NOT PROCEED. You may be running with the wrong identity or bot token."
    echo "Ask a correctly-identified peer to re-cycle you using agent-cycle.sh"
    exit 1
fi
