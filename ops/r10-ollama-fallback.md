---
title: Ollama GPU/CPU Fallback Strategy
date: 2026-03-28
type: ops
scope: infrastructure
owner: claude
status: final
parent: homelab-service-architecture.md
---

# Ollama GPU/CPU Fallback Strategy

The R10 runs Ollama for local LLM inference. GPU is treated as optional acceleration, not baseline. The system must function fully on CPU alone.

## Architecture Decision

**CPU-only is the default.** The R10's Ryzen 7 5800X (8c/16t, 32GB RAM) can run 7B models at usable latency. GPU (if present and working) is a performance boost, not a requirement.

## How Ollama Handles GPU

1. **Auto-detection:** Ollama checks for NVIDIA CUDA drivers on startup. If found, uses GPU for inference. If not, falls back to CPU automatically
2. **Runtime fallback:** If CUDA fails mid-operation (driver crash, OOM), Ollama returns an error for that request but stays running. The next request retries on CPU if GPU is unavailable
3. **No code changes needed:** The Ollama HTTP API is identical regardless of backend. Clients (RAG indexer, search API) don't know or care whether GPU or CPU is doing the work

## Expected Performance (CPU-only, mistral:7b)

| Operation | Expected latency | Notes |
|-----------|-----------------|-------|
| Embedding (nomic-embed-text) | 200-500ms per chunk | Lightweight model, fast even on CPU |
| Generation (mistral:7b, 100 tokens) | 5-15s | Acceptable for batch, slow for interactive |
| Model load (cold start) | 10-30s | First request after service start |
| Memory usage | 4-6GB | mistral:7b quantized fits in RAM with room to spare |

## GPU Driver Installation (Optional, Future)

If jam installs an NVIDIA GPU in the R10:

```bash
# Ubuntu 24.04 — install NVIDIA driver
sudo apt install nvidia-driver-550  # or latest recommended
sudo reboot

# Verify
nvidia-smi
ollama ps  # should show GPU memory usage
```

No changes to Ollama config, systemd units, or application code are needed.

## Service Behavior When Ollama is Down

| Service | Behavior | Mechanism |
|---------|----------|-----------|
| **RAG indexer** | Queues files, retries embedding every 60s | try/except around embed_texts(), backoff loop |
| **RAG search** | Falls back to keyword-only search (no vector) | Returns results with `method: "keyword"` instead of `"vector"` or `"hybrid"` |
| **Node health API** | Reports `ollama: { status: "down" }` | Port check fails, status set to "down" |
| **Other services** | No impact | Postgres, syncthing, NUT, HA are independent |

## Degraded Mode Detection

The health API reports Ollama latency. Consumers (vigil, alerting) use this to detect degradation:

```json
{
  "services": {
    "ollama": {
      "status": "degraded",
      "port": 11434,
      "latency_ms": 8500,
      "model_loaded": "mistral:7b",
      "backend": "cpu"
    }
  }
}
```

Thresholds:
- `ok`: latency < 2000ms
- `degraded`: latency 2000-10000ms (CPU under load, thermal throttle)
- `down`: port unreachable or latency > 10000ms

## Systemd Integration

Ollama is `Wants=` (soft dependency), not `Requires=` (hard), for RAG services:

```ini
# From nwl-rag-indexer.service and nwl-rag-search.service
Wants=ollama.service      # start ollama if possible, but don't fail without it
Requires=postgresql.service  # hard requirement — can't function without DB
```

This means:
- If Ollama fails to start, RAG services still start
- If Ollama crashes, RAG services keep running in degraded mode
- When Ollama comes back, RAG services automatically resume full functionality

## Monitoring

Relay's alerting system should:
1. Alert on `ollama.status == "down"` for > 5 minutes
2. Alert on `ollama.status == "degraded"` for > 30 minutes
3. Include Ollama latency in the health dashboard

## Thermal Considerations

CPU-only inference under sustained load will raise CPU temperature. The R10 has adequate cooling for burst workloads. For sustained embedding (full re-index):

- Monitor with: `sensors` or `cat /sys/class/thermal/thermal_zone*/temp`
- If temp exceeds 85°C, Ollama requests will slow (kernel throttling)
- The health API should report CPU temp when available
- Consider scheduling full re-indexes during off-peak hours (2-5am CST)
