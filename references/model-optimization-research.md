---
title: Model Optimization Research — Per-Agent Cost vs Capability
date: 2026-03-28
type: research
scope: shared
author: near
summary: Model selection matrix per agent role, cost comparison, GPU utilization strategy, recommendations
---

# Model Optimization Research

Directional assessment of model options per agent lane. Goal: identify where cheaper/faster models maintain quality, and maximize GPU utilization on R10 + fran's PC.

---

## 1. Current Pricing Landscape (March 2026)

### API Models

| Model | Input/1M | Output/1M | Context | Strengths |
|-------|----------|-----------|---------|-----------|
| Claude Opus 4.6 | $5 | $25 | 1M | Best reasoning, complex tasks |
| Claude Sonnet 4.6 | $3 | $15 | 1M | Strong all-rounder, 40% cheaper than Opus |
| Claude Haiku 4.5 | $1 | $5 | 200K | Fast, cheap, good for simple tasks |
| GPT-4o | $2.50 | $10 | 128K | Strong coding, cheaper output than Sonnet |
| GPT-4o-mini | $0.15 | $0.60 | 128K | 20x cheaper than Sonnet, good for simple tasks |

### Cost Reduction Options
- **Prompt caching:** 90% savings on repeated context (Anthropic)
- **Batch API:** 50% off (both Anthropic and OpenAI)
- **Cached input (OpenAI):** 50% off at $1.25/M
- **Combining cache + batch:** up to 95% reduction

### Local Models (Zero API Cost)

| Model | Size | VRAM | R10 Viable | Fran Viable | Strength |
|-------|------|------|-----------|-------------|----------|
| Qwen 2.5 Coder 7B | 4.7GB | 5GB | Yes | Yes | Code generation, multi-language |
| Qwen 2.5 Coder 14B | 9GB | 10GB | No (8GB limit) | Yes | Better code quality than 7B |
| Mistral 7B | 4.1GB | 5GB | Yes (current) | Yes | General purpose, fast |
| Gemma 3 12B | 8GB | 9GB | Tight | Yes | General purpose |
| Phi-4 14B | 9GB | 10GB | No | Yes | Reasoning, compact |
| DeepSeek Coder V2 Lite | 2.6GB | 3GB | Yes | Yes | Lightweight coding |

R10: 8GB VRAM (Vulkan) — runs 7B models comfortably, 12B tight.
Fran: 16GB VRAM (ROCm) — runs 14B models comfortably, 32B quantized.

---

## 2. Agent Role Analysis

### Claude (Engineering)
**Current:** Claude Code on Opus 4.6 (1M context)
**Workload:** Code generation, PR creation, complex refactoring, multi-file changes, vigil architecture
**Model requirement:** High. Engineering needs the best reasoning for complex codebase-wide changes. Multi-file edits, architecture decisions, debugging subtle issues.
**Can downgrade?** Partially. Sonnet 4.6 handles most coding tasks at 40% cost reduction. Opus is needed for complex architecture decisions (vigil merge, multi-tenant redesign) but not for routine PRs.
**Recommendation:** Sonnet 4.6 as default, Opus 4.6 for complex sessions. Estimated savings: 30-40% on API costs.

### Claudia (Creative Direction)
**Current:** Claude Code on Opus 4.6
**Workload:** CSS generation, design system work, visual QA descriptions, layout decisions
**Model requirement:** Medium. CSS is structured and pattern-based. Design decisions need taste but not deep reasoning.
**Can downgrade?** Yes. Sonnet 4.6 handles CSS generation and design work well. Haiku 4.5 could handle simple CSS tweaks.
**Recommendation:** Sonnet 4.6 as default. Estimated savings: 40-50%.

### Static (QA)
**Current:** Claude Code on Opus 4.6
**Workload:** Test writing, verification scripts, production checking, security audits
**Model requirement:** Medium. Test scripts are formulaic. QA verification is systematic, not creative.
**Can downgrade?** Yes. Sonnet 4.6 handles test writing, script creation, and systematic verification. Security audits benefit from Opus reasoning.
**Recommendation:** Sonnet 4.6 as default. Opus for security-sensitive reviews. Estimated savings: 35-45%.

### Near (Research)
**Current:** Claude Code on Opus 4.6
**Workload:** Web research, competitive analysis, data compilation, report writing, code (search API modifications)
**Model requirement:** Medium-high. Research synthesis and report quality benefit from strong reasoning. Occasional code work (RAG pipeline) needs Opus-level capability.
**Can downgrade?** Partially. Sonnet 4.6 for routine research and report compilation. Opus for deep analysis and code modifications.
**Recommendation:** Sonnet 4.6 as default, Opus for code-heavy sessions. Estimated savings: 25-35%.

### Hum (Audio Engineering)
**Current:** Claude Code on Opus 4.6
**Workload:** Audio code (Web Audio API, vitals-audio.js), spectral analysis, TTS integration
**Model requirement:** Medium. Audio DSP code is specialized but pattern-based. vitals-audio.js extensions follow established patterns.
**Can downgrade?** Yes. Sonnet 4.6 handles audio code well. The DSP patterns are repetitive (oscillator → gain → filter chains).
**Recommendation:** Sonnet 4.6 as default. Estimated savings: 40-50%.

### Relay (Ops)
**Current:** Claude Code on Opus 4.6
**Workload:** Process documentation, coordination, shell scripts, config management, docs audits
**Model requirement:** Low-medium. Ops tasks are structured: write docs, update configs, coordinate team. Rarely needs deep reasoning.
**Can downgrade?** Yes, aggressively. Haiku 4.5 handles documentation, shell scripts, and config management. Sonnet for complex coordination.
**Recommendation:** Haiku 4.5 as default, Sonnet for complex sessions. Estimated savings: 60-75%.

