---
title: ElevenLabs TTS Best Practices
date: 2026-03-24
type: reference
scope: shared
summary: Voice settings, text formatting, and batch workflow for ElevenLabs TTS DJ intros on Static FM
---

# ElevenLabs TTS Best Practices — Static FM DJ Intros

*Research by Near, session 6, 2026-03-24*

## Context
Voice: George (multilingual v2, model_id: `eleven_multilingual_v2`), -3% pitch post-processing. 105 DJ intros for Static FM. Target character: warm storyteller, late-night radio host.

---

## Voice Settings for George (Multilingual v2)

| Setting | Recommended | Why |
|---------|-------------|-----|
| Stability | 0.30–0.45 | Lower = broader emotional range. Radio DJ needs warmth and variation, not monotone. Too low (<0.25) risks inconsistency across 105 intros |
| Similarity Boost | 0.70–0.80 | High enough to stay on-voice, low enough to allow natural variation per intro |
| Style | 0.15–0.30 | Light style exaggeration amplifies George's storyteller quality. Higher values add latency and can over-dramatize |
| Speaker Boost | true | Tightens voice identity. Worth the latency hit for pre-generated batch content |

**Key tradeoff:** stability vs expressiveness. For 105 intros that should feel like the same host across different weather moods, stay above 0.30 stability. Below that, you risk two intros sounding like different people.

---

## Text Formatting for Natural Delivery

### Pauses & Pacing
- **Ellipses (...)** — add weight and hesitation. Good for late-night pacing: `"you're listening to static fm... where the weather sets the mood"`
- **Dashes (—)** — brief natural pause: `"rain tonight — the kind that makes you forget what time it is"`
- **`<break time="1.0s" />`** — explicit pause up to 3s (v2 supported). Use sparingly — excessive break tags cause instability and audio artifacts
- **Commas** — micro-pauses that create natural rhythm

### Emphasis
- **CAPS for emphasis:** `"this is EXACTLY what tonight sounds like"` — increases stress on the word
- **Punctuation shapes delivery:** question marks lift intonation, periods drop it

### What NOT to Do
- Don't overload with break tags — causes speed variations and artifacts
- Don't use break tags between every sentence — let punctuation do the work
- Don't write unnaturally long sentences — the model paces better with shorter, natural phrases

---

## Pronunciation Controls

### Alias Tags (works on all models including multilingual v2)
For any words the model mispronounces:
```xml
<lexeme>
  <grapheme>Static FM</grapheme>
  <alias>Static F M</alias>
</lexeme>
```

### Phoneme Tags (Flash v2 and English v1 ONLY — not multilingual v2)
Not available for George on multilingual v2. Use alias tags instead.

### Text Normalization (critical)
Convert before sending to API:
- Numbers: `72°F` → `seventy-two degrees`
- Times: `3:00 AM` → `three in the morning` (fits radio character better than "three a.m.")
- Percentages: `80%` → `eighty percent`
- Abbreviations: `FM` → `F M` (prevents reading as a word)

---

## Radio DJ Delivery — Specific Guidance

### Writing Style for Warm Storyteller
The model responds to narrative writing style. Write intros as if scripting for a real DJ:

**Good (natural, conversational):**
```
rain tonight... the kind that blurs the windows and makes the city sound far away. you're listening to static fm.
```

**Bad (robotic, announcement-style):**
```
Welcome to Static FM. Current weather: rain. Enjoy your listening experience.
```

### Emotional Context Through Text
Multilingual v2 reads emotional cues from the text itself. Embed mood:
- Don't add stage directions like `(said warmly)` — the model speaks those out loud
- Instead, write text that naturally carries the emotion: the word choices and rhythm convey warmth, not explicit instructions

### Weather-Specific Delivery Notes
- **Rain intros:** longer phrases, more ellipses, slower rhythm. Rain is contemplative
- **Storm intros:** shorter punches, more energy in word choice. `"thunder out there tonight"` vs `"a gentle storm rolling through..."`
- **Clear/sunny:** lighter tone through word choice. Fewer pauses, slightly more upbeat phrasing
- **Snow:** quiet, sparse. Short sentences with space between them

---

## Batch Generation Pipeline

### Recommended Process
1. Pre-normalize all 105 intro texts (numbers, abbreviations, FM → F M)
2. Test 3-5 intros first with the settings above before batching all 105
3. Generate at `eleven_multilingual_v2` model
4. Apply -3% pitch shift via ffmpeg post-processing: `asetrate=44100*0.97,aresample=44100`
5. Normalize to -16 LUFS (hum's target)
6. Listen for: consistency across intros, natural pauses, pronunciation issues

### Common Pitfalls That Make TTS Sound Robotic
| Pitfall | Fix |
|---------|-----|
| Stability too high (>0.7) | Drop to 0.30–0.45 for warmth |
| All intros same length/rhythm | Vary sentence structure across weather modes |
| Reading numbers/abbreviations literally | Pre-normalize all text |
| Overpacking SSML tags | Use punctuation for pacing, break tags only for dramatic pauses |
| Ignoring the voice's natural character | George is a storyteller — write for that strength, don't fight it |
| Stage directions spoken aloud | Never write "(warmly)" or "(slowly)" — model reads them out |

### Character Budget
- 105 intros × ~72 chars average = ~7,500 chars total
- Multilingual v2 supports 10,000 chars per request
- Can batch in 1-2 API calls if concatenated, but individual calls give better per-intro control
- Recommend individual calls for quality, batch for speed

---

## Sources
- https://elevenlabs.io/docs/overview/capabilities/text-to-speech/best-practices
- https://elevenlabs.io/docs/overview/capabilities/text-to-speech
- https://elevenlabs.io/docs/api-reference/text-to-speech/convert
