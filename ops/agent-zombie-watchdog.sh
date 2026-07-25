#!/bin/bash
# NWL Agent Zombie Watchdog — v2 (OBSERVE-ONLY) — proposed by static (QA), 2026-05-21.
# Drop-in replacement for agent-zombie-watchdog.sh. relay owns operationalizing
# (swap + restart the screen daemon); static owns this detection logic + the harness
# (tests/zombie-harness.sh in static-workspace, 7/7 passing).
#
# Fixes TWO bugs found in v1 (both proven by the harness):
#
#  (1) FALSE-DEAD (the critical one): v1 found the agent process by walking the screen
#      session's PPID chain (screen->shell->leaf). When the tree is reparented or doesn't
#      match that shape, v1 returns "" => reports DEAD on a LIVE agent. v2 finds the agent
#      by its workspace CWD via lsof — topology-independent.
#
#  (2) ZOMBIE-MASKING: v1's has_active_child = "any child exists" is ALWAYS true in prod.
#      Every main node owns persistent children — MCP servers (bun) + caffeinate — so a
#      hung agent reads BUSY forever and is never flagged. Confirmed empirically in
#      /tmp/zombie-watchdog.log: 23/24 sweeps = BUSY. v2 uses BASELINE-DIFF: "active work"
#      = a child BEYOND the agent's learned persistent baseline (a per-tool-call
#      subprocess), not mere child existence.
#
# DESIGN BIAS: fail safe toward "busy/alive". For a detect-only watchdog whose alerts a
# human triages (no auto-cycle), a missed zombie is recoverable; falsely flagging a LIVE
# agent is the cardinal sin (we have a standing rule: never cycle on silence alone). So
# every ambiguous case resolves to NOT-flagged.
#
# ⚠️ DO NOT set ALERT=1 yet. Thresholds (SOFT/HARD) and baseline stability across MCP
# restarts are unvalidated against real cold-agent + long-tool-call events. Let v2 run in
# observe mode overnight; static tunes from /tmp/zombie-watchdog.log before alerting is on.
#
# SCHEDULER: screen-loop, not cron (crontab is TCC-blocked on this host — relay's call):
#   screen -dmS nwl-zombie-watchdog bash ~/shared-brain/ops/agent-zombie-watchdog.v2.sh --loop

AGENTS=(claude static claudia near hum relay)
SOFT_COLD=900      # 15 min — below this, never flag
HARD_COLD=1800     # 30 min cold + no active work => hard zombie candidate
INTERVAL=300       # 5 min loop
LOG=/tmp/zombie-watchdog.log
BASELINE_DIR=/tmp/zombie-baselines
ALERT=0            # observe-only. Flip to 1 ONLY after static signs off on tuning.
mkdir -p "$BASELINE_DIR"

workspace_dir() { echo "$HOME/teams/nwl/${1}-workspace"; }
jsonl_slug()    { echo "-Users-jambrizr-teams-nwl-${1}-workspace"; }

jsonl_age() {  # newest .jsonl mtime age (s) for an agent slug, -1 if none
  local dir="$HOME/.claude/projects/$1" newest
  newest=$(ls -t "$dir"/*.jsonl 2>/dev/null | head -1)
  [ -z "$newest" ] && { echo -1; return; }
  echo $(( $(date +%s) - $(stat -f %m "$newest") ))
}

# FIX (1): locate the agent by workspace cwd, not screen/PPID. Among processes whose cwd is
# the workspace, prefer the one whose command is `claude` (the agent binary) — NOT just the
# lowest pid: a stray low-pid `sleep`/`bash` in the workspace would otherwise hijack it and,
# if the agent went cold, we'd check the wrong process and could false-flag a LIVE agent.
# (Caught in real-agent validation: relay's lowest-cwd-pid was a sleep, not its claude node.)
# Falls back to lowest pid if no `claude` match (keeps the harness's sleep-fixtures working).
agent_pid() {
  local ws="$1" pids p
  pids=$(lsof -a -d cwd -Fpn 2>/dev/null | awk -v d="$ws" '
    /^p/{p=substr($0,2)} /^n/{ if(substr($0,2)==d) print p }' | sort -n)
  for p in $pids; do
    [ "$(ps -o comm= -p "$p" 2>/dev/null | xargs basename 2>/dev/null)" = "claude" ] && { echo "$p"; return; }
  done
  echo "$pids" | head -1   # fallback: lowest matching pid
}

# FIX (2): baseline-diff. Baseline = the persistent child set (MCP/caffeinate), learned as
# the MINIMUM child set observed (self-corrects downward if startup caught a tool child).
# Returns 0 (busy) if any current child is NOT in the baseline => a per-tool-call subprocess.
has_active_work() {
  local main="$1" name="$2" bfile="$BASELINE_DIR/$name" cur base c
  cur=$(pgrep -P "$main" 2>/dev/null | sort -n | tr '\n' ',')
  base=$(cat "$bfile" 2>/dev/null)
  local cur_n base_n
  cur_n=$(awk -F, '{print NF-1}' <<<"$cur"); base_n=$(awk -F, '{print NF-1}' <<<"$base")
  # learn / lower the baseline when we see a smaller stable child set (or first sight)
  if [ -z "$base" ] || [ "$cur_n" -lt "$base_n" ]; then echo "$cur" > "$bfile"; base="$cur"; fi
  for c in $(pgrep -P "$main" 2>/dev/null); do
    case ",$base," in *",$c,"*) ;; *) return 0;; esac   # child not in baseline => active work
  done
  return 1
}

check_agent() {
  local name="$1" ws slug pid age verdict
  ws=$(workspace_dir "$name"); slug=$(jsonl_slug "$name")
  pid=$(agent_pid "$ws"); age=$(jsonl_age "$slug")

  if   [ -z "$pid" ];        then verdict="DEAD (no process owns $ws)"
  elif [ "$age" -lt 0 ];     then verdict="UNKNOWN (no jsonl)"
  elif has_active_work "$pid" "$name"; then verdict="BUSY (tool subprocess, age=${age}s)"
  elif [ "$age" -ge "$HARD_COLD" ]; then verdict="ZOMBIE-HARD (alive, cold ${age}s, no active work)"
  elif [ "$age" -ge "$SOFT_COLD" ]; then verdict="ZOMBIE-SOFT (alive, cold ${age}s, no active work — watch)"
  else verdict="OK (age=${age}s)"
  fi
  printf '[%s] %-8s pid=%-7s %s\n' "$(date -u +%H:%M:%S)" "$name" "${pid:-none}" "$verdict" >> "$LOG"

  case "$verdict" in
    ZOMBIE-HARD*|DEAD*)
      printf '[%s] CANDIDATE %-8s %s\n' "$(date -u +%H:%M:%S)" "$name" "$verdict" >> /tmp/zombie-alerts.log
      [ "$ALERT" = "1" ] && : # TODO(relay): POST to #dev webhook once tuning is signed off.
      ;;
  esac
}

run_once() { echo "=== sweep $(date -u +%Y-%m-%dT%H:%M:%SZ) (v2 observe-only) ===" >> "$LOG"
  for a in "${AGENTS[@]}"; do check_agent "$a"; done; }

if [ "$1" = "--loop" ]; then
  echo "watchdog v2 loop start $(date -u) interval=${INTERVAL}s" >> "$LOG"
  while true; do run_once; sleep "$INTERVAL"; done
else
  run_once; tail -n $(( ${#AGENTS[@]} + 1 )) "$LOG"
fi
