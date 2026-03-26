---
title: Mission Control — Existing Tools Research
date: 2026-03-25
type: research
author: near
scope: mission control dashboard
---

# Mission Control — Fork Candidates & Architecture Research

## Requirements
1. Live terminal streaming (6+ agent terminals in web browser)
2. Usage/cost metrics dashboard (API tokens, session duration, plan limits)
3. Simple task checklist (done/not done, no kanban)
4. Chat panel (jam talks to relay from dashboard)

## Recommended Architecture: Composite Approach

| Requirement | Tool | Coverage |
|------------|------|----------|
| Terminal streaming | ttyd (6 instances, iframe grid) | 100% |
| Usage/cost metrics | Fork disler/claude-code-hooks-multi-agent-observability | 85% |
| Task checklist | Custom (sqlite + vue component) | ~2hrs build |
| Chat panel | widgetbot embed or custom discord webhook | 70-90% |

## Recommended Fork Base

**disler/claude-code-hooks-multi-agent-observability**
- GitHub: https://github.com/disler/claude-code-hooks-multi-agent-observability
- Stack: Bun server, SQLite, Vue.js, WebSocket push
- Why: built for claude code multi-agent, tmux-aware, lightweight
- Customization: ~40%. Add ttyd iframes, strip kanban→checklist, add chat panel

## Alternative Fork Bases

**builderz-labs/mission-control**
- GitHub: https://github.com/builderz-labs/mission-control
- Stars: 3,306 | License: MIT
- Stack: Node.js, SQLite, SPA, WebSocket + SSE
- 101 REST endpoints, role-based access, zero external deps
- More mature but heavier abstraction. Good API-first backend

**hoangsonww/Claude-Code-Agent-Monitor**
- GitHub: https://github.com/hoangsonww/Claude-Code-Agent-Monitor
- Stack: Node.js, Express, React, WebSockets, SQLite
- Real-time monitoring via hooks, session tracking, mobile-friendly
- React alternative if team prefers react over vue

## Terminal Streaming Tools

**ttyd** (recommended)
- GitHub: https://github.com/tsl0922/ttyd
- Stars: 11,268 | License: MIT
- C + libwebsockets + xterm.js
- Run 6 instances on ports 7681-7686, embed as iframes

**gotty**
- GitHub: https://github.com/yudai/gotty (19,437 stars)
- Maintained fork: https://github.com/sorenisanerd/gotty
- Go + xterm.js. Effectively legacy — ttyd is better maintained

**sshwifty**
- GitHub: https://github.com/nirui/sshwifty
- Built-in multi-session UI (no iframe grid needed)
- AGPL license — restrictive

## Chat Integration

**widgetbot**
- URL: https://widgetbot.io
- GitHub: https://github.com/widgetbot-io
- License: GPL-3.0
- Pixel-perfect discord embed as iframe/react component
- Near-zero customization for read-only view

## Observability Platforms (overkill, reference only)

**langfuse** — 23,739 stars, industry standard LLM observability. Use SDK to pipe data in, don't fork
**RagaAI-Catalyst** — 16,116 stars, Apache-2.0, Python. Wrong stack for web dashboard

## Build Estimate

MVP: 2-3 sessions focused work
- Fork disler's project as base
- Add CSS grid with 6 ttyd iframe panels
- Strip kanban → flat checklist
- Embed widgetbot or build minimal discord message sender
- Style with NWL design language (claudia)
- Add notification sounds (hum)
