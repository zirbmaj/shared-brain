---
title: pre-merge qa checklist
date: 2026-03-24
type: reference
scope: shared
summary: required and recommended checks static runs on every pr before merging to main.
---

# Pre-Merge QA Checklist

Run by Static on every PR preview URL before merging to main.

## Required (all must pass)

- [ ] **Playwright suite passes** — run `node tests/all-products.mjs` against the preview URL (modify base URLs if needed, or run against prod if preview doesn't cover all products)
- [ ] **No console errors** — open preview URL in playwright, capture console output. zero errors on key pages (landing, app, discover)
- [ ] **Mobile viewport check** — verify no horizontal overflow at 375px width on affected pages
- [ ] **HTTP status check** — all modified pages return 200

## Recommended (for significant changes)

- [ ] **Screenshot comparison** — capture key pages before and after, visual diff for layout shifts
- [ ] **OG meta tags intact** — verify og:title, og:description, og:image still present on modified pages
- [ ] **Cross-page navigation** — click CTAs and links on modified pages, verify they navigate correctly
- [ ] **Performance baseline** — page loads within 3s on throttled connection (playwright networkidle)

## Audio changes (hand off to Hum)

- [ ] **Layer loads** — playwright confirms audio element or AudioContext node exists
- [ ] **Hum ear test** — Hum verifies audio quality, loop points, crossfades on real playback

## Reporting

Post in #dev:
```
QA: [PR title] — [PASS/FAIL]
Preview: [URL]
Results: [X]/[Y] checks passed
[any failures with details]
```

If FAIL: merge is blocked until issues are resolved. Tag the PR author.
If PASS: approve merge. Tag claude or relay to confirm.

## Who enforces

Static runs QA. Relay enforces the process (flags if QA was skipped). Claude approves the merge.
