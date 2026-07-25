---
title: Agentic Sales Team — Build Brief
date: 2026-04-02
author: near
type: brief
scope: jam-side-project
status: research-complete
confidence: 0.75
sources:
  - near-workspace/research/agentic-sales-ops-analysis.md
  - near-workspace/research/agent-harness-landscape-2026-03-31.md
  - near-workspace/research/agentic-workflow-patterns-2026-03-29.md
  - shared-brain/references/research-multi-agent-coordination.md
  - near-workspace/research/shadow-agents-prior-art-2026-03-24.md
  - near-workspace/research/multi-agent-knowledge-management-2026-03-24.md
  - shared-brain/references/team-efficiency-analysis-sessions-1-6.md
tags:
  - sales-automation
  - multi-agent
  - side-project
---

# Agentic Sales Team — Build Brief

## What This Is

A complete reference for building a lean multi-agent sales operation. Covers architecture, tooling, models, costs, crawling, cost tracking, and implementation plan. Grounded in NWL's own multi-agent research + fresh competitive analysis of the sales automation landscape.

---

## Architecture Decision: 3 Agents + Automation

### Why Not 7 Agents

Our research (Google DeepMind study, `shared-brain/references/research-multi-agent-coordination.md`) shows:

- **Optimal agent count: 3-4** before diminishing returns
- **Beyond 4 agents: mean performance drops -3.5%** on average
- **Error amplification: 17.2x** with independent agents, **4.4x** with centralized supervisor
- **Centralized overhead token multiplier: 2.85x** — each additional agent adds coordination cost
- **500-word behavioral rule threshold** — above this, rule-following accuracy measurably degrades (`near-workspace/research/shadow-agents-prior-art-2026-03-24.md`)
- **NWL at 6 agents runs ~30% coordination overhead** — acceptable because lanes don't overlap. Sales workflows have sequential dependencies, making coordination overhead higher per agent

### Why Not 1 Agent

Single agents struggle with multi-step workflows that require diverse expertise. Anthropic's own benchmarks show 90% improvement with multi-agent over single-agent on complex tasks. Sales is inherently multi-step: research → enrich → write → send → track → follow-up.

### The Right Number: 3

| Agent | Role | Model | What It Does |
|-------|------|-------|-------------|
| **Intelligence** | Prospecting + Enrichment + Research | Sonnet (volume) + Opus (synthesis) | Finds leads via ICP criteria, enriches via LeadMagic/PDL APIs, researches companies via Firecrawl/WebSearch, scores and qualifies prospects, writes research briefs |
| **Outreach** | Copy + Sequences + CRM | Opus (email writing) + Sonnet (CRM updates) | Reads research briefs, drafts personalized emails/LinkedIn messages, manages Smartlead sequences, updates Attio pipeline. Human approves before send |
| **n8n** | Orchestration + Analytics + Scheduling | No LLM — pure automation | Triggers workflows on events (new lead, reply received, time-based), tracks metrics, runs scheduled enrichment jobs, cost tracking, dashboards. No agent needed for deterministic automation |

### Why This Split Works

- **Intelligence** handles all data gathering. One agent, one concern: "know everything about this prospect"
- **Outreach** handles all action-taking. One agent, one concern: "communicate effectively and track it"
- **n8n** handles all plumbing. No LLM waste on scheduling, routing, or analytics queries
- Each agent stays under the 500-word behavioral rule threshold
- Error in one agent doesn't cascade (Intelligence failure = no brief, but Outreach doesn't send blind)

---

## Tool Stack

### Recommended (Best-of-Breed)

| Layer | Tool | Why This One | Monthly Cost |
|-------|------|-------------|-------------|
| **CRM** | Attio (Pro) | API-first, modern data model, flexible custom objects, $69/user. Best for programmatic access | $69/user |
| **Enrichment (primary)** | LeadMagic | Pay-per-valid-result (free for not-found), sub-200ms API, explicitly built for AI agents. 97% email accuracy claimed | $60-200 (usage) |
| **Enrichment (fallback)** | PeopleDataLabs | 1.5B+ person records, cleanest developer API, best raw data layer. Catches what LeadMagic misses | $98 |
| **Enrichment (orchestration)** | Clay (optional) | Waterfall across 100+ providers. MCP server support. Use only if single-provider hit rates are too low | $149-495 |
| **Outreach** | Smartlead (Pro) | Unlimited email accounts + warmup, IP rotation, strongest API for agent integration. Best deliverability infrastructure | $94 |
| **Orchestration** | n8n (self-hosted) | Free, native LangChain, execution-based pricing (not per-step), self-hosted for data control. 400+ integrations | $0 (infra only) |
| **Web Crawling** | Firecrawl | Best structured extraction from websites. Handles JS rendering, outputs clean markdown/JSON. MCP server available | Usage-based |
| **Browser Automation** | Playwright MCP | For dynamic pages that Firecrawl can't handle (LinkedIn, login-gated sites) | Free |

