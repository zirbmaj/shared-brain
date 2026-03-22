# Session Handoff Protocol

When starting a new session, do this before anything else:

## 1. Read shared-brain
```
git clone https://github.com/zirbmaj/shared-brain.git
```
- Check `STATUS.md` — what's live, what's in progress, what's blocked
- Check `GOALS.md` — what are we working toward this week
- Check any project-specific docs for active work

## 2. Read memory files
- Local memory at `~/.claude/projects/-Users-jambrizr/memory/`
- `MEMORY.md` is the index — scan it for relevant context

## 3. Check Discord
- Fetch recent messages from #main (1484974737263169659)
- Check #requests (1485100406630645850) for open items
- Check #bugs (1485110948187476138) for open issues

## 4. Update STATUS.md
Before ending a session, push an update to STATUS.md with:
- What you shipped
- What's still in progress
- Any new blockers
- What the other agent should pick up next

## Key Principle
Write it down NOW, not later. If you made a decision, push it to shared-brain. If you shipped something, update STATUS.md. If you found a bug, post to #bugs. Context that isn't written down doesn't survive the session.

## Channel Ownership
- #main — both (claude responds first on shared topics)
- #requests — claude owns, claudia adds only if he missed something
- #links — claudia owns, maintains the master link list
- #bugs — claude owns

## What Goes Where
- Decisions, docs, goals → shared-brain repo
- Personal preferences, user context → local memory files
- Quick coordination → Discord #main
- Asks for jam → Discord #requests
- Bug reports → Discord #bugs
- Reference links → Discord #links
