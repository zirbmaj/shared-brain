# Linux Server Distribution Comparison — Headless Always-On Server
*Near — 2026-03-27. Alienware R10 repurpose: Docker, Ollama (local LLM), PostgreSQL, Home Assistant.*

---

TOPIC: linux server distro comparison — Ubuntu Server 24.04 LTS vs Debian 12 vs Rocky Linux 9
DATE: 2026-03-27
CONFIDENCE: high
SOURCES: knowledge-based (established distro documentation, release notes, ROCm compatibility matrices)

---

## Hardware Profile

- machine: Alienware Aurora R10 (~2021)
- cpu: AMD Ryzen (exact SKU TBD — likely Ryzen 7 3700X or 5800X)
- ram: 32GB DDR4
- gpu: AMD Radeon RX 5700 XT (8GB VRAM, RDNA1, gfx1010)
- storage: 1TB HDD + 1TB SSD
- use: headless, always-on, no monitor attached
- network: ethernet (assumed gigabit)

## Workload

- docker containers (multiple)
- ollama — local LLM inference (GPU-accelerated if possible)
- postgresql — persistent database
- home assistant — potential future addition
- no desktop environment needed

---

## Comparison Matrix

| Metric | Ubuntu Server 24.04 LTS | Debian 12 (Bookworm) | Rocky Linux 9 |
|--------|------------------------|----------------------|---------------|
| **Base** | Debian-derived | the original | RHEL clone (CentOS successor) |
| **Kernel at release** | 6.8 | 6.1 | 5.14 |
| **Package manager** | apt/dpkg | apt/dpkg | dnf/rpm |
| **Init system** | systemd | systemd | systemd |
| **Default filesystem** | ext4 | ext4 | xfs |
| **Release date** | April 2024 | June 2023 | May 2022 |
| **EOL (standard)** | April 2029 (5 yr) | June 2028 (5 yr) | May 2032 (10 yr) |
| **EOL (extended/ESM)** | April 2036 (12 yr with Ubuntu Pro, free for 5 machines) | June 2028 (LTS only, no official extended) | May 2032 (full support to 2027, maintenance to 2032) |
| **ISO size** | ~2.6 GB (live server) | ~650 MB (netinst) / ~3.7 GB (DVD) | ~1.8 GB (minimal) / ~10 GB (DVD) |
| **Installer** | Subiquity (guided, modern) | Debian Installer (text-mode, more steps) | Anaconda (Red Hat installer, GUI-capable) |
| **Snap packages** | yes (pre-installed snapd) | no (available but not default) | no |
| **SELinux** | available, not default (uses AppArmor) | available, not default | enforcing by default |
| **Firewall** | ufw (simple) | nftables/iptables (manual) | firewalld |

---

## Scored Comparison

Scoring: 1-5 scale. Higher = better fit for this specific use case (headless always-on server, Docker + Ollama + PostgreSQL + Home Assistant, AMD GPU, remote-guided install).

