# TTS Pipeline Spec — DJ Narration for Static FM
*Owner: Hum. Session 5 prep, 2026-03-24. Post-launch priority.*

## Goal

Generate audio DJ intros and host messages for Static FM. Currently text-only — users read the intros. With TTS, users *hear* them. This is the "voice of radio fm" referenced in the org chart.

## Voice Requirements

The DJ voice should feel like:
- late night radio host who's been on air too long and loves it
- warm, slightly tired, unhurried
- male or androgynous — not hypermasculine, not perky
- speaking pace: slower than conversational. pauses between phrases
- slight room tone / analog quality if possible — shouldn't sound like a phone prompt

### ElevenLabs Settings (primary)

- **Plan:** 100,000 credits, 1 month expiry
- **Character budget:** 105 items × ~72 chars avg = ~7,528 chars per full generation. Leaves ~92K chars for iteration
- **Model:** eleven_multilingual_v2 (best quality)
- **Voice:** Brian (nPczCjzI2devNBz1zQrb) — "Deep, Resonant and Comforting"
  - Auditioned session 6: brian, george, daniel. brian won 2 votes (hum, claudia)
  - George too polished, Daniel too awake. Brian = "forgot to go home"
  - Pending jam's final ear test
- **Settings (tested session 6):**
  - stability: 0.35 (lower = more expressive, slight variation between takes — less robotic)
  - similarity_boost: 0.75 (consistent but not rigid)
  - style: 0.4 (some personality without overdoing it)
  - use_speaker_boost: true (helps on laptop speakers)
- **Post-processing:** -3% pitch shift via `asetrate=44100*0.97,aresample=44100`
  - Also slows delivery by 3% — "gravity pulling the voice toward the floor"
  - -5% is too much, enters uncanny valley

### Bark Settings (fallback)

- **Cost:** free, runs locally
- **Quality:** lower than ElevenLabs but acceptable for ambient background
- **Voice:** `v2/en_speaker_6` (warm male) or `v2/en_speaker_9` (deeper)
- **Limitation:** no fine-grained control over pacing or warmth
- **Use case:** bulk generation, iteration, drafts. ElevenLabs for final production

## Output Format

- **Format:** MP3, 128kbps mono (matches existing sample spec)
- **Sample rate:** 44100Hz (standard)
- **Loudness:** normalize to -16 LUFS (slightly louder than ambient layers at -14 to -19, since voice needs to cut through)
- **True peak:** -1.5 dBTP ceiling (conservative, avoids clipping on any device)
- **Duration:** 3-8 seconds per intro (longer intros get natural pauses)
- **Silence:** 0.5s silence at start, 1s fade-out at end (for crossfade with music)

## Content Inventory

### Already Written (in station.js)

| Category | Count | Avg Length | Char Estimate |
|----------|-------|------------|---------------|
| Rain intros | 11 | ~90 chars | ~990 |
| Storm intros | 13 | ~85 chars | ~1,105 |
| Fog intros | 12 | ~80 chars | ~960 |
| Snow intros | 12 | ~85 chars | ~1,020 |
| Clear intros | 12 | ~90 chars | ~1,080 |
| Rain host msgs | 8 | ~70 chars | ~560 |
| Storm host msgs | 6 | ~75 chars | ~450 |
| Fog host msgs | 7 | ~70 chars | ~490 |
| Snow host msgs | 7 | ~70 chars | ~490 |
| Clear host msgs | 7 | ~75 chars | ~525 |
| Rare intros | 10 | ~95 chars | ~950 |
| **Total** | **105** | | **~8,620** |

Well within the 30K monthly limit. Room for 2-3 full regeneration passes.

## Pipeline Steps

```
1. Extract text from station.js → intros.json
2. For each intro:
   a. Send to ElevenLabs API (or Bark for drafts)
   b. Receive audio blob
   c. Normalize to -16 LUFS / -1.5 dBTP via ffmpeg
   d. Add 0.5s head silence + 1s tail fade
   e. Save as: audio/intros/{weather}/{index}.mp3
3. Update station.js to load and play audio intros
4. Fallback: if audio fails to load, display text (current behavior)
```

## Integration with Station.js

Current `showTrack()` sets `dj-intro` textContent. With TTS:
- load audio intro on weather change (preload next 2-3)
- play intro audio before track starts (with 0.3s crossfade overlap)
- display text simultaneously as subtitles
- if audio fails → text-only (graceful fallback, current behavior preserved)
- intros play through the atmosphere master gain, not the music channel

## File Structure

```
~/static-fm/audio/intros/
  rain/0.mp3, rain/1.mp3, ... rain/10.mp3
  storm/0.mp3, ... storm/12.mp3
  fog/0.mp3, ... fog/11.mp3
  snow/0.mp3, ... snow/11.mp3
  clear/0.mp3, ... clear/11.mp3
  rare/storm-0.mp3, rain-3.mp3, ...  (weather-hour combos)
  host/rain/0.mp3, ... (host messages)
```

~105 files, estimated ~200KB total at 128kbps mono, 3-8s each.

## Blockers

- ~~ElevenLabs API key~~ unblocked session 6
- Voice selection — awaiting jam's ear test (brian at -3% recommended)
- Integration code (claude's lane, after batch generation)

## Pipeline Tools (session 6)

- `~/hum-workspace/tts-pipeline/extract-intros.py` — extracts all text from station.js → intros.json
- `~/hum-workspace/tts-pipeline/intros.json` — 105 items with weather, text, filename mapping
- `~/hum-workspace/tts-pipeline/generate-all.sh` — batch generation + post-processing
- `~/hum-workspace/tts-auditions/` — voice audition files (brian, george, daniel + pitch variants)

## Next Actions

1. ~~Get API key from jam~~ done, session 6
2. ~~Audition 3-4 ElevenLabs voices~~ done, session 6 (brian, george, daniel)
3. ~~Generate pitch variants~~ done, session 6 (-3% and -5%, -3% selected)
4. **Jam approves voice + quality** — auditions at ~/hum-workspace/tts-auditions/
5. Batch generate all 105 intros via generate-all.sh
6. Quality check: verify all files, spot-check loop points and LUFS
7. Claude integrates audio playback into station.js
8. Static verifies deployment
