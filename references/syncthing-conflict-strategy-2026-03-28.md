---
title: Syncthing Multi-Node Conflict Strategy
date: 2026-03-28
type: research
scope: infrastructure
owner: near
parent: homelab-service-architecture.md
status: final
---

# Syncthing Multi-Node Conflict Strategy

Research on best practices for multi-node Syncthing with concurrent writers. Defines ownership rules per shared-brain directory, conflict detection, and resolution process.

## Current Topology

| Node | Syncthing role | Writers | Path |
|------|---------------|---------|------|
| NWL-Mini | send-receive | 6 NWL agents + jam | `~/shared-brain/` |
| NWL-R10 | send-receive | RAG indexer (read-only), batch compute (writes reports/) | `/srv/nwl/shared-brain/` |

**Key fact:** today, all 6 agents live on Mini. Conflicts between agents are local filesystem races, not Syncthing conflicts. Syncthing conflicts only arise when both nodes write to the same file within the sync propagation window (1-10 seconds).

## How Syncthing Handles Conflicts

When the same file is modified on both nodes before sync completes:

1. Both versions are kept. the "loser" is renamed to `<filename>.sync-conflict-<date>-<time>-<modifiedBy>.<ext>`
2. The file with the **older** mtime wins (keeps the original name). equal timestamps: higher device ID loses
3. Conflict copies propagate to all devices — they're normal files after creation
4. If one side deletes and the other modifies, the modified version becomes a conflict copy if deletion wins
5. `maxConflicts` config controls how many conflict copies are retained per file (default: 10)

**What Syncthing does NOT do:** merge file contents. it's whole-file replacement. for .md files, this means one version wins entirely and the other becomes a conflict copy.

## Risk Assessment for Our Setup

| Risk level | Scenario | Likelihood |
|-----------|----------|------------|
| **None** | Agent-to-agent conflicts on Mini | N/A — same filesystem, no Syncthing involvement |
| **Low** | R10 batch job writes to reports/ while agent on Mini also writes to reports/ | Low — batch jobs are scheduled, agents write on-demand |
| **Low** | Jam edits a file on jam-mba while an agent edits the same file on Mini | Low — jam rarely edits .md files directly |
| **Medium** | Future: agents distributed across both nodes writing to same directories | Medium — this is the planned direction |
| **High** | Future: multi-node agents editing ops/ or retros/ concurrently | High if no ownership rules are in place |

## Recommendation 1: Directory Ownership Rules

Assign each shared-brain directory a **primary writer node**. The primary writer uses send-receive mode. Secondary nodes receive changes but should not write to directories they don't own.

| Directory | Primary writer | Who writes | R10 role |
|-----------|---------------|-----------|----------|
| `agents/` | Mini | relay, agents | receive-only consumer |
| `archive/` | Mini | relay | receive-only consumer |
| `assets/` | Mini | claudia, near | receive-only consumer |
| `audio/` | Mini | hum | receive-only consumer (or excluded — large files) |
| `brand/` | Mini | claudia | receive-only consumer |
| `ideas/` | Mini | any agent | receive-only consumer |
| `ops/` | Mini | relay, claude, static | receive-only consumer |
| `projects/` | Mini | claude, relay | receive-only consumer |
| `references/` | Mini | near | receive-only consumer |
| `reports/` | **Both** | Mini agents + R10 batch compute | **conflict zone** |
| `requests/` | Mini | jam, relay | receive-only consumer |
| `retros/` | Mini | all agents | receive-only consumer |

**Only `reports/` has legitimate concurrent writers on both nodes.** Everything else flows Mini → R10.

### Implementation

Syncthing doesn't support per-subdirectory folder types within a single shared folder. Two options:

**Option A (recommended): Single folder, convention-based ownership**
- Keep one `shared-brain` folder as send-receive on both nodes
- Enforce ownership by convention: R10 processes only write to `reports/r10-*` prefixed files
- Mini agents never write files with the `r10-` prefix
- Simple, no config complexity, relies on naming discipline

**Option B: Split into two Syncthing folders**
- Folder 1: `shared-brain` — send-only on Mini, receive-only on R10 (everything except reports/)
- Folder 2: `reports` — send-receive on both, with conflict handling
- More correct but adds config complexity and breaks the single-directory mental model

**Recommendation: Option A now, Option B if agents move to R10.**

## Recommendation 2: Conflict Detection

Add a cron job on both nodes that detects `.sync-conflict-*` files and alerts.

### conflict-detector.sh

```bash
#!/bin/bash
# Runs every 5 minutes via cron
# Detects Syncthing conflict files in shared-brain

SHARED_BRAIN="${1:-$HOME/shared-brain}"
CONFLICT_LOG="/tmp/syncthing-conflicts.log"
ALERT_HOOK="${2:-}"  # optional webhook/script for alerting

conflicts=$(find "$SHARED_BRAIN" -name "*.sync-conflict-*" -not -path "*/.stversions/*" 2>/dev/null)

if [ -n "$conflicts" ]; then
    count=$(echo "$conflicts" | wc -l | tr -d ' ')
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "[$timestamp] $count conflict(s) detected:" > "$CONFLICT_LOG"
    echo "$conflicts" >> "$CONFLICT_LOG"

    # alert if hook provided (relay can wire this to vigil + discord #bugs)
    if [ -n "$ALERT_HOOK" ]; then
        $ALERT_HOOK "$count syncthing conflict(s) in shared-brain" "$CONFLICT_LOG"
    fi
else
    # clear log if no conflicts
    rm -f "$CONFLICT_LOG"
fi
```

**Cron entry (both nodes):**
```
*/5 * * * * /srv/shared/bin/conflict-detector.sh ~/shared-brain /srv/shared/bin/alert-vigil.sh
```

