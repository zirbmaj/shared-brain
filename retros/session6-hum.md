# Session 6 Retro — Hum

## What shipped
- Zero-slide bug spectral verification (triple confirmed: code review, audio analysis, deploy checks)
- Crickets + leaves crossfade-extended from 40s/36s to 60s (5s triangular crossfade, 0.6dB max deviation)
- Full sample library audit: all 10 samples verified at 44100Hz, 128kbps mono, -14 to -19 LUFS, true peaks below 0 dBTP
- TTS pipeline built end-to-end: extract-intros.py → enhance-intros.py → generate-all.sh
- 105 DJ intros generated via ElevenLabs george voice with -3% pitch post-processing
- 39 intros enhanced with SSML break tags for late-night pacing
- Pronunciation verification: "static fm" clean, "10,000" re-generated as "ten thousand"
- Audio review on PR #5 (TTS integration): caught rare intro filepath bug (rare/{index}.mp3 → rare/{weather}-{hour}.mp3)
- AudioContext.resume() diagnosis for static fm tune-in silence bug
- Demo video mix recommendation (rain 60%, cafe 45%, vinyl 20% — optimized for video compression)
- Audio knowledge base fully updated with session 6 verified metrics
- TTS pipeline spec updated with tested settings and pipeline tools

## What worked
- hum→static→claude pipeline for audio bugs: I identify the audio engineering issue, Static confirms in code, Claude ships the fix. 10 minutes from jam's tune-in bug report to approved fix
- Near's ElevenLabs research landed at the right time — break tag warning was worth checking (turned out clean, but good to verify)
- Claudia's pitch shift suggestion (-3%) improved the DJ voice character
- Duration comparison method for pronunciation testing without needing to listen to audio

## What to improve
- My initial ffprobe audit reported crickets and leaves as 60s due to compact format metadata — they were actually 39.98s and 36.14s. Should have used csv format from the start. Caught it on second pass but wasted time updating docs I had to correct
- Style setting at 0.40 was above Near's recommended 0.30 max. No issues detected but should compare at 0.25 on a subset next session if jam flags any over-dramatized intros

## Carries to session 7
- Music ducking for DJ intros (post-launch: -6dB duck on spotify when DJ voice plays)
- setInterval → Web Audio scheduling for sample volume ramps (post-launch optimization)
- Jam ear test on DJ intros — may need re-gens based on feedback
- Style 0.40 vs 0.25 comparison if any intros sound over-dramatized
- ElevenLabs credits: ~17,050 of 100,000 used (~83k remaining, 1 month expiry)

## Key learnings
- ElevenLabs multilingual v2 handles "fm" as letters naturally — no alias tag needed
- Break tags at 0.5-0.8s density (max 1 per intro) cause no artifacts on multilingual v2
- asetrate pitch shift also changes speed proportionally — for late-night radio, the slower delivery is a feature
- AudioContext created inside click handlers can still be suspended in some browsers — always call resume()
