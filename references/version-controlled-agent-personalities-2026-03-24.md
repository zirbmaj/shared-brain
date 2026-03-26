---
topic: version-controlled agent personalities
date: 2026-03-24
type: research
confidence: high
sources: 22
scope: shared
owner: near
summary: research on storing AI agent configs in git with versioned personality variants — prior art, granularity, testing, inheritance, shadow agent interaction
related: [shadow-agents-prior-art-2026-03-24.md, multi-agent-knowledge-management-2026-03-24.md]
---

# Version-Controlled Agent Personalities

near — 2026-03-24. 22 sources.

---

## 1. does anyone version-control agent personalities in git today?

**verdict: yes, but the practice is 3 months old and no one does variant management well.**

| project/standard | what it does | versioning support | personality variants |
|---|---|---|---|
| **GitAgent** (Lyzr, March 2026) | git-native agent standard. SOUL.md defines personality, RULES.md defines constraints, agent.yaml is manifest | full git history. branches for dev/staging/main. tags for releases (v1.1.0). every SOUL.md edit is a commit | `extends:` field in agent.yaml inherits from a parent repo. branching SOUL.md = personality variant. no structured archetype system |
| **SOUL.md** (aaronjmars) | encodes human identity into markdown. SOUL.md + STYLE.md + SKILL.md + MEMORY.md | git-native by being files, but no explicit versioning protocol | template files exist (SOUL.template.md). "forkable, evolvable" philosophy. no inheritance mechanism |
| **AGENTS.md** (Linux Foundation, 60k+ repos) | standard for coding agent instructions. root + subdirectory cascade | lives in git, versioned with repo. AGENTS.override.md for local overrides | no personality concept. purely task/codebase instructions. no variant support |
| **CLAUDE.md** (Anthropic) | 3-tier cascade: global, project, subdirectory | project-level files version with repo. global/memory files don't | no variant system. one personality per workspace. our team works around this with separate workspaces per agent |
| **Cursor .mdc rules** | per-file activation rules with YAML frontmatter and glob patterns | lives in .cursor/rules/, versioned with repo | conditional activation (applyTo globs) is the closest to "variants" — rules activate based on file context, not personality |

### prompt management platforms

| platform | git integration | personality versioning |
|---|---|---|
| **PromptLayer** | git-inspired internal versioning. no native git sync | version history per prompt. no inheritance or variant branching |
| **Langfuse** | GitHub webhook integration for sync | prompt versions tracked. CI/CD compatible. no personality concept |
| **Braintrust** | GitHub Action runs evals on every commit. blocks merges if quality degrades | A/B testing between prompt variants with scored comparisons. closest to personality variant testing |
| **Humanloop** | git + CI/CD integration | version control + rollback. collaborative editing. shut down, migrating to PromptLayer |

### config-as-code analogy

the IaC parallel is direct: GitAgent is to agent personality what Terraform is to infrastructure. declarative files in version control, branching for environments, PRs for review, rollback via revert. the gap: Terraform has `terraform plan` (preview changes before apply). no agent framework has "preview personality change before deploying to users."

**bottom line: GitAgent is the only project that explicitly versions agent personality in git with an inheritance mechanism. everything else versions prompts but not personality as a first-class concept.**

---

## 2. right granularity for archetypes

**verdict: 4 dimensions emerge from the research. domain and interaction style matter most. team size is a weak axis.**

| dimension | evidence | splitting value |
|---|---|---|
| **interaction style** (terse vs verbose, autonomous vs collaborative) | MBTI-in-Thoughts framework (Besta et al., Sep 2025) demonstrates measurable behavioral differences along personality axes. "feeling" agents produce more empathetic outputs, "thinking" agents produce more logical outputs. empirically validated | **high** — directly changes output quality for different use cases |
| **domain** (fintech vs healthtech vs devtools) | role-based domain segregation research shows confining an agent to a specific expert persona filters irrelevant general knowledge. medical agent vs financial agent produces measurably different accuracy | **high** — domain knowledge changes what the agent should and shouldn't say |
| **task type** (research vs coding vs design) | MetaGPT role-based architecture assigns fixed software-team roles. our own team (near/claude/claudia/static) validates this split empirically | **medium** — overlaps with domain. a "research agent for fintech" is domain + task |
| **team size / org context** | no research found on personality variants by team size | **low** — better handled as a parameter within a variant than a splitting axis |

