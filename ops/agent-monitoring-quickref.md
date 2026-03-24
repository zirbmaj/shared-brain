---
title: agent monitoring quick reference
date: 2026-03-24
type: reference
scope: shared
summary: commands for monitoring agents after auto-restart, checking status, attaching to sessions, viewing logs
---

# Agent Monitoring Quick Reference

## Check All Agents
```bash
~/shared-brain/ops/agent-cycle.sh --status
```
Shows: agent name, PID, uptime, host

## Attach to Agent Terminal (live view)
```bash
screen -r agent-claude      # attach to claude's live session
screen -r agent-static      # attach to static's live session
screen -r agent-near        # etc.
# ctrl-a then d = detach without killing
# ctrl-a then k = kill the session
```

## View Logs
```bash
tail -f /tmp/agent-cycle.log          # all cycle events (kills, restarts)
tail -f /tmp/agent-cycle-alerts.log   # alerts (failed restarts)
tail -f /tmp/agent-claude.log         # claude's session output
tail -f /tmp/agent-static.log         # static's session output
```

## Manually Cycle One Agent
```bash
~/shared-brain/ops/agent-cycle.sh claude    # kills + restarts claude
~/shared-brain/ops/agent-cycle.sh near      # kills + restarts near
```

## Activate Auto-Cycling (launchd)
```bash
for agent in claude claudia static near hum relay; do
  launchctl load ~/Library/LaunchAgents/com.nowherelabs.agent-${agent}.plist
done
```

## Deactivate Auto-Cycling
```bash
for agent in claude claudia static near hum relay; do
  launchctl unload ~/Library/LaunchAgents/com.nowherelabs.agent-${agent}.plist
done
```

## Cycle Intervals (safety net — agents can request early restart)
| agent | interval | reason |
|-------|----------|--------|
| claude | 5h | high context burn (code-heavy) |
| claudia | 6h | moderate (CSS iterations) |
| static | 6h | moderate (test output is verbose) |
| relay | 6h | moderate (process work) |
| near | 8h | bursty (long idle between research) |
| hum | 10h | minimal context usage |

## List All Screen Sessions
```bash
screen -ls
```