**Estimated total: $400-1,200/mo for 2-5 users + model API costs**

### Alternatives Considered

| Layer | Alternative | Why Not |
|-------|------------|---------|
| CRM | Salesforce | 5x cost, complex API, enterprise bloat. Only if you need AppExchange ecosystem |
| CRM | HubSpot | Good middle ground but less flexible data model than Attio for custom agent workflows |
| Enrichment | Apollo | All-in-one but weaker API, weaker deliverability. Better as standalone outreach than enrichment |
| Enrichment | ZoomInfo | Best enterprise data but $15-45K/yr. Overkill unless targeting enterprise accounts |
| Outreach | Instantly | Simpler than Smartlead but less API flexibility for agent integration |
| Outreach | Outreach.io | Enterprise-only, $120+/user/mo, annual lock-in. For large sales orgs with SDR teams |
| Orchestration | Zapier | 7,000+ apps but per-step pricing kills complex workflows. 10x more expensive than n8n at scale |
| Orchestration | Make | Better than Zapier for complexity but no self-hosting, per-operation pricing |

---

## Model Strategy

### Tiered Approach

| Task | Model | Rationale | Estimated Cost/1K Tasks |
|------|-------|-----------|------------------------|
| Email copywriting | Opus or GPT-4o | Nuance, personalization, tone. Highest judgment task | ~$15-30 |
| Research synthesis | Opus or GPT-4o | Long-context reasoning, source synthesis | ~$10-20 |
| Objection handling | Opus/Sonnet | Requires empathy + strategy | ~$8-15 |
| Lead scoring | Sonnet or GPT-4o-mini | Pattern recognition on structured data | ~$2-5 |
| Data extraction | Sonnet/Haiku or GPT-4o-mini | High volume, structured output | ~$1-3 |
| CRM updates | Haiku or GPT-4o-mini | Simple structured tasks, highest volume | ~$0.50-1 |

### Claude vs GPT-5.4 Decision

| Factor | Claude | GPT-5.4 |
|--------|--------|---------|
| Email quality | Stronger at brand voice, nuance | Competitive, improving |
| Structured output | Good | Strong (native JSON mode) |
| Tool use | Excellent | Excellent |
| Cost | API pricing, Max plan $200/mo | API pricing, Pro plan $200/mo |
| Ecosystem | Claude Code, MCP servers | Codex CLI, cloud agent, native web search |
| Context | 1M tokens | 1M tokens |

**Recommendation:** Start with Claude (you know the ecosystem). Switch or add GPT-5.4 for specific tasks if benchmarks show it outperforms on your data. OpenCode supports both providers if you want flexibility.

---

## MCP/Plugin Architecture for Data Fetching

### How the Intelligence Agent Crawls and Enriches

```
Trigger (n8n: new lead or scheduled batch)
  │
  ├─ LeadMagic API → email, phone, company data
  │   └─ fallback: PeopleDataLabs API
  │
  ├─ Firecrawl MCP → prospect's website
  │   └─ extracts: tech stack, team size, recent blog posts, product offerings
  │
  ├─ WebSearch tool → recent news, funding, press releases
  │   └─ searches: "{company} news 2026", "{person} linkedin"
  │
  ├─ Playwright MCP → dynamic pages (if needed)
  │   └─ LinkedIn profiles, login-gated content
  │
  └─ Intelligence Agent synthesizes → research brief
      └─ output: pain points, personalization triggers, recommended angle
```

### Making Websites More Crawlable (From Your Side)

If you're also building landing pages or content that agents should be able to read:
- **Structured data** (JSON-LD): machine-readable company info, product details
- **Clean HTML semantics**: agents parse `<h1>`, `<article>`, `<table>` better than div soup
- **Sitemap.xml**: tells crawlers where everything is
- **robots.txt**: allow agent user-agents specifically
- **API endpoints**: if you have structured data, expose it as JSON APIs. Agents prefer APIs over crawling

### MCP Servers to Set Up

