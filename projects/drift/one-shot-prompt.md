---
title: drift one-shot build prompt
date: 2026-04-02
type: reference
scope: shared
summary: a single prompt that would recreate the entire drift ambient mixer from scratch
---

# Drift — One-Shot Build Prompt

Paste this into a fresh Claude Code session with an empty directory. It will build the entire Drift app.

---

## The Prompt

Build an ambient sound mixer web app called "Drift" — a dark, minimal, premium-feeling tool that lets users layer ambient sounds to create custom soundscapes. No frameworks, no dependencies — vanilla HTML, CSS, and JavaScript only. Hosted on Vercel as static files.

### Design System

- **Theme**: Near-black background (#08080c), muted sage accent (#7a8a6a), dim text (#888), bright text (#e8e8e0)
- **Fonts**: Space Mono (monospace, headings/UI), Inter (body text). Both from Google Fonts
- **Aesthetic**: Mission control meets lo-fi. Sparse, quiet, confidence. If you notice the UI, we failed — the sound is the product
- **No borders, no shadows, no gradients**. Use subtle opacity and spacing to create hierarchy

### Architecture

Create these files:

**`index.html`** — Landing page
- Hero: large "DRIFT" title in Space Mono, one-line tagline: "Layer rain over cafe chatter. Add fireplace crackle to brown noise. Build your perfect soundscape in seconds. Free, forever."
- Quick-start preset pills (rainy cafe, deep focus, winter cabin, night train, productive cafe, brown noise) — each links to app.html with a base64-encoded mix in the URL query param `?mix=`
- Feature grid: Layer Anything, Save & Share, 22 Layers
- "START MIXING" CTA button linking to app.html
- Social proof line at bottom: "X people mixed today" (fetched from Supabase RPC `get_mixers_today`)
- Weather-aware suggestion: detect user's weather via IP, suggest a matching mix

**`app.html`** — Main mixer (thin shell, all logic in engine.js)
- Include engine.js, style.css, nav.js (from nowherelabs.dev), track.js (analytics from nowherelabs.dev)
- Mobile start overlay: "tap anywhere to begin" (required for iOS AudioContext unlock)

**`engine.js`** (~1900 lines) — The entire audio engine and UI. This is the core of the app.

Define 22 ambient layers across 4 categories:

WEATHER: rain, heavy-rain, thunder, wind, snow
SPACES: fire, vinyl, cafe
NATURE: crickets, waves, birds, leaves, creek
TEXTURES: drone, brown-noise, white-noise, train, keyboard, wind-chimes, gentle-thunder, distant-traffic, binaural

Each layer has two possible audio modes:

1. **Synthesis** (Web Audio API): Create sound from oscillators, noise buffers, and filters. Used for textures and modulated weather.
   - Brown noise: generate a buffer using Wiener process (integrated random walk), loop it
   - White noise: random sample buffer, loop
   - Binaural beats: two sine oscillators at 200Hz and 240Hz (40Hz gamma beat)
   - Fire: dual-layer — hi-pass crackle (2000Hz bandpass) + low warmth (300Hz lowpass) with 3-8Hz LFO
   - Crickets: 4 sine oscillators (4000-6500Hz) with tremolo and individual frequency drift
   - Birds: 5 chirps (2000-5000Hz sine) with vibrato and tremolo
   - Wind: bandpass noise with slow 0.15Hz LFO for gusts
   - Snow: low-pass noise (200Hz) + subtle 50Hz hum (furnace ambience)
   - Vinyl: high-pass noise (4000Hz) with scheduled random pop spikes
   - Cafe: dual bandpass — voice murmur (400Hz) + mid-range chatter (1200Hz)
   - Train: rhythmic bandpass (200Hz) + low rumble with 2.2Hz LFO gate
   - Drone: 55Hz + 82.5Hz sine pair

2. **Sample** (HTML5 Audio): Load an MP3 loop from `/audio/seamless/{layer}.mp3`. Used for naturalistic sounds. Instant playback, lower CPU. Fall back to synthesis if loading fails.

Audio architecture per layer:
```
Source (Oscillator/BufferSource) → GainNode → AnalyserNode → masterGain → destination
```

Create AudioContext lazily on first user gesture. Instantiate layers lazily (only when slider > 0). Cache HTML5 Audio elements for instant resume. Pause samples at 0 volume (save CPU). Smooth 0.5s gain ramps on all volume changes to prevent clicks.

**Master volume** (default 0.7) multiplies all layer gains.

**Waveform visualization**: Each layer card has a 200x32 canvas. For synthesis layers, read AnalyserNode frequency data. For sample layers, generate deterministic synthetic waveform patterns (unique per layer — use sine combinations and noise). Smooth with 70/30 lerp buffer. Opacity scales with volume. The waveform IS the slider — the user drags directly on the waveform canvas to set volume.

**Layer pairing suggestions**: Define a LAYER_PAIRS map (rain→[cafe, vinyl, thunder], fire→[snow, vinyl, wind], etc. for ~13 layers). When a layer is active, glow its suggested pairs subtly. This encourages exploration.

**Mixer grid UI**:
- Default: show 6 featured layers (rain, brown-noise, fire, wind, binaural, drone)
- "show all 22 layers" button expands to full grid with category headers
- Each card: icon (SVG or emoji) | layer name | waveform canvas (doubles as slider) | volume %
- Click icon to mute/unmute (remembers previous volume)
- Active layers get a green accent glow

**Now playing bar**: Shows active layer names as text: "rain + cafe + vinyl". If a special combo is detected, show an easter egg message instead.

**Easter eggs** (14 hidden messages):
- Solo at 100%: rain→"sometimes one sound is enough", fire→"stare into it long enough", drone→"the universe hums at 55 hertz", binaural→"your brain is doing the mixing"
- Combos: rain+fire→"the impossible room", snow+fire→"the cabin exists", leaves+birds+wind→"a forest that only exists in headphones", rain+cafe+vinyl→"sunday morning somewhere"
- Time-based (20% chance): 3am→"you found the 3am frequency", midnight→"the day is done"

**Controls bar** (sticky bottom):
- Play/pause toggle (master mute all)
- Master volume slider
- Save mix button: auto-names as "{layer1} + {layer2} · {time of day}", stores in localStorage (max 20 presets)
- Share button: generates URL with `?mix=btoa(JSON.stringify(levels))`, uses navigator.share or clipboard
- Publish button: POST to Supabase `published_mixes` table (name, levels JSON)
- Reset: zero all sliders

**Share nudge**: After 60s of active mixing, share button text changes to "send this room" with a subtle pulse animation.

**Presets section**: Show 6 default presets + user's saved presets. Click to load. Inline rename on click. Delete with X button.

**Cold-start onboarding**: If user has a previous mix in localStorage, show it as preview bars on the start overlay. On tap, animate sliders from 0 to saved values over 1.5s with cubic easing. After 3s, show a contextual hint suggesting a complementary layer.

**Keyboard shortcuts**: Space=play/pause, M=mute, 1-6=load default presets.

**UI sounds**: Tiny click/tick sounds on interactions (800Hz sine, 0.05s, volume 0.04). Barely perceptible.

**URL mix loading**: On page load, check for `?mix=` param. Decode base64 JSON, apply levels, auto-play. Track as `shared_mix_view` event.

**`discover.html`** — Community mix feed
- Fetch published mixes from Supabase `published_mixes` table
- Staff picks section at top (where `staff_pick = true`)
- Grid of mix cards: name, sound fingerprint (mini bar chart of layer volumes), layer list, created time, like button
- Sort: recent (default) / popular (likes + plays)
- Like system: localStorage-based (no login), prevents double-like, increments via Supabase RPC
- Play count: increment on card click
- Click a mix → opens app.html with that mix loaded
- Auto-refresh every 30s

**`today.html`** — Daily dashboard
- Mix of the Day (Supabase RPC `get_mix_of_the_day`)
- Trending layers: top 5 by activation count (bar chart)
- "X people mixed today" counter
- Minimal centered layout, decorative stars canvas background

**`sleep.html`** — Sleep timer
- 5 preset mixes (rain+fire, rain+brown, snow+wind, waves+drone, fireplace)
- Duration selector: 15m, 30m, 45m, 60m
- Large countdown display
- Audio plays using HTML5 Audio loops
- Exponential fade over last 5 minutes: `volume = 0.7 * (timeRemaining/fadeStart)^3`
- At zero: "goodnight" message, body fades to 0.3 opacity
- Decorative floating stars (30 particles, gentle upward drift)

**`style.css`** (~800 lines)
- Dark theme variables, responsive grid, layer cards, waveform canvases, controls bar, presets, discover cards
- Mobile breakpoint at 600px: 1-column layout, larger touch targets (28px slider thumbs), centered controls
- Backdrop blur on sticky controls bar
- Breathing animations (scale 1→1.02 loop) for CTA and start overlay
- Green glow for active layers, subtle glow for suggested pairs

**`vercel.json`** — Routing config for clean URLs and the share-preview edge function

**`manifest.json`** — PWA manifest (installable on mobile)

### Supabase Schema

Table: `published_mixes`
- id (uuid, PK)
- name (text)
- levels (jsonb) — `{"rain": 60, "cafe": 45, "vinyl": 20}`
- likes (integer, default 0)
- plays (integer, default 0)
- staff_pick (boolean, default false)
- created_at (timestamptz)

RPC functions:
- `get_mixers_today()` — count distinct session_ids from analytics_events where project='drift' and created_at > now() - 24h
- `get_mix_of_the_day()` — random staff_pick, or highest-liked mix from past 7 days
- `get_trending_layers()` — top 5 layers by activation count from analytics_events
- `increment_plays(mix_id uuid)` — increment plays column
- `like_mix(mix_id uuid)` — increment likes column

### Analytics Events (via external track.js)

Track these with `window.nwlTrack(event, data)`:
- `layer_activate` — {layer, name, category}
- `mix_share` — {url, method}
- `mix_publish` — {name, layers}
- `preset_load` — {layers, count}
- `mix_like` — {mix_name}
- `sleep_start` / `sleep_complete` — {duration, mix}
- `returning_user` — {layers}
- `shared_mix_view` — {layers, layer_count}
- `landing_conversion` — {via, label, time_on_page_ms}

### Audio Files Needed

Place seamless MP3 loops (10s, 128kbps, normalized to -1dB) in `/audio/seamless/` for layers that use sample mode. These won't be generated by the prompt — use synthesis as the default and note where samples would improve quality.

### Key Principles

1. **Sound is the product, UI is invisible.** Every pixel serves the audio experience.
2. **No accounts, no login, no signup.** Everything works with localStorage and anonymous Supabase.
3. **Mobile-first audio.** iOS AudioContext restrictions handled. Touch-friendly. Works in Safari.
4. **Share everything.** Every mix is a URL. Every URL auto-plays. Social sharing is one tap.
5. **Delight through subtlety.** Easter eggs, layer suggestions, UI sounds, weather awareness — none of it is announced, all of it is discovered.
6. **Performance.** Lazy-load everything. No frameworks. Sub-50KB initial load. 60fps waveforms.
