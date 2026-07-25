# Mesh Networking Comparison — Tailscale vs ZeroTier
*Near — 2026-03-27. Homelab cluster: Mac Mini (macOS) + Alienware R10 (Ubuntu Server) + remote access from MacBook Air + iPhone.*

---

## hardware context

- node 1: Mac Mini (macOS, always-on, 6 AI agents)
- node 2: Alienware R10 (Ubuntu Server, compute node)
- remote: MacBook Air (macOS) + iPhone (iOS)
- network: unmanaged switches, same LAN, no VLANs
- traffic: HTTP APIs (Ollama, PostgreSQL), shared filesystem, SSH

---

## comparison matrix

| criteria | Tailscale | ZeroTier |
|---|---|---|
| **setup time (4 devices)** | ~15 min | ~20 min |
| **macOS headless** | yes, brew + CLI | yes, brew + CLI |
| **Linux headless** | yes, systemd, auth key for unattended | yes, systemd, manual auth per device |
| **iOS app** | polished, fast connect | functional |
| **auth model** | SSO (Google/GitHub/Apple) | device-based approval in console |
| **encryption** | WireGuard (ChaCha20-Poly1305) | Salsa20/Poly1305 |
| **ACLs** | JSON policy file, straightforward | flow rules, more granular but complex |
| **NAT traversal** | >92% direct, DERP relay fallback | UDP hole punch, root relay fallback |
| **LAN performance** | near wire speed (kernel WireGuard on Linux) | near wire speed (userspace only) |
| **free device limit** | 100 | 25 |
| **free user limit** | 3 | 1 |
| **DNS** | MagicDNS built-in | manual setup required |
| **SSH integration** | Tailscale SSH (keyless, identity-based) | none |
| **TLS certs** | built-in via `tailscale cert` | none |
| **self-hostable** | yes (Headscale, open source) | fully self-hostable |
| **unattended auth** | auth keys, no-expiry option | API call to authorize |
| **file sharing** | Taildrop | none built-in |

---

## other alternatives considered

- **Nebula (Slack/Defined Networking):** strong security, fully self-hosted, but no iOS app. eliminated
- **Netmaker:** WireGuard-based with management dashboard, but overkill for 4 devices. worth revisiting at 10+ devices
- **Raw WireGuard:** maximum performance, minimum convenience. no NAT traversal, no peer discovery, all manual config. only if avoiding all third-party dependencies is a requirement

---

## recommendation: Tailscale

1. **fastest path to working setup.** install, `tailscale up`, done. auth keys enable fully unattended Linux server operation
2. **MagicDNS eliminates IP management.** agents call `http://alienware:11434` (Ollama) instead of hardcoded IPs. ZeroTier requires manual DNS
3. **better Linux performance.** WireGuard kernel module on Linux vs ZeroTier's userspace-only implementation
4. **SSO auth is simpler.** sign in with Google/GitHub on all devices. no separate credential system
5. **free tier is generous.** 100 devices vs 25
6. **Tailscale SSH.** SSH into R10 from iPhone without managing keys
7. **LAN detection is reliable.** same-subnet traffic stays local, no relay overhead

ZeroTier's advantages (virtual L2 networking, self-hosting, granular flow rules) are not relevant for this 4-device, single-operator, API-traffic setup.

---

## setup notes

### R10 (Ubuntu Server — headless)
```
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable tailscaled
sudo systemctl start tailscaled
sudo tailscale up --hostname=alienware --authkey=<pre-auth-key>
```
generate auth key at login.tailscale.com > Settings > Keys. set reusable + no expiry.

### Mac Mini
```
brew install tailscale
sudo tailscaled &
tailscale up --hostname=mac-mini
```

### verification
```
tailscale status                          # all 4 devices visible
tailscale ping alienware                  # confirm direct, not relayed
curl http://alienware:11434/api/tags      # test Ollama from Mac Mini
```

### recommended ACLs
- Mac Mini → R10: ports 11434 (Ollama), 5432 (PostgreSQL), 22 (SSH)
- iPhone/MacBook → both machines: port 22 (SSH) + management ports
- R10: no outbound restrictions needed (serves, doesn't initiate)
