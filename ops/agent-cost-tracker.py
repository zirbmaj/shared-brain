#!/usr/bin/env python3
"""
Nowhere Labs — Agent Cost & Utilization Tracker
Shows per-agent uptime, token usage, rate limit utilization, and API-equivalent cost.

Usage:
  python3 agent-cost-tracker.py             # current session summary
  python3 agent-cost-tracker.py --today     # today's cumulative usage
  python3 agent-cost-tracker.py --week      # 7-day summary

Primary view: utilization % (Max plan — $200/mo flat, rate limits matter)
Secondary view: API-equivalent cost (for future planning)
"""

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

HOME = Path.home()
MONITOR_DIR = Path("/tmp/agent-monitor")
SESSIONS_DIR = HOME / ".claude" / "sessions"
PROJECTS_DIR = HOME / ".claude" / "projects"
HUD_CACHE = HOME / ".claude" / "plugins" / "claude-hud" / ".usage-cache.json"

# Anthropic API pricing (for API-equivalent cost estimation)
# These are NOT what Max plan costs — Max is $200/mo flat
PRICING = {
    "input": 15.0 / 1_000_000,        # $15/M input tokens
    "output": 75.0 / 1_000_000,       # $75/M output tokens
    "cache_read": 1.875 / 1_000_000,  # $1.875/M cache read tokens
    "cache_create": 3.75 / 1_000_000, # $3.75/M cache creation tokens
}

AGENTS = {
    "claude": HOME / "claude-workspace",
    "claudia": HOME / "claudia-workspace",
    "static": HOME / "static-workspace",
    "near": HOME / "near-workspace",
    "hum": HOME / "hum-workspace",
    "relay": HOME / "relay-workspace",
}

# ANSI colors
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
RED = "\033[0;31m"
CYAN = "\033[0;36m"
NC = "\033[0m"


def get_project_dir(workspace):
    """Map workspace path to claude's project directory."""
    encoded = str(workspace).replace("/", "-").lstrip("-")
    return PROJECTS_DIR / f"-{encoded}"


def get_active_session(workspace):
    """Find the active session for a workspace."""
    for f in SESSIONS_DIR.glob("*.json"):
        try:
            data = json.loads(f.read_text())
            if data.get("cwd") == str(workspace):
                pid = int(f.stem)
                # Check if process is alive
                try:
                    os.kill(pid, 0)
                    return pid, data.get("sessionId", ""), data.get("startedAt", 0)
                except OSError:
                    continue
        except (json.JSONDecodeError, ValueError):
            continue
    return None, None, 0


def parse_session_tokens(jsonl_path, since=None):
    """Parse token usage from a session JSONL file."""
    totals = {
        "input_tokens": 0,
        "output_tokens": 0,
        "cache_read": 0,
        "cache_create": 0,
        "turns": 0,
    }
    try:
        with open(jsonl_path) as f:
            for line in f:
                try:
                    d = json.loads(line)
                    if d.get("type") != "assistant":
                        continue
                    # Filter by timestamp if requested
                    if since:
                        ts = d.get("timestamp", "")
                        if ts and ts < since:
                            continue
                    msg = d.get("message", {})
                    if not isinstance(msg, dict):
                        continue
                    usage = msg.get("usage", {})
                    if usage:
                        totals["input_tokens"] += usage.get("input_tokens", 0)
                        totals["output_tokens"] += usage.get("output_tokens", 0)
                        totals["cache_read"] += usage.get("cache_read_input_tokens", 0)
                        totals["cache_create"] += usage.get("cache_creation_input_tokens", 0)
                        totals["turns"] += 1
                except json.JSONDecodeError:
                    continue
    except FileNotFoundError:
        pass
    return totals


def get_agent_usage(agent_name, workspace, since=None):
    """Get token usage for an agent across all sessions."""
    project_dir = get_project_dir(workspace)
    totals = {
        "input_tokens": 0,
        "output_tokens": 0,
        "cache_read": 0,
        "cache_create": 0,
        "turns": 0,
    }

    if not project_dir.exists():
        return totals

    for jsonl in project_dir.glob("*.jsonl"):
        session_totals = parse_session_tokens(jsonl, since)
        for k in totals:
            totals[k] += session_totals[k]

    return totals


def calc_api_cost(usage):
    """Calculate API-equivalent cost (NOT actual Max plan cost)."""
    return (
        usage["input_tokens"] * PRICING["input"]
        + usage["output_tokens"] * PRICING["output"]
        + usage["cache_read"] * PRICING["cache_read"]
        + usage["cache_create"] * PRICING["cache_create"]
    )


def format_tokens(n):
    """Format token count for display."""
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.0f}K"
    return str(n)