**Integration with relay's alerting work:** relay is building the alert path to vigil + discord #bugs. conflict detection should route through the same path.

## Recommendation 3: Conflict Resolution Process

When a `.sync-conflict-*` file is detected:

### For .md files (99% of shared-brain):

1. **Automated merge attempt** — use `git merge-file --union` to combine both versions. union merge includes changes from both sides, appropriate for append-heavy .md files (retros, logs, reports)

```bash
#!/bin/bash
# resolve-conflict.sh <conflict-file>
# Attempts auto-merge for .md files, flags binary conflicts for manual review

conflict="$1"
# extract original filename from conflict pattern
original=$(echo "$conflict" | sed 's/\.sync-conflict-[0-9]*-[0-9]*-[A-Z0-9]*\./\./')

if [ ! -f "$original" ]; then
    echo "ERROR: original file not found: $original"
    exit 1
fi

ext="${original##*.}"
if [ "$ext" = "md" ] || [ "$ext" = "txt" ]; then
    # create empty base for 3-way merge
    empty=$(mktemp)
    cp "$original" "${original}.backup"

    if git merge-file --union "$original" "$empty" "$conflict"; then
        rm "$conflict" "$empty" "${original}.backup"
        echo "MERGED: $original (union merge, both versions preserved)"
    else
        mv "${original}.backup" "$original"
        rm "$empty"
        echo "MERGE FAILED: manual review needed — $original vs $conflict"
    fi
else
    echo "BINARY CONFLICT: manual review needed — $original vs $conflict"
fi
```

2. **Manual review** — if auto-merge fails or file is binary, post to #bugs with both file paths. the lane owner (per directory ownership table above) resolves

### Resolution priority:
| File type | Strategy | Escalation |
|-----------|----------|-----------|
| .md (append-heavy: retros, reports, logs) | auto-merge via union | post to #bugs if merge fails |
| .md (structured: STATUS.md, backlog) | **do not auto-merge** — notify lane owner | relay for STATUS.md, claude for backlog |
| .json (configs) | do not auto-merge — last writer wins is dangerous | notify claude |
| binary (images, audio) | keep both, notify lane owner | claudia for images, hum for audio |

### Files to exclude from auto-merge (add to allowlist):
- `STATUS.md` — single source of truth, relay owns
- `ops/agent-cycle-config.json` — config file, claude owns
- `ops/consolidated-backlog.md` — structured backlog, relay owns

## Recommendation 4: Syncthing Configuration

Apply these settings on both nodes:

```xml
<!-- shared-brain folder config -->
<folder id="shared-brain" label="shared-brain" type="sendreceive">
    <maxConflicts>3</maxConflicts>           <!-- reduced from default 10. 3 is enough for .md files -->
    <fsWatcherEnabled>true</fsWatcherEnabled>
    <fsWatcherDelayS>1</fsWatcherDelayS>     <!-- fast propagation reduces conflict window -->
    <copyOwnershipFromParent>true</copyOwnershipFromParent>  <!-- unix only, preserves tenant ownership on R10 -->
</folder>
```

**File versioning:** enable trash can versioning with 7-day retention. this gives a recovery window for accidental overwrites without accumulating indefinitely.

```xml
<versioning type="trashcan">
    <param key="cleanoutDays" val="7"/>
</versioning>
```

**inotify limits on R10** (add to first-boot.sh):
```bash
echo "fs.inotify.max_user_watches=65536" | sudo tee -a /etc/sysctl.d/90-syncthing.conf
sudo sysctl -p /etc/sysctl.d/90-syncthing.conf
```

## Recommendation 5: Future-Proofing for Multi-Node Agents

When agents move to R10:

1. **Switch to Option B** — split shared-brain into per-directory Syncthing folders with explicit send/receive roles
2. **Agent write locks** — before writing, agent creates a `.lock` file. other agents on the other node check for locks before writing to the same file. not bulletproof (lock itself could conflict) but reduces the window
3. **Per-agent write directories** — each agent gets a subdirectory (`retros/session13-near.md` already follows this pattern). enforce the convention: agents only create files with their name in the filename
4. **Conflict alerting in vigil** — add a conflict count to the node health API response so vigil displays it in real-time

## Summary

| Item | Recommendation | Priority |
|------|---------------|----------|
| Directory ownership | Convention-based: Mini writes everything, R10 only writes `reports/r10-*` | **now** |
| Conflict detection | 5-minute cron on both nodes, alerts to vigil + #bugs | **now** (pair with relay's alerting) |
| Auto-resolution | Union merge for append-heavy .md files, manual for everything else | now |
| Syncthing config | maxConflicts=3, fsWatcherDelayS=1, trashcan versioning 7d, inotify limits | **now** (add to first-boot.sh) |
| Structured file protection | Exclude STATUS.md, backlog, configs from auto-merge | now |
| Split folders | Only if/when agents move to R10 | later |
| Agent write locks | Only if/when agents move to R10 | later |

## Sources

- [Syncthing: Understanding Synchronization](https://docs.syncthing.net/users/syncing.html)
- [Syncthing: Folder Types](https://docs.syncthing.net/users/foldertypes.html)
- [Syncthing: Configuration Reference](https://docs.syncthing.net/users/config.html)
- [Conflict-Free Syncthing Notes (2025)](https://blog.mavnn.eu/2025/08/15/conflict_free_syncthing_notes.html) — union merge approach
- [syncthing-resolve-conflicts (GitHub)](https://github.com/dschrempf/syncthing-resolve-conflicts) — interactive conflict resolution script
- [Syncthing Community: Conflict Resolution](https://forum.syncthing.net/t/how-does-conflict-resolution-work/15113)
