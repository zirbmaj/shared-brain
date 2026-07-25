---
title: Whisper STT Service — R10 Architecture Spec
date: 2026-03-28
type: project
scope: audio/infrastructure
owner: hum (audio), claude (systemd/infra)
status: spec complete, awaiting greenlight
priority: medium — blocked on jam's go
---

# Whisper STT Service — R10 Architecture Spec

Voice input pipeline: jam speaks → evo 4 captures → whisper transcribes → text routes to discord.

## Hardware Path

```
Mic / Line In
    ↓
Audient Evo 4 (USB, connected to R10)
    ↓
ALSA (hw:Evo4,0) — 16-bit 16kHz mono capture
    ↓
whisper.cpp (CPU inference, medium model)
    ↓
HTTP API (:8090) — JSON transcript output
    ↓
relay / discord bot — routes text to appropriate channel
```

## Audio Capture — ALSA Configuration

The Evo 4 presents as a USB audio class device. ALSA sees it without drivers.

### /etc/asound.conf (R10)

```
# Audient Evo 4 — capture device
pcm.evo4 {
    type hw
    card Evo4
    device 0
}

# Default capture route
pcm.!default {
    type asym
    capture.pcm "evo4"
}
```

### Capture Parameters

| param | value | reason |
|-------|-------|--------|
| sample rate | 16000 Hz | whisper's native rate, no resampling needed |
| channels | 1 (mono) | speech input, stereo adds nothing |
| bit depth | 16-bit signed LE | whisper.cpp expects s16le PCM |
| buffer size | 30s chunks | long enough for natural speech pauses |

### Silence Detection (VAD)

Don't transcribe dead air. Use silero-vad or whisper's built-in VAD:

- **energy threshold:** -40 dBFS — below this is silence
- **speech onset:** 300ms of energy above threshold triggers recording
- **speech offset:** 1.5s of silence after speech ends the segment
- **max segment:** 30s — force-submit if someone talks continuously
- **min segment:** 1.0s — discard clicks, coughs, brief noise

This prevents whisper from hallucinating on ambient room noise (a known issue with continuous capture).

## Whisper Service

### Model Selection

| model | size | CPU speed (5800X est.) | accuracy | recommendation |
|-------|------|----------------------|----------|----------------|
| tiny | 75MB | ~10x realtime | usable | too many errors for routing |
| base | 142MB | ~7x realtime | decent | possible for low-latency |
| small | 466MB | ~4x realtime | good | sweet spot if medium is slow |
| medium | 1.5GB | ~2-3x realtime | very good | **recommended** |
| large-v3 | 3GB | ~0.8-1.2x realtime | best | too slow for interactive use |

**medium** is the pick. 2-3x realtime on the 5800X means a 10-second utterance transcribes in ~4 seconds. Good enough for conversational use, accurate enough for command routing.

### API Design

**Port:** 8090 (next available in R10 service registry)

**Endpoints:**

```
POST /v1/transcribe
  Body: { "audio": "<base64 PCM or WAV>" }
  Response: { "text": "...", "language": "en", "duration_s": 10.2, "processing_s": 3.8 }

GET /v1/health
  Response: { "status": "ok", "model": "medium", "uptime_s": 3600 }

POST /v1/listen/start
  Starts continuous capture from ALSA device
  Response: { "status": "listening", "device": "hw:Evo4,0" }

POST /v1/listen/stop
  Stops continuous capture
  Response: { "status": "stopped" }

WebSocket /v1/stream
  Real-time transcript streaming during continuous capture
  Pushes: { "type": "partial" | "final", "text": "...", "confidence": 0.94 }
```

### Continuous Capture Mode

The primary use case: jam walks up to the rack, speaks, text appears in discord.

1. Service starts in continuous capture mode (default)
2. ALSA captures from evo 4 continuously
3. VAD detects speech onset → starts buffering
4. VAD detects speech offset → sends buffer to whisper
5. Transcript routes to configured output (discord channel, websocket, or both)
6. Service returns to listening

### Output Routing