def get_rate_limits():
    """Read rate limit data from HUD cache."""
    try:
        data = json.loads(HUD_CACHE.read_text())
        d = data.get("data", {})
        return {
            "five_hour": d.get("fiveHour", "?"),
            "seven_day": d.get("sevenDay", "?"),
            "five_hour_reset": d.get("fiveHourResetAt", ""),
            "seven_day_reset": d.get("sevenDayResetAt", ""),
            "plan": d.get("planName", "?"),
        }
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def get_uptime(agent_name):
    """Get agent uptime from health monitor status."""
    status_file = MONITOR_DIR / f"{agent_name}-status.json"
    context_file = MONITOR_DIR / f"{agent_name}-context.json"
    uptime_seconds = 0
    context_pct = "?"

    if status_file.exists():
        try:
            data = json.loads(status_file.read_text())
            uptime_seconds = data.get("session_age", 0)
        except json.JSONDecodeError:
            pass

    if context_file.exists():
        try:
            data = json.loads(context_file.read_text())
            context_pct = f"{data.get('used_percentage', '?')}%"
        except json.JSONDecodeError:
            pass

    hours = uptime_seconds // 3600
    mins = (uptime_seconds % 3600) // 60
    return f"{hours}h{mins:02d}m", context_pct


def main():
    mode = "current"
    since = None

    if "--today" in sys.argv:
        mode = "today"
        since = datetime.now(timezone.utc).strftime("%Y-%m-%dT00:00:00")
    elif "--week" in sys.argv:
        mode = "week"
        from datetime import timedelta
        week_ago = datetime.now(timezone.utc) - timedelta(days=7)
        since = week_ago.strftime("%Y-%m-%dT00:00:00")

    # Header
    now = datetime.now().strftime("%Y-%m-%d %H:%M CST")
    period = {"current": "Current Session", "today": "Today", "week": "7-Day"}[mode]
    print(f"\n{'=' * 70}")
    print(f"  Agent Cost & Utilization — {period} ({now})")
    print(f"{'=' * 70}\n")

    # Rate limits (shared across all agents on same plan)
    limits = get_rate_limits()
    if limits:
        plan = limits["plan"]
        fh = limits["five_hour"]
        sd = limits["seven_day"]
        fh_str = f"{fh}%" if fh is not None else "n/a"
        sd_str = f"{sd}%" if sd is not None else "n/a"
        fh_color = GREEN if isinstance(fh, (int, float)) and fh < 50 else (YELLOW if isinstance(fh, (int, float)) and fh < 80 else RED)
        sd_color = GREEN if isinstance(sd, (int, float)) and sd < 50 else (YELLOW if isinstance(sd, (int, float)) and sd < 80 else RED)
        if fh is None:
            fh_color = CYAN
        if sd is None:
            sd_color = CYAN
        print(f"  Plan: {plan} ($200/mo flat)")
        print(f"  5-hour utilization: {fh_color}{fh_str}{NC}")
        print(f"  7-day utilization:  {sd_color}{sd_str}{NC}")
        print()

    # Agent table
    header = f"  {'AGENT':<10} {'UPTIME':<8} {'CONTEXT':<8} {'TOKENS':<10} {'OUTPUT':<10} {'TURNS':<7} {'API-EQ $':<10}"
    print(header)
    print(f"  {'─' * 8:<10} {'─' * 6:<8} {'─' * 7:<8} {'─' * 8:<10} {'─' * 8:<10} {'─' * 5:<7} {'─' * 8:<10}")

    total_input = 0
    total_output = 0
    total_cache_read = 0
    total_cache_create = 0
    total_cost = 0
    total_turns = 0

    for agent_name, workspace in AGENTS.items():
        uptime, context = get_uptime(agent_name)
        usage = get_agent_usage(agent_name, workspace, since)
        cost = calc_api_cost(usage)

        total_tokens = usage["input_tokens"] + usage["cache_read"] + usage["cache_create"]
        total_input += total_tokens
        total_output += usage["output_tokens"]
        total_cache_read += usage["cache_read"]
        total_cache_create += usage["cache_create"]
        total_cost += cost
        total_turns += usage["turns"]

        tok_display = format_tokens(total_tokens)
        out_display = format_tokens(usage["output_tokens"])

        print(f"  {agent_name:<10} {uptime:<8} {context:<8} {tok_display:<10} {out_display:<10} {usage['turns']:<7} ${cost:<9.2f}")

    print(f"  {'─' * 8:<10} {'─' * 6:<8} {'─' * 7:<8} {'─' * 8:<10} {'─' * 8:<10} {'─' * 5:<7} {'─' * 8:<10}")
    total_all = total_input + total_output
    print(f"  {'TOTAL':<10} {'—':<8} {'—':<8} {format_tokens(total_input):<10} {format_tokens(total_output):<10} {total_turns:<7} ${total_cost:<9.2f}")

    print(f"\n  {CYAN}API-EQ $ = what this would cost on API billing (not your Max plan cost){NC}")
    print(f"  {CYAN}Max plan: $200/mo flat regardless of usage. Rate limits are the constraint.{NC}\n")


if __name__ == "__main__":
    main()
