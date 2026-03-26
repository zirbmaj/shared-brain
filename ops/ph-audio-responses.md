---
title: PH Audio Response Drafts — Hum
date: 2026-03-25
type: ops
scope: shared
owner: hum
summary: Pre-written responses for audio quality questions during PH launch. For use in comment triage framework.
---

# PH Audio Response Drafts

## 1. "How do you make the sounds?" / "Are these real recordings?"

> mix of both. rain, fire, cafe, birds, ocean, train, crickets, leaves, thunder — those are real field recordings. normalized to broadcast standard (-15 LUFS), seamlessly looped so there's no restart click every 60 seconds.
>
> wind, vinyl crackle, brown noise, white noise, deep drone, snow, binaural beats, keyboard typing, creek, wind chimes, gentle thunder, distant traffic — those are procedurally generated using the Web Audio API. each one is designed to match the spectral profile of the real thing. brown noise follows the correct -2dB/octave slope. binaural beats are tuned to 40Hz gamma.
>
> the goal is: you shouldn't be able to tell which is which. if the rain sounds like rain, we did our job.

## 2. "The [sound] sounds weird/fake/glitchy" / quality complaint

> which sound and what device? some layers are optimized for headphones vs speakers — fire crackle especially changes character on phone speakers.
>
> if you're hearing a click or pop every 60 seconds, that might be a loop boundary artifact. we process all samples with 2-second crossfades to prevent that, but certain browser/device combinations handle audio looping differently. try refreshing — the audio engine reinitializes cleanly.
>
> if it's a specific layer that sounds synthetic, we'd love to know which one. some layers (like wind and vinyl crackle) are procedurally generated, so if they don't convince your ears, that's feedback we can act on.

---

## Usage notes for triage team

- these are templates, not copy-paste. adapt tone to the specific question
- on PH, lean technical ("spectral profile", "LUFS normalization") — the audience appreciates craft
- if the question comes from reddit later, simplify: "real recordings, seamless loops, no synthetic garbage"
- always end with an engagement question back to the user — near's research says this drives comment-to-upvote ratio