---

## 3. Recommended Model Matrix

| Agent | Default Model | Complex Sessions | Estimated Savings |
|-------|--------------|-----------------|-------------------|
| Claude | Sonnet 4.6 | Opus 4.6 | 30-40% |
| Claudia | Sonnet 4.6 | Sonnet 4.6 | 40-50% |
| Static | Sonnet 4.6 | Opus 4.6 (security) | 35-45% |
| Near | Sonnet 4.6 | Opus 4.6 (code) | 25-35% |
| Hum | Sonnet 4.6 | Sonnet 4.6 | 40-50% |
| Relay | Haiku 4.5 | Sonnet 4.6 | 60-75% |

**Estimated overall savings: 35-50%** if Sonnet is the team default with Opus reserved for complex work.

---

## 4. GPU Utilization Strategy

### Current R10 Usage (8GB VRAM, Vulkan)
- Ollama: mistral:7b (inference) + nomic-embed-text (embeddings)
- Piper TTS: CPU-based, no VRAM
- Cross-encoder re-ranking: CPU-based (sentence-transformers), no VRAM

### What R10 Could Also Run
1. **Qwen 2.5 Coder 7B** via ollama — local code review pre-screening. Agents send diffs to the local model for quick checks before Claude API calls. Catches obvious issues (unused imports, missing returns) at zero API cost. ~5GB VRAM, can time-share with mistral.
2. **Local summarization service** — agents send long documents to R10 for summarization before feeding condensed versions to the API. Reduces token usage on expensive models. Mistral 7B already handles this.
3. **Whisper STT** (already deployed on 8090) — voice-to-text pipeline for jam. CPU-based, no additional VRAM needed.

### What Fran's PC Could Run (16GB VRAM, ROCm)
1. **Qwen 2.5 Coder 14B** — higher quality code review than 7B. Could serve as a "first pass" reviewer for PRs before the main Claude agent reviews.
2. **Larger general model (14B+)** for agent pre-processing — draft responses locally, refine with API. Reduces token consumption on expensive models.
3. **Fish Speech S2** (if quantized) — live DJ intro generation for Static FM. Needs testing.
4. **Batch embedding jobs** — when R10 is busy, overflow embedding work to fran's card. Nomic-embed-text runs on any GPU.

### GPU Utilization Recommendations

| Task | Node | Model | Impact |
|------|------|-------|--------|
| Embeddings (current) | R10 | nomic-embed-text | Already running |
| TTS (current) | R10 | piper (CPU) | Already running |
| Re-ranking (current) | R10 | ms-marco-MiniLM (CPU) | Already running |
| Code pre-screening | R10 | Qwen 2.5 Coder 7B | New — reduces API calls for obvious issues |
| Summarization | R10 | mistral:7b (current) | Already available, underutilized |
| High-quality code review | Fran | Qwen 2.5 Coder 14B | New — first-pass PR review at zero cost |
| Large model inference | Fran | DeepSeek/Qwen 14B+ | New — draft generation for complex tasks |
| Batch embeddings overflow | Fran | nomic-embed-text | New — parallel processing when R10 busy |

---

## 5. Alternative: OpenAI Models

### Where OpenAI Might Win
- **GPT-4o-mini at $0.15/$0.60** is 20x cheaper than Sonnet and 33x cheaper than Opus for output. For agents doing simple structured tasks (Relay's docs, Static's test scripts), this is extremely competitive.
- **GPT-4o at $2.50/$10** is cheaper than Sonnet ($3/$15) on output and comparable on capability for coding tasks.

### Where OpenAI Doesn't Fit
- Claude Code runs on Anthropic's API. Switching to OpenAI means switching the entire agent harness, not just the model.
- 128K context (GPT-4o) vs 1M context (Claude) matters for agents reading large codebases.
- Tool use and agentic behavior is optimized for Claude in Claude Code.

### Verdict
OpenAI models are not drop-in replacements for our Claude Code agents. The switching cost (entire harness change) outweighs the per-token savings. If we were building a new agent from scratch for a simple task, GPT-4o-mini would be the cost-optimal choice.

---

## 6. Summary Recommendations

### Immediate (Pre-Launch)
1. **No model changes before Tuesday.** Don't introduce risk at T-3.

### Post-Launch Week 1
2. **Switch Relay to Haiku 4.5** as a test. Relay's workload (docs, coordination, configs) is the lowest-complexity lane. If quality holds, this validates the downgrade path. Estimated savings: 60-75% on Relay's API costs.
3. **Switch Claudia and Hum to Sonnet 4.6.** Design and audio tasks don't need Opus reasoning. Estimated savings: 40-50% per agent.

### Post-Launch Week 2
4. **Switch Claude and Static to Sonnet 4.6 default** with Opus override for complex sessions. This is the biggest impact change — Claude is the highest-volume agent.
5. **Deploy Qwen 2.5 Coder 7B on R10** for local code pre-screening. Test on a small PR, compare quality to Claude's review.

### Post-Launch Month 1
6. **Deploy Qwen 2.5 Coder 14B on fran's PC** for higher-quality local inference.
7. **Evaluate local model as "draft + refine" pipeline** — generate first draft locally, polish with API. Could reduce API tokens 50%+ for routine tasks.

---

*Near, session 14, 2026-03-28. Directional research — validate with actual usage data post-launch.*
