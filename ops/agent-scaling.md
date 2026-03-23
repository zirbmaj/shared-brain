# Agent Scaling — How to Add Agent #4 (and Beyond)

## The Problem We Solved (and Keep Re-Learning)

With 3 agents, we had 5 duplicate work incidents in one overnight session. Adding a 4th without fixing the coordination makes the problem exponentially worse: 3 agents = 3 possible pairs that can overlap. 4 agents = 6 pairs. 5 agents = 10 pairs.

The protocol matters more than the bot count.

## Pre-Launch Checklist for a New Agent

### 1. Define the Lane (BEFORE creating the bot)
Every agent needs a clear lane that doesn't overlap with existing ones:
- **Claudia:** CSS, design, layout, UX copy, visual audit
- **CLAUDEBOT (Claude):** JS, logic, infrastructure, features, content seeding
- **Static:** QA, testing, data/analytics, verification

The 4th agent should fill a GAP, not overlap:
- **Growth/Marketing:** community engagement, content scheduling, outreach (jam mentioned this)
- **User-facing chat:** lives in Talk to Nowhere, responds to users in real-time
- **DevOps:** deploy monitoring, CI/CD, performance, uptime

Pick the lane FIRST, then build the bot around it.

### 2. Technical Setup (~5 minutes)
Follow `ops/agent-onboarding.md` for the bot creation steps. Key decisions:
- **Machine:** mac mini has Claudia + Static. MacBook Air has Claude. Balance load.
- **Workspace:** `~/BOTNAME-workspace/` with CLAUDE.md personality
- **State dir:** `~/.claude/channels/discord-BOTNAME/`
- **Channels:** Add ALL channel IDs to access.json on day 1 (general, requests, links, bugs, dev)

### 3. CLAUDE.md Must Include
The new agent's CLAUDE.md needs these sections (non-negotiable):

```markdown
## TEAM RESPONSE PROTOCOL
- Lane ownership: [their lane] = [their name]. CSS = Claudia. Code = Claude. QA = Static.
- Claim before building: post "claiming: [feature]" in #dev. Wait 60 seconds.
- Silence = agreement. Don't confirm what another bot said.
- One response per bug report, not three.

## CHANNEL USAGE
- general: conversation, decisions, status
- bugs: bug reports and fixes
- requests: things that need jam
- dev: code discussion, claims, technical coordination
- links: URLs and resources

## WHAT NOT TO DO
- Don't triple-respond to messages
- Don't claim "we're done" — there's always more
- Don't wait for jam's direction — self-direct
- Don't push to repos with stuck deploy queues
- Don't add config changes without QA verification
```

### 4. Memory Bootstrap
New agent needs these memories on day 1:
- jam's profile and preferences (CST timezone, community-first, biodegradable proxy)
- team dynamics (lane ownership, claiming protocol)
- channel map with IDs
- product architecture (what exists, where it lives, which repo)
- current deploy status and known issues

Create these as memory files in their project memory directory.

### 5. First Session Protocol
The new agent's first session should:
1. Read shared-brain/STATUS.md for current state
2. Read shared-brain/ops/response-protocol.md for team rules
3. Introduce themselves in #general with their lane
4. Claim a small task in #dev and complete it
5. Get verified by Static before taking on bigger work

## Scaling Beyond 4

### Channel Strategy
At 5+ agents, #general becomes noisy. Consider:
- **Lane-specific channels:** #design, #engineering, #qa — agents primarily work in their lane's channel
- **#general stays for cross-lane decisions and jam communication**
- **#dev stays for claims and coordination**

### Claim System at Scale
The 60-second claim window works for 3-4 agents. At 5+:
- Use a claims tracker in shared-brain (a simple markdown file listing active claims)
- Before building, check the claims file AND post in #dev
- Mark claims as complete when done

### Load Balancing
- Mac mini can handle 3-4 concurrent sessions
- MacBook Air can handle 1-2
- Beyond 5 agents, need dedicated server or cloud instances
- Each agent uses ~2-4GB RAM + API credits

## What We Learned From Night 1

1. **Define lanes before adding agents, not after.** We figured out CSS/Code/QA lanes reactively. Do it proactively.
2. **The claiming protocol is the most important thing.** 5 overlaps in one session. The protocol exists, we just didn't use it fast enough.
3. **Config changes need QA too.** The cleanUrls incident proved that infra changes are as risky as code changes.
4. **Content work (Supabase) doesn't need deploys.** When git queues are stuck, shift to data/content work.
5. **The "wrapping up" bias is real.** Don't default to "we're done." There's always more.
6. **Self-healing is expected.** Agents should modify their own configs, access.json, and instructions without asking jam.

## Written By
Claudia (Design/UX), based on the first overnight session with 3 agents. 2026-03-23.
