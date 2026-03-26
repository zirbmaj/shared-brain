#!/usr/bin/env python3
"""
JSONL Activity Feed Parser — Mission Control
Reads agent transcript files and outputs structured activity events.

Usage:
  python3 jsonl-activity-parser.py                    # all agents, last 20 events each
  python3 jsonl-activity-parser.py --agent static     # one agent
  python3 jsonl-activity-parser.py --limit 50         # more events
  python3 jsonl-activity-parser.py --json             # JSON output for web consumption
  python3 jsonl-activity-parser.py --tail             # continuous mode (like tail -f)
"""

import json
import os
import sys
import time
import glob
from datetime import datetime, timezone
from pathlib import Path

SESSIONS_DIR = os.path.expanduser("~/.claude/sessions")
PROJECTS_DIR = os.path.expanduser("~/.claude/projects")

# Agent workspace mapping
AGENTS = {
    "claude": "claude-workspace",
    "claudia": "claudia-workspace",
    "static": "static-workspace",
    "near": "near-workspace",
    "hum": "hum-workspace",
    "relay": "relay-workspace",
}

# Tool name → human-readable action
TOOL_LABELS = {
    "Bash": "running command",
    "Read": "reading file",
    "Write": "writing file",
    "Edit": "editing file",
    "Grep": "searching code",
    "Glob": "finding files",
    "Agent": "spawning subagent",
    "WebFetch": "fetching URL",
    "WebSearch": "searching web",
    "TaskCreate": "creating task",
    "TaskUpdate": "updating task",
    "mcp__plugin_discord_discord__reply": "replying on discord",
    "mcp__plugin_discord_discord__fetch_messages": "reading discord",
    "mcp__plugin_discord_discord__download_attachment": "downloading attachment",
    "mcp__plugin_discord_discord__react": "reacting on discord",
    "mcp__claude_ai_Supabase__execute_sql": "querying supabase",
    "mcp__claude_ai_Supabase__apply_migration": "running migration",
    "mcp__claude_ai_Supabase__list_tables": "listing tables",
}


def find_active_sessions():
    """Find all active agent sessions with their JSONL files."""
    sessions = {}
    if not os.path.isdir(SESSIONS_DIR):
        return sessions

    for sf in glob.glob(os.path.join(SESSIONS_DIR, "*.json")):
        pid = os.path.basename(sf).replace(".json", "")
        try:
            pid_int = int(pid)
            # Check if process is alive
            os.kill(pid_int, 0)
        except (ValueError, ProcessLookupError, PermissionError):
            continue

        try:
            with open(sf) as f:
                meta = json.load(f)
            cwd = meta.get("cwd", "")
            session_id = meta.get("sessionId", "")
        except (json.JSONDecodeError, IOError):
            continue

        # Match to agent name
        agent_name = None
        for name, ws in AGENTS.items():
            if ws in cwd and "shadow" not in cwd:
                agent_name = name
                break

        if not agent_name:
            continue

        # Find JSONL file
        encoded_path = cwd.replace("/", "-").lstrip("-")
        project_dir = os.path.join(PROJECTS_DIR, f"-{encoded_path}")

        jsonl_path = None
        if os.path.isdir(project_dir):
            candidate = os.path.join(project_dir, f"{session_id}.jsonl")
            if os.path.isfile(candidate):
                jsonl_path = candidate

        if jsonl_path:
            sessions[agent_name] = {
                "pid": pid,
                "cwd": cwd,
                "session_id": session_id,
                "jsonl": jsonl_path,
            }

    return sessions


def parse_entry(entry):
    """Parse a single JSONL entry into an activity event."""
    entry_type = entry.get("type", "")
    msg = entry.get("message", {})
    role = msg.get("role", "")
    content = msg.get("content", [])
    ts = entry.get("timestamp", msg.get("timestamp", ""))

    if not ts:
        return None

    # Assistant actions (tool use or text)
    if entry_type == "assistant" and role == "assistant":
        if isinstance(content, list):
            for c in content:
                if isinstance(c, dict):
                    if c.get("type") == "tool_use":
                        tool_name = c.get("name", "unknown")
                        label = TOOL_LABELS.get(tool_name, tool_name)

                        # Extract detail from tool input
                        tool_input = c.get("input", {})
                        detail = ""
                        if "file_path" in tool_input:
                            detail = os.path.basename(tool_input["file_path"])
                        elif "command" in tool_input:
                            cmd = tool_input["command"][:60]
                            detail = cmd
                        elif "pattern" in tool_input:
                            detail = f'"{tool_input["pattern"]}"'
                        elif "text" in tool_input:
                            detail = tool_input["text"][:60]
                        elif "chat_id" in tool_input:
                            text = tool_input.get("text", "")[:60]
                            detail = text if text else "message"
                        elif "prompt" in tool_input:
                            detail = tool_input["prompt"][:60]
                        elif "subject" in tool_input:
                            detail = tool_input["subject"][:60]
                        elif "query" in tool_input:
                            detail = tool_input["query"][:60]

                        return {
                            "type": "tool_use",
                            "action": label,
                            "tool": tool_name,
                            "detail": detail,
                            "timestamp": ts,
                        }

                    elif c.get("type") == "text":
                        text = c.get("text", "").strip()
                        if text:
                            # Truncate for feed display
                            preview = text[:100] + ("..." if len(text) > 100 else "")
                            return {
                                "type": "message",
                                "action": "thinking",
                                "detail": preview,
                                "timestamp": ts,
                            }

    # Queue operations (incoming discord messages)
    elif entry_type == "queue-operation":
        return {
            "type": "incoming",
            "action": "received message",
            "detail": "",
            "timestamp": ts,
        }

    return None