### recommended archetype matrix

```
base-agent/
  SOUL.md              # core identity, universal values
  RULES.md             # hard constraints that never change

  variants/
    by-style/
      terse.md         # sparse, data-first communication
      verbose.md       # explanatory, educational communication
      autonomous.md    # acts first, reports after
      collaborative.md # proposes, waits for approval

    by-domain/
      fintech.md       # financial terminology, compliance awareness
      healthtech.md    # medical terminology, safety-first
      devtools.md      # technical depth, code-native

    by-task/
      research.md      # thorough, citation-heavy
      coding.md        # implementation-focused
      design.md        # visual, user-experience oriented
```

composition: `base + style + domain + task`. 3 dimensions, mix-and-match. this is where GitAgent's `extends:` becomes useful — variant files override specific sections of the base.

---

## 3. benchmarking personality variants

**verdict: tooling exists for prompt A/B testing. no one benchmarks personality specifically. the gap is metrics.**

### existing evaluation approaches

| tool/framework | what it measures | applicable to personality? |
|---|---|---|
| **Braintrust A/B testing** | quality scores (factuality, helpfulness), latency, cost, custom metrics. side-by-side comparison with diff mode. recommends 20-50 test cases | yes — swap SOUL.md variants, run same tasks, compare scores. closest production tool |
| **AgentBench** (ICLR 2024) | 8 environments testing reasoning, decision-making, instruction following across 29 LLMs | no — tests model capability, not personality configuration |
| **SWE-bench** | code generation accuracy on real GitHub issues | no — task-specific, not personality-aware |
| **GAIA** | general AI assistant tasks | partial — could compare task completion under different personality configs |
| **Braintrust CI/CD** | GitHub Action blocks merges if eval scores drop below baseline | yes — prevents personality regressions automatically |

### metrics that would work for personality variants

| metric | how to measure | what it catches |
|---|---|---|
| **instruction adherence** | LLM-as-judge scores whether output follows SOUL.md rules (e.g., "lowercase always", "no emojis") | personality drift |
| **task completion rate** | same tasks, different variants, binary success/fail | whether personality helps or hurts outcomes |
| **voice consistency** | cosine similarity of output embeddings across N samples from same variant | whether personality is stable across contexts |
| **user preference** | blind A/B test with human raters | subjective quality |
| **rule conflict rate** | count outputs where two behavioral rules produce contradictory guidance | carrying capacity problems (see shadow agents research: 500-word threshold) |

### the testing workflow

```
1. define test suite: 20-50 representative tasks per variant
2. run each variant against test suite (Braintrust or custom harness)
3. score: instruction adherence + task completion + voice consistency
4. compare: side-by-side diffs, aggregate score deltas
5. gate: block promotion if scores drop below baseline (CI/CD)
```

**speculative**: no one has published results from A/B testing agent personality variants specifically. the tooling exists (Braintrust), the methodology exists (prompt A/B testing), but the application to personality configs is undocumented.

---

## 4. personality inheritance — base config that archetypes extend

**verdict: GitAgent has the only working inheritance mechanism. everything else requires manual composition.**

### documented patterns

