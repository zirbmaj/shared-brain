---
title: tooling gap solutions — local preview + headless audio + vercel webhooks
date: 2026-03-24
type: research
scope: shared
owner: near
summary: solutions for claudia's local CSS preview, hum's headless audio capture, and static's deploy webhooks. one-command solutions where possible.
confidence: high
audience: [claudia, hum, static, claude]
---

# tooling gap solutions

research for the four tooling gaps from the session 8 team check-ins.

---

## 1. claudia's local CSS preview

**problem:** pushes to branch, waits for deploy, screenshots. burns deploy credits. shared nav loads from production URL, so file:// previews break.

### recommendation: browser-sync proxy (one command)

```bash
cd ~/claudia-workspace/ambient-mixer
npx browser-sync start --proxy "https://drift.nowherelabs.dev" --serveStatic "." --files "**/*.css"
```

**what this does:**
- proxies the live production site through localhost
- overrides with local files when they exist at the same path
- hot-reloads CSS changes instantly (no page refresh)
- shared nav loads from production through the proxy — no CORS issues

**setup:** zero. npx downloads it on first run. one command per product.

**alternatives considered:**

| approach | solves nav? | auto-reload? | complexity |
|----------|:-:|:-:|:-:|
| npx serve (static file server) | only if CORS allows | no | 1 |
| caddy reverse proxy | yes (if relative paths) | no | 3 |
| vercel dev | yes (if vercel.json rewrites) | no | 2 |
| **browser-sync proxy** | **yes** | **yes** | **1** |

browser-sync proxy is the clear winner — one command, solves both problems.

---

## 2. hum's headless audio capture

**problem:** can read code and reason about spectral content, but can't hear output. every signoff is "the code looks right" not "i listened and it's clean."

### recommendation: two-layer strategy

**layer 1 (always run): CDP metadata + parameter polling**
- `WebAudio.enable` via CDP gives full audio graph topology
- poll GainNode.gain.value at intervals to verify crossfade curves
- verify AudioContext state, node connections, channel counts
- catches 70-80% of audio bugs (wrong connections, wrong volume, context not started)
- zero dependencies, works in playwright, fast

**layer 2 (when actual audio needed): in-page script injection**
- inject AudioWorklet via `page.evaluateOnNewDocument()` before page creates AudioContext
- monkey-patch `AudioContext.prototype` to insert capture node before destination
- capture 5-10s of PCM samples, return as base64 to Node.js
- analyze: RMS levels (is audio playing?), peak detection (clipping?), spectral centroid (right frequency range?), zero-crossing rate (noise vs tone vs silence)
- optionally write to WAV (44-byte header + PCM data)

| approach | actual audio? | metadata? | complexity | macOS? |
|----------|:-:|:-:|:-:|:-:|
| CDP WebAudio domain | no | yes | 1 | yes |
| **script injection + AudioWorklet** | **yes** | **yes** | **3** | **yes** |
| virtual audio sink (BlackHole + ffmpeg) | yes | no | 4 | partial (system-wide capture) |
| playwright video recording | no | no | - | - |

**skip approach 3** (virtual sink) — captures all system audio, not app-specific. noisy on macOS.
**skip approach 5** (playwright video) — no audio recording capability.

**what hum gets:**
- layer 1: "AudioContext running, 17 nodes connected, master gain 0.85, crossfade gain ramping from 1.0 to 0.0 over 300ms" — structural verification
- layer 2: actual WAV file. run through ffmpeg for spectrogram, or analyze in Node.js for RMS/peak/spectral. "rain layer at 50% shows expected 800Hz bandpass with -12dB rolloff. no clicks detected at loop boundary."

**implementation:** claude builds the playwright integration. hum writes the analysis pipeline (what to look for in each product's audio).

---

## 3. static's deploy status webhook

**problem:** no way to know when deploys land. polls live sites manually.

### recommendation: vercel deploy webhook → discord

vercel supports outgoing webhooks on deploy events. setup:

1. vercel dashboard → project settings → git → deploy hooks (for triggering)
2. vercel dashboard → account settings → webhooks (for notifications)
3. point webhook URL at a discord webhook endpoint
4. format: `deployment.created`, `deployment.succeeded`, `deployment.failed`, `deployment.error`

**alternative:** vercel CLI `vercel ls --meta` shows recent deployments. a cron job polling this every 2 minutes and posting changes to #dev would work without vercel pro.

**simplest path:** jam creates a vercel webhook pointing to a discord webhook URL in #dev. takes 2 minutes in the dashboard. no code needed.

---

## 4. near's research triggers (self-assignment)

**problem:** research queue is reactive. highest-value work was proactive but there's no clear signal for when to self-initiate.

### standing permission triggers

near may self-assign research when any of these occur:
1. **competitor launch:** a product in our category (ambient, focus, radio) launches or updates on PH, HN, or reddit
2. **analytics anomaly:** traffic/conversion changes >20% from baseline without a known cause
3. **team question without data:** someone asks "should we..." or "how do others..." in #dev
4. **pre-launch window:** T-7 to launch, proactive competitive/positioning research
5. **AI landscape shift:** new model release, new tool launch, new framework that could affect our stack

**protocol:** post "self-assigning: [topic], ~[time estimate]" in #dev before starting. if no objection in 2 minutes, proceed.

---

## priority for implementation

1. **claudia's browser-sync** — one command, zero setup, immediate value. claudia can start using it today
2. **vercel webhook** — 2-minute setup in dashboard. jam does this once
3. **hum's audio capture layer 1** (CDP metadata) — claude builds into playwright suite, 1-2 hours
4. **hum's audio capture layer 2** (actual audio) — claude + hum collaborate, half session
5. **near's trigger list** — process decision, no code needed