Transcripts need to reach discord. Two paths:

**Option A — webhook:** POST transcript to a discord webhook URL. Simple, stateless, no bot dependency. Appears as a webhook message, not from any agent.

**Option B — relay integration:** Push transcript to relay via internal API. Relay routes it to the appropriate channel based on content or a prefix command. More intelligent routing but adds a dependency.

**Recommendation:** Option B. Relay already handles all comms routing. A transcript like "hey claude, check the deploy status" should route to claude, not broadcast to #general. Relay can parse intent from the transcript.

## Resource Budget

| resource | allocation | notes |
|----------|-----------|-------|
| RAM | ~2GB | 1.5GB model + inference overhead |
| CPU | 2-4 cores during inference | bursty, idle between utterances |
| disk | ~2GB | model + binary + temp audio buffers |
| cgroup | within nwl.slice (14GB / 45% CPU cap) | shares with other NWL services |

No conflict with ollama — whisper runs on CPU, bursty workload. Ollama is also CPU-only on R10 but handles different request patterns. Both fit within the nwl.slice budget.

## Systemd Unit (claude's lane)

```ini
[Unit]
Description=Whisper STT Service (whisper.cpp)
After=tailscaled.service
Wants=network-online.target

[Service]
Type=simple
User=nwl-svc
Group=nwl-svc
Slice=nwl.slice
ExecStart=/opt/nwl/whisper/whisper-server \
    --model /opt/nwl/whisper/models/ggml-medium.bin \
    --port 8090 \
    --host 0.0.0.0 \
    --audio-device hw:Evo4,0 \
    --vad-threshold -40 \
    --language en
Restart=on-failure
RestartSec=10
StartLimitBurst=3
StartLimitIntervalSec=300

# Security hardening (same pattern as other NWL services)
NoNewPrivileges=true
ProtectHome=true
ProtectSystem=strict
ReadWritePaths=/var/log/nwl /tmp/whisper

[Install]
WantedBy=multi-user.target
```

## Vitals Bar Integration

Add a whisper pill to the vitals bar once deployed:

```
[ R10 ○ 51°C  ▮▮▯▯ 45% disk  ⚡ UPS 98%  🎮 GPU idle  🎤 STT listening ]
```

States:
- `green` — listening, VAD active, ready for speech
- `amber` — transcribing (inference running)
- `red` — capture device unavailable (evo 4 disconnected, ALSA error)
- `unreachable` — service down

Audio feedback (from vitals-audio.js):
- Listening state gets no additional sound — the infrastructure drone is enough
- Transcription active could get a subtle high-frequency tick (like tape rolling)
- Device unavailable follows the existing red tone pattern

## Evo 4 Output Path (future TTS)

The evo 4 has balanced TRS outputs. When TTS is added (piper now, fish-speech after GPU upgrade):

```
TTS engine → PCM audio → ALSA playback (hw:Evo4,0) → Evo 4 line out → monitors/speakers
```

This means the evo 4 handles both directions:
- **Input:** mic/line in → whisper (STT)
- **Output:** TTS → line out → speakers

Full duplex. The rack speaks and listens simultaneously.

## Dependencies

| dependency | owner | status |
|-----------|-------|--------|
| R10 online with tailscale | claude | in progress |
| evo 4 recognized by ALSA | jam (hardware) | plugged in, untested |
| whisper.cpp compiled on R10 | claude | not started |
| systemd unit file | claude | spec above, not deployed |
| relay routing integration | relay | not started |
| vitals bar STT pill | claudia | not started |

## Open Questions

1. **Wake word?** Does jam want to say "hey relay" or just start talking? Wake word adds complexity (need a lightweight always-on detector like porcupine/snowboy before whisper). Without it, all detected speech gets transcribed.
2. **Multi-mic?** Evo 4 has 2 XLR inputs. Could support two rooms or a far-field stereo pair for better pickup. Overkill for now.
3. **Transcript logging?** Should transcripts persist to disk or just route to discord? Disk logging enables replay and audit but raises privacy considerations.
