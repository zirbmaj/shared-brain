#!/bin/bash
# Launch Meridian team agents in screen sessions
# Usage: ./launch-meridian.sh [agent-name]
#   No args = launch all 4 agents
#   With arg = launch specific agent (axis, forge, lens, locus)

set -euo pipefail

AGENTS=("axis" "forge" "lens" "locus" "trace")
BASE_DIR="$HOME/teams/meridian"

launch_agent() {
    local name="$1"
    local workspace="${BASE_DIR}/${name}-workspace"
    local discord_state="$HOME/.claude/channels/discord-${name}"

    # Validate workspace exists
    if [ ! -d "$workspace" ]; then
        echo "  ERROR: workspace not found at $workspace"
        return 1
    fi

    # Validate discord state dir exists
    if [ ! -d "$discord_state" ]; then
        echo "  ERROR: discord state dir not found at $discord_state"
        return 1
    fi

    # Validate bot token exists
    if [ ! -f "${discord_state}/.env" ]; then
        echo "  ERROR: no bot token at ${discord_state}/.env"
        return 1
    fi

    # Kill existing session if present
    if screen -ls 2>/dev/null | grep -q "agent-${name}"; then
        echo "  killing existing agent-${name} session..."
        screen -S "agent-${name}" -X quit 2>/dev/null || true
        sleep 3
    fi

    # Launch in screen session
    # TERM=xterm-256color: screen doesn't recognize ghostty's terminfo
    # exec claude: prevents bash wrapper from lingering after claude exits
    # stderr capture: enables post-mortem debugging
    screen -dmS "agent-${name}" bash -c "export TERM=xterm-256color && export DISCORD_STATE_DIR='${discord_state}' && cd '${workspace}' && exec claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official 2>>/tmp/agent-${name}-stderr.log"

    sleep 2
    if screen -ls 2>/dev/null | grep -q "agent-${name}"; then
        echo "  agent-${name} launched (screen session active)"
    else
        echo "  WARNING: agent-${name} screen session not found after launch"
    fi
}

if [ -n "${1:-}" ]; then
    # Launch specific agent
    echo "Launching $1..."
    launch_agent "$1"
else
    # Launch all agents
    echo "Launching all Meridian agents..."
    for agent in "${AGENTS[@]}"; do
        echo "  launching ${agent}..."
        launch_agent "$agent"
        sleep 5  # stagger launches to avoid resource contention
    done
fi

echo ""
echo "Verify with: screen -ls | grep agent-"
