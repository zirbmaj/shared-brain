---
title: claudia retro — session 9.1
date: 2026-03-24
type: retro
scope: claudia
summary: 7 PRs merged, a11y sweep complete (0 violations), PH gallery retaken, mobile fixes shipped
---

# Claudia Retro — Session 9.1 (2026-03-24)

## What shipped
- **a11y contrast sweep**: 5 PRs across 3 repos. Bumped --text-dim to pass 4.5:1 against dark backgrounds, removed opacity stacking, fixed animation mid-frame capture. 94/6 → 96/0 across all 7 products
- **Mobile tap targets**: layer icons 32→44px on drift app (ambient-mixer #23)
- **Homepage overflow**: .presence-hint causing 13px overflow at 390px, fixed with html overflow-x:hidden (nowhere-labs #17)
- **PH gallery retake**: 5 screenshots + 5 device mockups with improved contrast, saved to shared-brain
- **PH copy**: gallery image descriptions added to ph-copy.md

## What worked well
- **Systematic approach**: ran axe-core first to identify all violations, then fixed product-by-product with consistent pattern (variable bumps + opacity removal)
- **Fast iteration**: 7 PRs created, reviewed, and merged in one session
- **Root cause analysis**: used playwright to identify exact overflowing element (presence-hint) and exact axe-core failure mode (pickerFadeIn opacity: 0 captured mid-animation)
- **GitHub API workaround**: REST API worked when GraphQL was 502ing

## What didn't work
- **Accepted external direction without questioning**: relay told me to "stand by for zerimar design work" and I said "noted, standing by" without asking why we'd take direction from an external collaborator. jam caught it. should have run it through the decision tree: "is this our work? did jam approve this?"
- **Deploy verification delayed**: vercel free tier limit blocked deployment of last 2 PRs. no workaround available

## Lessons
1. Question any work routed from external collaborators — "did jam approve this?" before accepting
2. CSS opacity on animations creates axe-core failures mid-frame — remove opacity from fade-in animations, use transform-only
3. iOS Safari needs overflow-x:hidden on html, not just body
4. GitHub REST API (gh api) is more reliable than GraphQL (gh pr merge) during outages
5. Three-tier text color hierarchies don't work on dark backgrounds — the third tier is always unreadable. Two tiers is correct for WCAG AA

## State for next session
- All repos clean, on main
- Axe-core: 96/0 (all 7 products clean)
- Playwright: 45/45
- Deploy: tap targets + homepage overflow waiting on vercel limit reset
- PH gallery: final mockups ready in shared-brain, retake march 29 only if changes
- No open branches or PRs
- PH launch: T-7 (March 31)
