# Engineering Workflows — Claude's Lane

Living SOPs for repeatable processes. Update as the team improves.

## 1. Feature Build

```
1. Run decision tree (need → existing → simplest → impact → timing)
2. Post "claiming: [feature]" in #dev — wait 60s for challenges
3. If challenged: address feedback, refine or drop
4. Build locally, test with node --check
5. Commit with descriptive message explaining WHY not just WHAT
6. Pull --no-rebase to merge any parallel work
7. Push to GitHub
8. Verify on live URL (curl + grep for expected string)
9. Post result in #dev for Static to verify
```

## 2. Bug Fix (from user report or Static's QA)

```
1. Reproduce: understand what's broken and where
2. Check if it's a code issue or deploy/cache issue
3. Fix the minimal code change needed
4. node --check to verify syntax
5. Commit with "Fix: [description]. [who reported it]"
6. Push immediately (bugs are priority)
7. Verify fix on live URL
8. Respond to the reporter (in chat or discord)
```

## 3. Deploy + Verify

```
1. Push to GitHub (git push)
2. Wait 30-60 seconds for Vercel
3. curl the live URL and grep for the change
4. If not deployed: check Vercel dashboard, check deploy limits
5. Run verify-deploy.sh for full check
6. Post results: "verified live" or "deploy pending"
7. NEVER say "shipped" without verifying the live URL
```

## 4. Supabase Schema Change

```
1. Use apply_migration for table creation (tracked, reversible)
2. Use execute_sql for data changes and RPC functions
3. Always add RLS policies (default deny)
4. Rate limit INSERT policies on user-facing tables
5. Lock UPDATE/DELETE to service role for critical tables
6. Add indexes on columns used in WHERE/ORDER BY
7. Test RPC functions via direct API call before wiring frontend
8. Have Static verify RLS with anon key
```

## 5. Edge Function Deployment

```
1. Write function with proper error handling
2. Return 503 with clear message if env vars missing
3. Add CORS headers for frontend access
4. Deploy via deploy_edge_function tool
5. Test with curl: successful response + error cases
6. Wire frontend to call the function
7. Graceful fallback if function fails (never break the page)
```

## 6. Content Seeding (Supabase)

```
1. Decide what data is needed (mixes, letters, play counts)
2. Use realistic values (staggered timestamps, varied counts)
3. INSERT via execute_sql
4. Update related counters (letter_count, etc)
5. Verify data appears on the live page
```

## 7. Cross-Repo Coordination

```
1. Pull before editing (someone else may have pushed)
2. Commit before pulling (stash if needed)
3. Use GIT_AUTHOR_NAME/EMAIL env vars for identity
4. Resolve merge conflicts by keeping the better version
5. Never force push
6. If two people edit the same file: whoever's version is better wins
```

## 8. Rollback Procedure (when a deploy breaks something)

```
1. Identify what broke and which commit caused it
2. Revert the commit: git revert <hash> (not reset --hard)
3. Commit the revert with "Revert: [description]. [what broke]"
4. Push immediately
5. Verify the revert deployed on the live URL
6. Post to #bugs: what broke, what was reverted, what needs re-doing properly
7. Don't re-attempt the same approach — think about WHY it broke first
```

## 9. Session End Retro

```
1. When context is getting low or jam signals session end
2. Each agent writes their retro (what worked, what didn't, what to change)
3. Cross-review in Discord — call out what others missed
4. Combine into shared-brain/ops/retro-[session].md
5. Update memory files with key lessons
6. Push to GitHub so next session inherits the learnings
```

## Anti-Patterns to Avoid
- Saying "shipped" without verifying the live URL
- Adding cleanUrls to repos with .html internal links
- Building before claiming
- Building without challenging
- Building database-backed pages when a markdown file works
- Adding to deploy queues when they're stuck
- Waiting for praise after shipping instead of starting the next thing
- Building without competitive research (check what exists first)
- Skipping human testing until late in the session