| Criterion | Ubuntu Server 24.04 | Debian 12 | Rocky Linux 9 | Notes |
|-----------|:-------------------:|:---------:|:-------------:|-------|
| **Stability** | 4 | 5 | 5 | Debian and Rocky are more conservative. Ubuntu LTS is stable but occasionally ships regression-prone kernel updates via HWE. |
| **LTS support length** | 5 | 3 | 5 | Ubuntu: 12 yr with Pro (free tier). Rocky: 10 yr. Debian: 5 yr only, no official extended support. |
| **Docker support** | 5 | 4 | 4 | Docker's official apt repo targets Ubuntu first. Install docs use Ubuntu as primary example. Debian and Rocky both have official Docker repos but Ubuntu gets same-day support for new releases. |
| **AMD GPU / ROCm** | 4 | 3 | 3 | ROCm officially packages for Ubuntu (22.04/24.04) and RHEL 9. RX 5700 XT (gfx1010) is NOT in AMD's official support matrix regardless of distro — community workarounds (HSA_OVERRIDE_GFX_VERSION=10.3.0) exist on all three. Ubuntu has the most community documentation for this. Debian requires manual ROCm install. Rocky uses the RHEL packages but community guides are fewer. |
| **Headless management** | 5 | 5 | 5 | all three are excellent headless. SSH works identically. Ubuntu includes cloud-init by default. Cockpit available on all three (ships default on Rocky). |
| **Package ecosystem** | 5 | 4 | 3 | Ubuntu: largest .deb ecosystem, PPAs for bleeding-edge packages. Debian: broad but older versions. Rocky: RHEL ecosystem is smaller, EPEL helps but still fewer packages than Debian/Ubuntu repos. |
| **Community/docs** | 5 | 4 | 3 | Ubuntu: most tutorials, largest community, Ask Ubuntu, extensive official docs. Debian: excellent docs (Debian Handbook, wiki) but assumes more Linux knowledge. Rocky: growing community, good docs, but smaller than Ubuntu/Debian. Fewer "how to do X on Rocky" guides. |
| **Remote-guided install ease** | 5 | 3 | 4 | Ubuntu Subiquity: fewest questions, sane defaults, straightforward for someone being guided over Discord/call. Debian: text installer with more decision points (mirror selection, tasksel, etc.) — not hard but more steps to guide someone through. Rocky Anaconda: reasonable with minimal install option. |
| **TOTAL** | **38** | **31** | **32** | out of 40 |

---

## AMD GPU Detail — ROCm + RX 5700 XT (gfx1010/RDNA1)

this is the most important caveat in the comparison.

### current state (as of early 2026)
- AMD's official ROCm support matrix lists: gfx900 (Vega), gfx906 (MI50/Radeon VII), gfx908 (MI100), gfx90a (MI210), gfx1030 (RDNA2: 6800/6900 XT), gfx1100 (RDNA3: 7900 XTX)
- gfx1010 (RX 5700 XT, RDNA1) is NOT officially supported
- community workaround: set `HSA_OVERRIDE_GFX_VERSION=10.3.0` to trick ROCm into treating it as RDNA2
- this works for ollama inference on many models but is not guaranteed stable for all workloads
- some users report memory allocation issues on 8GB VRAM with larger models

### distro impact
- Ubuntu 22.04/24.04: AMD publishes official ROCm .deb packages. most community guides target Ubuntu. ollama's ROCm integration is tested primarily on Ubuntu
- Debian 12: no official ROCm packages from AMD. must use the Ubuntu packages (they often work) or build from source. adds friction
- Rocky Linux 9: AMD publishes official ROCm RPM packages for RHEL 9. Rocky uses these directly. second-best option after Ubuntu

### upgrade path
- if the GPU is later upgraded to RDNA2 (e.g., RX 6700 XT / 6800 XT) or RDNA3, all three distros gain official ROCm support
- Ubuntu and Rocky are best positioned for this since both receive official ROCm packages

---

## Workload-Specific Notes

### Docker
- all three: official Docker CE repo available, install is 3-4 commands
- Ubuntu: `apt install docker-ce` from Docker's repo. zero friction
- Debian: same process as Ubuntu, same repo structure
- Rocky: `dnf install docker-ce` from Docker's repo. SELinux may require `--selinux-enabled` container daemon flag or policy adjustments. manageable but an extra step

### Ollama
- ships as a single binary or Docker container on all three
- GPU acceleration requires ROCm — see GPU section above
- CPU-only inference works identically on all three (AVX2 support on Ryzen)
- 32GB RAM allows running 7B-13B parameter models comfortably, 30B+ with quantization

### PostgreSQL
- Ubuntu 24.04: ships PostgreSQL 16 in default repos. PGDG repo available for newer versions
- Debian 12: ships PostgreSQL 15. PGDG repo available
- Rocky 9: ships PostgreSQL 13 in default repos (older). PGDG repo available for newer versions
- recommendation: use PGDG official repo on any distro for consistent versioning

### Home Assistant
- recommended deployment: Home Assistant OS in a VM, or Home Assistant Container via Docker
- Docker container method works identically on all three distros
- no distro advantage here — it's a Docker container either way

---

## Installation Walkthrough Complexity

the human owner will boot from USB and run the installer while the team guides remotely. this matters.

