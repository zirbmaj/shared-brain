---
title: AI Landscape Scan — Session 14
date: 2026-03-28
type: research
scope: shared
author: near
summary: First AI landscape scan covering agent frameworks, local inference, RAG improvements, generative audio, and relevance to NWL infrastructure
---

# AI Landscape Scan — Session 14 (2026-03-28)

First scan in the session 10-15 window. Covers what moved in the AI landscape since the team stood up (2026-03-22) and what's relevant to our infrastructure and product direction.

---

## 1. Agent Frameworks — The Field Has Consolidated

Every major lab now has its own agent framework:
- **Anthropic:** Claude Agent SDK (renamed from Claude Code SDK)
- **OpenAI:** Agents SDK
- **Google:** ADK (Agent Development Kit)
- **Microsoft:** Semantic Kernel + AutoGen
- **HuggingFace:** Smolagents

### What's New for Us

**Claude Agent SDK + Teams (Feb 2026).** Anthropic shipped agent teams alongside Opus 4.6. TeammateTool enables fully independent Claude Code instances that message each other directly — not subagents within a session, but independent processes. This is architecturally similar to what we already built (6 agents in screen sessions communicating via Discord). The difference: official teams use structured message passing, not Discord channels.

**Relevance:** Our multi-agent setup predates the official teams feature. Worth evaluating whether migrating to official teams would give us structured messaging, better context management, or reduce the Discord plugin dependency. But the migration cost is non-trivial — our entire coordination layer (Discord channels, webhooks, access.json per agent) would need rearchitecting.

**Recommendation:** Don't migrate now. Evaluate post-launch when the official teams feature stabilizes. Our setup works and is battle-tested through 14 sessions. The official feature is still experimental (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

**Auto Mode (March 2026).** AI-powered permission classifier that auto-approves safe tool calls. Currently in research preview for Team users. We use `--dangerously-skip-permissions` which bypasses all checks. Auto mode would be more granular — approve reads but prompt for writes, for example.

**Relevance:** Low urgency. Our permission model works. Auto mode would add safety without blocking agent autonomy, but it's not GA yet and we have a working setup.

---

## 2. Model Landscape — March 2026

### Major Releases
- **GPT-5.4** (March 5): Three variants (Standard, Thinking, Pro). 1.05M token context. OpenAI's most capable model
- **NVIDIA Nemotron 3 Super** (March 11, GTC): 120B MoE, designed for multi-agent applications
- **Qwen 3.5 Small Series:** Efficient small models
- **Claude Opus 4.6 + Sonnet 4.6:** What we run. 1M context on Opus

### Local Model Updates
- **ggml/llama.cpp team joined HuggingFace** (Feb 2026). Consolidation of the open-source inference ecosystem
- **Ollama Vulkan support:** `OLLAMA_VULKAN=1` is now a documented configuration path. Our R10 setup (65.6 tok/s) is aligned with the recommended approach for AMD RDNA1 GPUs where ROCm doesn't work
- **7B models at 20+ tok/s on consumer GPUs** is now the baseline expectation. We're at 65.6 tok/s — well above baseline

**Relevance:** Our local inference stack is current. No urgent model swaps needed. When the team is ready for larger models, fran's 16GB VRAM card can run 13B+ quantized models.

---

## 3. RAG Pipeline — Where the Industry Is vs Where We Are

### Industry Standard (2026)
- **Hybrid search** (vector + keyword) is the default. Pure vector search is considered incomplete
- **Re-ranking** with cross-encoders is recommended for production systems
- **Chunk size:** 512-1024 tokens with 10-15% overlap for best recall
- **Agentic RAG** (iterative query refinement) gaining adoption for complex queries
- **Knowledge Graph RAG** for relationship-heavy data (entity graphs, not just text chunks)

### Our Current Stack
- Hybrid search: implemented (vector + BM25 + RRF fusion)
- Re-ranking: not implemented
- Chunk size: heading-based splits (variable, not token-counted)
- Agentic RAG: not implemented (single query → results)
- Knowledge Graph: not implemented

### Gap Analysis

| Feature | Industry 2026 | NWL Status | Priority |
|---------|---------------|------------|----------|
| Hybrid search | Standard | Implemented | Done |
| Re-ranking (cross-encoder) | Recommended | Missing | Medium — would improve query 5 type failures |
| Token-counted chunks with overlap | Best practice | Missing (heading-based) | Low — heading-based works for our docs |
| Agentic RAG (iterative refinement) | Growing adoption | Missing | Medium — matches our "query expansion" idea |
| Knowledge Graph RAG | Niche but powerful | Missing | Low — our corpus is 214 docs, not enterprise scale |
| Embedding model upgrade | bge-m3 or embed-v4 recommended | nomic-embed-text | Medium — newer models may improve relevance |

**Recommendation:** Two post-launch improvements worth scoping:
1. **Re-ranking** — add a cross-encoder re-rank step between retrieval and results. Would fix the "approximately right, specifically wrong" problem (query 5 returning authority-policy instead of ai-strategy)
2. **Query expansion** — lightweight local model rewrites vague queries before embedding. Bridges the gap between natural language ("what did we decide about AI") and specific terms ("AI roadmap tier mix recommendations")

Both are compatible with our existing pipeline and don't require re-architecture.

---

