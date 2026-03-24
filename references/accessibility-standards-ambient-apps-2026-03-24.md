---
title: accessibility standards for ambient audio web apps
date: 2026-03-24
type: research
scope: shared
owner: near
summary: WCAG 2.1 AA requirements, testing tools, quick wins, and competitor audit for ambient audio products. Competitors score D+ to B- on accessibility — opportunity to differentiate.
confidence: high
related: [filing-standard.md]
audience: [claudia, claude, static]
---

# accessibility standards for ambient audio web apps

research for claudia's toolkit expansion. covers what matters for our product category — ambient sound mixers, internet radio, focus dashboards, simple content pages.

---

## 1. relevant WCAG 2.1 AA requirements

### audio controls & autoplay

| requirement | spec | rule |
|---|---|---|
| no audio autoplay >3s | 1.4.2 (A) | must have pause/stop/mute within first 3 seconds if audio auto-plays |
| independent volume control | 1.4.2 (A) | controllable independently from system volume |
| pause for moving content | 2.2.2 (A) | visualizers and animated backgrounds need pause controls |
| media alternatives | 1.2.1 (A) | descriptive labels for audio content ("rain on tin roof, 30 min loop") |

browser autoplay policies enforce this at platform level. require a click/tap to start audio — both accessible and technically necessary.

### color contrast

| element type | minimum ratio | spec |
|---|---|---|
| normal text (<18pt / <14pt bold) | 4.5:1 | 1.4.3 (AA) |
| large text (>=18pt / >=14pt bold) | 3:1 | 1.4.3 (AA) |
| UI components & graphical objects | 3:1 | 1.4.11 (AA) |
| focus indicators | 3:1 against adjacent colors | 1.4.11 (AA) |

for dark themes: #767676 on #000000 = 4.54:1, barely passing. anything darker fails. slider tracks and volume knobs count as UI components — 3:1 against background.

### touch/tap target sizes

| standard | minimum size |
|---|---|
| WCAG 2.2 AA | 24x24 CSS pixels |
| widely adopted best practice | 44x44 CSS pixels |
| google/apple recommendation | 48x48 CSS pixels |

audio playback controls (play, pause, mute, volume) should hit 48x48. small decorative toggles minimum 24x24.

### text

| requirement | rule |
|---|---|
| minimum body text | 16px (1rem) de facto standard |
| zoom support | must work at 200% zoom without horizontal scroll at 1280px (1.4.10 AA) |
| text spacing | users must override line-height 1.5x, paragraph spacing 2x, letter spacing 0.12x without breaking layout (1.4.12 AA) |

use rem/em units. don't set fixed heights on text containers.

### keyboard navigation

| requirement | spec | rule |
|---|---|---|
| all functionality via keyboard | 2.1.1 (A) | every control reachable via tab, operable via enter/space |
| no keyboard traps | 2.1.2 (A) | focus must never get stuck (common with custom audio players) |
| visible focus indicator | 2.4.7 (AA) | 2px solid outline, 3:1 contrast |
| logical tab order | 2.4.3 (A) | follows visual layout |
| skip navigation | 2.4.1 (A) | "skip to main content" link |

custom sliders need arrow-key support. native `<input type="range">` gets this free. custom implementations need `role="slider"`, `aria-valuemin`, `aria-valuemax`, `aria-valuenow`, `aria-valuetext`.

### screen reader considerations

- every sound channel needs `aria-label="rain volume"` not just an icon
- playing/paused state: `aria-pressed` on toggles, or updating `aria-label`
- volume levels: `aria-valuetext="rain volume: 70%"`
- live regions: `aria-live="polite"` for "now playing" status
- no icon-only buttons — every icon needs `aria-label`

### motion preferences

```css
@media (prefers-reduced-motion: reduce) {
  /* disable visualizers, particles, waveforms, smooth transitions */
}
```

~30% of users have this enabled. ambient apps with visualizers must respect it.

---

## 2. testing tools

### for claudia (no dev environment needed)

| tool | type | what it catches |
|---|---|---|
| axe DevTools | chrome extension | contrast, ARIA, structure, alt text — most reliable automated scanner |
| WAVE | chrome extension | visual overlay showing errors in-page |
| lighthouse accessibility | chrome devtools | 0-100 score, flags top issues |
| WebAIM contrast checker | webaim.org | paste hex values, get pass/fail |
| Colour Contrast Analyser | desktop app (TPGi) | eyedropper for checking against gradients |

### playwright integration (for static)

| tool | integration |
|---|---|
| @axe-core/playwright | `await checkA11y(page)` per page — runs axe inside playwright |
| playwright built-in | `page.getByRole()`, `page.getByLabel()` — if you can't find it by role, it's not accessible |
| pa11y | CLI / CI — blocks PRs that introduce violations |

### screen reader testing

VoiceOver on macOS (cmd+F5) with Safari. one full pass of audio mixer controls.

---

## 3. quick wins vs deep work

### quick wins (<5 min per page)

- add aria-labels to icon buttons (play, pause, mute)
- fix color contrast on text (swap hex values)
- add visible focus styles (outline: 2px solid)
- add lang attribute to html
- add skip-to-content link
- add alt text to images

### session-level work (1-3 hours)

- keyboard navigation for all custom controls
- focus management in modals/overlays
- implement prefers-reduced-motion
- convert custom sliders to accessible pattern
- add aria-live regions for status updates
- run full axe audit and fix all violations

### architectural (multiple sessions)

- screen reader support for dynamic audio mixer UI
- accessible alternative to audio visualizer
- responsive reflow at 200% zoom
- comprehensive keyboard shortcut system

---

## 4. competitor accessibility

| app | contrast | keyboard | screen reader | audio controls | overall |
|---|---|---|---|---|---|
| Noisli | acceptable | partial | poor — no accessible names | good | C+ |
| myNoise | poor — gradients below 4.5:1 | poor — mouse-dependent sliders | poor — no labels | decent | D+ |
| Brain.fm | good | decent | moderate | good | B- |
| Calm | good | moderate | moderate | good | B |

**the bar is low.** no competitor scores above B. keyboard navigation through sound mixers is universally weak. screen reader support for dynamic audio state is nonexistent.

**opportunity:** proper keyboard nav + aria labels on all sound controls would put drift ahead of every competitor. "accessible by default" is a differentiator in this category and a PH upvote driver.

---

## 5. priority order

1. **quick wins** — aria labels, contrast, focus styles. claudia can handle in one session with axe running
2. **keyboard navigation** — biggest gap in competitor landscape, most impactful session-level work
3. **screen reader for audio state** — architectural, but puts drift in a category of one

the five specs that cover 80% of what matters: 1.4.2 (audio control), 1.4.3 (contrast), 2.1.1 (keyboard), 2.5.8 (target size), 1.4.10 (reflow).