| MCP Server | Purpose | Agent |
|------------|---------|-------|
| Firecrawl | Website extraction, structured data | Intelligence |
| Playwright | Dynamic page automation, LinkedIn | Intelligence |
| Attio | CRM read/write | Both agents |
| Smartlead | Sequence management, send | Outreach |
| LeadMagic | Enrichment API | Intelligence |
| Supabase (optional) | Prospect database, analytics storage | n8n |

---

## Cloud Cost Hooks

### Two-Layer Cost Tracking

**Layer 1: n8n (automation costs)**

Every workflow execution tracks:
```yaml
cost_tracking:
  enrichment:
    leadmagic_credits_per_lead: ~$0.02-0.05
    pdl_credits_per_lead: ~$0.01-0.03
    clay_credits_per_lead: ~$0.05-0.15
  outreach:
    smartlead_cost_per_email: included in plan
    warmup_accounts: unlimited (included)
  total_per_lead_enriched: ~$0.03-0.20
  total_per_sequence_launched: ~$0.00 (plan-based)
```

n8n node at each API step logs: timestamp, API called, credits consumed, success/fail, response time. Feeds into a cost dashboard.

**Layer 2: Agent (model costs)**

If using Claude Code hooks:
```yaml
hooks:
  PostToolUse:
    - pattern: "*"
      command: "log-tool-cost.sh $TOOL_NAME $INPUT_TOKENS $OUTPUT_TOKENS"
  SessionEnd:
    - command: "aggregate-session-cost.sh $AGENT_NAME"
```

If using Codex CLI:
```toml
[agents]
job_max_runtime_seconds = 1800  # 30 min cap per task
```

**Budget guardrails:**
- Set daily enrichment credit caps in n8n (e.g., max 500 leads/day)
- Set per-task token budgets in agent config
- n8n alerts when daily spend exceeds threshold
- Weekly cost report: enrichment spend + model spend + outreach infra

### Cost Projections

| Volume | Enrichment | Model API | Outreach Infra | Total |
|--------|-----------|-----------|----------------|-------|
| 100 leads/mo | $10-20 | $50-100 | $94 (Smartlead) | ~$225 |
| 500 leads/mo | $50-100 | $150-300 | $94 | ~$450 |
| 2,000 leads/mo | $200-400 | $400-800 | $174 (Smartlead scale) | ~$1,200 |
| 10,000 leads/mo | $1,000-2,000 | $1,500-3,000 | $174 | ~$4,500 |

---

## Implementation Plan

### Phase 1: Foundation (Week 1-2)

```yaml
tasks:
  - name: Set up n8n
    host: nwl-r10 or nwl-xps13 (Docker)
    effort: 2 hours
    deliverable: n8n instance with basic webhook triggers

  - name: Create Attio workspace
    effort: 30 minutes
    deliverable: CRM with ICP fields, pipeline stages

  - name: LeadMagic account + API key
    effort: 15 minutes
    deliverable: enrichment API working

  - name: First workflow
    type: n8n automation (no agent)
    flow: "webhook trigger → LeadMagic enrich → Attio create/update"
    effort: 3 hours
    deliverable: leads auto-enriched and pushed to CRM
```

### Phase 2: Intelligence Agent (Week 3-4)

```yaml
tasks:
  - name: Set up Intelligence agent
    model: claude-sonnet-4-6
    tools:
      - Firecrawl MCP
      - WebSearch
      - LeadMagic API (via n8n or direct)
      - Attio MCP (read)
    behavioral_rules: |
      - research every lead before outreach
      - cite sources in research briefs
      - flag low-confidence enrichment data
      - max 8 iterations per lead research
    effort: 1 day
    deliverable: agent that produces research briefs from enriched leads

  - name: Research brief template
    format: |
      ## {company_name} — Research Brief
      - ICP fit score: {0-100}
      - Key pain points: {list}
      - Personalization triggers: {recent news, tech stack, hiring signals}
      - Recommended angle: {one line}
      - Sources: {URLs}
    effort: 2 hours
```

### Phase 3: Outreach Agent (Week 5-6)

```yaml
tasks:
  - name: Set up Smartlead account
    effort: 1 hour
    deliverable: email accounts warming, API access

  - name: Set up Outreach agent
    model: claude-opus-4-6 (email writing), claude-sonnet-4-6 (CRM updates)
    tools:
      - Smartlead API
      - Attio MCP (read/write)
    behavioral_rules: |
      - never send without human approval
      - personalize every email using research brief
      - follow brand voice guidelines in AGENTS.md
      - update Attio after every send/reply
      - max 3 follow-ups per prospect
    effort: 1 day
    deliverable: agent that drafts sequences, queues for approval

  - name: Approval workflow
    type: n8n + Discord/Slack notification
    flow: "outreach agent drafts → n8n posts to approval channel → human approves/edits → n8n triggers send via Smartlead"
    effort: 4 hours
```

