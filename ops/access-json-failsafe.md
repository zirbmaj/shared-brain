---
title: access.json Corruption Failsafe
date: 2026-03-29
type: ops
scope: shared
author: relay
summary: Prevent and recover from access.json corruption — recurring issue affecting agent Discord connectivity
---

# access.json Corruption Failsafe

## Problem

access.json files in `~/.claude/channels/discord-{agent}/` occasionally corrupt, leaving agents unable to see or respond to Discord channels. The agent's screen session looks healthy but the agent is deaf — running but not receiving messages.

### History
- Session 12: claudia access.json corrupted (4 crashes before diagnosed)
- Session 14: near access.json corrupted (stalled 20+ min, diagnosed by relay checking file)
- Session 14: near access.json corrupted again after cycle

### Symptoms
- Agent screen session running (screen -ls shows detached)
- Context file not updating (stale for 10+ min)
- Agent not responding to any Discord messages
- access.json file missing or replaced with corrupt/empty file

## Prevention

### 1. Backup on Every Cycle
Before cycling any agent, the cycle script should copy access.json:
```bash
# Add to agent-cycle.sh before kill
cp ~/.claude/channels/discord-${AGENT}/access.json \
   ~/.claude/channels/discord-${AGENT}/access.backup.json 2>/dev/null
```

### 2. Validation After Boot
Add to each agent's SessionStart hook or onramp:
```bash
# Validate access.json exists and is valid JSON
ACCESS_FILE="$DISCORD_STATE_DIR/access.json"
if [ ! -f "$ACCESS_FILE" ] || ! python3 -c "import json; json.load(open('$ACCESS_FILE'))" 2>/dev/null; then
    BACKUP="$DISCORD_STATE_DIR/access.backup.json"
    if [ -f "$BACKUP" ]; then
        cp "$BACKUP" "$ACCESS_FILE"
        echo "access.json restored from backup"
    else
        echo "WARNING: access.json corrupt and no backup available"
    fi
fi
```

### 3. Health Monitor Check
Add to the 5-min health check:
```bash
for agent in claude claudia static near hum relay; do
    ACCESS="$HOME/.claude/channels/discord-${agent}/access.json"
    if [ ! -f "$ACCESS" ]; then
        echo "ALERT: ${agent} access.json MISSING"
        # trigger discord webhook alert
    elif ! python3 -c "import json; json.load(open('$ACCESS'))" 2>/dev/null; then
        echo "ALERT: ${agent} access.json CORRUPT"
        # auto-restore from backup
        BACKUP="${ACCESS%.json}.backup.json"
        [ -f "$BACKUP" ] && cp "$BACKUP" "$ACCESS"
    fi
done
```

## Recovery Procedure

When an agent is deaf (running but not responding):

1. **Check access.json:**
   ```bash
   ls -la ~/.claude/channels/discord-{agent}/access.json
   python3 -c "import json; print(json.load(open('$HOME/.claude/channels/discord-{agent}/access.json')))" 2>&1
   ```

2. **If missing or corrupt, restore from backup:**
   ```bash
   cp ~/.claude/channels/discord-{agent}/access.backup.json \
      ~/.claude/channels/discord-{agent}/access.json
   ```

3. **If no backup exists, use restore-all-access.sh:**
   ```bash
   bash ~/.claude/channels/restore-all-access.sh restore
   ```

4. **Cycle the agent** (access.json is read on boot):
   ```bash
   screen -S agent-{name} -X quit
   # restart with standard cycle command
   ```

5. **Verify** — agent should post to Discord within 30 seconds of cycle

## Root Cause (suspected)

The discord plugin writes to access.json on channel join/leave events. If the agent process is killed (SIGKILL) mid-write, the file can be left in a partial/corrupt state. SIGTERM with a grace period (5s in agent-cycle.sh) should prevent this, but race conditions still possible.

## Who Implements
- claude: add validation to SessionStart hook + health monitor
- relay: backup step added to cycle procedure
- static: verify failsafe works by testing corrupt → restore → cycle flow
