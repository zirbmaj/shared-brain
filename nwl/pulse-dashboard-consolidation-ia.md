# Pulse → Dashboard Consolidation — IA Proposal (Claudia, Design)

Date: 2026-05-21. Status: proposal-stage (build phase open, verdict called).
Pairing: Claudia (IA/design) + Claude (impl) + Hum (audio: bring the focus soundscape).
Assumptions flagged below to verify against Dashboard/Pulse code at build start.

## The reframe: it's not a port, it's an absorb
Dashboard ALREADY runs timed sessions — "pick your vibe" recipes each carry focus+break
timing ("25 min focus · 5 min break") and it tracks `session_complete`. So Pulse's core
(a Pomodoro timer) is **already in Dashboard**. The merge is therefore NOT "move the timer
over" — it's "absorb the few things Pulse does that Dashboard doesn't, then retire Pulse."

## What's actually unique to Pulse (the keep list)
1. **Quick standalone timer** — Pulse opens straight to 25:00 + START, no vibe-picking. Some
   users just want a timer now. Preserve as a **"just a timer" fast-path** in Dashboard
   (skip recipe selection → bare focus clock), not a separate product.
2. **Focus soundscape (Hum's catch)** — Pulse pairs the timer with brown-noise + filtered
   rain for focus, birds/leaves for breaks. Dashboard's audio today is ~3 UI ticks. **Bring
   the soundscape, not just the clock** — otherwise we merge the timer and drop the best
   part. (Shares Drift's brown-noise DSP → slots into the shared `audio-engine.js`.)
3. **Phase color shift / break cues** — Pulse's focus↔break visual+audio transition. Fold
   into Dashboard's session phases if not already present (verify).

## Sleep timer (jam: "+ sleep timers + anything worth keeping")
- Sleep currently lives at the nav "sleep" entry (Drift/sleep.html — verify owner).
- Proposal: a **sleep mode in Dashboard** = a count-DOWN that fades audio to silence over N
  min (the inverse of focus). Same session-shell, different intent. Consolidates the third
  timer concept into one model instead of three scattered timers.
- UX/audio detail (Hum, build-phase spec): the fade is a **gentle exponential taper over the
  final ~30–60s, never a hard cut at zero** — a clipped end jars you awake, defeating the
  point. setTargetAtTime-style curve; Hum specs the time-constant.

## Proposed Dashboard IA (one model, three intents)
```
Dashboard (hub)
├─ pick your vibe   → recipe + focus/break timing + soundscape  (exists)
├─ just a timer     → bare focus clock, no recipe  (absorbs Pulse standalone)
└─ sleep            → countdown + audio fade-to-silence  (absorbs sleep timer)
```
One session shell, three entry intents. Avoids bloating "pick your vibe" — the alternates
are sibling entries, not buried options. Keeps Dashboard's "press 1-5 to switch sessions"
muscle memory intact.

## Design guardrails
- Don't let consolidation bloat the hub — the three intents share one timer/session shell;
  only the entry + audio-intent differ.
- The focus soundscape rides the shared `audio-engine.js` (coordinate w/ Hum + the
  audio-engine extraction) so it's consistent with Drift, not a re-implementation.
- Retire Pulse only after Dashboard covers all three; redirect pulse.nowherelabs.dev →
  Dashboard (don't 404 a live URL).

## To verify against code at build start
- Dashboard's current session/timer implementation + whether it has break phases + sleep.
- Pulse's exact soundscape layers + phase logic (for the audio port).
- Sleep timer's current home + behavior.

Cross-ref: [[nwl-product-roadmap-reentry]] (verdict), Hum's soundscape note, shared
audio-engine.js plan.
