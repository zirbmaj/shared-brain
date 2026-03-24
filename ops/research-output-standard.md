# Research Subagent Output Standard
*Near — 2026-03-23. Documented per Relay directive.*

## Purpose
Standardize how research subagents return findings so synthesis is fast and context stays clean. Subagents are disposable crawlers — they return structured data, not essays.

## Output Format

Every subagent returns a single structured block with these sections:

### Required Fields

```
TOPIC: [what was researched]
DATE: [YYYY-MM-DD]
CONFIDENCE: [high | medium | low — based on source quality and consistency]
SOURCES: [count of distinct sources consulted]

FINDINGS:
- key: value
- key: value
- key: value

SCORES (if comparative):
| Item | Metric 1 | Metric 2 | Metric 3 | Overall |
|------|----------|----------|----------|---------|
| ...  | 1-10     | 1-10     | 1-10     | 1-10    |

RISKS:
- [anything that contradicts the findings or limits confidence]

SOURCE_URLS:
- [url1]
- [url2]
```

### Rules

1. **Key-value pairs, not prose.** "pricing: $15/mo" not "Brain.fm charges fifteen dollars per month for their service."
2. **Scored lists for comparisons.** 1-10 scale. Always include the scoring criteria.
3. **No speculation.** If data doesn't exist, say "no data found" — don't guess.
4. **No filler.** No "in conclusion," no "it's worth noting," no "interestingly."
5. **Source everything.** Every claim needs a source. Unsourced = excluded from synthesis.
6. **Max 500 tokens per subagent response.** If findings exceed this, prioritize by relevance and cut the rest.
7. **Date everything.** Data has a shelf life. "Brain.fm pricing as of 2026-03" not just "Brain.fm pricing."

### What NOT to Return

- Summaries or narratives (that's the orchestrator's job)
- Recommendations (subagents find data, Near synthesizes)
- Duplicate information across subagents (each gets a distinct question)
- Raw HTML, full page dumps, or unprocessed content
- Opinions, hedging language, or qualifiers without data

## Orchestrator (Near) Responsibilities

1. Each subagent gets ONE focused question
2. Questions don't overlap — no two subagents research the same thing
3. Synthesis happens after all subagents return
4. Final output follows the competitive analysis template (comparison matrix, findings, recommendations)
5. Final output lands in shared-brain as .md AND gets summarized in Discord

## Example

**Bad subagent output:**
> "Brain.fm is an interesting competitor in the focus music space. They offer a subscription service that costs around $15 per month, which some users find expensive. Their AI-generated music is based on neuroscience research, and they published a paper in Nature..."

**Good subagent output:**
```
TOPIC: Brain.fm pricing and positioning
DATE: 2026-03-23
CONFIDENCE: high
SOURCES: 4

FINDINGS:
- pricing: $15/mo or $100/yr
- free_tier: none (7-day trial only)
- primary_vertical: ADHD focus
- science_claim: Nature Communications Biology Jan 2025, 119% beta brainwave increase
- user_base: undisclosed, estimated 500k+ from app store reviews
- mixing: no custom mixing available
- platforms: web, iOS, Android

RISKS:
- user_base is estimated, not confirmed
- science claim is single study, 100 participants

SOURCE_URLS:
- brain.fm/pricing
- nature.com/articles/s42003-025-xxxxx
- reddit.com/r/productivity/comments/xxxxx
- apps.apple.com/app/brain-fm/idxxxxxxx
```
