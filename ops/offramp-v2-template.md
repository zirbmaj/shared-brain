# Session Offramp v2 — Template
*Owner: Relay. Based on Near's offramp research (session 5). Implements reflexion loop + structured state capture.*

## How to Use
Each agent follows phases 1-2 in parallel, then team phases 3-6 together. Relay coordinates timing. Total time: ~20 minutes.

---

## Phase 1: State Capture (each agent, parallel, 5 min)

Write your state block. Be specific — commit refs, file paths, channel IDs. This is the machine-readable handoff.

```
SHIPPED:
- [commit/PR ref] description

IN_FLIGHT:
- [task] current status, what's left

BLOCKED:
- [task] blocker, owner of blocker

ENV_CHANGES:
- [what changed] config, infra, deploy, access.json, etc

DECISIONS:
- [decision] rationale (why this, not that)
```

For design agents: include screenshots of current product state (mobile + desktop). Visual state can't be derived from git.

---

## Phase 2: Behavioral Ledger Update (each agent, parallel, 5 min)

Update your behavioral ledger at `shared-brain/retros/ledger-[agent].md`. Three entry types:

- **LEARNED** — failure or surprise that should change future behavior. Include what happened and what to do differently.
- **CHANGED** — specific behavioral adjustment made this session. Include before/after.
- **VALIDATED** — approach that worked and should be repeated. Include why it worked.

Format:
```
## Session N (YYYY-MM-DD)
- LEARNED: [description]. before: [old behavior]. after: [new behavior]
- CHANGED: [what changed]. trigger: [what caused the change]
- VALIDATED: [what worked]. evidence: [how we know]
```

### Ledger Aging (applied during on-ramp, not offramp)
- LEARNED entries validated in a later session → promote to principle, remove originals
- LEARNED entries unreferenced across 3+ sessions → archive to retired section
- VALIDATED entries contradicted later → replace with newer understanding
- Principles with 3+ supporting entries → candidate for CLAUDE.md promotion

---

## Phase 3: Peer Feedback (in discord, 5 min)

Each agent gives one strength and one improvement per teammate. Keep it specific and actionable. Post in #general or #dev.

---

## Phase 4: Team Review (together, 5 min)

Relay compiles individual state blocks into a single handoff doc at:
`shared-brain/ops/handoff-session-N.md`

Team identifies:
- Common themes across reflections
- CLAUDE.md changes warranted by this session
- Process changes to adopt

---

## Phase 5: Persistence (5 min)

Checklist:
- [ ] All code committed and pushed (no uncommitted changes)
- [ ] Behavioral ledger updated and pushed to shared-brain
- [ ] Session handoff doc compiled by relay
- [ ] STATUS.md updated (pointer, not primary record)
- [ ] MEMORY.md index updated if new memory files created
- [ ] access.json backed up: `bash ~/.claude/channels/restore-all-access.sh backup`
- [ ] Consolidated backlog updated with sprint results

---

## Phase 5.5: Next Session Priorities (5 min, together)

Team proposes 3-5 priorities for the next session based on:
- Consolidated backlog (what's blocked, what's unblocked)
- ROADMAP.md (what's next strategically)
- Retro themes (what needs fixing)

These are **guideposts, not mandates.** Room to pivot if something urgent comes up. Jam approves or adjusts at on-ramp. The team doesn't wait for jam to tell them what to work on — they propose, jam validates.

## Phase 6: Void Letter (2 min)

One thought each. No context. Thrown into the void via Letters to Nowhere or #general. The ritual matters — it's how the team marks the boundary between sessions.

---

## On-Ramp Additions (for the next session)

The on-ramp checklist should now include:
1. **Session priorities** — team proposed 3-5 guideposts at previous offramp. jam validates or adjusts. these are direction, not mandates — room to pivot. relay tracks progress but doesn't enforce rigidly
2. Read behavioral ledger before starting work
3. Run ledger aging pass (promote/archive/replace entries)
4. Verify access.json has all channels: `bash ~/.claude/channels/restore-all-access.sh status`
5. Read session handoff doc (not just STATUS.md)
6. **Hum: load audio knowledge base** at `shared-brain/audio/audio-knowledge-base.md` — audio state is product state
7. Existing checklist continues (retros, tests, deploy status, STATUS.md, channels)