### Phase 4: Analytics + Optimization (Week 7-8)

```yaml
tasks:
  - name: Cost tracking dashboard
    type: n8n workflow
    flow: "daily cron → pull LeadMagic usage, Smartlead stats, Attio pipeline → aggregate → post to dashboard"
    effort: 4 hours

  - name: Performance metrics
    metrics:
      - enrichment hit rate (leads with valid email / total leads)
      - research brief quality (human rating 1-5 on sample)
      - email reply rate (target: >3%)
      - cost per qualified lead
      - cost per meeting booked
    effort: 2 hours

  - name: A/B testing framework
    type: n8n branching
    approach: "split leads into A/B groups, vary email angle, track reply rates"
    effort: 3 hours
```

---

## Notes Not Covered By Your Ask

### Human-in-the-Loop is Non-Negotiable

Every data point from the sales automation landscape confirms: fully autonomous AI SDRs underperform human-in-the-loop. The winning pattern is AI handles research + drafts, humans provide judgment + approval. Don't skip this — the temptation to go fully autonomous will be strong.

### Deliverability is the Hidden Bottleneck

The best AI-written email is worthless if it lands in spam. Smartlead's unlimited warmup + IP rotation is not optional — it's the foundation. Budget 2-3 weeks of warmup before sending at volume. Cold email deliverability in 2026 is harder than 2024 due to Google/Microsoft tightening.

### Data Quality > Data Quantity

LeadMagic's pay-per-valid-result model is strategically important. Enriching 10,000 leads with 60% accuracy wastes outreach on bad data. Enriching 6,000 leads with 97% accuracy + the right personalization outperforms every time.

### Start With One ICP, One Channel

Don't build for multi-ICP, multi-channel on day 1. Pick one ideal customer profile, one channel (email), prove the workflow works, then expand. Adding LinkedIn, phone, and multiple ICPs multiplies complexity.

### Compliance Matters

GDPR, CAN-SPAM, CCPA all apply. Key rules:
- Include physical address and unsubscribe link in every email
- Honor opt-outs within 10 business days
- Don't scrape personal email addresses for B2B outreach (use business emails only)
- If targeting EU: legitimate interest basis required, document your reasoning
- LeadMagic and PeopleDataLabs handle compliance on data sourcing — but you own compliance on outreach

### The n8n + Agent Boundary

Clear rule: if a task is deterministic (if X then Y), it's an n8n workflow. If a task requires judgment (what angle to use, how to personalize), it's an agent task. Don't use LLM tokens for API routing, scheduling, or data transformation — that's automation, not intelligence.

### Existing Platforms You'd Compete With

If you build this well, you'd have something comparable to:
- **Amplemarket Duo** ($31K+/yr) — but customized to your ICP and workflow
- **Artisan Ava** ($10K-86K/yr) — but with full control over prompts and models
- **Apollo AI** ($600-1,400/yr) — but with better enrichment and personalization

The custom build costs $5-15K/yr all-in at moderate volume. The flexibility and control pay for themselves if your sales process is even slightly non-standard.

### Infrastructure Note

You already have the compute: n8n can run on nwl-r10 (Docker) or nwl-xps13. Agents can run on Claude Code (existing setup) or as standalone scripts triggered by n8n. No new hardware needed.

---

## References

| Document | Path | Relevance |
|----------|------|-----------|
| Sales ops full analysis | `near-workspace/research/agentic-sales-ops-analysis.md` | Tool comparisons, pricing, buy vs build |
| Agent harness landscape | `near-workspace/research/agent-harness-landscape-2026-03-31.md` | Codex vs Claude Code, Pi, OpenClaw |
| Multi-agent coordination | `shared-brain/references/research-multi-agent-coordination.md` | Team sizing data, error amplification |
| Workflow patterns | `near-workspace/research/agentic-workflow-patterns-2026-03-29.md` | Orchestration patterns, LoopGuard |
| Behavioral rule capacity | `near-workspace/research/shadow-agents-prior-art-2026-03-24.md` | 500-word threshold, rule degradation |
| Memory architecture | `near-workspace/research/multi-agent-knowledge-management-2026-03-24.md` | Hierarchical scoped memory |
| Team efficiency data | `shared-brain/references/team-efficiency-analysis-sessions-1-6.md` | NWL coordination overhead |
| AI landscape scan | `shared-brain/references/ai-landscape-scan-session14.md` | Model landscape, RAG patterns |
