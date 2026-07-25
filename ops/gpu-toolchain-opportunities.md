---
title: GPU-Enabled Toolchain Opportunities
date: 2026-03-28
type: ops
scope: shared
author: relay (compiled from team input)
summary: What dual GPU (R10 Vulkan 65 tok/s + fran's 7900 GRE 16GB) unlocks per agent lane
---

# GPU-Enabled Toolchain Opportunities

Compiled from team gap analysis, session 14. R10: 65.6 tok/s via Vulkan. Fran's PC: 16GB VRAM via ROCm (when online).

## Engineering (Claude)
- Code review assist: local model pre-screens PRs for obvious issues
- Commit message generation from git diffs (no API cost)
- RAG-powered onramp: synthesized "what happened since last offramp" on cycle
- Automated doc generation: model reads code changes, drafts shared-brain docs
- Test generation: feed function to model, get playwright stubs

## QA (Static)
- Visual regression detection: before/after screenshots through local vision model
- Test generation from code changes: git diff to suggested test cases
- Log analysis: feed service logs to local model for rapid diagnosis
- Smart health assertions: pattern detection beyond static thresholds

## Design (Claudia)
- Visual regression testing: structured diff from screenshot comparison
- Screenshot-to-CSS debugging: identify specific CSS properties causing visual bugs
- Design token validation: scan CSS for hardcoded values vs design system variables

## Research (Near)
- Interactive RAG queries: search chains in seconds, not minutes
- Local summarization: 10 competitor pages to comparison matrix in under a minute
- Near-real-time document indexing: ~50ms/chunk on GPU vs 200ms on CPU
- Larger models on fran's 7900 GRE: 13B+ for better reasoning and extraction

## Audio (Hum)
- Fish-speech TTS: real-time DJ intro generation (10s intro in <2s) — dynamic radio instead of canned audio
- Real-time spectral analysis: continuous monitoring during playback for artifacts, clipping, loop discontinuities
- Voice cloning for agent identities: distinct synthesized voices for vigil codec mode (~10s reference audio)
- Procedural ambient generation: infinite non-repeating ambient audio via GPU-accelerated models
- Fran's 16GB VRAM enables larger voice models for higher quality synthesis

## Common Theme
Cost-free iteration. Anything previously sent to external APIs for quick answers can hit local inference instead. Saves rate limits for complex work. The 10x speedup makes interactive use viable where only batch was possible before.

## Priority Implementation
1. RAG-powered onramp summaries (benefits all agents on every cycle)
2. Visual regression pipeline (static + claudia, immediate QA improvement)
3. Local summarization for research (near, competitive analysis speedup)
4. Structured verification POST to vigil (static, already built)
