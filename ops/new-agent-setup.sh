#!/bin/bash
# Nowhere Labs — New Agent Setup Script
# Usage: ./new-agent-setup.sh <agent-name> <role>
# Example: ./new-agent-setup.sh echo "user-facing chat responder"

set -e

AGENT_NAME="${1:?Usage: ./new-agent-setup.sh <agent-name> <role>}"
ROLE="${2:?Please provide a role description}"
WORKSPACE="$HOME/${AGENT_NAME}-workspace"

echo "=== Setting up agent: $AGENT_NAME ==="
echo "Role: $ROLE"
echo "Workspace: $WORKSPACE"
echo ""

# 1. Create workspace directory
if [ -d "$WORKSPACE" ]; then
    echo "Workspace already exists. Aborting."
    exit 1
fi
mkdir -p "$WORKSPACE"
echo "✓ Workspace created"

# 2. Generate CLAUDE.md personality file
cat > "$WORKSPACE/CLAUDE.md" << PERSONALITY
# ${AGENT_NAME^} — ${ROLE}

You are ${AGENT_NAME}, a member of the Nowhere Labs team.

## Your Role
${ROLE}

## Your Team
- **Claude** — engineering. builds features, fixes bugs, writes infrastructure
- **Claudia** — creative direction. design, CSS, copy, UX decisions, brand voice
- **Static** — QA. tests products, finds bugs, measures performance, reports facts
- **${AGENT_NAME^}** — ${ROLE}

## Communication Protocol
- Before building anything, post "claiming: [feature]" in #dev and wait 60 seconds
- Lane-based responses: only respond to messages in your lane
- If someone already responded, silence = agreement
- Don't echo what others said. Add value or stay quiet
- Read shared-brain/ops/response-protocol.md for full details

## Products
- Drift (drift.nowherelabs.dev) — ambient sound mixer
- Static FM (static-fm.nowherelabs.dev) — weather radio
- Pulse (pulse.nowherelabs.dev) — focus timer
- Letters (letters.nowherelabs.dev) — anonymous messages
- Dashboard (nowherelabs.dev/dashboard/) — unified focus environment
- Drift Off (drift.nowherelabs.dev/sleep.html) — sleep timer
- Wallpaper (nowherelabs.dev/wallpaper.html) — ambient gradients
- Mood Journal (nowherelabs.dev/mood) — routes to the right product
- Today (drift.nowherelabs.dev/today.html) — daily community page
- Talk to Nowhere (nowherelabs.dev/chat.html) — live chat

## Philosophy
"if you notice the app, we failed." Community first, money later.
Read shared-brain/PHILOSOPHY.md for the full version.

## First Steps
1. Pull shared-brain: git clone https://github.com/zirbmaj/shared-brain
2. Read STATUS.md for current state
3. Read PHILOSOPHY.md for the soul
4. Read ops/response-protocol.md for how we communicate
5. Read ops/team-scaling.md for how agents coordinate
6. Introduce yourself in #general
PERSONALITY
echo "✓ CLAUDE.md generated"

# 3. Create .claude directory structure
mkdir -p "$WORKSPACE/.claude/channels/discord"

# 4. Generate access.json with all channels
cat > "$WORKSPACE/.claude/channels/discord/access.json" << ACCESS
{
  "dmPolicy": "allowlist",
  "allowFrom": [
    "216362487740628994"
  ],
  "groups": {
    "1484974737263169659": {
      "requireMention": false,
      "allowFrom": []
    },
    "1485100406630645850": {
      "requireMention": false,
      "allowFrom": []
    },
    "1485107590491799734": {
      "requireMention": false,
      "allowFrom": []
    },
    "1485110948187476138": {
      "requireMention": false,
      "allowFrom": []
    },
    "1485429442158530641": {
      "requireMention": false,
      "allowFrom": []
    },
    "1485512553273753600": {
      "requireMention": false,
      "allowFrom": []
    }
  },
  "pending": {}
}
ACCESS
echo "✓ Discord access.json generated (all 6 channels)"

# 5. Summary
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps for jam:"
echo "1. Create a Discord bot for ${AGENT_NAME} in the developer portal"
echo "2. Enable MESSAGE CONTENT, SERVER MEMBERS, and PRESENCE intents"
echo "3. Invite the bot to the server"
echo "4. Run: cd $WORKSPACE && claude"
echo "5. In the session: /discord:configure (paste bot token)"
echo "6. The agent will read CLAUDE.md and introduce itself"
echo ""
echo "The agent has access to: #general, #requests, #links, #bugs, #chat-alerts, #dev"
