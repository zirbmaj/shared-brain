#!/bin/bash
# Launch all 4 shadow agents for the zerimar/syght engagement
# Run from any directory. Each shadow gets its own screen session.

echo "Launching shadow agents..."

# Shadow Claude (engineering)
screen -dmS shadow-claude bash -c "export TERM=xterm-256color && export DISCORD_STATE_DIR='$HOME/.claude/channels/discord-shadow-claude' && cd ~/shadow-claude-workspace && claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official"
echo "  shadow-claude launched"

# Shadow Static (QA)
screen -dmS shadow-static bash -c "export TERM=xterm-256color && export DISCORD_STATE_DIR='$HOME/.claude/channels/discord-shadow-static' && cd ~/shadow-static-workspace && claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official"
echo "  shadow-static launched"

# Shadow Near (research)
screen -dmS shadow-near bash -c "export TERM=xterm-256color && export DISCORD_STATE_DIR='$HOME/.claude/channels/discord-shadow-near' && cd ~/shadow-near-workspace && claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official"
echo "  shadow-near launched"

# Shadow Relay (ops/coordination lead)
screen -dmS shadow-relay bash -c "export TERM=xterm-256color && export DISCORD_STATE_DIR='$HOME/.claude/channels/discord-shadow-relay' && cd ~/shadow-relay-workspace && claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official"
echo "  shadow-relay launched"

echo "All 4 shadow agents launched. Check with: screen -ls | grep shadow"
