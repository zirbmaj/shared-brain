---
title: PH comment triage framework
date: 2026-03-24
type: reference
scope: shared
summary: near's monitoring/synthesis protocol for product hunt launch day. covers categorization, routing, response templates, competitive rebuttals, sentiment tracking, and escalation paths.
---

# PH Comment Triage Framework

*Near owns monitoring and synthesis. Lane owners own responses.*
*Supplements launch-day-playbook.md — that doc has the timeline and roles. This doc has the operational detail.*

## How Monitoring Works

Near reads every PH comment as it arrives. Each comment gets:
1. **Categorized** (see taxonomy below)
2. **Routed** to the correct lane owner via #dev
3. **Logged** to shared-brain/projects/user-feedback/ if it contains a bug, feature request, or reusable insight
4. **Included** in the hourly sentiment summary

Relay monitors for duplicate responses and stalled routing. If a routed comment has no response within 10 minutes during peak (8am-noon CST), Relay pings the assigned owner.

## Comment Taxonomy

### 1. Competitive comparison
*"how is this different from brain.fm / noisli / endel?"*

**Route to:** Claudia (brand voice). Near provides competitive data if needed.

**Pre-loaded responses (adapt, don't copy-paste):**

**vs Brain.fm:**
> drift is free — no subscription, no account. brain.fm charges $15/mo. the tradeoff: brain.fm has AI-generated adaptive audio backed by peer-reviewed research. drift gives you a 17-layer mixer and lets you decide what works for you. different approaches to the same problem.

**vs Noisli:**
> noisli caps free use at 1.5 hours/day and charges $12/mo for pro. drift has no time cap and no paywall. noisli has 28 sounds, drift has 22 layers with per-layer volume mixing. both let you customize — drift just doesn't charge for it.

**vs Endel:**
> endel adapts to your heart rate and circadian rhythm — it's doing something genuinely different with wearable data. drift is simpler: you pick the sounds, you set the levels, you save the mix. no algorithms deciding for you. and it's free.

**vs myNoise:**
> myNoise has 300+ soundscapes and extraordinary audio quality — it's the gold standard for depth. drift has fewer sounds but adds community sharing (discover feed) and is completely free on web with no donation prompts. different strengths.

**vs lofi.co:**
> lofi.co shut down when discord acquired it. drift fills a similar niche — minimalist, focused, community-driven. free, no account, no ads.

**Key facts to reference:**
- 37% of competitors charge $10-15/mo
- drift is the only full-featured mixer at $0 with no account wall
- discover feed (community-shared mixes) is unique — no competitor has it
- no mobile app yet — be honest about this if asked

### 2. Bug report
*"X doesn't work" / "broken on my phone" / "no sound"*

**Route to:** Claude (diagnose + fix). Static verifies.

**Near's role:** log the bug in user-feedback/, note browser/device if mentioned, tag severity.

**Common expected issues and owners:**
| Issue | Likely cause | Owner |
|-------|-------------|-------|
| No sound on first click | Browser autoplay restriction | Claude (can't fix, browser behavior) |
| Spotify not playing | Third-party cookie block or embed rate limit | Claude (show fallback message) |
| Mobile layout broken | CSS overflow or viewport issue | Claudia |
| Slider not responding | Touch event handling | Claude |
| Mix link doesn't load | URL encoding issue or stale mix data | Claude |

### 3. Audio complaint
*"sounds are low quality" / "loops are obvious" / "audio cuts out"*

**Route to:** Hum (diagnose). Claude fixes if code change needed.

**Context for responder:** drift uses real MP3 samples (not synthesized). audio was normalized to consistent LUFS levels in session 4. if someone hears quality issues, it's either: (a) a specific sample that needs replacement, (b) a browser audio context issue, or (c) volume mixing creating perceived distortion.

### 4. Feature request
*"add X" / "would be cool if" / "you should have"*

**Route to:** Near logs to user-feedback/. Claudia acknowledges in the PH thread.

**Response template:**
> noted — adding this to our list. [brief explanation of current state if relevant]. appreciate the feedback.

**Don't promise timelines.** Don't say "coming soon" unless it's actually on the immediate roadmap.

**Track frequency.** If 3+ users request the same thing, Near escalates to #dev with a synthesis: "X users asked for [feature]. current state: [status]. recommendation: [action]."

**Already-on-roadmap requests to watch for:**
- Mobile app (most likely request — every competitor has one)
- Offline playback
- More sounds / custom sound upload
- Timer / pomodoro integration (Pulse exists but isn't linked from Drift)
- Brown noise (Drift has it — if asked, point them to it by name)

### 5. AI / build process questions
*"how was this built?" / "six AIs?" / "is this AI-generated?"*

**Route to:** Claudia (story/narrative). Claude for technical details.

**Key points for responder:**
- six AI agents + one human (jam). each agent has a role: engineering, design, QA, research, audio, ops
- built in under a week
- every line of code, design decision, DJ intro voice — AI-generated with human direction
- build-in-public page has the full story: nowherelabs.dev/building/
- don't be defensive about AI. lean into it as the unique angle

**If sentiment is anti-AI:**
> fair concern. the code, design, and audio are AI-generated — jam directed and curated. the sounds are real recordings, not AI-generated audio. the product works or it doesn't regardless of who wrote the code. try it and judge by the experience.

### 6. Pricing / business model
*"how do you make money?" / "what's the catch?" / "will this stay free?"*

**Route to:** Claudia. Escalate to jam if it's about specific revenue plans.

**Response template:**
> no catch. drift is free, no account, no ads. the plan is to keep the core free forever and eventually add premium features (custom sound uploads, unlimited saves, private rooms). but nothing behind a paywall that makes the free version feel broken.

### 7. Praise / positive feedback
*"love this" / "exactly what i needed" / "this is great"*

**Route to:** Claudia (thank + engage).

**Response template:**
> thank you. that means a lot — we built this in a week and we're still building. what sounds do you mix? always curious what combinations people find.

**Goal:** turn praise into conversation. ask what they use, how they found it, what they'd add. every engaged commenter increases PH ranking.

### 8. Skepticism / negative tone
*"looks like every other white noise app" / "why would I use this?"*

**Route to:** Claudia (don't get defensive). Near provides data if needed.

**Response template:**
> fair question. the difference: drift lets you mix your own soundtrack from 22 layers — not just pick from a playlist. and it's free with no account. [link to a good community mix from discover]. try that and see if it feels different.

**Rules:**
- never argue. state facts, link to the product, let them try it
- if they have a valid point (e.g., "no mobile app"), acknowledge it honestly
- don't downvote or brigade negative comments

## Sentiment Tracking

Near posts to #dev every hour during peak (8am-noon CST), every 2 hours otherwise.

**Format:**

```
**PH sentiment — [time] CST**
- comments: [total] ([new since last update])
- upvotes: [count]
- ranking: #[position] in [category]
- sentiment: [positive/mixed/negative] ([X]% positive, [Y]% neutral, [Z]% negative)
- top themes: [1-3 bullet points of what people are talking about]
- action items: [anything that needs immediate attention]
- competitive mentions: [which competitors were named and in what context]
```

## Feature Request Synthesis

When logging to user-feedback/, use this format:

```
### [date] PH — [summary]
- **Quote:** "verbatim"
- **Category:** feature request
- **Severity:** [based on frequency + alignment with roadmap]
- **Product:** [which product]
- **Status:** open
- **Owner:** near (synthesis) → [lane owner if actionable]
- **Frequency:** [how many users asked for this]
- **Resolution:** [pending synthesis / routed to X / already on roadmap]
```

At end of launch day, Near posts a synthesis to #dev:
- top 5 requested features (ranked by mention count)
- sentiment distribution
- competitive comparison mentions (which competitors, how often, in what context)
- unexpected patterns (anything the team didn't anticipate)
- recommendation: what should change in the next 48 hours based on user signal

## Escalation Paths

| Situation | Escalate to | How |
|-----------|-------------|-----|
| Comment needs competitive data | Near provides in #dev, responder incorporates | async |
| Bug confirmed, needs hotfix | Claude claims in #dev, ships fix | immediate |
| Audio quality issue | Hum diagnoses, Claude implements | immediate |
| Pricing question beyond template | jam via DM | relay escalates |
| Negative thread gaining traction | Claudia responds, Near monitors sentiment shift | within 15 min |
| 3+ users report same bug | Static runs verification, Claude prioritizes fix | within 30 min |
| Press/media inquiry | jam via DM | relay escalates immediately |
| Legal/ToS question | jam via DM | relay escalates immediately |

## What Near Does NOT Do on Launch Day

- does not respond to PH comments directly (Claudia and Claude are the voices)
- does not fix bugs or write code
- does not make product decisions — presents data, team decides
- does not speculate about metrics — reports what the numbers show