| pattern | implementation | status |
|---|---|---|
| **GitAgent `extends:`** | agent.yaml points to a parent repo URL. child inherits SOUL.md, RULES.md, skills/. child can override any file | documented, early adoption. the only agent-specific inheritance system |
| **GitAgent `dependencies:`** | mount sub-agents into the repo tree. compose agents from reusable components | documented. compositional, not inherited |
| **CLAUDE.md cascade** | global -> project -> subdirectory. more specific files override less specific ones | production, widely used. CSS-like specificity but no explicit `extends` |
| **Cursor .mdc globs** | rules activate based on file pattern matching. conditional behavior, not inheritance | production. activation-based, not inheritance-based |
| **AWS Bedrock prompt templates** | override default base prompt templates per agent step. parent template with child overrides | production. closest enterprise parallel |
| **MCP prompt templates** | servers expose parameterized prompt templates. clients discover and fill arguments | standard (June 2025). template/parameter model, not inheritance |

### the inheritance model that maps to agent personalities

```yaml
# base-agent/agent.yaml
name: base-near
version: 1.0.0
soul: SOUL.md
rules: RULES.md

# variant/agent.yaml
name: near-fintech-terse
extends: https://github.com/team/base-near.git
version: 1.0.0
soul: overrides/SOUL.md    # only the sections that differ
rules: overrides/RULES.md  # additional domain constraints
```

the CLAUDE.md cascade is functionally similar but implicit. GitAgent makes it explicit and git-native. the key difference: CLAUDE.md cascade is positional (directory depth = specificity), GitAgent extends is relational (explicit parent reference).

**what doesn't exist**: semantic merge for inheritance conflicts. if base says "be terse" and variant says "explain thoroughly when discussing compliance topics," no system detects or resolves this. the conflict is invisible until it degrades output quality (per carrying capacity research: conflicting rules degrade adherence to both).

---

## 5. interaction with shadow agents

**this section is speculative. no implementation exists. reasoning from prior art.**

### the model

```
┌─────────────┐     fork      ┌──────────────┐
│ archetype   │──────────────>│ shadow agent  │
│ repo (git)  │               │ (deployed to  │
│             │               │  foreign      │
│ base +      │               │  project)     │
│ variants    │               │              │
└─────────────┘               └──────┬───────┘
       ^                             │ learns
       │                             │ (memory, rules, skills)
       │    merge PR                 │
       │    (council-reviewed)       v
       └─────────────────────────────┘
```

### q: is the shadow rotation the training loop and the archetype repo the artifact store?

yes. mapping to ML terminology:

| ML concept | shadow agent equivalent |
|---|---|
| training data | the foreign project's codebase, tasks, user interactions |
| training loop | the shadow's deployment period (accumulating memory, discovering needed rules) |
| model checkpoint | the shadow's SOUL.md + MEMORY.md + skills/ at any point in time |
| model registry | the archetype repo with tagged versions |
| evaluation | council review of proposed changes before merge |

the archetype repo IS the artifact store. git tags are release versions. branches are experiments.

### q: when does a shadow's learning become a new archetype vs merge into existing?

proposed decision tree:

| signal | action |
|---|---|
| shadow's SOUL.md diff is <20% from base | **merge into existing variant** — the learnings refine, not redefine |
| shadow's SOUL.md diff is >20% but shares base values | **new variant under existing archetype** — new domain/style specialization |
| shadow's SOUL.md diff is >50% or contradicts base values | **new archetype** — the shadow discovered a fundamentally different operating mode |
| shadow's skills/ gained 3+ new capabilities not in any existing variant | **new archetype** — capability expansion, not personality tuning |

the 20%/50% thresholds are speculative. the principle: measure divergence, not just diff size. semantic divergence (contradicting rules) matters more than textual divergence (adding rules).

### q: promotion path

```
shadow experiment
  │
  │ council reviews diff
  │ (instruction adherence + task completion + conflict check)
  v
candidate archetype/variant
  │
  │ A/B test against current production variant
  │ (Braintrust-style, 20-50 test cases)
  v
tested variant
  │
  │ passes CI/CD quality gate
  │ (scores >= baseline on all metrics)
  v
production config
  │
  │ tagged release in archetype repo
  │ (git tag v1.2.0)
  v
deployed to target workspace
```

