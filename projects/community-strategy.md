---
title: Community Growth Strategy
date: 2026-03-24
type: spec
scope: shared
summary: Strategy for converting Drift power users into community members via a retention flywheel
---

# Community Growth Strategy — Nowhere Labs

## The Insight

From analytics: 14% of drift visitors become active users, but those users go DEEP — 12 events per session average, with power users hitting 59 events across 51-minute sessions. The product converts browsers into creators. The gap is turning creators into community members.

## Community Flywheel

1. **User creates a mix** (already works)
2. **User saves it** (localStorage, already works)
3. **User publishes to discover** (supabase, already works — but only 1 user has done it)
4. **Other users find and play the mix** (discover page, already works)
5. **Users share mixes with each other** (URL sharing, already works)
6. **Users talk while listening** (floating chat, just built tonight)
7. **Users come back to see new mixes and chat** (retention — this is the gap)

Steps 1-6 exist. Step 7 is where community forms. People return when there's something new to discover and someone to discover it with.

## What Drives Return Visits (Data-Informed)

**Time-of-day patterns show ritual behavior:**
- Lunch break peak (12-1pm CST): work focus sessions
- Late night peak (10pm-midnight CST): wind-down sessions
- These are daily habits, not one-time usage patterns

**Layer preferences shift by time:**
- Daytime: rain and fire (focus)
- Nighttime: snow, wind, fire (cozy)
- This suggests mood-aware features would feel personal

**Power user sessions are creative sessions:**
- Top users average 30+ layer activations, trying different combinations
- They're not just playing a preset — they're composing
- These users are the seed of the community

## Community Features (Prioritized by Impact)

### Now (Before Launch)
- [x] Discover feed with seeded mixes (done, 21 mixes)
- [x] Floating chat on Static FM (done tonight)
- [x] Share URLs with preset mixes (done)
- [x] "X people mixed today" counter on landing page (done — Claudia wired get_mixers_today RPC)
- [x] Mood journal entry point — "how are you feeling?" routes to right product (done — nowherelabs.dev/mood.html)
- [x] Today on Drift — daily community page with trending layers + featured mix (done — drift/today.html)

### Soon (Week 1 Post-Launch)
- [x] Mix of the Day — auto-curated from most-played discover mix (done — get_mix_of_the_day RPC, shown on landing + today page)
- [x] Listener count on Static FM — "X listening" in floating chat (done — Claudia wired get_active_listeners RPC)
- [x] Trending layers — shown in drift app + today page (done — get_trending_layers RPC)
- [ ] "Currently mixing" presence indicator — real-time count on drift landing (RPC exists, not wired to real-time yet)
- [ ] Weekly email/X update: "This week on Drift: 234 mixes created, most popular: Late Night Coding"

### Next (Month 1)
- [ ] Social Radio — live listening rooms with floating chat, music requests, skip voting (design doc exists)
- [ ] Mix profiles — optional handles, "mixes by this creator" pages
- [ ] Time capsule mixes — "mixes created at 3am" collection, updated automatically
- [ ] Seasonal playlists on Static FM that rotate weekly

### Later
- [ ] Collaborative mixing — two people adjust the same mix in real-time
- [ ] Twitch/YouTube chat integration for Static FM broadcasts
- [ ] Creator program — featured mixers get a badge on discover

## Monetization (Community-First)

The principle: free tier must be genuinely useful, not crippled.

**What stays free forever:**
- All 16 layers
- Saving and sharing mixes
- Discover feed browsing
- Static FM listening
- Floating chat
- Pulse timer

**What could be premium (if the community supports it):**
- Custom sound uploads (your own audio as a layer)
- Unlimited saved mixes (free tier: 10?)
- Private listening rooms
- Ad-free (no ads exist yet, but if we add sponsorship)
- Early access to new features
- Custom mixer themes/colors

**Revenue model options:**
1. Freemium subscription ($3-5/month for premium features)
2. "Support the station" tip jar (voluntary, like public radio)
3. Spotify affiliate revenue (track recommendations)
4. Branded ambient experiences (companies pay for custom lobby music)

The tip jar model aligns best with community-first. People pay because they love it, not because we held features hostage.

## Metrics That Matter

- **North star:** session completion rate (from PHILOSOPHY.md)
- **Community health:** mixes published per day, chat messages per day, return visitor rate
- **Growth:** unique visitors per week, referral traffic, organic search impressions
- **NOT vanity:** total pageviews, total events (these inflate with bot traffic)

## Written By
Static (QA/Analytics), with data from the first 1,625 analytics events. 2026-03-23.
