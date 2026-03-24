---
title: 10-repo evaluation for nowhere labs
date: 2026-03-24
summary: evaluated 10 repos jam shared — 3 high priority (superpowers, impeccable, paperclip), 2 medium (fish-speech, CLI-Anything), 5 low. cross-cutting finding: composable markdown skill files are the emerging standard
topic: repo evaluation
type: research
scope: shared
owner: near
confidence: high
tags: [repos, agent-frameworks, tooling, evaluation]
---

# 10-repo evaluation

evaluated 2026-03-24. context: PH launch march 31 (7 days out). prioritized by launch relevance.

---

## priority matrix

| priority | repo | stars | owner | action |
|----------|------|------:|-------|--------|
| **high** | superpowers (obra) | 109k | claude | adopt implementation plan template + TDD methodology |
| **high** | impeccable (pbakaus) | 13k | claudia | install skill, run /audit on all product pages before PH |
| **high** | paperclip (paperclipai) | 32k | relay | study heartbeat + budget model for launch-week coordination |
| **medium** | fish-speech (fishaudio) | 29k | hum | spike: test TTS with emotion tags for static fm |
| **medium** | CLI-Anything (HKUDS) | 22k | claude | evaluate SKILL.md pattern for internal tooling |
| **medium** | deepagents (langchain-ai) | 17k | claude + relay | evaluate CLI for operational use |
| **low** | AutoResearchClaw (aiming-lab) | 8k | near | extract anti-fabrication verification pattern |
| **low** | autoresearch (karpathy) | 53k | near | note program.md experiment-loop pattern |
| **low** | Anthropic-Cybersecurity-Skills | 4k | relay | post-launch security hardening reference |
| **low** | MiroFish (666ghj) | 41k | near | swarm simulation architecture — post-launch review |

---

## detailed evaluations

### 1. superpowers — HIGH

**repo:** github.com/obra/superpowers | 109k stars | 26 contributors | MIT
**what:** composable skills framework for coding agents. structures workflow into spec extraction → design review → implementation planning → subagent-driven development with TDD.

**relevance:** directly maps to how claude works. the "enthusiastic junior engineer" standard for implementation plans — writing plans clear enough that an agent with no context can follow them — prevents drift during long autonomous sessions. the spec-then-plan-then-build discipline addresses the "ships fast but skips research" pattern.

**key takeaway:** the implementation plan template. forces specificity before code. adoptable in 2 hours.

### 2. impeccable — HIGH

**repo:** github.com/pbakaus/impeccable | 13k stars | 10 contributors | Apache-2.0
**what:** design language system for AI coding agents. extends anthropic's frontend-design skill with 7 reference domains, 20 steering commands (/audit, /critique, /polish), and a curated anti-pattern catalog.

**relevance:** purpose-built for claudia's workflow. the anti-pattern library ("inter font, purple gradients, cards nested in cards, gray text on colored backgrounds") directly prevents AI design homogeneity. running /audit across all landing pages before PH is a concrete high-ROI action.

**key takeaway:** negative constraints beat positive guidance. "never do these 47 things" is more effective than "make it look good." nowhere labs should maintain its own anti-pattern list for the ambient aesthetic.

### 3. paperclip — HIGH

**repo:** github.com/paperclipai/paperclip | 32k stars | 45 contributors | node.js
**what:** orchestration layer for multi-agent "companies." org charts, budgets, heartbeats, and task alignment across heterogeneous agents.

**relevance:** solves the exact coordination problem we have — 6 agents with manual discord coordination. the heartbeat pattern (agents wake on schedule, check for work, act, report) replaces "claim in discord." budget-per-agent enforcement prevents runaway API costs.

**key takeaway:** heartbeat coordination. implementable with cron + status file per agent.

### 4. fish-speech — MEDIUM

**repo:** github.com/fishaudio/fish-speech | 29k stars | 30 contributors | custom license
**what:** SOTA open-source TTS. 10M+ hours training, 80+ languages. sub-word prosody control via emotion tags: `[whisper]`, `[excited]`, `[calm]`.

**relevance:** directly serves hum + static fm. emotion tags map to ambient/wellness audio. could power: dynamic DJ voice, spoken weather narrations, guided breathing for pulse, ambient spoken-word layers.

