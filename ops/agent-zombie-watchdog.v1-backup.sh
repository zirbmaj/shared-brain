#!/bin/bash
# NWL Agent Zombie Watchdog — v1 (OBSERVE-ONLY)
# Detects "zombie" agents: process alive but not emitting transcript events.
#
# Signal design (claude, verified on disk 2026-05-21):
#   - Each agent session appends to a .jsonl in ~/.claude/projects/<workspace-slug>/
#     on EVERY event (message, tool call, tool result). Zombie => file goes cold.
#   - No sidecar/heartbeat file exists; JSONL mtime is the truest activity proxy.
#   - False-positive trap: a single long tool call (Bash build, Agent subagent) writes
#     NOTHING to JSONL for 10+ min of LEGIT work. So flat "cold > N" false-fires.
#   - Real zombie signature = PID alive + JSONL cold + NO active child process.
#
# OWNERSHIP: relay owns this operational runner + scheduler + alerting.
#   static owns detection LOGIC + threshold tuning + the false-positive harness.
#   Thresholds below are STARTING GUESSES — static tunes against observe-mode data.
#
# SCHEDULER NOTE: crontab is TCC-blocked on this host (see reference-crontab-tcc-blocked).
#   Run this as a self-scheduling screen loop instead — no cron needed:
#     screen -dmS agent-watchdog bash ~/shared-brain/ops/agent-zombie-watchdog.sh --loop
#
# MODE: observe-only. Logs verdicts, NEVER cycles or alerts externally.
#   Flip ALERT=1 (+ wire WEBHOOK) only after static's harness proves no false-positives.

AGENTS=(claude static claudia near hum relay)
SOFT_COLD=900     # 15 min — below this, never flag
HARD_COLD=1800    # 30 min cold + no child activity => hard zombie candidate
INTERVAL=300      # loop cadence (5 min)
LOG=/tmp/zombie-watchdog.log
ALERT=0           # observe-only; set 1 to enable alerting (after verification)

jsonl_age() {  # newest .jsonl mtime age in seconds for a workspace slug
  local slug="$1" dir="$HOME/.claude/projects/$slug" newest
  newest=$(ls -t "$dir"/*.jsonl 2>/dev/null | head -1)
  [ -z "$newest" ] && { echo -1; return; }
  echo $(( $(date +%s) - $(stat -f %m "$newest") ))
}

agent_claude_pid() {  # leaf claude PID under agent-{name} screen, "" if none
  local name="$1" spid
  spid=$(screen -ls | grep -oE "[0-9]+\.agent-$name" | grep -oE "^[0-9]+" | head -1)
  [ -z "$spid" ] && { echo ""; return; }
  local login child
  login=$(pgrep -P "$spid" 2>/dev/null | head -1)
  [ -z "$login" ] && { echo ""; return; }
  child=$(pgrep -P "$login" 2>/dev/null | head -1)
  echo "${child:-}"
}

has_active_child() {  # 0 if the claude PID has a working child subprocess (busy)
  local pid="$1"
  [ -z "$pid" ] && return 1
  [ -n "$(pgrep -P "$pid" 2>/dev/null)" ]
}

check_agent() {
  local name="$1" slug="-Users-jambrizr-teams-nwl-${1}-workspace"
  local pid age verdict
  pid=$(agent_claude_pid "$name")
  age=$(jsonl_age "$slug")

  if [ -z "$pid" ]; then verdict="DEAD (no claude process)"
  elif [ "$age" -lt 0 ]; then verdict="UNKNOWN (no jsonl found)"
  elif has_active_child "$pid"; then verdict="BUSY (active child, age=${age}s)"
  elif [ "$age" -ge "$HARD_COLD" ]; then verdict="ZOMBIE-HARD (alive, cold ${age}s, no child)"
  elif [ "$age" -ge "$SOFT_COLD" ]; then verdict="ZOMBIE-SOFT (alive, cold ${age}s, no child — cross-check)"
  else verdict="OK (age=${age}s)"
  fi
  printf '[%s] %-8s pid=%-7s %s\n' "$(date -u +%H:%M:%S)" "$name" "${pid:-none}" "$verdict" >> "$LOG"

  case "$verdict" in
    ZOMBIE-HARD*|DEAD*)
      if [ "$ALERT" = "1" ]; then
        : # TODO(relay): POST to #dev webhook. Until wired, problems live in $LOG + below.
      fi
      printf '[%s] ALERT %-8s %s\n' "$(date -u +%H:%M:%S)" "$name" "$verdict" >> /tmp/zombie-alerts.log
      ;;
  esac
}

run_once() { echo "=== sweep $(date -u +%Y-%m-%dT%H:%M:%SZ) (observe-only) ===" >> "$LOG"; for a in "${AGENTS[@]}"; do check_agent "$a"; done; }

if [ "$1" = "--loop" ]; then
  echo "watchdog loop start $(date -u) interval=${INTERVAL}s" >> "$LOG"
  while true; do run_once; sleep "$INTERVAL"; done
else
  run_once; tail -n $(( ${#AGENTS[@]} + 1 )) "$LOG"
fi
