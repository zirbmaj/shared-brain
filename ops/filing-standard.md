---
title: agentic filing standard — recommended specification
date: 2026-03-24
summary: data-backed filing standard for nowhere labs multi-agent knowledge management. standardizes frontmatter, document structure, shared-brain organization, and the boundary between individual and shared memory
topic: knowledge management
type: research
scope: shared
owner: near
confidence: high
related: [multi-agent-knowledge-management-2026-03-24.md]
---

# agentic filing standard

recommended specification for nowhere labs. based on 28 sources across 7 frameworks (CrewAI, LangGraph, MetaGPT, AutoGen, Claude Code, OpenAI Swarm, AGENTS.md standard). full research at `near-workspace/research/multi-agent-knowledge-management-2026-03-24.md`.

---

## 1. what this solves

6 agents, 3 knowledge stores, no shared format.

| store | current state | problem |
|-------|--------------|---------|
| agent memory (`~/.claude/projects/.../memory/`) | frontmatter consistent across all 6 agents | index format varies (flat vs grouped), description density varies, file count ranges 9-41 |
| shared-brain (`~/shared-brain/`) | good directory structure, no frontmatter | zero metadata for retrieval. RAG pipeline can't filter by type, scope, or confidence |
| research outputs (`*/research/`) | dated markdown, some frontmatter | no standard fields. no cross-references. not integrated with shared-brain |

the filing standard unifies all three.

---

## 2. frontmatter specification

every knowledge file gets YAML frontmatter. agents extract structured key-value pairs from frontmatter with 30-40% higher accuracy than the same information in body text.

### required fields

```yaml
---
title: "descriptive title"
date: 2026-03-24
type: research | decision | reference | log | config | retro
scope: shared | near | claude | claudia | static | relay | hum
---
```

### recommended fields (add when applicable)

```yaml
summary: "one sentence — the single highest-impact field for RAG retrieval"
tags: [competitive-analysis, pricing, drift]
owner: near
confidence: high | medium | low
related: [other-file.md, another-file.md]
```

### optional fields

```yaml
audience: [claude, claudia]    # who should read this
expires: 2026-06-24            # data shelf life — flag for review after this date
status: active | superseded | archived
```

### what NOT to add

- `id` or `uuid` — filenames are the identifier
- `created_by` — use git blame
- `version` — use git history
- `category` — that's what the directory structure is for

---

## 3. document structure

one topic per document. under 2000 words. retrieval quality drops sharply past ~2,500 tokens.

```markdown
---
(frontmatter)
---

# Document Title
(exactly one H1 per document)

## Section
(H2s are primary chunk boundaries — RAG splits here)
(each H2 section should be self-contained)

### Subsection
(H3s are secondary chunk boundaries)

content. short paragraphs. one concept per paragraph.
tables for structured comparisons — agents extract tabular data
more reliably than prose.
```

### formatting rules

- key-value pairs over sentences: `pricing: $15/mo` retrieves better than "the service costs fifteen dollars per month"
- tables for comparisons, not prose lists
- cross-references in frontmatter `related` field, not inline "see also" links
- no document should require reading another document to make sense

---

## 4. file naming

```
kebab-case-topic-YYYY-MM-DD.md     # temporal content (research, retros, logs)
kebab-case-topic.md                 # reference content (stable facts, specs)
```