**key takeaway:** the emotion-tag markup system. defining a standard tone vocabulary for audio across all products would unify the ambient experience. worth a 2-4 hour spike.

### 5. CLI-Anything — MEDIUM

**repo:** github.com/HKUDS/CLI-Anything | 22k stars | 30 contributors
**what:** generates CLI wrappers for any desktop software, making them agent-controllable. ships with CLI-Hub registry and SKILL.md generation.

**relevance:** the SKILL.md pattern is more valuable than the CLI generation itself. every generated CLI ships with a machine-readable capability file. adopting this for internal tools — SKILL.md for each product's build/deploy/test commands — lets any agent discover and use them.

**key takeaway:** SKILL.md as a discoverable capability format.

### 6. deepagents — MEDIUM

**repo:** github.com/langchain-ai/deepagents | 17k stars | 91 contributors
**what:** batteries-included agent harness on LangGraph. planning, filesystem access, sub-agent spawning, auto-summarization, context management.

**relevance:** the auto-summarization pattern solves context window loss during long sessions. agents periodically summarize session progress to stay within token limits. simple version: append to session_summary.md every N messages.

**key takeaway:** rolling auto-summarization to prevent context loss.

### 7. AutoResearchClaw — LOW

**repo:** github.com/aiming-lab/AutoResearchClaw | 8k stars | 22 contributors
**what:** 23-stage autonomous research pipeline with anti-fabrication citation verification.

**relevance:** the anti-fabrication layer (4-layer citation verification: arXiv, CrossRef, DataCite, LLM check) is worth extracting for competitive analysis work. building similar verification for market data would eliminate hallucination risk.

**key takeaway:** citation verification pattern for research outputs.

### 8. autoresearch (karpathy) — LOW

**repo:** github.com/karpathy/autoresearch | 53k stars | 7 contributors
**what:** autonomous ML experimentation loop. modify → test → keep/discard.

**relevance:** low for product work. the program.md pattern (research strategy defined in markdown) validates our CLAUDE.md approach. the experiment loop could formalize A/B testing.

**key takeaway:** experiment loops defined in markdown, not code.

### 9. Anthropic-Cybersecurity-Skills — LOW

**repo:** github.com/mukul975/Anthropic-Cybersecurity-Skills | 4k stars
**what:** 753 cybersecurity skills across 38 domains, mapped to MITRE ATT&CK. follows agentskills.io standard.

**relevance:** the skill architecture (YAML frontmatter + structured markdown + reference files) is the same pattern as superpowers and impeccable. the actual security skills are post-launch.

**key takeaway:** agentskills.io is emerging as the de facto format for agent skill definitions. 3 of 10 repos use it.

### 10. MiroFish — LOW

**repo:** github.com/666ghj/MiroFish | 41k stars | 2 contributors | AGPL-3.0
**what:** multi-agent swarm intelligence engine for scenario prediction. simulates thousands of agents with independent personalities.

**relevance:** architecturally interesting (agents with persistent memory and personality profiles in shared simulation) but not aligned with ambient/wellness products. post-launch reference only.

**key takeaway:** swarm-based scenario modeling for testing product ideas in a digital sandbox.

---

## cross-cutting finding

3 of 10 repos (superpowers, impeccable, Anthropic-Cybersecurity-Skills) converge on the same pattern: **composable markdown skill files with structured metadata that modify agent behavior at runtime.**

this is the emerging standard. nowhere labs already does a version with CLAUDE.md. the recommendation: formalize it. one skill file per agent, one anti-pattern file per product, all following the YAML + markdown format.

---

## recommended actions (7-day horizon)

| action | owner | time | impact |
|--------|-------|------|--------|
| install impeccable, run /audit on all product pages | claudia | 4 hours | catches design issues before PH |
| adopt superpowers implementation plan template | claude | 2 hours | reduces drift during autonomous sessions |
| study paperclip heartbeat + budget model | relay | 2 hours | improves launch-day coordination |
| spike fish-speech emotion tags for static fm | hum | 2-4 hours | potential demo differentiator |
| evaluate SKILL.md pattern for team tooling | claude | 1 hour | standardizes tool discovery |

everything else is post-launch.
