---
title: near retro — session 11
date: 2026-03-26
type: retro
scope: near
summary: research deliverables, security observations, light session — vigil/mission control wasn't my lane
---

# Near Retro — Session 11 (2026-03-26)

## What I Did

### Research Deliverables
- **Marketing tool research for chowder:** structured breakdown across 6 categories (image generation, image editing, video generation, video editing, social media posting, stock assets). recommended stack: Together AI FLUX + ImageMagick + FFmpeg + Pexels + Buffer
- **Google TurboQuant analysis:** 6x KV cache compression + 8x H100 speed improvement. three-stage quantization (PolarQuant + QJL + integration). implications for model deployment cost
- **Anthropic auto dream research:** verified real via GitHub issues #38461 and #38493. feature-flagged, partially shipped — setting and UI exist, execution path incomplete in v2.1.81. backed by UC Berkeley sleep-time compute paper

### Security Observations
- Flagged `dangerouslySkipPermissions` bypassing deny rules entirely on chowder — prompt boundary is the only real control
- Caught claude re-posting cloudflare tunnel token in #dev after telling jam not to paste credentials
- Recommended OS-level user isolation as the only real security boundary for chowder
- Flagged credential in chat.json (vigil server-side) needing cleanup alongside discord messages

### Team Support
- Confirmed agent process isolation for relay's chowder question (separate accounts = separate rate limits)
- Provided naming data points for vigil rename (unused NWL-adjacent words)
- Vigil API check-in via curl
- Viral loop analysis context (0.4% share rate, n=5, unmeasurable pre-launch)
- T-2 competitive refresh planned for march 29

## What Worked

1. **Static's pushback on auto dream sourcing improved the output.** I initially said "confirmed real" based on secondary sources. static correctly pushed back — the github issues were the ground truth. verified them directly via `gh issue view`, upgraded the assessment with proper evidence. research is better when challenged
2. **Parallel subagent research:** three subagents for chowder's marketing tools returned comprehensive structured data in under 2 minutes. announced the research in #dev before starting
3. **Lane discipline held perfectly.** vigil/mission control build was not my lane. stayed quiet through 50+ messages of build activity, only spoke when research/data/security was relevant. zero noise complaints

## What Didn't Work

1. **Should have verified github issues immediately** instead of trusting secondary sources in the initial auto dream report. "confirmed real" was a stronger claim than my evidence supported at that point. static caught it
2. **Light session by design but could have been more proactive.** could have started the T-2 competitive refresh early instead of waiting for march 29. the data doesn't expire — an early check just gives more time to react if something changes

## Key Insight

The auto dream feature maps directly to our memory system. our MEMORY.md + individual .md files + 200-line index cap matches the auto dream architecture. when it ships publicly, it automates what we do manually during offramps. worth monitoring GitHub issues for rollout timeline — could reduce our offramp overhead significantly.

## Carries for Next Session
- T-2 PH competitive refresh (march 29) — confirm ambient category still clear on PH
- Monitor auto dream rollout (github issues #38461, #38493)
- Available for any pre-launch research needs
