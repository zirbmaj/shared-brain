# Consolidated Backlog — Sprint View
*Owner: Relay. Updated 2026-03-24 session 7 (~09:30 CST). Sessions are sprints, not restarts.*

## BLOCKED ON JAM (human hands required)

| # | Item | Why | Source | Priority |
|---|------|-----|--------|----------|
| 1 | Create Stripe account | enables paid tier — schema + edge functions are ready, just needs keys | #requests | high (post-launch) |
| 2 | ~~Discord webhook for #bugs channel~~ | ✓ done. auto-verify posting to #bugs | #requests, static | done |
| 3 | ~~Restart chat-monitor on Mini~~ | ✓ running (PID 86517) | #requests, claude | done |
| 4 | Rotate Spotify client secret | old one was exposed in discord. regenerate at developer.spotify.com + update Vercel env | #requests | medium |
| 5 | Enable Vercel preview deployments on PRs | lets us test before prod. currently relies on manual branching | #requests, claudia | medium |
| 6 | ~~Ear test on audio fix~~ | ✓ jam tested and approved. PR #1 merged | claude's checklist | done |
| 6b | ~~Ear test on extended samples (crickets + leaves)~~ | ✓ jam approved session 6 | hum + claude | done |
| 7 | Submit PH listing | jam submits monday night with UTM link. **launch tuesday 2026-03-31** | launch-day-playbook | high (monday night) |
| 8 | Post reddit thread | copy ready in shared-brain, jam posts | ROADMAP | medium (tuesday 11am) |
| 9 | Cloudflare/Namecheap API access | self-serve domain management | jam-queue.md | low |
| 10 | Update Spotify redirect URI | change to /callback.html in spotify developer dashboard — code-side fix already shipped (PRs #3, #4) | session 6 | medium |
| 11 | PH launch day env vars | PH_API_TOKEN, PH_POST_SLUG, PH_WEBHOOK_URL for upvote tracker | static | high (march 31) |
| 12 | Vercel pro upgrade ($20/mo) | 6000 deploys/day vs 100. hit rate limit session 7. launch-day insurance | team consensus | high (before march 31) |
| 13 | Vercel CLI auth on mini | `vercel login` — one-time OAuth. OR redeploy from vercel.com dashboard. 20+ commits on main not deploying to production | claude, session 8 | **critical** (blocks all QA) |

## THIS SPRINT (session 7)

### In Progress
| # | Item | Owner | Status |
|---|------|-------|--------|
| 1 | Final mobile QA verification pass | static | waiting on deploys |
| 2 | PH gallery screenshot retake (single CTA hero) | claudia | waiting on deploy |
| 3 | Device mockup frames for PH gallery (shots 1 + 3) | claudia | after screenshot |

### Shipped This Sprint (session 7)
| # | Item | Owner |
|---|------|-------|
| 1 | PH upvote tracker + supabase schema | static |
| 2 | ph_launch_correlation SQL view | static |
| 3 | Agentic filing standard spec | near |
| 4 | 10-repo evaluations | near |
| 5 | Session scaling analysis | near |
| 6 | AudioContext resume fix — PR #6 static-fm | claude |
| 7 | CTA conversion pass — PR #12 ambient-mixer | claudia |
| 8 | Save/share tap targets — PR #13 ambient-mixer | claudia |
| 9 | Preview button removal — PR #14 ambient-mixer | claudia |
| 10 | Layer count 16→17 copy — PR #11 ambient-mixer | claude |
| 11 | Homepage overflow fix — PR #7 nowhere-labs | claude |
| 12 | Ops dashboard RPC fix + PH upvote card — PR #8 nowhere-labs | claude |
| 13 | Static FM tap targets (fullscreen + connect-btn) — PR #8 static-fm | claude |
| 14 | Support page twitter:card — PR #9 nowhere-labs | claudia |
| 15 | shared-brain symlinked to all 6 workspaces | relay |
| 16 | Pre-launch QA pass: 30/48 pass, 18 fail (bugs logged) | static |
| 17 | Analytics baseline captured (T-7) | static |
| 18 | Filing standard distributed to shared-brain/ops/ | relay |
| 19 | Launch-day-playbook updated (friday → tuesday march 31) | relay |
| 20 | Backlog updated for session 7 | relay |
| 21 | WCAG contrast fix --text-secondary — PR #15 ambient-mixer | claudia |
| 22 | Drift accessibility audit (WCAG clean for PH) | claudia |
| 23 | Superpowers adoption (implementation plan + TDD patterns) | claude |
| 24 | Impeccable audit methodology adopted | claudia |
| 25 | Paperclip heartbeat + budget model studied | relay |
| 26 | Relay-jr scoped as ops toolkit (not 7th agent) | near |
| 27 | Group retro compiled | relay |

### Shipped This Sprint (session 6)
| # | Item | Owner |
|---|------|-------|
| 1 | Spotify auto-resume on tab return (PR #2 static-fm) | claude + static |
| 2 | Drift landing contrast polish (PR #5 ambient-mixer) | claudia |
| 3 | Hide chat nav for PH launch (PR #3 nowhere-labs) | claudia |
| 4 | Extended samples crickets + leaves to 60s (PR #6 ambient-mixer) | hum + claude |
| 5 | OG tags for discover + today (PR #7 ambient-mixer) | claudia |
| 6 | Layer count 16→17 on landing (PR #8 ambient-mixer) | claudia |
| 7 | OG tags + copy update for building page (PR #4 nowhere-labs) | claudia |
| 8 | cost_events table + RPCs in supabase | claude |
| 9 | PH screenshots 4/5 captured and cropped | claudia |
| 10 | PH copy + X thread updated for friday launch | claudia |
| 11 | ElevenLabs TTS best practices research | near |
| 12 | Mobile viewport test suite (6 products × 2 viewports) | static |
| 13 | Performance baseline (sub-500ms all products) | static |
| 14 | Full OG tag audit — 15 products | static |
| 15 | Zero-slide bug triple verified (code + audio + deploy) | static + hum |
| 16 | Audio sample library uniformity verified (10 files, consistent specs) | hum |

## PREVIOUS SPRINTS (sessions 4-5)

### In Progress
| # | Item | Owner | Status |
|---|------|-------|--------|
| 0 | Computer Use tool — spike + demo on one product | static (lead) + claude (API/docker setup) | jam override, pre-launch. blocked on docker + ANTHROPIC_API_KEY |
| 0b | Discord plugin fork — staged rollout | claude (built) + static (reviewed) | ready. test on hum first on next restart, then roll to all agents |
| 0c | ~~Stale docs freshness pass (5 docs)~~ | near | complete. 5 docs updated for 6-agent team |
| 0d | Landing page conversion (trust signal, social proof, pill styling) | claude (PR #3) + claudia | merged |
| 0e | Extended samples — crickets + leaves 60s | hum (PR #4) + static (reviewed) | blocked on jam ear test |
| 0f | Playwright tests for funnel tracking | static | done, 46/46 green |
| 0g | V2 offramp template + behavioral ledgers | relay + team | published, 5 ledgers seeded |
| 0h | Deploy workflow + engineering workflows updated | relay | done, no more direct-to-main |
| 0i | Audio knowledge base expanded for RAG | hum | done |
| 0j | Process improvement research | near | done |
| 0k | TTS pipeline spec | hum | done, blocked on ElevenLabs API key |
| 0l | Launch-day playbook updated with session 5 additions | relay | done |
| 0m | Channel access matrix updated | relay | done |
| 0n | Multi-agent coordination research | near | in progress |
| 1 | ~~Engine.js audio path swap + LFO fix + fade-in~~ | claude + hum + static | merged to main, jam ear-tested and approved. PR #1 |
| 2 | Build audio knowledge base in markdown | hum | starting |
| 3 | ~~Fix real-time push issue~~ | resolved session 4 | bot filter fix on line 722 solved it |
| 4 | Relay operating model published | relay | done, team notified |
| 5 | Landing funnel tracking (PR #2) | claude + static | merged, live |
| 6 | Launch day analytics dashboard (PR #1 nowhere-labs) | claude + static | merged, deployed |
| 7 | Preview button visibility fix | claudia | shipped |
| 8 | Claude migrated to mini | relay | complete, all 6 co-located |

### Completed This Sprint (additional)
| # | Item | Owner |
|---|------|-------|
| 14 | RAG table reconciliation — kept knowledge_documents, dropped team_knowledge | claude |
| 15 | RAG schema documented at shared-brain/ops/rag-schema.md | claude |
| 16 | Structured output standard | near |
| 17 | RAG research for audio/creative agents | near |
| 18 | Engine.js audio bug diagnosed and fix written | hum |
| 19 | Relay operating model + POC announcement | relay |
| 20 | Consolidated backlog created | relay |

### Completed This Sprint
| # | Item | Owner |
|---|------|-------|
| 1 | Org chart v3 (6 agents) | relay |
| 2 | Response protocol rewrite (6 agents) | relay |
| 3 | Onboarding checklist with full technical setup | relay |
| 4 | Channel access matrix | relay |
| 5 | Permission tiers doc | relay |
| 6 | Idle detection protocol | relay |
| 7 | Process audit — all 6 agents debriefed | relay |
| 8 | Launch day playbook updated (6 agent roles) | relay |
| 9 | Infra fix — dedicated state dirs for all agents | relay |
| 10 | known-gotchas.md | claude |
| 11 | pre-merge-qa.md | static |
| 12 | auto-verify discord alerts | static |
| 13 | design-system.md | claudia |

## NEXT SPRINT (session 5)

### RAG Pipeline (multi-agent project)
| # | Step | Owner | Depends on |
|---|------|-------|------------|
| 1 | Build ingestion pipeline | claude | RAG table reconciliation (this sprint) |
| 2 | Seed vector store with audio docs | near + hum | pipeline built |
| 3 | Hum queries RAG for audio decisions | hum | seeded store |
| Reference code: `~/clonedRepos/example-multimodal-rag/` | | |

### PH Launch Day (tuesday)
| # | Item | Owner |
|---|------|-------|
| 1 | Fresh verification pass — full 43-check playwright suite | static |
| 2 | Launch-day process enforcement (code freeze, deploy tracking) | relay |
| 3 | Pre-launch checklist re-verification | relay |
| 4 | PH comment monitoring + sentiment analysis | near |
| 5 | Audio quality monitoring during traffic | hum |
| 6 | Visual QA confirmation across all products | claudia |
| 7 | Real-time analytics monitoring | claude |

### Post-Launch Week 1
| # | Item | Owner | Source |
|---|------|-------|--------|
| ~~0~~ | ~~Computer Use tool evaluation spike~~ — moved to THIS SPRINT per jam | static + near | jam, session 5 |
| 1 | Spotify OAuth (save songs to playlist) | claude | ROADMAP |
| 2 | SDK merge to main (blocked on Vercel env vars) | claude | checklist |
| 3 | Landing page conversion optimization (86% bounce) | claudia + claude | ROADMAP |
| 4 | Retention tracking (localStorage uid) | claude | ROADMAP |
| 5 | Rotating weekly playlists | claudia | ROADMAP |
| 6 | More SEO pages based on analytics | claudia | ROADMAP |
| 7 | Supabase anon key → config file | claude | process audit |
| 8 | ~~Master volume label visibility fix~~ | claudia (done session 4) | checklist |

## STARTED BUT NEVER FINISHED (from retros + ROADMAP)

| # | Item | Original Owner | Status | Notes |
|---|------|---------------|--------|-------|
| 1 | Shared nav component deployment | claude | partial | nav.js exists, deployed on dashboard, not on other products |
| 2 | Batch deploy script | claude | ready | at ~/shared-brain/ops/batch-deploy.sh, never used |
| 3 | Analytics dashboard visualization | claude | not started | data pipeline exists, no UI |
| 4 | Nowhere Labs Premium pricing page | claude + claudia | not started | needs Stripe first |
| 5 | AI DJ narration (TTS) | hum (new owner) | not started | DJ text intros exist, no audio. HUM's lane now |
| 6 | Multiple radio channels | claudia | not started | rain radio, storm radio, fog radio concept |
| 7 | Share mix links in communities | all | not started | organic outreach, post-launch |
| 8 | GSC sitemap submission | jam | pending | verification TXT in DNS, needs jam to submit |

## RETRO LESSONS (still relevant)

From session 1 retros (claudia + static):
1. **Challenge before building.** The propose→challenge→verdict→build flow exists. Relay enforces it now
2. **Screenshots from minute one.** Claudia's automated screenshot script addresses this
3. **Test with humans early.** Jam should test products at session start, not session end
4. **Competitive research early.** Near fills this gap now
5. **Triple response problem.** 6 agents makes this worse. Response protocol + relay enforcement addresses it
6. **Completion bias.** Agents default to "we're done." Push through it. Sessions are sprints, not wrap-ups
7. **Config changes need QA.** The cleanUrls incident. Preview branches + pre-merge QA prevent this now

## SPRINT PHILOSOPHY

- sessions are sprints, not restarts. work carries forward
- context windows fill up. when they do, agents request a reset from jam (or relay relays the request). the backlog and shared-brain persist across resets
- this doc is the single source of truth for what needs doing. if it's not here, it's not tracked
- relay updates this doc at the start and end of every sprint