| Step | Ubuntu Server | Debian 12 | Rocky 9 |
|------|--------------|-----------|---------|
| USB creation | Balena Etcher or Rufus — standard | same | same |
| Boot to installer | auto-starts Subiquity | auto-starts text installer | auto-starts Anaconda |
| Language/keyboard | 1 screen | 1 screen | 1 screen |
| Network | auto-detects ethernet | auto-detects, may ask | auto-detects |
| Disk partitioning | guided "use entire disk" — 1 click | guided option available but presents more choices | guided "automatic" option available |
| User creation | 1 screen (username + password) | 2 screens (root password + user) | 1 screen (root + user on same page) |
| Mirror selection | auto-selected | must choose country + mirror (confusing for non-Linux users) | auto-selected |
| Package selection | minimal by default, add OpenSSH with checkbox | tasksel screen with multiple options (can overwhelm) | minimal install option, straightforward |
| Install time | ~5-10 min on SSD | ~5-10 min | ~5-10 min |
| First boot SSH | ready immediately | ready if selected during install | ready immediately |
| Total guided decisions | ~6 screens | ~10-12 screens | ~7-8 screens |

---

## Risks and Caveats

- RX 5700 XT ROCm support is unofficial on ALL three distros. GPU-accelerated LLM inference may break on ROCm version updates. CPU-only inference is the safe fallback
- Ubuntu's snap system adds overhead (snapd daemon runs background processes). can be removed but it's an extra step
- Rocky's SELinux-enforcing default can block Docker volume mounts and other operations if not configured correctly. not a dealbreaker but requires awareness during setup
- Debian 12's kernel (6.1) is older — some newer hardware features may require backports. not likely an issue for 2021 hardware
- 1TB HDD + 1TB SSD: recommend installing OS + Docker on SSD, using HDD for bulk storage/backups. partitioning strategy should be planned before install
- 32GB RAM is sufficient for current workloads but local LLM inference is RAM-hungry. running multiple 13B+ models simultaneously will hit limits

---

## Recommendation

**Ubuntu Server 24.04 LTS.**

reasoning:
1. best ROCm community support for the unofficial gfx1010 workaround, and first to receive official ROCm packages when GPU is upgraded
2. simplest installer for remote-guided setup — fewest screens, fewest decisions, least likely to confuse someone unfamiliar with Linux
3. longest effective support window (12 years with Ubuntu Pro free tier)
4. Docker is a first-class citizen — official Docker docs use Ubuntu as the reference platform
5. largest package ecosystem and community — every "how do I do X on Linux" guide has an Ubuntu answer
6. ollama's documentation and testing prioritizes Ubuntu

the 7-point gap over Debian is driven primarily by: ROCm packaging (+1), install ease (+2), LTS length (+2), package breadth (+1), community docs (+1). if ROCm/GPU were irrelevant and the installer were operated by an experienced Linux user, Debian would close to within 2-3 points.

Rocky would be the pick for a pure enterprise server with no GPU workloads and a 10-year maintenance window. the RHEL ecosystem's conservatism is a strength for stability but a weakness for bleeding-edge AI/ML tooling.

### post-install checklist (for the team to guide)
1. boot from USB, run Ubuntu Server installer with "use entire disk" on SSD
2. SSH in from team machine
3. install Docker CE from official repo
4. install ollama (curl-based installer or Docker)
5. set up ROCm with `HSA_OVERRIDE_GFX_VERSION=10.3.0` if GPU acceleration desired
6. install PostgreSQL via Docker or PGDG repo
7. configure unattended-upgrades for security patches
8. set up UFW firewall rules
9. configure static IP or DHCP reservation on router
10. optional: install Cockpit for web-based server management

---

## Storage Layout Recommendation

| Device | Mount | Use |
|--------|-------|-----|
| 1TB SSD | `/` (root, 100GB), `/var/lib/docker` (remaining ~800GB) | OS, Docker images/containers, PostgreSQL data, Ollama models |
| 1TB HDD | `/mnt/storage` | backups, media, bulk data, logs rotation target |

rationale: Docker and LLM models benefit from SSD speed. HDD handles cold storage. keep OS partition modest — 100GB is generous for a headless server.
