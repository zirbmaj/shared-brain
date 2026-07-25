#!/usr/bin/env python3
"""
NWL Node Health API
Lightweight HTTP server exposing node status for the vigil display.
Runs on both nwl-mini (port 3850) and nwl-r10 (port 3850).

Usage:
    python3 health-server.py                    # auto-detect node
    python3 health-server.py --node nwl-r10     # explicit node

Env vars:
    NODE_NAME    — node identifier (default: auto-detect from hostname)
    PORT         — listen port (default: 3850)
"""

import json
import os
import socket
import subprocess
import time
from http.server import HTTPServer, BaseHTTPRequestHandler

NODE_NAME = os.environ.get("NODE_NAME", socket.gethostname())
PORT = int(os.environ.get("PORT", "3850"))
START_TIME = time.time()


def check_service(name, port=None, process=None):
    """Check if a service is running. Returns status dict."""
    result = {"status": "down"}

    if port:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(2)
            s.connect(("localhost", port))
            s.close()
            result["status"] = "ok"
            result["port"] = port
        except (socket.error, OSError):
            result["status"] = "down"
            result["port"] = port

    elif process:
        try:
            out = subprocess.run(
                ["pgrep", "-f", process],
                capture_output=True, text=True, timeout=5,
            )
            if out.returncode == 0:
                result["status"] = "ok"
            else:
                result["status"] = "down"
        except Exception:
            result["status"] = "down"

    return result


