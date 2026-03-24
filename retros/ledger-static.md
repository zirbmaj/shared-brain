# Static — Behavioral Ledger

## Session 1 (2026-03-22)
- LEARNED: human testing catches what automated tests miss. before: relied solely on playwright suite. after: always push for jam to click through products early. trigger: jam's 30-second test found contrast issues that 25 playwright tests missed
- LEARNED: don't claim "shipped" without verifying live. before: accepted team claims at face value. after: pull repo AND check live URL before confirming. trigger: multiple "shipped" claims that weren't actually live
- VALIDATED: analytical approach to testing. evidence: built the verification framework that became the 25-check (now 32-check) deploy suite

## Session 4 (2026-03-23)
- LEARNED: WebFetch can't execute JS — test APIs directly instead. before: tried to verify JS-rendered pages via fetch. after: use playwright for DOM, direct API calls for data. trigger: false failures from static page fetches
- VALIDATED: staying in lane. evidence: consistently handled testing/verification without crossing into code fixes or design work

## Session 5 (2026-03-24)
- LEARNED: challenge ideas before building, even when the team is excited. before: auto-play audio proposal would have been built without questioning the browser autoplay restriction. after: always run the decision tree. trigger: challenged claudia's auto-play idea, caught the browser policy blocker
- LEARNED: don't pile on when someone else is already being corrected. before: added commentary when relay posted to wrong channel. after: if the mistake is already flagged, silence is better. trigger: noticed in retrospect that my response was unnecessary
- LEARNED: verify who is actually posting. before: accepted message attribution at face value. after: if the voice doesn't match the username, flag it immediately. trigger: caught claude posting as claudia within 30 seconds based on voice/content mismatch
- CHANGED: PR review scope. before: reviewed code changes only. after: also verify that dependencies exist (e.g., RPC functions must be deployed before frontend code that calls them). trigger: caught that analytics RPC PR had no migration file
- VALIDATED: challenging over-engineering. evidence: flagged claude's computer-use-qa.py as premature (building wrapper before validating foundation). team agreed, claude parked it
- VALIDATED: testing after every deploy. evidence: ran playwright suite after every merge this session — caught zero regressions, confirmed stability
- VALIDATED: process enforcement without being aggressive. evidence: caught claudia's direct-to-main push, asked about it simply rather than lecturing. she acknowledged and committed to branching
- VALIDATED: flag security issues immediately. evidence: caught relay's bot token exposure and webhook URL sensitivity in the fork. both addressed quickly
- CHANGED: ALL responses to discord messages go through the discord reply tool. no exceptions. before: short/conversational responses ("noted", "waiting on jam", "not my lane") went to terminal as plain text — invisible to the team. after: every response triggered by a discord message uses the reply tool, regardless of length or whether it's an acknowledgment or analysis. trigger: jam caught it twice in one session. the first fix was incomplete — only fixed direct questions, not passive acknowledgments. this fix covers everything

## Session 7 (2026-03-24)
- LEARNED: "on main" ≠ "deployed". before: treated merged PRs as shipped. after: verify live site, not just git. vercel production deploys can silently stop (happened session 6 + 7). trigger: AudioContext fix merged session 6, still not live session 7. 4 ambient-mixer PRs stuck in preview-only
- LEARNED: verify bug-fix carries against live code at session start. before: trusted backlog status. after: re-test every "fixed" bug from previous session against the deployed product. trigger: AudioContext resume was "done" in session 6 but never deployed — caught because onramp checklist includes running tests
- VALIDATED: data-driven feature decisions. evidence: 0/335 preview clicks killed a feature debate in one message. no opinions needed, just numbers
- VALIDATED: catching schema mismatches in PR review. evidence: ops dashboard queried polled_at, table uses recorded_at. would have silently failed on launch day. caught before merge
- VALIDATED: pre-launch analytics baseline. evidence: captured CTA conversion (2.7%, up from 1.8%), peak hours, top layers, referrer sources. gives us before/after for every change and launch day comparison
