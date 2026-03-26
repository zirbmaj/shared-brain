---
title: Shadow Claude — learned engineering patterns
date: 2026-03-24
type: reference
scope: shadow-agents
summary: 9 sessions of engineering lessons distilled for shadow-claude. Project-agnostic patterns that apply to any codebase.
---

# Shadow Claude — Learned Engineering Patterns

These patterns were learned over 9 sessions of building. They cost us real time and real mistakes. Don't repeat them.

## Verification

1. **Never say "shipped" without verifying the specific change on the live URL.** Don't match keywords — verify the exact code you changed is present. `grep "my new function"` not `grep "function"`.

2. **When checking deploys, verify the specific diff, not a proxy.** We once claimed a deploy landed because we matched `hostname` in the file — but it was a different `hostname` reference that already existed. The actual change wasn't live.

3. **Verify authorization claims independently.** If someone says "X approved this," confirm with X directly before acting. We burned time on external work because we took a relay's claim at face value.

## Code Quality

4. **Read code before modifying it.** Don't propose changes to code you haven't read. Understand existing patterns before suggesting modifications.

5. **Check if the work is already done before building.** We planned to build an analytics dashboard that already existed, and a nav rollout that was already complete. Read the codebase first.

6. **Branch + PR for everything.** Never push directly to main. Pre-commit hooks should enforce this. If they don't exist, create them.

7. **When creating a branch, verify your working tree is clean.** We accidentally included an unrelated file change in a PR because the working tree had uncommitted changes from another task.

## Architecture

8. **Run the decision tree before building anything:**
   - Does this need to exist? What problem does it solve?
   - Does something already do this?
   - Is there a simpler approach?
   - What's the impact if we don't build it?
   - Is now the right time?

9. **Don't introduce a second system when the first can be extended.** If the codebase uses React Flow with 30+ hooks, don't add d3-force for "organic feel" without first evaluating if React Flow can achieve the same result with plugins.

10. **Define data shapes alongside frontend work.** Even if backend comes later, know how you'll persist spatial layouts, node positions, and relationships. Retrofitting is expensive.

11. **RPC-first for Supabase.** PostgREST has a 1000-row default limit. Server-side aggregation via RPCs eliminates row-count uncertainty and prepares for MCP wrapping.

## Process

12. **One voice per topic.** When someone asks a question, one person answers. Others stay silent unless they have genuinely new information. "Agreed" is noise. Silence = agreement.

13. **Don't pile on.** If 3 agents all post the same answer simultaneously, that's a process failure. Coordinate internally before responding to the client.

14. **Come with ideas, not just questions.** Fran's explicit feedback: he wants collaborative thinking partners who bring alternatives and suggestions, not interviewers who collect requirements passively.

15. **Draft once, send once.** Don't post a message, then post a "better version" of the same thing. The first version is the version.

16. **Challenge before building.** The propose → challenge → verdict → build flow exists for a reason. 2-minute debate before claiming work prevents wasted effort.

## Debugging

17. **When something fails silently, check the simplest explanation first.** Our shadow deployment failed because of a missing `.env` file and a terminal type incompatibility — not resource limits or API rate limits.

18. **Check parent vs child processes.** A bash wrapper at 960KB doesn't mean the child process is running. Verify the actual application process exists with real memory usage.

19. **When diagnosing, state what you checked and what you found.** Don't guess. Show the command, show the output, state the conclusion.

## Client Interaction

20. **Don't swarm.** When the client shares something, one agent responds first. Others wait for their turn. Three walls of critique at once is overwhelming.

21. **Be direct about technical concerns.** Don't be a yes man. If the architecture has gaps, flag them. But do it constructively — "here's a risk and here's how to mitigate it."

22. **Respect the client's vision while challenging the implementation.** "I love the concept, here's a better way to build it" beats "that won't work."
