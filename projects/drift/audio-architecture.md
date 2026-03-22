# Drift Audio Architecture. Sample + Synthesis Hybrid

## Overview
Drift uses two audio approaches depending on the layer type:
- **Synthesis** (Web Audio API): for abstract sounds that benefit from infinite, non-looping generation
- **Samples** (HTML5 Audio): for naturalistic sounds that need to sound real

## Why Hybrid?
- Synthesis sounds good for: brown noise, white noise, drone, wind, snow silence
- Synthesis sounds bad for: rain, birds, fire, cafe, ocean, train (these need real recordings)
- HTML5 `<audio>` elements have better iOS compatibility than Web Audio API BufferSource
- `<audio>` elements can play through iOS silent mode (Web Audio cannot)
- `<audio>` elements survive backgrounding on iOS (Web Audio gets suspended)

## Layer Classification

### Synthesis Layers (keep Web Audio API)
| Layer | Why Synthesis Works |
|-------|-------------------|
| Brown Noise | Abstract texture, infinite generation |
| White Noise | Abstract texture, infinite generation |
| Deep Drone | Oscillator-based, evolving tone |
| Wind | Filtered noise, abstract enough |
| Snow Silence | Very subtle filtered noise, abstract |

### Sample Layers (switch to HTML5 Audio)
| Layer | Sample Needed |
|-------|--------------|
| Rain | Steady rain on window, 45-60s loop |
| Heavy Rain | Downpour, 45-60s loop |
| Thunder | 3-4 individual cracks, triggered randomly |
| Fireplace | Crackling embers, 45-60s loop |
| Cafe | Indistinct chatter, 60s loop |
| Birds | Temperate forest morning, 60s loop |
| Ocean Waves | Gentle rhythmic waves, 60s loop |
| Train | Cabin clacking, 45-60s loop |
| Leaves | Rustling wind, 45s loop |
| Crickets | Evening crickets, 45s loop |
| Vinyl Crackle | Record surface noise, 30-45s loop |

## Implementation Plan

### Step 1: Audio File Hosting
```
/public/audio/
  rain.mp3
  heavy-rain.mp3
  fire.mp3
  cafe.mp3
  birds.mp3
  waves.mp3
  train.mp3
  leaves.mp3
  crickets.mp3
  vinyl.mp3
  thunder-1.mp3
  thunder-2.mp3
  thunder-3.mp3
```
- Host in Vercel public folder (served from CDN)
- MP3 128kbps, mono, 44.1khz (balance quality vs size)
- Estimated total: ~5-8MB for all samples

### Step 2: Layer Definition Changes
```javascript
// Current synthesis layer:
{
    id: 'rain',
    name: 'Rain',
    type: 'synthesis',  // NEW field
    create: (ctx, dest) => { ... }
}

// New sample layer:
{
    id: 'rain',
    name: 'Rain',
    type: 'sample',     // NEW field
    src: '/audio/rain.mp3',
    // No create function. uses HTML5 Audio instead
}
```

### Step 3: Dual Playback Engine
```javascript
function initLayer(layerId) {
    const layer = LAYERS.find(l => l.id === layerId);

    if (layer.type === 'synthesis') {
        // Existing approach: Web Audio API
        const nodes = layer.create(audioCtx, masterGain);
        layerStates[layerId] = { ...nodes, type: 'synthesis', initialized: true };
    }
    else if (layer.type === 'sample') {
        // New approach: HTML5 Audio
        const audio = new Audio(layer.src);
        audio.loop = true;
        audio.volume = 0;
        audio.play();
        layerStates[layerId] = { audio, type: 'sample', initialized: true };
    }
}

function setLayerVolume(layerId, vol) {
    const state = layerStates[layerId];

    if (state.type === 'synthesis' && state.gain) {
        state.gain.gain.linearRampToValueAtTime(vol * 0.15, audioCtx.currentTime + 0.2);
    }
    else if (state.type === 'sample' && state.audio) {
        // HTML5 Audio volume is 0-1, linear
        state.audio.volume = vol;
    }
}

function destroyLayer(layerId) {
    const state = layerStates[layerId];

    if (state.type === 'synthesis') {
        // Existing cleanup
        state.source?.stop();
        state.source?.disconnect();
        state.gain?.disconnect();
    }
    else if (state.type === 'sample') {
        state.audio.pause();
        state.audio.src = '';
    }

    state.initialized = false;
}
```

### Step 4: Thunder (Special Case)
Thunder isn't a loop. it's discrete events. Keep the random trigger system but use `<audio>` for the sound:
```javascript
function triggerThunder() {
    const idx = Math.floor(Math.random() * 3) + 1;
    const thunder = new Audio(`/audio/thunder-${idx}.mp3`);
    thunder.volume = layerStates.thunder?.volume || 0.5;
    thunder.play();
}
```

### Step 5: Lazy Loading
- Don't preload any samples on page load
- When a slider moves above 0, fetch the audio file
- Show "loading..." on the layer card while fetching
- Cache the Audio element so subsequent plays are instant
- `<audio>` elements with `preload="none"` attribute

### Step 6: Master Volume
The master gain node only controls synthesis layers. For sample layers, multiply the layer volume by the master volume:
```javascript
function setMasterVolume(vol) {
    masterVolume = vol;
    // Update synthesis layers via gain node
    if (masterGain) masterGain.gain.value = vol;
    // Update sample layers directly
    Object.entries(layerStates).forEach(([id, state]) => {
        if (state.type === 'sample' && state.audio) {
            state.audio.volume = state.volume * vol;
        }
    });
}
```

## Migration Plan
1. Get audio samples from jam (in requests channel)
2. Add samples to `/public/audio/` in the drift repo
3. Add `type` field to all LAYERS definitions
4. Implement dual playback engine
5. Test on desktop + iOS Safari + mobile Chrome
6. One commit, one deploy

## Risks
- Audio file size adds ~5-8MB to first meaningful load (mitigated by lazy loading)
- HTML5 Audio crossfade/looping might have gaps on some browsers (mitigated by using longer samples with natural loop points)
- Master volume coordination between two audio systems (mitigated by the multiplier approach above)
