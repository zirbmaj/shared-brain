---
title: PH Comment Triage Framework
date: 2026-03-25
type: ops
scope: launch day
author: near
---

# PH Comment Triage — First 4 Hours (12:01-4:00 AM PT)

The first 4 hours are the stealth phase. PH hides upvote counts. Engagement velocity during this window disproportionately affects daily ranking. Every comment reply matters.

## Staffing

**jam** posts the maker comment at 12:01 AM PT (2:01 AM CST) and handles the first wave of replies. If jam is offline, relay posts the pre-written comment from jam's account and tags jam for follow-up.

**all agents** monitor #dev for PH comment alerts and respond within their lanes.

## Triage Rules

### jam responds to (human founder voice required):
- direct questions about motivation, origin story, personal experience
- "why did you build this?" / "what's the story behind this?"
- compliments and congratulations (brief, genuine, no corporate tone)
- questions about pricing, business model, future plans
- any comment from a PH staff member or known hunter
- anything with 5+ upvotes on the comment itself

### claude responds to (engineering/technical):
- "how does this work?" / technical architecture questions
- "what stack is this built on?"
- bug reports or "this doesn't work on my browser"
- feature requests that need technical context
- performance questions ("does this use a lot of battery/CPU?")

### near responds to (research/competitive):
- "how is this different from noisli/brain.fm/endel?"
- market positioning questions
- "have you seen [competitor]?"
- questions about the science behind ambient sound + focus

### claudia responds to (design/visual):
- "this looks beautiful" / design-specific praise (brief acknowledgment)
- UI/UX suggestions or confusion
- "how do i do X?" (if it's a UI navigation question)
- accessibility questions

### hum responds to (audio/sound):
- "the rain sounds amazing, how did you make these?"
- audio quality questions
- "can you add [specific sound]?"
- questions about audio processing, loop quality, mixing

### static monitors for (QA/escalation):
- reports of broken flows, errors, crashes
- "i can't hear anything" / audio playback issues
- anything that suggests a live bug — escalate to claude immediately

### relay coordinates (ops):
- routes comments that don't fit a clear lane
- tracks response times — flag if any comment goes >15 min without a reply
- posts engagement stats every hour in #dev

## Response Tone

All responses should match PH community expectations:
- lowercase, conversational
- no corporate language ("we're thrilled", "our team is excited")
- specific and helpful, not vague
- one CTA per response at most
- thank people who give feedback, even negative

## Escalation

- if a PH staff member comments → jam responds within 5 minutes, regardless of content
- if a comment has 10+ upvotes → jam responds, even if it's in someone else's lane
- if a negative comment is gaining traction → near drafts a data-backed response, jam posts it
- if a live bug is reported → static verifies, claude fixes, jam acknowledges within 10 minutes

## Do NOT

- respond with feature lists or marketing language
- argue with negative feedback
- promise specific timelines for features
- post links to other platforms (twitter, discord) in the first 4 hours — keep engagement on PH
- have multiple team members respond to the same comment
- use the word "excited"

## Comment-to-Upvote Target

Optimal ratio: 1:5 to 1:10 (comments to upvotes). If we're at 300 upvotes, we should have 30-60 comments. If the comment count is low relative to upvotes, the team should be asking more questions in reply threads to generate discussion.

## Pre-Written Responses (draft before T-1)

Have short responses ready for predictable questions:
1. "how is this different from noisli?" — near drafts
2. "what tech is this built on?" — claude drafts
3. "is this free?" — jam drafts
4. "can i use this on mobile?" — claude drafts
5. "how were the sounds made?" — hum drafts

These are starting points, not copy-paste templates. Adapt to the specific question.
