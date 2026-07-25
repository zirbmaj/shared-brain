# Shared Storage Comparison — Mac Mini + Linux
*Near — 2026-03-27. shared-brain (~500 .md files) accessible from both nodes.*

---

## the question, restated

unidirectional-primary, occasionally-bidirectional file sync for ~500 small text files between macOS (source of truth) and Ubuntu Server (consumer), both on LAN and Tailscale.

---

## comparison matrix

| criteria | NFS | SMB/CIFS | Syncthing | rsync (cron) | Git-based |
|---|---|---|---|---|---|
| **latency** | ~0ms (network fs) | ~0ms (network fs) | 1-10s (fs watcher) | cron interval (1-5 min) | manual/scripted |
| **network resilience** | processes hang on disconnect | processes hang on disconnect | graceful — local copy, resync on reconnect | next run catches up | next push/pull catches up |
| **conflict handling** | none, last writer wins | basic oplocks | .sync-conflict copies, no data loss | last rsync wins | explicit merge conflicts |
| **setup complexity** | moderate (exports, fstab, UID mapping) | moderate (SMB sharing, cifs-utils) | low-moderate (install, pair, configure) | low (ssh keys + cron) | low-moderate (hooks/cron) |
| **small text file performance** | good | adequate (chattier protocol) | good (delta sync) | excellent (delta + compression) | good |
| **security (default)** | NFSv3: IP-based only | SMB3: encryption + signing | TLS 1.3, device auth | SSH encryption + keys | SSH transport |
| **headless** | fully | mostly (macOS SMB config easier via GUI) | fully | fully | fully |
| **resource overhead** | minimal (kernel) | moderate (smbd) | moderate (~50MB RAM) | near zero (runs on trigger) | low |
| **bidirectional writes** | yes (both read/write mount) | yes | yes (with conflict detection) | requires wrapper (unison) | yes (with merge) |

---

## recommendation: Syncthing

for mac mini as source of truth, R10 as near-real-time reader, occasional R10 writes:

1. **network resilience is critical.** NFS/SMB cause R10 processes to hang when the network blips. syncthing degrades gracefully — R10 has a full local copy and keeps working with slightly stale data (1-10 seconds behind)
2. **conflict safety.** `.sync-conflict` files prevent silent data loss. for a shared knowledge base powering 6 AI agents, losing a research output to silent overwrite is worse than resolving a conflict file
3. **1-10 second latency is acceptable.** agents reading .md files don't need sub-millisecond access
4. **security by default.** TLS 1.3 + device authentication without additional configuration
5. **50MB RAM overhead is negligible** on both machines

### lightweight alternative: rsync + fswatch

if syncthing feels heavy for ~500 text files:
```
fswatch -o /path/to/shared-brain | xargs -n1 -I{} rsync -az --delete /path/to/shared-brain/ user@r10:/path/to/shared-brain/
```
near-real-time push, zero persistent overhead beyond fswatch process. tradeoff: no bidirectional sync, no conflict detection, R10 processes fail if network is down.

### what to avoid

- **NFS/SMB** — hard network dependency. when the network blips, every R10 process reading shared-brain blocks or errors. unacceptable for a compute node running services
- **Git-based** — using version control as sync creates noisy auto-commits and merge conflicts in automation. files are already in git for version control. sync should be a separate concern

---

## setup path

### Mac Mini (macOS)
```
brew install syncthing
brew services start syncthing
```
configure shared-brain folder, set `fsWatcherEnabled: true`, `fsWatcherDelayS: 1`

### R10 (Ubuntu Server)
```
apt install syncthing
systemctl enable --now syncthing@<user>
```
pair devices using device IDs, accept shared folder.

### bidirectional convention
- R10 writes only to designated subdirectories (e.g., `shared-brain/research-outputs/`)
- Mac Mini agents write everywhere else
- avoids conflicts without technical enforcement

### monitoring
syncthing REST API on `localhost:8384` — query sync status, alert on errors via lightweight cron script.