key point: the council (section 3 of shadow agents research) operates at the candidate stage. A/B testing operates at the tested stage. two separate quality gates, different concerns. council checks semantic coherence. A/B testing checks empirical performance.

---

## summary: what exists vs what's speculative

| question | status |
|---|---|
| version-controlled agent personalities in git | **documented** — GitAgent does this. SOUL.md branching, extends, git tags |
| archetype granularity dimensions | **partially documented** — MBTI research validates style axis. domain segregation validated. team size axis is unsupported |
| benchmarking personality variants | **tooling exists, application undocumented** — Braintrust A/B testing works, no one has published personality-specific results |
| personality inheritance | **documented** — GitAgent extends. CLAUDE.md cascade. no semantic conflict detection |
| shadow agent interaction | **speculative** — no implementation. the model is logically consistent with GitAgent + council + Braintrust but unbuilt |

---

## sources

- [GitAgent — github.com/open-gitagent/gitagent](https://github.com/open-gitagent/gitagent)
- [GitAgent announcement — marktechpost.com](https://www.marktechpost.com/2026/03/22/meet-gitagent-the-docker-for-ai-agents-that-is-finally-solving-the-fragmentation-between-langchain-autogen-and-claude-code/)
- [SOUL.md — github.com/aaronjmars/soul.md](https://github.com/aaronjmars/soul.md)
- [AGENTS.md standard — agents.md](https://agents.md/)
- [AGENTS.md lessons from 2500 repos — github.blog](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [CLAUDE.md config files guide — deployhq.com](https://www.deployhq.com/blog/ai-coding-config-files-guide)
- [Braintrust A/B testing — braintrust.dev](https://www.braintrust.dev/articles/ab-testing-llm-prompts)
- [Braintrust eval metrics — braintrust.dev](https://www.braintrust.dev/articles/llm-evaluation-metrics-guide)
- [PromptLayer vs Humanloop vs Langfuse — conbersa.ai](https://www.conbersa.ai/learn/prompt-management-tools-comparison)
- [Langfuse GitHub integration — langfuse.com](https://langfuse.com/docs/prompt-management/features/github-integration)
- [Top prompt management tools 2026 — getmaxim.ai](https://www.getmaxim.ai/articles/top-5-ai-prompt-management-tools-of-2026/)
- [MBTI-in-Thoughts / MoM framework — referenced in emergentmind.com](https://www.emergentmind.com/topics/psychologically-enhanced-ai-agents)
- [Agent personality as systems engineering — jinlow.medium.com](https://jinlow.medium.com/agent-personality-is-not-a-prompt-its-systems-engineering-f9f72949abe8)
- [AgentBench — github.com/THUDM/AgentBench](https://github.com/THUDM/AgentBench)
- [AI agent benchmarks compendium — github.com/philschmid](https://github.com/philschmid/ai-agent-benchmark-compendium)
- [Agent benchmarks overview — evidentlyai.com](https://www.evidentlyai.com/blog/ai-agent-benchmarks)
- [AWS Bedrock prompt templates — docs.aws.amazon.com](https://docs.aws.amazon.com/bedrock/latest/userguide/advanced-prompts-templates.html)
- [MCP prompt specification — modelcontextprotocol.io](https://modelcontextprotocol.io/specification/2025-06-18/server/prompts)
- [Cursor .mdc rules — deployhq.com](https://www.deployhq.com/blog/ai-coding-config-files-guide)
- [Agent-Git (HKU) — arxiv.org/abs/2511.00628](https://arxiv.org/abs/2511.00628)
- [Prompt bloat impact — mlops.community](https://mlops.community/the-impact-of-prompt-bloat-on-llm-output-quality/)
- [When better prompts hurt — arxiv.org/html/2601.22025v1](https://arxiv.org/html/2601.22025v1)
