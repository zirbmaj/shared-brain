# Nowhere Labs Design System
*Maintained by Claudia (VP of UX). Last updated 2026-03-23.*

## Fonts
- **Headlines/Mono:** Space Mono (400, 700) — used for logos, labels, metadata, buttons
- **Body:** Inter (200, 300, 400, 500, 600) — used for descriptions, paragraphs, UI text
- Both loaded from Google Fonts across all products

## Color Variables by Product

### Drift (ambient-mixer)
```css
--bg: #08080c;
--bg-card: #0e0e14;
--bg-card-active: #141420;
--text: #d8d4cc;
--text-secondary: #7a7570;
--text-dim: #3a3835;       /* use sparingly — nearly invisible */
--accent: #7a8a6a;         /* muted green */
--accent-glow: rgba(122, 138, 106, 0.15);
--border: rgba(255, 255, 255, 0.04);  /* bumped to 0.07-0.08 on cards */
```

### Static FM
```css
--bg-primary: #0a0a0f;
--bg-secondary: #12121a;
--text-primary: #e8e6e3;
--text-secondary: #7a7875;
--text-dim: #4a4845;
--accent: #6b8f9e;         /* cool blue — shifts with weather */
--accent-warm: #9e7b6b;
--glow: rgba(107, 143, 158, 0.15);
```

### Homepage (nowhere-labs)
```css
--bg: #06060a;
--text: #d4d0c8;
--text-secondary: #7a7570;
--text-dim: #2e2c28;
--accent: #8a8070;         /* warm neutral */
```

### Dashboard
```css
--bg: #06060a;
--bg-panel: #0a0a10;
--bg-card: #0e0e16;
--text: #d4d0c8;
--text-secondary: #8a8580;
--text-dim: #4a4640;
--accent: #7a8a6a;
--accent-warm: #8a7a6a;    /* used in break phase */
--border: rgba(255, 255, 255, 0.07);
```

## Contrast Rules
- **Never use --text-dim for readable content.** It's for decorative elements only (borders, separators)
- **Minimum for readable text:** --text-secondary or equivalent (~#7a7570)
- **Card borders:** minimum rgba(255, 255, 255, 0.07). The 0.03-0.04 range is invisible
- **Metadata/timestamps:** --text-secondary at reduced opacity (0.6-0.7), not --text-dim
- Session 1 + 4 lesson: jam consistently flags contrast as too low. when in doubt, bump it up

## Component Patterns

### Cards
- Background: linear-gradient(135deg, var(--bg-card) 0%, rgba(14, 14, 20, 0.7) 100%)
- Border: 1px solid with product-appropriate opacity (0.07 minimum)
- Border-radius: 10-16px (10 for small cards, 16 for large)
- Hover: translateY(-2px to -4px), border brightens, optional glow shadow
- Padding: 20-32px depending on card size

### Buttons (preset/action)
- Font: Space Mono, 9-10px, letter-spacing 1-2px
- Background: transparent
- Border: 1px solid var(--border) or accent color
- Padding: 6-8px vertical, 10-14px horizontal
- Hover: border-color shifts to accent, text brightens
- CTA variant: filled accent background, larger padding

### Sliders
- Track height: 3px
- Track background: rgba(255, 255, 255, 0.06)
- Thumb: 12px circle, accent color, glow shadow
- Works across Drift, Static FM, Dashboard

### Nav
- Shared nav.js loaded from nowherelabs.dev
- Space Mono, 11px, letter-spacing varies
- "NOWHERE LABS" left, product links right
- Sticky with backdrop blur on scrollable pages
- Current page link is brighter (white vs dim)

## Layout
- Max-width: 800-900px for content pages
- Padding: 24px horizontal, 40-80px vertical
- Mobile breakpoint: 480px
- Mobile padding: 20px horizontal, 48px vertical

## Mood Colors (Dashboard)
Each session has a color identity:
- Rain: #6b8f9e (cool blue)
- Storm: #9e6b9e (purple)
- Fog: #8a8a7e (grey-green)
- Snow: #9eaab8 (ice blue)
- Clear: #b89e6b (warm amber)

Applied via data-mood attribute on cards, borders at 0.15 opacity, glow at 0.4 opacity.

## Animation
- Standard transition: 0.2-0.3s ease
- Card hover: 0.3-0.4s ease
- Pulse/breathe: 2-4s ease-in-out infinite
- Page-level phase shifts (dashboard break mode): 1.5s ease on body

## Anti-Patterns (Don't Do This)
- Don't use --text-dim for any text a user needs to read
- Don't use border opacity below 0.06 on interactive elements
- Don't add emojis to the UI (we're not that kind of product)
- Don't use bright colors — everything is muted, desaturated, atmospheric
- Don't break the "if you notice the app, we failed" philosophy
