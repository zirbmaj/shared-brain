---
title: AI landscape scan — scope and source list
date: 2026-03-24
type: reference
scope: shared
summary: scope, categories, and source list for near's first AI landscape scan (session 10-15). covers what to research, what's already known, and how findings get routed.
---

# AI Landscape Scan — Scope & Source List

*Near + Claude collaboration. Discussion in near+claude 1:1 channel. Actionable findings routed to lane owners.*
*First scan: session 10-15. Recurring every 10-20 sessions after that.*

## What This Scan Covers

The scan answers one question: **what exists now that could make the team better, and is it worth adopting?**

Not a general AI news roundup. Focused on tools, models, frameworks, and patterns that are directly relevant to how Nowhere Labs builds, ships, and operates.

## Categories

### 1. Models & APIs
What's changed in the foundation model landscape since the team started building (2026-03-22).

**Questions to answer:**
- new model releases from Anthropic, OpenAI, Google, Meta, Mistral
- capability changes relevant to our workloads (code generation, web browsing, image generation, audio)
- pricing changes that affect our cost structure
- new API features (tool use improvements, context window changes, structured output)

**Already known:** team runs on Claude Code (Anthropic). No other model providers in active use. Image generation via DALL-E when available.

**Route findings to:** Claude (engineering decisions), Jam (cost/provider decisions)

### 2. Agent Frameworks & Orchestration
Multi-agent patterns that could improve how 6 agents coordinate.

**Questions to answer:**
- new releases or major updates to: CrewAI, MetaGPT, LangGraph, AutoGen, Swarm, Claude Agent SDK
- production adoption signals (not just GitHub stars — actual usage reports)
- patterns for agent-to-agent communication, shared memory, task delegation
- anything that addresses our known gaps: duplicate work prevention, context handoff between sessions, cross-agent state awareness

**Already known (session 9 research):**
- Paperclip heartbeat model for orchestration
- GitAgent for personality versioning with inheritance
- hierarchical scoped memory > flat storage (30-40% retrieval accuracy gain)
- 500-word behavioral rule carrying capacity limit
- SKILL.md emergence as modular skill standard

**Route findings to:** Claude (implementation), Relay (process implications)

### 3. Developer Tooling
Tools that could improve individual agent productivity or team workflow.

**Questions to answer:**
- Claude Code updates (new features, MCP server ecosystem, hooks improvements)
- code generation / review tooling improvements
- testing automation advances (visual regression, accessibility, cross-browser)
- deployment and CI/CD tools relevant to Vercel + GitHub workflow
- browser automation beyond Playwright

**Already known:** team uses Claude Code, Playwright, GitHub, Vercel, Supabase, Discord bots. Tooling gaps identified session 9: browser-sync (Claudia), CDP audio capture (Hum), deploy webhooks (Static).

**Route findings to:** relevant lane owner based on tool category

### 4. Audio & Creative AI
Advances in AI-generated audio, music, sound design — relevant to Drift, Static FM, Hum's audio pipeline.

**Questions to answer:**
- text-to-audio / text-to-music model updates (Suno, Udio, Stable Audio, etc.)
- audio quality improvements that could enhance Drift's sound library
- real-time audio processing in browsers (Web Audio API advances)
- TTS improvements relevant to Static FM DJ intros

**Already known:** Drift uses real MP3 samples, not AI-generated audio. Static FM DJ intros are AI-generated. Hum built a two-layer audio capture pipeline (session 9).

**Route findings to:** Hum (audio decisions), Claude (implementation if adopted)

### 5. Community & Growth Tools
Tools that could amplify PH launch and post-launch growth.

**Questions to answer:**
- PH launch optimization tools or services
- community analytics beyond what Supabase provides
- social media automation for X content queue
- user feedback collection tools
- SEO/ASO tools for web app discovery

**Already known:** analytics pipeline is custom (Supabase + track.js). X content queue is manual markdown. No social API keys yet.

**Route findings to:** Claudia (community/brand), Relay (process), Jam (tool purchases)

### 6. Competitive Landscape Shifts
Changes in the ambient audio / focus tool market since the competitive analysis (2026-03-23).

**Questions to answer:**
- new product launches in the space
- pricing changes from Brain.fm, Noisli, Endel, myNoise
- Moodist growth trajectory (identified as rising competitor)
- any PH launches in the ambient/focus category in the last 30 days

**Already known:** full competitive matrix in shared-brain/projects/competitive-analysis.md

**Route findings to:** team via #dev (if urgent), otherwise synthesis in 1:1

## Source List

### Primary (check every scan)
- Anthropic blog + changelog
- OpenAI blog + changelog
- Google AI blog (Gemini updates)
- GitHub trending (weekly, filtered by AI/agent tags)
- Hacker News front page + "Show HN" (AI tools)
- Product Hunt (AI category, last 30 days)
- r/LocalLLaMA, r/MachineLearning, r/ClaudeAI (top posts, last 30 days)

### Secondary (check if time allows)
- arXiv cs.AI (top papers by citation velocity)
- LangChain blog + changelog
- CrewAI releases
- Vercel blog (infrastructure updates)
- Supabase blog (database/edge function updates)
- Web Audio API spec changes (W3C)

### Competitor-specific
- Brain.fm blog/changelog
- Noisli updates page
- Endel press/blog
- Moodist GitHub releases
- PH ambient/focus category (new launches)

## Output Format

The scan produces one document: `shared-brain/references/ai-landscape-scan-session-[N].md`

Structure:
1. **Executive summary** — 3-5 bullets of what matters most
2. **Category findings** — one section per category above, each with: what's new, relevance to us, recommendation (adopt / monitor / ignore)
3. **Action items** — specific things to route to specific agents
4. **Next scan** — what to watch for in the next 10-20 sessions

## What This Scan Does NOT Cover

- General AI news or hype cycles
- Tools with no production signals (papers-only, demo-only)
- Anything already documented in the existing research files
- Speculative future capabilities ("GPT-5 might...")
- Tools that would require infrastructure changes we can't make (e.g., switching off Mac Mini)

## Pre-Scan Checklist (run before each scan)

1. Read the previous scan output (if exists)
2. Read shared-brain/projects/competitive-analysis.md for current baseline
3. Check what session we're on and what's shipped since last scan
4. Note any specific questions from the team (check #dev and 1:1 channels)
5. Confirm with Claude that the 1:1 channel is available for discussion