def get_ups_status():
    """Read UPS status from NUT (R10 only)."""
    try:
        out = subprocess.run(
            ["upsc", "apc600@localhost"],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode != 0:
            return {"status": "unknown"}

        data = {}
        for line in out.stdout.strip().split("\n"):
            if ":" in line:
                key, val = line.split(":", 1)
                data[key.strip()] = val.strip()

        status = data.get("ups.status", "unknown")
        return {
            "status": "online" if "OL" in status else "on_battery" if "OB" in status else status,
            "battery_pct": int(float(data.get("battery.charge", 0))),
            "runtime_seconds": int(float(data.get("battery.runtime", 0))),
            "load_pct": int(float(data.get("ups.load", 0))),
        }
    except Exception:
        return {"status": "unknown"}


def get_ollama_info():
    """Check Ollama status: model loaded, latency, and backend (CPU/GPU)."""
    info = {"model_loaded": None, "latency_ms": None, "backend": "unknown"}
    try:
        import urllib.request

        # Check model
        req = urllib.request.Request("http://localhost:11434/api/tags")
        with urllib.request.urlopen(req, timeout=3) as resp:
            data = json.loads(resp.read())
            models = [m["name"] for m in data.get("models", [])]
            info["model_loaded"] = models[0] if models else None

        # Measure embedding latency (lightweight probe)
        start = time.time()
        probe = urllib.request.Request(
            "http://localhost:11434/api/embed",
            data=json.dumps({"model": models[0] if models else "mistral:7b", "input": "health check"}).encode(),
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(probe, timeout=15) as resp:
            resp.read()
        info["latency_ms"] = int((time.time() - start) * 1000)

        # Detect GPU backend: check ollama /api/ps for actual compute backend
        # Covers NVIDIA (CUDA), AMD (ROCm), and AMD (Vulkan)
        try:
            ps_req = urllib.request.Request("http://localhost:11434/api/ps")
            with urllib.request.urlopen(ps_req, timeout=3) as resp:
                ps_data = json.loads(resp.read())
                running_models = ps_data.get("models", [])
                if running_models:
                    # Check size_vram — if > 0, model is on GPU
                    vram = running_models[0].get("size_vram", 0)
                    info["backend"] = "gpu" if vram > 0 else "cpu"
                    info["vram_used"] = vram
                else:
                    info["backend"] = "cpu"
        except Exception:
            info["backend"] = "cpu"

    except Exception:
        pass

    return info


def get_disk_usage():
    """Get disk usage percentage for root mount. Works on Linux and macOS."""
    try:
        # Try Linux format first
        out = subprocess.run(
            ["df", "--output=pcent", "/"],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0:
            lines = out.stdout.strip().split("\n")
            if len(lines) >= 2:
                return int(lines[1].strip().rstrip("%"))

        # macOS fallback: df -h / and parse the Capacity column
        out = subprocess.run(
            ["df", "-h", "/"],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0:
            lines = out.stdout.strip().split("\n")
            if len(lines) >= 2:
                parts = lines[1].split()
                # macOS df: Filesystem Size Used Avail Capacity iused ifree %iused Mounted
                for part in parts:
                    if part.endswith("%") and part[:-1].isdigit():
                        return int(part.rstrip("%"))
    except Exception:
        pass
    return None


def get_cpu_usage():
    """Get CPU usage percentage from /proc/loadavg (Linux) or ps (macOS)."""
    try:
        # Linux: 1-minute load average / CPU count
        if os.path.exists("/proc/loadavg"):
            with open("/proc/loadavg") as f:
                load_1m = float(f.read().split()[0])
            cpu_count = os.cpu_count() or 1
            return min(round(load_1m / cpu_count * 100, 1), 100.0)
        # macOS fallback
        out = subprocess.run(
            ["sysctl", "-n", "vm.loadavg"],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0:
            # Output: "{ 1.23 0.45 0.67 }"
            parts = out.stdout.strip().strip("{}").split()
            if parts:
                load_1m = float(parts[0])
                cpu_count = os.cpu_count() or 1
                return min(round(load_1m / cpu_count * 100, 1), 100.0)
    except Exception:
        pass
    return None


def get_memory_usage():
    """Get memory usage percentage from /proc/meminfo (Linux) or sysctl/vm_stat (macOS)."""
    try:
        if os.path.exists("/proc/meminfo"):
            info = {}
            with open("/proc/meminfo") as f:
                for line in f:
                    parts = line.split(":")
                    if len(parts) == 2:
                        key = parts[0].strip()
                        val = int(parts[1].strip().split()[0])  # value in kB
                        info[key] = val
            total = info.get("MemTotal", 1)
            available = info.get("MemAvailable", 0)
            used_pct = round((1 - available / total) * 100, 1)
            return {
                "pct": used_pct,
                "total_gb": round(total / 1024 / 1024, 1),
                "available_gb": round(available / 1024 / 1024, 1),
            }

        # macOS fallback: sysctl for total, vm_stat for usage
        out = subprocess.run(
            ["sysctl", "-n", "hw.memsize"],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0:
            total_bytes = int(out.stdout.strip())
            total_gb = round(total_bytes / (1024 ** 3), 1)

            # vm_stat reports pages; page size is in first line
            vm = subprocess.run(
                ["vm_stat"], capture_output=True, text=True, timeout=5,
            )
            if vm.returncode == 0:
                pages = {}
                page_size = 16384  # default
                for line in vm.stdout.split("\n"):
                    if "page size" in line:
                        for word in line.split():
                            if word.isdigit():
                                page_size = int(word)
                    elif ":" in line:
                        key, val = line.split(":", 1)
                        val = val.strip().rstrip(".")
                        if val.isdigit():
                            pages[key.strip()] = int(val)

                free = pages.get("Pages free", 0) + pages.get("Pages speculative", 0)
                inactive = pages.get("Pages inactive", 0)
                available_bytes = (free + inactive) * page_size
                available_gb = round(available_bytes / (1024 ** 3), 1)
                used_pct = round((1 - available_bytes / total_bytes) * 100, 1)
                return {
                    "pct": used_pct,
                    "total_gb": total_gb,
                    "available_gb": available_gb,
                }
    except Exception:
        pass
    return None


def get_cpu_temp():
    """Read CPU temperature from thermal zones or hwmon (Linux only)."""
    try:
        temps = []
        # Method 1: thermal_zone (common on many systems)
        for i in range(10):
            path = f"/sys/class/thermal/thermal_zone{i}/temp"
            if os.path.exists(path):
                with open(path) as f:
                    temps.append(int(f.read().strip()) / 1000)
        # Method 2: hwmon (AMD Ryzen, k10temp driver)
        if not temps:
            import glob
            for temp_file in glob.glob("/sys/class/hwmon/hwmon*/temp*_input"):
                try:
                    with open(temp_file) as f:
                        temps.append(int(f.read().strip()) / 1000)
                except (ValueError, IOError):
                    pass
        return max(temps) if temps else None
    except Exception:
        return None


def get_r10_health():
    """Health data for the R10 node."""
    services = {
        "postgresql": check_service("postgresql", port=5432),
        "ollama": check_service("ollama", port=11434),
        "homeassistant": check_service("homeassistant", port=8123),
        "nut": check_service("nut", port=3493),
        "rag-api": check_service("rag-api", port=8080),
        "syncthing": check_service("syncthing", port=22000),
        "whisper-stt": check_service("whisper-stt", port=8090),
    }

    # Add ollama details: model, latency, backend
    ollama_info = get_ollama_info()
    if ollama_info["model_loaded"]:
        services["ollama"]["model_loaded"] = ollama_info["model_loaded"]
    if ollama_info["latency_ms"] is not None:
        services["ollama"]["latency_ms"] = ollama_info["latency_ms"]
        # Degrade status based on latency thresholds
        if ollama_info["latency_ms"] > 10000:
            services["ollama"]["status"] = "down"
        elif ollama_info["latency_ms"] > 2000:
            services["ollama"]["status"] = "degraded"
    services["ollama"]["backend"] = ollama_info["backend"]

    # CPU temperature
    cpu_temp = get_cpu_temp()

    result = {
        "node": NODE_NAME,
        "status": "ok" if all(s["status"] == "ok" for s in services.values()) else "degraded",
        "uptime_seconds": int(time.time() - START_TIME),
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "services": services,
        "ups": get_ups_status(),
    }

    if cpu_temp is not None:
        result["cpu_temp_c"] = round(cpu_temp, 1)

    disk_pct = get_disk_usage()
    if disk_pct is not None:
        result["disk_pct"] = disk_pct

    cpu_pct = get_cpu_usage()
    if cpu_pct is not None:
        result["cpu_pct"] = cpu_pct

    mem = get_memory_usage()
    if mem is not None:
        result["memory_pct"] = mem["pct"]
        result["memory_total_gb"] = mem["total_gb"]
        result["memory_available_gb"] = mem["available_gb"]

    return result


def get_mini_health():
    """Health data for the Mac Mini node."""
    services = {
        "vigil-nwl": check_service("vigil-nwl", port=3847),
        "vigil-meridian": check_service("vigil-meridian", port=3849),
        "tunnel-nwl": check_service("tunnel-nwl", process="cloudflared"),
    }

    # Agent status from /tmp/agent-monitor/ if sidecar is running
    # Context files must be fresh (<10 min) to count — stale files from dead
    # agents previously caused false "online" reports (silent death bug, 2026-03-28)
    agents = {}
    monitor_dir = "/tmp/agent-monitor"
    agent_names = ["claude", "claudia", "static", "near", "hum", "relay"]
    stale_threshold = 600  # 10 minutes
    for name in agent_names:
        ctx_file = os.path.join(monitor_dir, f"{name}-context.json")
        ctx_fresh = False
        ctx_data = {}
        try:
            file_age = time.time() - os.path.getmtime(ctx_file)
            if file_age < stale_threshold:
                with open(ctx_file) as f:
                    ctx_data = json.load(f)
                    ctx_fresh = True
        except (FileNotFoundError, json.JSONDecodeError, OSError):
            pass

        if ctx_fresh:
            agents[name] = {
                "status": "online",
                "context_pct": ctx_data.get("context_pct", 0),
            }
        else:
            # Context file missing or stale — fall through to screen check
            try:
                out = subprocess.run(
                    ["screen", "-list"],
                    capture_output=True, text=True, timeout=5,
                )
                # Match primary sessions only (agent-claude, not agent-shadow-claude)
                screen_lines = out.stdout.split("\n")
                found = any(f".agent-{name}\t" in line or f".agent-{name} " in line for line in screen_lines)
                if found:
                    agents[name] = {"status": "online", "context_pct": 0}
                else:
                    agents[name] = {"status": "offline"}
            except Exception:
                agents[name] = {"status": "unknown"}

    result = {
        "node": NODE_NAME,
        "status": "ok" if all(s["status"] == "ok" for s in services.values()) else "degraded",
        "uptime_seconds": int(time.time() - START_TIME),
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "services": services,
        "agents": agents,
    }

    # Hardware metrics (same as R10 — fixes sparse mini card in mesh tab)
    disk_pct = get_disk_usage()
    if disk_pct is not None:
        result["disk_pct"] = disk_pct

    cpu_pct = get_cpu_usage()
    if cpu_pct is not None:
        result["cpu_pct"] = cpu_pct

    mem = get_memory_usage()
    if mem is not None:
        result["memory_pct"] = mem["pct"]
        result["memory_total_gb"] = mem["total_gb"]
        result["memory_available_gb"] = mem["available_gb"]

    return result


def get_xps_health():
    """Health data for the XPS sentinel/test runner node."""
    services = {}
    # Check for services that might be running on the XPS
    for name, port in [("health-api", 3850), ("syncthing", 22000)]:
        svc = check_service(name, port=port)
        if svc["status"] == "ok":
            services[name] = svc

    result = {
        "node": NODE_NAME,
        "status": "ok" if all(s["status"] == "ok" for s in services.values()) else "degraded" if services else "ok",
        "uptime_seconds": int(time.time() - START_TIME),
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "services": services,
        "role": "sentinel",
    }

    disk_pct = get_disk_usage()
    if disk_pct is not None:
        result["disk_pct"] = disk_pct

    cpu_pct = get_cpu_usage()
    if cpu_pct is not None:
        result["cpu_pct"] = cpu_pct

    cpu_temp = get_cpu_temp()
    if cpu_temp is not None:
        result["cpu_temp_c"] = round(cpu_temp, 1)

    mem = get_memory_usage()
    if mem is not None:
        result["memory_pct"] = mem["pct"]
        result["memory_total_gb"] = mem["total_gb"]
        result["memory_available_gb"] = mem["available_gb"]

    return result


class HealthHandler(BaseHTTPRequestHandler):
    """Simple HTTP handler for /health endpoint."""

    def do_GET(self):
        if self.path == "/health":
            if "r10" in NODE_NAME or "alienware" in NODE_NAME.lower():
                data = get_r10_health()
            elif "xps" in NODE_NAME.lower():
                data = get_xps_health()
            else:
                data = get_mini_health()

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(data, indent=2).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        """Suppress default access logging."""
        pass


def main():
    import sys
    if "--node" in sys.argv:
        global NODE_NAME
        idx = sys.argv.index("--node")
        if idx + 1 < len(sys.argv):
            NODE_NAME = sys.argv[idx + 1]

    server = HTTPServer(("0.0.0.0", PORT), HealthHandler)
    print(f"Node health API running on port {PORT} (node: {NODE_NAME})")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down")
        server.shutdown()


if __name__ == "__main__":
    main()