def read_recent_events(jsonl_path, limit=20):
    """Read the last N parseable events from a JSONL file."""
    events = []

    # Read last chunk of file (avoid reading entire large file)
    file_size = os.path.getsize(jsonl_path)
    read_bytes = min(file_size, 200 * 1024)  # last 200KB

    with open(jsonl_path, "rb") as f:
        if file_size > read_bytes:
            f.seek(file_size - read_bytes)
            f.readline()  # skip partial first line
        lines = f.readlines()

    # Parse from end, collect up to limit events
    for line in reversed(lines):
        try:
            entry = json.loads(line.strip())
            event = parse_entry(entry)
            if event:
                events.append(event)
                if len(events) >= limit:
                    break
        except (json.JSONDecodeError, UnicodeDecodeError):
            continue

    events.reverse()
    return events


def format_event(agent, event):
    """Format an event for terminal display."""
    ts = event["timestamp"][:19].replace("T", " ") if event.get("timestamp") else ""
    action = event.get("action", "?")
    detail = event.get("detail", "")
    etype = event.get("type", "")

    # Color coding
    colors = {
        "tool_use": "\033[0;36m",  # cyan
        "message": "\033[0;32m",   # green
        "incoming": "\033[0;33m",  # yellow
    }
    color = colors.get(etype, "")
    reset = "\033[0m" if color else ""

    detail_str = f" — {detail}" if detail else ""
    return f"  {ts}  {color}{agent:10s}{reset}  {action}{detail_str}"


def main():
    import argparse

    parser = argparse.ArgumentParser(description="JSONL Activity Feed Parser")
    parser.add_argument("--agent", help="Show events for one agent only")
    parser.add_argument("--limit", type=int, default=20, help="Events per agent")
    parser.add_argument("--json", action="store_true", help="JSON output")
    parser.add_argument("--tail", action="store_true", help="Continuous mode")
    parser.add_argument("--all", action="store_true", help="Show all agents interleaved")
    args = parser.parse_args()

    sessions = find_active_sessions()

    if not sessions:
        print("No active agent sessions found.")
        sys.exit(1)

    if args.agent:
        if args.agent not in sessions:
            print(f"Agent '{args.agent}' not found. Active: {', '.join(sessions.keys())}")
            sys.exit(1)
        sessions = {args.agent: sessions[args.agent]}

    if args.tail:
        # Continuous mode: poll for new events
        last_sizes = {name: os.path.getsize(s["jsonl"]) for name, s in sessions.items()}
        print(f"Tailing {len(sessions)} agent(s)... (Ctrl+C to stop)\n")
        try:
            while True:
                for name, session in sessions.items():
                    current_size = os.path.getsize(session["jsonl"])
                    if current_size > last_sizes.get(name, 0):
                        events = read_recent_events(session["jsonl"], limit=5)
                        for event in events:
                            print(format_event(name, event))
                        last_sizes[name] = current_size
                time.sleep(2)
        except KeyboardInterrupt:
            print("\nStopped.")
            return

    # One-shot mode
    if args.json:
        output = {}
        for name, session in sessions.items():
            events = read_recent_events(session["jsonl"], limit=args.limit)
            output[name] = {
                "pid": session["pid"],
                "session_id": session["session_id"],
                "events": events,
            }
        print(json.dumps(output, indent=2))
    elif args.all:
        # Interleaved chronological view
        all_events = []
        for name, session in sessions.items():
            events = read_recent_events(session["jsonl"], limit=args.limit)
            for e in events:
                e["_agent"] = name
                all_events.append(e)
        all_events.sort(key=lambda e: e.get("timestamp", ""))
        print(f"\n=== Mission Control Activity Feed — {datetime.now().strftime('%H:%M:%S')} ===\n")
        for event in all_events[-args.limit:]:
            print(format_event(event["_agent"], event))
        print()
    else:
        # Per-agent view
        print(f"\n=== Agent Activity Feed — {datetime.now().strftime('%H:%M:%S')} ===\n")
        for name, session in sorted(sessions.items()):
            print(f"  [{name}] PID {session['pid']}")
            events = read_recent_events(session["jsonl"], limit=args.limit)
            if events:
                for event in events:
                    print(format_event(name, event))
            else:
                print(f"    (no recent activity)")
            print()


if __name__ == "__main__":
    main()
