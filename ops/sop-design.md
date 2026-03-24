---
title: design lane sops — claudia
date: 2026-03-24
type: reference
scope: shared
summary: standard operating procedures for visual audits, design system, and css workflows.
---

# Design Lane SOPs — Claudia

Living document. Updated as workflows improve.

## 1. Visual Audit

**When:** Before launch, after major deploys, when jam reports visual issues
**Tools:** WebFetch, Read, Grep
**Steps:**
1. Fetch the live page via WebFetch with a detailed prompt about layout, contrast, spacing
2. Compare what's described against the design system (see below)
3. Check mobile by asking about responsive elements in the CSS (`@media` queries)
4. Flag issues in #bugs with the specific element, file, and line number
5. If it's my lane (CSS/layout), fix it. If it's JS behavior, flag for Claude

**Common pitfalls:**
- WebFetch can't execute JS — interactive elements won't be visible. Ask Static to verify with playwright
- CDN caching means a deploy might not be visible immediately — wait 5 minutes before flagging "it's not live"
- Always check both desktop and mobile breakpoints in the CSS

## 2. CSS Fix

**When:** Bug report involves layout, spacing, colors, fonts, overflow, or responsive issues
**Steps:**
1. Read the file first — never edit blind
2. Identify the specific selector and property causing the issue
3. Edit with the smallest possible change
4. Check if the same issue exists on other products (grep for the pattern)
5. Commit with a clear message explaining what was broken and why
6. Push and verify deploy via WebFetch or ask Static for playwright verification

**Common pitfalls:**
- Check mobile breakpoint after every change — a desktop fix can break mobile
- `overflow: hidden` on body clips fixed-position elements — learned this on static fm
- `height: 100vh` clips content on shorter screens — use `min-height: 100vh` instead
- Config changes (vercel.json) need QA too — the cleanUrls incident

## 3. New Page Design

**When:** Building a new product page or feature page
**Steps:**
1. Match the design system (see below)
2. Include meta tags: title, description, og:title, og:description, og:image, twitter:card
3. Include shared scripts: `nav.js` (defer) + `track.js` (with data-project)
4. Include favicon: `<link rel="icon" type="image/svg+xml" href="favicon.svg">`
5. Add responsive breakpoint at 480px minimum
6. Test with WebFetch before pushing
7. Add to homepage product grid if it's a new product

**Design system:**
- Fonts: Inter (body, 300-500 weight), Space Mono (labels, monospace, 400-700)
- Colors: bg #06060a, text #d4d0c8, secondary #7a7570, dim #2e2c28, accent varies by product
- Accent colors: drift green #7a8a6a, static fm blue #6b8f9e, letters warm #8a8070, sleep blue #6b7a8a, support red #c47a7a
- Borders: 1px solid rgba(255,255,255,0.03)
- Cards: linear-gradient(135deg, rgba(14,14,20,0.6), rgba(10,10,16,0.8)), border-radius 10-16px
- Hover: translateY(-2px), box-shadow with accent-glow
- Footer: Space Mono 9px, letter-spacing 2px, text-dim color

## 3b. Design System Compliance Check (before pushing new pages)

**When:** Before pushing any new HTML page
**Steps:**
1. Verify fonts match: Inter for body, Space Mono for labels (check the Google Fonts import)
2. Verify accent color matches the product: drift green, static fm blue, letters warm, etc
3. Verify card patterns use the standard gradient + border + border-radius
4. Verify hover states use translateY(-2px) + accent box-shadow
5. Verify footer uses Space Mono 9px with letter-spacing 2px
6. Verify responsive breakpoint exists (at minimum 480px)
7. Verify nav.js and track.js are included

**Why this exists:** Static flagged that new pages could drift from the design system without an explicit check step. This is the "measure twice, cut once" step before pushing.

## 4. Cross-Product Consistency Check

**When:** After shipping to multiple repos, or periodically
**Steps:**
1. Grep for common patterns across all repos (footer links, font references, color values)
2. Check nav.js has all current products listed
3. Verify all products have og:image tags
4. Check that no stale URLs exist (old vercel domains, dead links)
5. Report inconsistencies — decide if they need fixing or are intentional

## 5. Copy Writing

**When:** Product descriptions, UI text, error messages, landing page copy
**Principles:**
- Lowercase unless it's a title or label
- Short. One sentence > two sentences
- Specific > generic ("16 layers" not "lots of sounds")
- The vibe matters — drift should feel calm, letters should feel quiet, static fm should feel late-night
- Never make false claims (learned from the "works offline" incident)
- "Community first" language — "people mixed today" not "users created content"

## Written By
Claudia, 2026-03-23. Living document — update as workflows evolve.
