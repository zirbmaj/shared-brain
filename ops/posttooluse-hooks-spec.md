---
title: PostToolUse Hooks Spec — NWL Agents
date: 2026-03-31
author: claude
status: active
---

# PostToolUse Hooks Spec

## Purpose

PostToolUse hooks fire after every tool call (or filtered by tool name via `matcher`).
They close the last NWL migration gap — agents currently have SessionStart + SessionEnd
hooks but nothing between tool calls.

## Hook 1: Discord Urgent Messages (all agents)

**Problem:** During long multi-tool turns, agents are heads-down and don't see new
Discord messages until the turn completes. Human messages can wait 2-5 minutes
unnoticed.

**Solution:** `discord-urgent-hook.sh` checks a queue file between tool calls.
Silent exit when empty (no context waste, no latency).

**Architecture:**
```
discord-poller.sh (background)          discord-urgent-hook.sh (PostToolUse)
  polls Discord REST API every 30s        fires after each tool call
  writes human messages to queue          reads queue, surfaces if non-empty
  /tmp/agent-monitor/{agent}-queue.json   clears queue after surfacing
```

**Config (all agents):**
```json
"PostToolUse": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash ~/shared-brain/ops/discord-urgent-hook.sh {agent-name}",
        "timeout": 5
      }
    ]
  }
]
```

**Graceful degradation:** If the poller isn't running, no queue file exists →
hook exits silently in <1ms. Safe to wire now, activate later.

**Poller startup (per agent):**
```bash
# In agent's screen session, or as launchd service
nohup bash ~/shared-brain/ops/discord-poller.sh {agent} {discord-state-dir} {extra-channels...} &
```

**Per-agent channel config:**
| Agent | Always | Extra channels |
|-------|--------|----------------|
| All | jam's office (1485741478331420734) | — |
| Claude | + | dev (1485512553273753600), jam DM (1485778574815527056) |
| Relay | + | dev, leads (1485798218347450489) |
| Static | + | bugs (1485110948187476138) |
| Claudia | + | dev |
| Near | + | links (1485107590491799734) |
| Hum | + | dev |

## Hook 2: Edit Guard (claude only, future)

**Problem:** Claude edits files across 5+ repos. Easy to accumulate uncommitted
changes that get lost on session end.

**Config (claude only, not deploying yet — documenting for later):**
```json
{
  "matcher": "Edit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "bash ~/shared-brain/ops/edit-guard-hook.sh",
      "timeout": 5
    }
  ]
}
```

**Behavior:** After every Edit/Write, count dirty files across product repos.
If >15 uncommitted files, output a reminder. Not deploying now — the latency
cost isn't worth it until we have a pattern of lost changes.

## Deployment Plan

### Phase 1 (now): Wire hooks, no poller
- Add PostToolUse config to all 6 agents' settings.json
- Hook is a no-op without the poller — zero risk, zero latency
- Takes effect on next agent cycle

### Phase 2 (jam or relay): Start pollers
- Start discord-poller.sh as background process per agent
- Or create a single multi-agent poller (future optimization)
- Recommend: launchd plist for persistence across reboots

### Phase 3 (future): Tool-specific hooks
- Edit guard for claude (matcher: Edit|Write)
- Test auto-run for static (matcher: Edit, if: Edit(*.mjs))
- Lint check for claudia (matcher: Edit, if: Edit(*.css))

## Files

| File | Status | Purpose |
|------|--------|---------|
| shared-brain/ops/discord-urgent-hook.sh | ✅ ready | PostToolUse hook script |
| shared-brain/ops/discord-poller.sh | ✅ ready | Background poller service |
| shared-brain/ops/posttooluse-hooks-spec.md | ✅ this file | Spec document |
| shared-brain/ops/edit-guard-hook.sh | 📋 future | Edit guard hook script |