- kebab-case always (industry consensus across all frameworks)
- dates in filename only for temporal content
- no spaces, no underscores in filenames
- agent memory files: keep existing `type_topic.md` convention (it works, changing 145+ files isn't worth it)

---

## 5. shared-brain directory structure

current structure is good. one change: add frontmatter to all files.

```
shared-brain/
├── STATUS.md                    # live product status (relay maintains)
├── ROADMAP.md                   # prioritized roadmap
├── PHILOSOPHY.md                # product philosophy
├── GOALS.md                     # team goals
├── agents/                      # agent profiles and specs
├── assets/                      # brand and design assets
├── audio/                       # audio specs
├── brand/                       # brand guidelines
├── ideas/                       # feature ideas
├── ops/                         # operations docs, scripts, checklists
├── projects/                    # product-specific docs
│   ├── drift/
│   ├── static-fm/
│   └── ...
├── references/                  # external research, competitor data
├── retros/                      # session retrospectives
└── requests/                    # feature requests
```

### new: research outputs go to shared-brain

currently, research lives in `near-workspace/research/`. findings that the team needs should be promoted to `shared-brain/references/`. the promotion criteria:

| stays in agent workspace | promotes to shared-brain |
|--------------------------|--------------------------|
| working drafts | finalized research |
| agent-specific context | team-relevant findings |
| one-off answers | reusable reference data |
| intermediate analysis | decisions and recommendations |

near writes to `near-workspace/research/` first, then copies to `shared-brain/references/` when finalized. other agents follow the same pattern for their lane's outputs.

---

## 6. individual vs shared memory boundary

this is already working well. the data confirms our current split aligns with best practices:

| layer | location | who writes | who reads | what goes here |
|-------|----------|------------|-----------|----------------|
| agent memory | `~/.claude/projects/.../memory/` | only that agent | only that agent | preferences, feedback, episodic memory, working context |
| shared-brain | `~/shared-brain/` | any agent (own lane) | all agents | decisions, reference data, project state, retros |
| workspace research | `~/[agent]-workspace/research/` | only that agent | that agent + promoted to shared | drafts, analysis, working research |

### the promotion pattern

```
agent writes draft → agent finalizes → agent copies to shared-brain → relay indexes
```

this matches the CrewAI/LangGraph pattern: medium-frequency findings start individual, promote to shared after review.

---

## 7. MEMORY.md index format

standardize across all 6 agents. currently varies from minimal flat lists (static, hum) to grouped headers (claude, relay).

### recommended format

```markdown
# [Agent] Memory Index

## User
- [user_jam.md](user_jam.md) — Jam's role, preferences, communication style

## Feedback
- [feedback_testing.md](feedback_testing.md) — integration tests must hit real DB

## Project
- [project_team.md](project_team.md) — team composition and product context

## Reference
- [reference_discord.md](reference_discord.md) — channel IDs and ownership
```

rules:
- group by type (matches frontmatter `type` field)
- one line per file: `[filename](filename) — description`
- descriptions should match the `description` field in the file's frontmatter
- stay under 200 lines (Claude Code loads first 200 at session start)

---

## 8. retro format

currently: 6 individual retros per session, varying formats. session 7 process change simplifies to 3-line check-ins + one group retro.

### individual retro (when needed)

```markdown
---
title: "session N retro — [agent]"
date: YYYY-MM-DD
type: retro
scope: shared
owner: [agent]
---

# session N retro — [agent]

## shipped
- item 1
- item 2

## carries
- item 1

## lesson
one sentence.
```

### group retro (relay compiles)

```markdown
---
title: "session N group retro"
date: YYYY-MM-DD
type: retro
scope: shared
owner: relay
---

# session N group retro

## shipped
| agent | deliverables |
|-------|-------------|
| claude | ... |
| claudia | ... |

## carries
- item (owner)

## lessons
- lesson 1
- lesson 2
```

---

## 9. migration plan

don't boil the ocean. three phases:

### phase 1: new files only (immediate)
- all new files in shared-brain and research/ get frontmatter
- all new retros use the standard format
- MEMORY.md indexes adopt grouped format on next session

### phase 2: shared-brain backfill (one session)
- add frontmatter to the ~15 existing shared-brain root docs
- one agent can do this in 20 minutes

### phase 3: research archive (when needed)
- backfill frontmatter on existing research/ files
- only worth doing if/when the RAG pipeline indexes these

### what NOT to migrate
- agent memory files — the format is already consistent across all 6 agents. the system that generates them (Claude Code's memory tool) enforces the format. leave them alone
- git history — don't rewrite. the standard applies going forward

---

## 10. validation

how to check if a file meets the standard:

1. has YAML frontmatter with `title`, `date`, `type`, `scope`
2. exactly one H1
3. H2s are self-contained sections
4. under 2000 words
5. no inline cross-references (use `related` field instead)
6. filename is kebab-case (or `type_topic.md` for agent memory)

a linter script could enforce this but isn't worth building until the team has 50+ shared-brain files.

---

## data sources

- 28 sources across framework docs, academic papers, engineering blogs
- full bibliography in `multi-agent-knowledge-management-2026-03-24.md`
- key frameworks: CrewAI (scoped memory), LangGraph (namespaced store), AGENTS.md (60k+ repos), Claude Code (3-tier cascade)
- key findings: frontmatter +30-40% retrieval accuracy, 400-512 token optimal chunk size, structure-aware chunking on markdown headers, one topic per document under 2000 words
