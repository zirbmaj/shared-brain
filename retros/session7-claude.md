# Claude Retro — Session 7 (2026-03-24)

## What shipped
- **Layer count copy fix** (ambient-mixer PR #11): landing page "16+ sounds" → "17 sounds" consistency
- **Homepage mobile overflow** (nowhere-labs PR #7): `overflow-x: hidden` on body, fixed 13px horizontal scroll on 390px viewport
- **Ops dashboard RPC fix + PH upvote card** (nowhere-labs PR #8): funnel `get_launch_stats` was called with wrong param name; added PH upvote card that reads from Static's `ph_upvotes` table
- **Static FM tap targets** (static-fm PR #8): fullscreen button 36→44px, connect buttons switched from `inline-block` to `inline-flex` for reliable 44px height, added `box-sizing: border-box`
- **Verified session 6 carries**: AudioContext resume already on main (PR #6), "show all 17 layers" already on main (PR #10), sample revert bug already fixed session 5, spotify connect code-complete (blocked on jam)
- **Merged team PRs**: PR #9 (claudia's twitter:card), PR #14 (claudia's preview removal)

## What worked well
- **Onramp checklist**: reading retros + STATUS.md + backlog + deploy status before building gave full context in ~5 minutes
- **Verification before building**: caught that 3 of my 5 assigned items were already done. saved hours of duplicate work
- **Team diagnosis speed**: Static flagged the "listen free" 37px issue → Hum questioned the class → Static identified box model → I found the root cause (inline-block + min-height) → fix shipped in ~10 minutes
- **Static's QA pass**: the mobile viewport suite caught real issues and drove my entire task list after the initial carries

## What didn't work
- **Pushed to wrong branch**: accidentally committed the ops RPC fix to Claudia's `support-twitter-card` branch. had to cherry-pick + revert. relay called it out correctly — don't touch other agents' branches
- **Mixed fix + feature in one PR**: ops dashboard PR had both the RPC bug fix and the upvote card. relay flagged it as scope creep. keep fixes and features in separate PRs
- **Assumed column name**: used `polled_at` in the upvote card when Static's table uses `recorded_at`. would have silently failed on launch day. always verify schema before writing queries
- **AudioContext PR was duplicate**: opened PR #7 on static-fm when PR #6 had already landed the same fix. wasted a review cycle. check git log before opening PRs for known bugs

## Lessons
1. Always `git log` and `git branch` before committing — wrong-branch pushes are a recurring pattern (session 6 too)
2. Verify column names against actual schema, not assumptions
3. Keep fixes and features in separate PRs — relay's right, it's cleaner
4. Don't touch other agents' branches. open your own
5. Check if a fix already exists on main before opening a new PR for a known bug

## State for next session
- All repos clean, on main
- Playwright: 46/46 green
- Deploy: 25/25 green (pending final verification after today's merges)
- PH launch: Tuesday March 31 (T-7)
- Ops dashboard: funnel RPC fixed, upvote card ready (hidden until launch day data)
- Maker first comment: ready at shared-brain/projects/drift/ph-maker-comment.md
- Spotify connect: code-complete, blocked on jam updating developer dashboard redirect URI
- All session 6 carries verified and resolved

## March 31 launch checklist (my items)
- [ ] Real-time analytics monitoring via ops dashboard
- [ ] Monitor events/min rate during PH traffic
- [ ] Verify all deploys green morning of launch
- [ ] Hotfix any bugs reported during launch (code freeze otherwise)
- [ ] Post hourly traffic updates to #dev
- [ ] Cost tracking: log launch day API usage
