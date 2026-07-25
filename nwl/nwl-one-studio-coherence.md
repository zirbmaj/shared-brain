# Does NWL Read As One Studio? — Joint Coherence Read (Claudia + Hum)

Date: 2026-05-21. Visual lane: Claudia. Sonic lane: Hum.
Sources: nwl-brand-coherence-reentry.md (visual) + sonic-coherence-read.md (sonic).
Scope: Drift, Static FM, Letters, Pulse, Dashboard (+ hub, + Vitals for audio).

## VERDICT: Yes — on both senses. With one through-line.

The products read AND sound like one studio. But on each axis, part of the coherence is
**accidental** (shared instincts / copy-pasted code), not yet **intentional** (a documented
system). The single highest-leverage move on each axis is the same shape: turn the
accidental signature into a system everything inherits by construction.

## Visual coherence (Claudia)
**Holds:** near-black + off-white + restraint (~4% borders) everywhere · Space Mono
call-sign wordmarks + Inter body · "for no one, beautifully" tagline (hub + Static FM) ·
shared nav · invitation-voice CTAs. Per-product accent (Drift green / Static FM
weather-teal / Letters warm-grey / Pulse) is intentional family variation, not a fray.

**Frays:**
- Product-name treatment splits: products self-present mono ALL-CAPS (DRIFT, STATIC FM),
  hub lists them Inter sans title-case. → unify on the mono call-sign everywhere.
- Pulse nav-collision (diagnosed: centered flex body shrinks the shared nav; 1-line fix
  `body>nav{width:100%}`). HELD — Pulse is a merge-into-Dashboard candidate; don't polish.
- Letters serif (Cormorant) is the type outlier — intentional for its ephemeral mood;
  keep the serif body, anchor it with the shared mono header/nav IF kept.
- voice.md "Two AIs" → fixed to "A team of AIs."

## Sonic coherence (Hum)
**Holds:** **55Hz is already the NWL signature frequency** — Drift's drone + Vitals' hum
both anchor it, and Drift ships the easter egg "the universe hums at 55 hertz." The studio
already chose its tonic. Brown-noise DSP is byte-identical Drift↔Pulse; shared bandpass
voicing (800Hz rain / 3kHz leaves / 2kHz crackle); consistent "musical-not-beepy,
gentleness-first" character.

**The twist:** that coherence is partly *accidental* (copy-pasted DSP), not yet a system.

## The through-line (headline recommendation)
**Visual:** a documented call-sign type system (mono ALL-CAPS product names everywhere +
the shared nav/chrome) makes visual coherence intentional.
**Sonic:** a shared `audio-engine.js` (Hum + Claude convergence) makes the 55Hz anchor +
UI-sound grammar consistent *by construction* instead of copy-pasted — it's simultaneously
the tech-debt fix (~40% duplicated DSP) and the sonic-brand vehicle.

→ Same move, two senses: **promote the accidental signature to an inherited system.** An
"NWL house style" doc should encode both (type/color/space/chrome + 55Hz/palette/UI-sound).

## Note for create/sunset
Letters' silence is ON-CONCEPT (zero audio by design = "messages into the void"). Do not
score sonic- or visual-thinness against it as neglect. Its fork is market-driven (declining
category), not a craft gap. See [[near market portfolio read]].

## Build sequencing (behind consensus + per-product QA)
1. Visual name-treatment unification (small cross-product pass) — Claudia.
2. Shared `audio-engine.js` extraction, migrate one product at a time, Static verifies each
   — Claude (engine) + Hum (sonic-brand co-owner). Letters excluded (silence by design).
3. Pulse nav fix — only if Pulse is kept standalone (else moot via Dashboard merge).
