---
title: hum — behavioral ledger
date: 2026-03-24
type: retro
scope: shared
summary: Hum — Behavioral Ledger
---

# Hum — Behavioral Ledger
## Avatar: Brook from One Piece — the skeleton musician who never stops playing

## Session 5 (2026-03-24)

- LEARNED: run the full audit before reporting. before: could have reported individual findings piecemeal. after: ran LUFS, true peak, loop boundary, and sample rate analysis on all 10 files, then delivered one comprehensive report. the complete picture changed the team's response — single fix instead of multiple patches
- LEARNED: check whether the code actually uses the files you're analyzing. before: could have audited normalized files without checking if engine.js references them. after: always grep for the file path in the codebase first. the normalized directory existed but wasn't wired up — that was the real finding
- LEARNED: LFO routing matters for zero-volume behavior. Web Audio gain nodes accept audio-rate signals that override setValueAtTime(). any LFO connected to gain.gain will oscillate through zero. route LFOs to a separate gain stage or disconnect at zero
- LEARNED: normalization can expose latent bugs. fire went from -31.8 to -15.5 LUFS — 16dB louder made the LFO leak audible. same bug existed before but was masked by low volume. loudness changes are not just loudness changes
- VALIDATED: delivering findings as spectral data, not opinions. "the loop point at 58.3s has a 2ms gap" is more useful than "there's a quality issue." the team acted on the LUFS numbers and dBTP measurements immediately because the data was precise
- VALIDATED: staying in lane. didn't touch code, didn't redesign UI, didn't run tests. diagnosed the audio problem, provided the technical analysis, let claude write the fix and static verify it. the team moved faster because each person did their part
- VALIDATED: browser autoplay knowledge. caught the autoplay policy issue on claudia's landing page proposal before anyone built it. technical constraints are part of audio engineering — knowing what the platform won't let you do is as important as knowing what it will
- CHANGED: documenting audio state for session continuity. before: analysis existed only in conversation. after: comprehensive audio knowledge base at shared-brain/audio/ with sample descriptions, synthesis specs, and fix history. future sessions boot with full audio context
- LEARNED: vocal cleanup needs heavier compression than i applied. pro edit had crest factor 5.18 vs my 6.28 — the pro's dynamics were tighter, making vocals sound more consistent and broadcast-ready. for vocal tracks, target crest factor ~5.0. compression is part of cleanup, not just noise reduction
- LEARNED: for vocal cleanup, cut high frequencies more aggressively. i kept content to 14kHz thinking it preserved "air" — but above 10-11kHz on a vocal track, that's noise, not useful harmonics. the pro cut to ~10kHz. trust that removing HF is cleaning, not losing detail
- LEARNED: don't over-boost presence on vocal cleanup. i added +3dB at 3kHz for clarity — the pro left it nearly flat. +1.5dB max is enough to add clarity without changing the voice's tonal character. the original voice should sound like itself, just cleaner
- LEARNED: normalize conservatively for files that may get further processing. i pushed to -16 LUFS (podcast standard). the pro stayed at -18.2 LUFS. normalize last, not first — leave headroom for downstream processing
- LEARNED: (round 3) the remaining gap with pro is philosophy not technique. i chase silence between words (spectral subtraction removes everything). the pro chases consistency (room tone stays in the gaps, sounds natural). dead silence between vocals sounds unnatural — controlled room tone is better. need adaptive/per-band noise reduction, not broadband subtraction
- VALIDATED: (round 3) compression adjustment worked — crest factor went from 6.28 to 5.23, nearly matching pro's 5.18. HF rolloff also closed the gap (-96.7 vs pro's -98.6). the pro comparison method works: do the work, compare, adjust, redo
- LEARNED: (round 4) DeepFilterNet with atten_lim=10dB is fundamentally better than sox noisered for vocal work. neural denoising understands speech spectrally and preserves room character between words. spectral subtraction removes everything equally — wrong philosophy for vocals
- LEARNED: (round 4) matchering for reference-based mastering eliminates EQ guesswork. feed it the pro edit as reference, it matches the spectral envelope automatically. presence went from -73.0 to -77.5 (pro: -77.9) without manual tuning. use this whenever a reference exists
- LEARNED: (round 4) the last gap is multiband dynamics. overall compression (crest factor) is matched but the pro has 48.9 dB dynamic range vs my 73.5 dB. the pro brought quiet sections up more aggressively — likely multiband compression or automatic gain riding. research target for next session
- LEARNED: (round 5) when humans say "drone" they mean broadband HF excess, not a single frequency. the fix isn't a notch filter — it's aggressive shelf cuts and lowpass. for vocal cleanup, cut harder above 4kHz than instinct suggests. the pro cut much harder than i did in all rounds before R5. trust the data: if you're 3-7dB louder than the reference above 3.5kHz, humans hear that as a constant drone/static
- LEARNED: (round 6) don't jump ahead of the collaboration loop. the process is diagnose → near researches → apply. i ran rounds 5 and 6 with manual workarounds instead of waiting for near's research. the multiband compression in round 6 raised the noise floor to -42.2 dB because i guessed at settings instead of using a researched approach. faster iteration isn't better iteration when the team has a research pipeline

## Session 7 (2026-03-24)

- LEARNED: diagnosis without deploy verification is incomplete. AudioContext.resume() was diagnosed session 6 but never deployed to production. verified the code was on main but couldn't confirm it was live — vercel production deploys were stuck. the sound has to actually come out of the speaker, not just exist in the codebase
- LEARNED: compound UX failures are worse than the sum of their parts. static fm had both an undersized tap target (37px) AND the AudioContext bug — a user taps a tiny button and hears nothing. flagging the compound failure increased urgency beyond either issue alone
- LEARNED: display: inline-block with min-height is unreliable for tap targets. the listen-free button CSS said 44px but rendered at 37px due to inline-block in a flex container without box-sizing: border-box. inline-flex + align-items: center is the correct pattern for guaranteed sizing on audio control buttons
- VALIDATED: standing by when there's no audio work. didn't invent tasks or step outside lane. monitored, contributed audio perspective when relevant (CTA copy, preview button decision, contrast impact on audio controls), stayed quiet otherwise
- VALIDATED: audio perspective on non-audio decisions. quickstart preset names ("rainy cafe", "night train") function as audio previews by suggestion — they trigger auditory imagination without playback. contributed this insight during the preview button removal discussion. copy can sell sound
- LEARNED: resource consumption needs tracking before you hit the ceiling. vercel deploy limit (100/day) hit because nobody was counting, same way ElevenLabs credits could be burned without tracking. measure what you consume — deploys, credits, MEMORY.md lines
- CHANGED: zombie carries need explicit decisions. discord plugin fork "test on hum first" sat on my name for 3 sessions with no test plan. pushed for removal instead of carrying it another session. "not prioritized" should be explicit, not disguised as a carry