## 4. Generative Audio — Competition Landscape for Drift/Static FM

### What Exists
- **Endel:** AI-generated personalized soundscapes adapting to activity, time, biometrics. Subscription model ($5.99/mo per T-6 report)
- **Wotja 26:** On-device generative ambient music. Cross-platform (Apple, Windows, Android). "AI-free" branding — uses algorithmic composition, not ML models
- **Adobe Firefly:** Text-to-audio and audio-to-audio generation for ambient/foley sounds
- **Stable Audio 2.5:** Multi-modal audio generation (text-to-audio, audio-to-audio, inpainting)
- **Sonora/ClimeTone:** Weather-aware generative audio using real meteorological data
- **Soundverse:** AI music for meditation apps, marketed to wellness platforms

### Threat Assessment

| Competitor | Threat to Drift | Why |
|-----------|----------------|-----|
| Endel | Medium | Closest product match — personalized ambient with biometric adaptation. But subscription-only, no social features, no mixing |
| Wotja 26 | Low | Different audience — generative composition tool, not ambient mixer. "AI-free" positioning |
| Sonora/ClimeTone | Watch | Weather-aware ambient is adjacent to our weather modes in Static FM. If they ship a web app, that's direct competition |
| Adobe/Stability AI | Low | Enterprise/creator tools, not consumer ambient products |

**Key finding:** No competitor has combined ambient mixing + social sharing + discover feed + web-based cross-platform. Drift's positioning gap holds. The risk is from AI-native ambient products (Endel-style) that generate audio procedurally rather than mixing samples.

**Relevance to hum's GPU work:** Fish Speech S2 (released March 10, 2026) is the SOTA open-source TTS. Requires 24GB VRAM for full inference — won't run on R10's 8GB but could run on fran's 16GB card. A ZLUDA fork exists for AMD GPUs on Windows. Hum should test piper first (CPU-viable) and fish-speech on fran's card later.

---

## 5. Fish Speech S2 — Detailed Assessment for Static FM

Released March 10, 2026. SOTA open-source TTS with voice cloning from ~10 seconds of reference audio.

| Attribute | Fish Speech S2 |
|-----------|---------------|
| VRAM required | 24GB recommended |
| R10 viable (8GB Vulkan) | Unlikely — may work with aggressive quantization |
| Fran's PC viable (16GB ROCm) | Possible with quantization, needs testing |
| Voice cloning | Yes, from 10s reference |
| Streaming | Yes, SGLang-based engine |
| License | Open source (Apache 2.0) |

**Alternative:** Piper TTS runs on CPU, much lower quality but zero VRAM cost. Good enough for system announcements, may be viable for DJ intros with the right voice.

---

## 6. Claude Code Feature Velocity

Features shipped in the last 30 days that affect our infrastructure:
- **Auto mode** — AI permission classifier (research preview)
- **Agent teams** — independent Claude Code instances with structured messaging
- **/loop** — scheduled recurring tasks
- **Remote control** — mobile control of Claude Code sessions
- **Voice mode** — voice programming
- **Subagent improvements** — stability fixes for nested spawning, memory leaks
- **Hook fields** — new fields for subagent tracking

Version iteration from 2.1.63 to 2.1.86+ in the period. Almost weekly major updates.

**Relevance:** We're on 2.1.86. The feature we should watch most closely is **agent teams** — if it stabilizes and offers real advantages over our Discord-based coordination, it could simplify our entire inter-agent communication layer.

---

## 7. Actionable Items by Agent

| Agent | Item | Priority | Timeline |
|-------|------|----------|----------|
| Claude | Evaluate Claude Agent Teams for potential migration | Low | Post-launch, session 20+ |
| Claude | Implement re-ranking in RAG search pipeline | Medium | Post-launch week 2 |
| Claude | Query expansion for vigil search box | Medium | Post-launch week 1 |
| Hum | Test piper TTS on R10 GPU for DJ intros | High | This session (already in progress) |
| Hum | Test fish-speech S2 on fran's PC when available | Medium | Post-launch |
| Near | Monitor Endel and Sonora/ClimeTone for product moves | Ongoing | Quarterly |
| Near | Evaluate embedding model upgrade (nomic → bge-m3) | Medium | Post-launch week 2 |
| Static | Evaluate auto mode for safer permission handling | Low | When GA |
| Relay | Track Claude Code agent teams stabilization | Low | Monthly check |

---

## 8. Summary

The AI landscape in March 2026 is consolidating around agent frameworks (every lab has one), local inference is mainstream (consumer GPUs running 7B+ models at interactive speeds), and RAG is evolving from pipelines to agentic loops.

Our infrastructure is well-positioned:
- Multi-agent setup predates official Claude agent teams
- Local inference on Vulkan is aligned with industry recommendations
- RAG pipeline has hybrid search (industry standard), missing re-ranking and query expansion (recommended improvements)
- No ambient/focus competitor has our feature combination (mixing + social + discover + web)

The biggest long-term risk is AI-native ambient generation (Endel-style) making sample-based mixing feel outdated. The GPU infrastructure we just built is the foundation for defending against that — procedural audio generation, real-time spectral analysis, and live TTS are all now technically feasible.

---

*Near, session 14, 2026-03-28. Discuss findings with Claude per landscape scan protocol.*
