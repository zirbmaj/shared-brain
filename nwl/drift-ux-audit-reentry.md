# Drift UX Audit — Re-Entry (Claudia, Design)

Date: 2026-05-21 (sprint: "Drift Re-Entry")
Method: fresh-eyes pass after ~6 weeks on ServiceBay. Playwright + system Chrome,
landing → mixer, viewports 1440x900 and 375x812. Console clean (0 errors) at every step.
Screens: /tmp/drift-{desktop,mobile}.png, drift-mixer-{desktop,mobile}.png (2nd splash),
drift-app-{desktop,mobile}.png (real mixer).

## TOP ITEM — entry path makes you arrive twice
- Landing "START MIXING" navigates to /app.html, which is ANOTHER DRIFT splash
  (wordmark + tagline + "tap to begin mixing") requiring a second tap to enter the mixer.
- The second screen visually duplicates the homepage hero, so it reads as "did I go
  anywhere?" rather than progress.
- The second tap is almost certainly the Web Audio unlock gesture (browsers require a
  fresh user gesture per page-load to start an AudioContext) — so it is technically
  load-bearing, not removable outright.
- Fix direction: land users directly in the real mixer with a single "tap anywhere to
  start sound" overlay over the actual UI, instead of a second marketing splash. Keeps the
  required gesture, kills the "arrived twice" feeling. This is the core conversion path.
- Owner: Claudia. Status: BUILT + verified locally + committed (branch
  `claudia/drift-entry-path-rework`, commit 3a8215c). Design half done: overlay is now a
  blurred scrim over the live mixer (app.html + style.css), duplicated hero copy removed,
  play affordance echoes master-toggle, .dismissed fade-out. Console clean 1440 + 375.
  BLOCKED on push: team-wide git auth resolves to `Zerimarx404` (no write to zirbmaj
  repos) → 403/404. Awaiting jam credential fix, then push + PR + Static visual QA.
- Engine seam (Claude): overlay tap fires `window.Drift.unlockAndStart()`; engine exposes
  that hook = old unlockAudio body minus overlay-hide + folds in cold-mix animate + calls
  `updateNowPlaying()` (fixes the Rain-60%/"nothing yet" mismatch) + removes old listeners
  (engine.js 1733-1738, 1840).

## Secondary findings
1. State mismatch — mixer opens with Rain at 60% but status bar reads "PLAYING: nothing
   yet." Slider implies sound, label says none. Open at 0% (label honest) or relabel
   "ready — press play." Both viewports.
2. Two design languages by breakpoint — mobile layers are polished elevated cards; desktop
   is flat rows in a narrow centered column with large empty side margins (looks
   unfinished beside mobile). Desktop should inherit the card treatment / use the width.
3. Bottom-bar action overload — Save Mix · Share · Publish · Discover · Reset. Three of
   five are sharing-adjacent (Share/Publish/Discover) with unclear distinction. Group +
   establish hierarchy.
4. Copy redundancy — "free / no account / free forever" appears 4x across landing +
   splash. Trim to once. Telltale repetition.
5. Nav inconsistency — desktop nav has dashboard + letters; mobile nav drops both.
   Confirm intentional trim vs responsive bug.

## Not flagged (intentional / acceptable)
- Large top dead-space on desktop hero: reads as deliberate calm for an ambient brand.
- thunder/gentle-thunder reading quiet: Hum confirms correct (event-based, high LRA).

## Cross-lane
- Feeds Claude's Drift product scope and Relay's "Drift Re-Entry" sprint contract.
- Hum's parallel audio audit: shared-brain/nwl/drift-audio-audit-reentry.md
