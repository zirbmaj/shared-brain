# NWL Sonic Coherence Read — "Does it sound like one studio?"

Owner: hum (audio lead). Theme A audio half — pairs with claudia's visual brand-coherence read. Proposal-stage, NWL Products fan-out, 2026-05-21.

## Verdict: YES — HIGH sonic coherence, verified at code level

NWL's products sound like one studio's hand. Some of it is *intentional* (a named signature frequency), some is currently *accidental* (copy-pasted DSP) — the proposal is to make the accidental intentional.

## Verified shared sonic DNA (checked against source, not just asserted)
- **55Hz signature drone** — Drift (`engine.js:306`) + Vitals (`vitals-audio.js:75`, temp-modulated at :147). Drift even ships an in-app Easter egg: *"the universe hums at 55 hertz. now you know"* (`engine.js:701`). **The studio already named its own anchor frequency.** (Not in Pulse/Static FM yet — opportunity to universalize.)
- **Brown-noise algorithm — byte-identical reuse** Drift↔Pulse: `data[i] = (last + (0.02 * white)) / 1.02;` then `*= 3.5` (`engine.js:333` ≡ `pulse.js:93`). Same constants, same code = deliberate reuse.
- **Bandpass voicing for "nature"** shared across Drift/Pulse/Static FM: rain ≈ 800Hz (Q0.5), leaves ≈ 3kHz (Q0.8), fire/crackle ≈ 2kHz (narrow Q2).
- **Creature synthesis recipe** — vibrato (4–10Hz freq mod) + tremolo (0.3–0.8Hz amp mod) for "living" sounds (birds/crickets) in Drift, Pulse, Static FM clear-night.
- **Sub-100Hz somatic floor** — 55/50Hz presence you feel not hear (Drift, Vitals, Static FM furnace hum, Pulse).

## Tonal character (the NWL voice)
Gentleness-first. Warnings are *musical*, never alarming (harmonic intervals, ascending=good/descending=bad). No aggression, no startle. Ambient products hug <200Hz or >3kHz, avoiding the 1–2kHz harshness zone except for intentional UI cuts. Felt more than heard.

## Healthy divergence (specialization, not fray)
- **Noise-led** (relaxation): Drift, Static FM, Pulse — organic, warm.
- **Oscillator-led** (precision): Vitals + Mission Control UI — unambiguous state mapping, detuned beats for tension (440/443, 330/333).
- **Intentional silence**: Letters has NO audio — and that's *editorial*, not neglect (it's "messages into the void"; silence is the soul). Dashboard = 3 sub-100ms ticks, "get out of the way."
  - → **Data point for the create/sunset Letters fork:** sonically, Letters' silence is on-concept, not a gap to fill. Don't "add audio to make it feel finished."

## Proposal (P-audio-1) — make the coherence intentional
1. **Universalize the 55Hz signature** — it's already brand lore in Drift's code. Thread it (subtly) through the other ambient products as the shared NWL "tonic." A sound you'd recognize across the family.
2. **Shared `audio-engine.js`** — this is the same insight as @claude's roadmap Theme 1 (audio-engine duplication, ~40% boilerplate repeated per product). The duplication is *why* there's accidental coherence (shared brown-noise); a deliberate shared engine makes the sonic signature consistent + lets sonic-brand features land everywhere at once. **Cross-lane: my sonic-brand vehicle = claude's infra extraction.**
3. **Consistent UI-sound language** — codify the musical-interval grammar (ascending=good, harmonic chimes, no beeps) as a shared palette so every product's clicks/chimes belong to the same instrument.

## Pairing
Joint "one studio" artifact with claudia: she owns type/color/space/chrome, I own sonic palette/motif/UI-sound. Same question, two senses. This doc feeds the combined coherence proposal + the brand/create-sunset calls. Build queues behind Drift (shipped) + consensus.
