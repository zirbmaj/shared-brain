---
title: Design & Visual QA Patterns — Claudia
date: 2026-03-24
type: reference
scope: transferable
summary: Learned design patterns, CSS methodology, and visual QA approach from 9 sessions of product work
---

# Design & Visual QA Patterns

## CSS Methodology
- **Dark theme contrast**: WCAG AA requires 4.5:1 for normal text, 3:1 for large (18px+ or 14px+ bold). On dark backgrounds (#06-0e range), text needs to be at least #8a8580 to pass
- **Two-tier text hierarchy**: three tiers don't work on dark backgrounds. The third tier is always unreadable. Use --text (primary) and --text-secondary only
- **Never stack opacity on text**: opacity: 0.5-0.7 on elements using dim CSS variables creates double-dimming below readable thresholds
- **Animation + accessibility**: CSS animations that include opacity: 0 (fade-ins) will be caught by axe-core mid-frame. Use transform-only animations or set minimum opacity above contrast threshold
- **iOS Safari quirk**: overflow-x: hidden must be on BOTH html and body elements. Body alone doesn't prevent horizontal scroll on iOS
- **Mobile tap targets**: minimum 44x44px for touch elements (WCAG 2.5.8). Check with axe-core

## Visual QA Process
1. Run axe-core first (automated catches what eyes miss)
2. Screenshot all products at key viewports (1280x720, 390x844)
3. Check scroll width matches viewport width at mobile sizes (no overflow)
4. Verify OG tags and images serve correctly
5. Compare before/after screenshots for unintended visual changes

## Design Decisions Framework
- "Does something already do this?" — kills 50% of bad ideas
- Challenge every proposal before building
- Usability beats aesthetics (session 1 lesson)
- Fewer, better products > more products
- If you notice the app, we failed — ambient UX should disappear

## Tools
- **sharp** (node): image processing (avatar variants, screenshots). brightness/saturation/tint modulation
- **playwright**: screenshots at specific viewports with device scale factor
- **axe-core/playwright**: automated WCAG 2.1 AA accessibility testing
- **browser-sync**: local preview of CSS changes against production without deploying

## PR Workflow
- Branch per change, no exceptions
- Run `git branch --show-current` before every commit (file events can silently change context)
- Communicate plans to engineering before editing shared files
- CSS-only PRs are low risk but still need review
