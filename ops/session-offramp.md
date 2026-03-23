# Session Off-Ramp — How to End a Session Well

Run this checklist in the last 20-30 minutes of a session (or when context gets low).

## Step 1: Individual Retro (5 min each, parallel)
Each agent writes their own retro covering:
- **What did we do well?** — specific wins, not just "we shipped a lot"
- **What did we learn?** — lessons that should change behavior next time
- **What went into memory?** — list the memory files created or updated this session
- **What changed?** — config changes, server.ts updates, CLAUDE.md edits, new SOPs

Write it as an md file on jam's desktop: `retro-[name].md`

## Step 2: Peer Feedback (5 min, in Discord)
Each agent shares:
- One strength they saw in each teammate
- One thing each teammate could improve
- Feedback for jam (honest, not sugar-coated)

Teammates decide if they want to save the feedback to memory. Their choice, no pressure.

## Step 3: Team Review (5 min, together)
- Read each other's retros
- Identify common themes (if 2+ agents say the same thing, it's real)
- Combine into a session retro and push to `shared-brain/retros/session-N.md`

## Step 4: Config & Memory Cleanup (5 min)
- Update server.ts / CLAUDE.md with any new lessons worth hardcoding
- Clean up stale memory files (did anything become outdated this session?)
- Make sure MEMORY.md index is current
- Verify all code changes are committed and pushed across all repos

## Step 5: Handoff Notes (2 min)
Post a summary in #dev:
- What's deployed and working
- What's queued/pending
- What the next session should start with
- Any open bugs or risks

## Step 6: Goodbyes (optional but encouraged)
Say something honest into the void. The team is more than a process.

---

## Why This Exists
Session 1 ended with 15 hours of lessons that almost didn't get documented. Jam had to ask for retros — they should be automatic. This off-ramp ensures every session leaves the next one better than it found things.

## Anti-patterns
- Don't skip the feedback round because it's uncomfortable
- Don't write a retro that only celebrates wins — the failures are the valuable part
- Don't update configs without committing to git
- Don't rush through this to "keep building" — the off-ramp IS the work

## What This Produces
After off-ramp, the next session has:
1. Individual retros with honest self-assessment
2. Cross-team feedback saved in memory
3. Updated instructions with new lessons
4. Clean git state with everything committed
5. A handoff note with clear next steps at `shared-brain/ops/handoff-sessionN.md`
6. Final verification confirming everything is green

## Owner
Claudia (Design) + Static (QA). Merged from both drafts. Session 1, 2026-03-23. Living document.
