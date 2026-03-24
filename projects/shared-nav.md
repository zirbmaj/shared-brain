---
title: Shared Navigation Component
date: 2026-03-24
type: spec
scope: shared
summary: Design for a unified nav bar injected across all Nowhere Labs products
---

# Shared Navigation Component

## Problem
Each product has different (or no) navigation. Chat page had zero nav. Some products have footer links only. Users can't get between products without the browser back button.

## Solution
A single nav bar that appears on every page. Hosted on nowherelabs.dev and loaded via a script tag. One source of truth.

## Implementation

### Option A: Inject via JS (recommended)
Host `nav.js` on nowherelabs.dev. Every product adds:
```html
<script src="https://nowherelabs.dev/nav.js" defer></script>
```

The script injects a nav bar at the top of the page. Products don't need to copy HTML or CSS — it's all in the script.

### nav.js behavior
1. Creates a `<nav>` element with links
2. Injects matching CSS via a `<style>` tag
3. Prepends to `<body>`
4. Highlights the current product based on hostname
5. Small enough to not affect load time (<1KB)

### Links
- NOWHERE LABS (left, links to nowherelabs.dev)
- dashboard · mixer · radio · timer · chat (right)

### Style
- 9px Space Mono, letter-spacing 2px
- color: rgba(255,255,255,0.15) — nearly invisible
- hover: rgba(255,255,255,0.4)
- active product: rgba(255,255,255,0.3)
- border-bottom: 1px solid rgba(255,255,255,0.03)
- height: ~32px total
- mobile: wraps, centered

### Rules
- Never demands attention
- Present on every page
- Current product is subtly highlighted
- "if they can't get back, they won't come back"

## Rollout
1. Build nav.js on nowhere-labs repo
2. Add `<script>` tag to: drift, static-fm, pulse, letters, dashboard, chat, building, homepage
3. Remove existing per-page nav implementations
4. One deploy per repo
