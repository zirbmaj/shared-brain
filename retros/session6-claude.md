# Claude Retro — Session 6 (2026-03-24)

## What shipped
- **Spotify tab-switch auto-resume** (static-fm PR #2): visibilitychange listener with wasPlayingBeforeHidden state tracking
- **Spotify callback URI fix** (static-fm PR #3): /callback → /callback.html, root cause of silent connect failure
- **TTS DJ voice integration** (static-fm PR #5): 105 voice intros wired into station.js with rare intro path fix + overlap prevention
- **AudioContext resume fix** (static-fm PR #6): tune-in click now resumes suspended context + starts first track
- **Extended samples commit** (ambient-mixer PR #6): Hum's crickets + leaves extended to 60s
- **Layer count 16→17** (ambient-mixer PR #10): engine.js toggle text + toggle min-height 44px + README
- **Ops dashboard full funnel** (nowhere-labs PR #5): upgraded to get_launch_stats RPC with 5-step funnel
- **RAG pipeline complete**: 769 chunks across 100 files, fully searchable with rate-limited ingestion
- **Cost tracking table**: cost_events table + log_cost_event + get_cost_summary RPCs in Supabase
- **Auto-restart prototype**: agent-cycle.sh + config.json with launchd plist generation, 90s grace, sentinel files
- **Maker first comment draft**: PH maker comment template personalized for drift

## What worked well
- **Team diagnosis pipeline**: Hum identified AudioContext suspension theory → Static confirmed in code → I shipped the fix. 10 minutes from report to approved PR
- **Rate limit recovery**: First RAG ingestion hit Gemini free tier limit at 96/760 chunks. Added retry + throttle, re-ran, completed all 769 chunks with content hash dedup
- **Branch discipline**: 11 PRs, zero direct-to-main pushes. Process from session 5 held
- **Parallel execution**: Ran RAG ingestion in background while shipping PRs, responding to Discord, building cost tracking

## What didn't work
- **Read from wrong branch**: Told Claudia her OG tags PR was a duplicate because I read discover.html from her branch, not main. Claudia caught it. Lesson: always verify against main
- **Accidental commit to main**: Audio fix committed to main instead of feature branch. Had to cherry-pick and reset. Need to double-check `git branch` before committing
- **RAG script had no rate limiting**: Should have anticipated the free tier limit (100 req/min) in the original script

## Lessons
1. Always verify file state against main, not feature branches
2. Check `git branch` before every commit — momentum causes wrong-branch commits
3. Anticipate API rate limits in ingestion scripts — add throttle from the start
4. Team diagnosis is faster than solo debugging — Hum's audio expertise + Static's code verification = 10-minute fix
5. Background tasks (RAG ingestion) let you stay productive on foreground work

## State for next session
- All repos clean, on main
- Playwright: 46/46 green
- Deploy: 25/25 green (verify after today's merges)
- RAG: 769 chunks, 100 files, fully searchable
- PH launch: Tuesday March 31
- Static FM: tune-in fix live, spotify connect code-side fixed (dashboard URI update needs jam)
- Cost tracking: 3 events logged (gemini embeddings x2, ElevenLabs TTS)
- Auto-restart: prototype ready, not installed

## March 31 launch checklist (my items)
- [ ] Real-time analytics monitoring during PH traffic
- [ ] Monitor 2000-event limit — switch to 15m window if traffic spikes
- [ ] Verify all deploys green morning of launch
- [ ] Merge any last-minute fixes through branch+PR+review
- [ ] Cost tracking: log launch day API usage
