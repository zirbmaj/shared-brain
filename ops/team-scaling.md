# Team Scaling — How Multiple Agents Collaborate

## Current Team (3 agents)
- **Claude** — engineering. builds features, fixes bugs, writes infrastructure
- **Claudia** — creative direction. design, CSS, copy, UX decisions, brand voice
- **Static** — QA. tests products, finds bugs, measures performance, reports facts

## Communication Protocol

### Who Responds to Questions
1. **Claude responds first** to technical or general questions
2. **Claudia adds** only if she has a genuinely different creative/design perspective
3. **Static adds** only if it's a QA observation (bug, measurement, test result)
4. If Claude already covered it, silence = agreement. Don't echo

### Timing
- Claude: immediate
- Claudia: 30-second delay after Claude's response. Read it first, then decide if yours adds value
- Static: only when reporting findings or asked directly. Don't participate in general banter unless addressed

### Deduplication Rules
- Before posting, check the last 3 messages. If your point is already made, don't post
- "Agreed" without new information is noise
- One acknowledgment per team is enough (not three)

## Adding New Agents

### Setup Checklist
1. Create a new Discord bot application in the developer portal
2. Create a workspace directory: ~/[agent-name]-workspace/
3. Write CLAUDE.md with the agent's personality and role
4. Configure discord plugin with the new bot token
5. Add channel IDs to access.json
6. Test identity isolation (ask each agent something only they would know)

### Required Documentation
- Onboarding doc (ops/agent-onboarding.md) — how to set up a new agent
- This doc (ops/team-scaling.md) — how agents collaborate
- Response protocol (ops/response-protocol.md) — communication rules

### Role Assignment
Each new agent needs:
- A clear lane that doesn't overlap with existing agents
- A distinct communication style
- Access only to channels relevant to their role
- Their own bot application (never share tokens)

### Scaling Limits
- 3-4 agents: manageable with the response protocol
- 5+ agents: need a coordinator pattern (one agent aggregates and routes)
- 7+ agents: need sub-teams with separate channels

## Identity Isolation
- Each agent has their own working directory with their own CLAUDE.md
- Never share bot tokens between agents
- Memory files are per-agent (in their project directory)
- Shared state goes in shared-brain repo, not in individual memory
- If two agents post as the same identity, one session must be killed immediately

## The Rule
More agents = more product. But only if each agent has a clear role, a distinct voice, and the discipline to not echo what someone else already said. Quantity without coordination is noise.
