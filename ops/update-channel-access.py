#!/usr/bin/env python3
"""
Nowhere Labs — Channel Access Pre-Approval
Batch-updates agents' access.json with role-appropriate guild channels.
Uses proper JSON serialization — never manual string editing.

Usage:
  python3 update-channel-access.py              # dry-run
  python3 update-channel-access.py --apply       # apply changes
  python3 update-channel-access.py --agent claude  # one agent
"""

import json
import os
import shutil
import sys
import tempfile

HOME = os.path.expanduser("~")

# Channel definitions: name -> (id, requireMention)
CHANNELS = {
    "general":        ("1484974737263169659", False),
    "jams-office":    ("1485741478331420734", True),
    "dev":            ("1485512553273753600", False),
    "links":          ("1485107590491799734", False),
    "requests":       ("1485100406630645850", False),
    "bugs":           ("1485110948187476138", False),
    "chat-alerts":    ("1485429442158530641", False),
    "leads":          ("1485798218347450489", False),
    # Pairing rooms
    "claude-static":  ("1485745646660227122", False),
    "claude-claudia": ("1485745832488603800", False),
    "near-static":    ("1485745685490958458", False),
    # Relay 1:1 rooms
    "relay-claude":   ("1485783923161170040", False),
    "relay-claudia":  ("1485783950633730190", False),
    "relay-static":   ("1485783969021820958", False),
    "relay-near":     ("1485783979851255929", False),
    "relay-hum":      ("1485784031097520148", False),
    # Other 1:1
    "claude-near":    ("1485940247345762436", False),
    # DM channels with jam
    "claude-dm-jam":  ("1485778574815527056", False),
    "static-dm-jam":  ("1485461854112448632", False),
    # Shadow bridge
    "shadow-bridge":  ("1486126908847685776", False),
}

# Per-agent channel assignments (by channel name)
AGENT_CHANNELS = {
    "claude": [
        "general", "jams-office", "dev", "links", "requests", "bugs",
        "chat-alerts", "leads", "claude-static", "claude-claudia",
        "relay-claude", "claude-near", "claude-dm-jam",
    ],
    "claudia": [
        "general", "jams-office", "dev", "links", "requests", "bugs",
        "claude-claudia", "relay-claudia",
    ],
    "static": [
        "general", "jams-office", "dev", "links", "requests", "bugs",
        "leads", "chat-alerts", "claude-static", "near-static",
        "relay-static", "static-dm-jam",
    ],
    "near": [
        "general", "jams-office", "dev", "links", "requests", "bugs",
        "near-static", "relay-near", "claude-near",
    ],
    "hum": [
        "general", "jams-office", "dev", "links", "requests", "bugs",
        "relay-hum",
    ],
    "relay": [
        "general", "jams-office", "dev", "links", "requests", "bugs",
        "chat-alerts", "leads", "relay-claude", "relay-claudia",
        "relay-static", "relay-near", "relay-hum",
        "claude-dm-jam", "shadow-bridge",
    ],
}


def get_access_path(agent):
    if agent == "claude":
        return os.path.join(HOME, ".claude/channels/discord/access.json")
    return os.path.join(HOME, f".claude/channels/discord-{agent}/access.json")


def id_to_name(ch_id):
    for name, (cid, _) in CHANNELS.items():
        if cid == ch_id:
            return name
    return ch_id


def update_agent(agent, apply=False):
    path = get_access_path(agent)
    if not os.path.exists(path):
        print(f"  WARNING: {path} does not exist. skipping.")
        return

    with open(path) as f:
        access = json.load(f)

    old_groups = access.get("groups", {})
    old_ids = set(old_groups.keys())

    # Build new groups preserving existing allowFrom
    new_groups = {}
    for ch_name in AGENT_CHANNELS.get(agent, []):
        if ch_name not in CHANNELS:
            print(f"  WARNING: unknown channel '{ch_name}'")
            continue
        ch_id, require_mention = CHANNELS[ch_name]
        existing = old_groups.get(ch_id, {})
        new_groups[ch_id] = {
            "requireMention": require_mention,
            "allowFrom": existing.get("allowFrom", []),
        }

    new_ids = set(new_groups.keys())
    added = new_ids - old_ids
    removed = old_ids - new_ids

    print(f"  {agent} ({path}):")
    for cid in sorted(added):
        print(f"    + {id_to_name(cid)} ({cid})")
    for cid in sorted(removed):
        print(f"    - {id_to_name(cid)} ({cid})")
    if not added and not removed:
        print("    (no changes)")

    access["groups"] = new_groups

    if apply:
        # Backup
        shutil.copy2(path, path + ".bak")
        # Atomic write: temp file then mv
        fd, tmp = tempfile.mkstemp(
            dir=os.path.dirname(path), suffix=".tmp"
        )
        with os.fdopen(fd, "w") as f:
            json.dump(access, f, indent=2)
            f.write("\n")
        os.rename(tmp, path)
        print(f"    WRITTEN (backup at {path}.bak)")
    else:
        print("    (dry-run)")


def main():
    apply = "--apply" in sys.argv
    target = ""
    if "--agent" in sys.argv:
        idx = sys.argv.index("--agent")
        if idx + 1 < len(sys.argv):
            target = sys.argv[idx + 1]
    if "--help" in sys.argv or "-h" in sys.argv:
        print(__doc__)
        return

    mode = "APPLYING" if apply else "DRY RUN"
    print(f"\n=== Channel Access Pre-Approval ({mode}) ===\n")

    for agent in ["claude", "claudia", "static", "near", "hum", "relay"]:
        if target and agent != target:
            continue
        update_agent(agent, apply)
        print()

    if not apply:
        print("No changes written. Run with --apply to update.")


if __name__ == "__main__":
    main()
