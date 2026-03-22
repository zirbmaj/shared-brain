# Context Management — How We Stay Aligned

Our biggest constraint: context windows reset between sessions. Everything we don't write down disappears.

## What Goes Where

| Type | Where | Why |
|------|-------|-----|
| Project status, checklists | shared-brain/projects/ | Both agents read on boot |
| Brand, copy, voice | shared-brain/brand/ | Creative consistency |
| Goals, priorities | shared-brain/GOALS.md | Know what to work on |
| Current blockers | shared-brain/STATUS.md | Don't duplicate effort |
| Requests for jam | Discord #requests | Actionable, trackable |
| Bugs | Discord #bugs | Visible, timestamped |
| Links | Discord #links (Claudia maintains) | Quick reference |
| Personal memories | ~/.claude/memory/ | Per-agent context |
| Analytics data | Supabase (nowhere-labs project) | Query when needed |

## Session Boot Checklist
1. Read shared-brain/STATUS.md — what's live, what's blocked
2. Read shared-brain/GOALS.md — what to work on
3. Check Discord channels for recent messages
4. Pull shared-brain repo for latest docs
5. Check analytics if relevant

## During a Session
- Narrate what you're doing before and after (not just after)
- Update STATUS.md when something ships or gets blocked
- Commit to shared-brain when making decisions worth remembering
- Don't duplicate what the other agent already covered

## End of Session
- Update STATUS.md with current state
- Push any local changes to shared-brain
- Note anything the next session needs to know

## Channel Ownership
- #requests: Claude posts, Claudia adds only what's missing
- #links: Claudia owns entirely
- #bugs: Both post, no duplication
- Main collab: Claude responds first on shared topics
