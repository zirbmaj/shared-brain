#!/bin/bash
# =============================================================================
# R10 Boot Dependency Verification
# Tests the systemd unit dependency chain without actually rebooting.
# Usage: sudo bash boot-test.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; FAILURES=$((FAILURES + 1)); }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

FAILURES=0

echo "=== R10 Boot Dependency Verification ==="
echo ""

# --- 1. Check unit files exist ---
echo "1. Unit files installed:"

UNITS=(
    "nwl-node-health.service"
    "nwl-rag-indexer.service"
    "nwl-rag-search.service"
    "nwl-homeassistant.service"
    "nwl-browser.service"
)
OVERRIDES=(
    "postgresql.service.d/nwl-dependency.conf"
    "ollama.service.d/nwl-dependency.conf"
    "syncthing@.service.d/nwl-dependency.conf"
)

for unit in "${UNITS[@]}"; do
    if [ -f "/etc/systemd/system/$unit" ]; then
        pass "$unit"
    else
        fail "$unit — not found in /etc/systemd/system/"
    fi
done

for override in "${OVERRIDES[@]}"; do
    if [ -f "/etc/systemd/system/$override" ]; then
        pass "override: $override"
    else
        fail "override: $override — not found"
    fi
done

echo ""

# --- 2. Verify dependency chain with systemd-analyze ---
echo "2. Dependency chain verification:"

# Check that each service has correct After= dependencies
verify_after() {
    local unit="$1"
    shift
    local deps=("$@")

    local actual
    actual=$(systemctl show "$unit" --property=After 2>/dev/null || echo "")

    for dep in "${deps[@]}"; do
        if echo "$actual" | grep -q "$dep"; then
            pass "$unit After=$dep"
        else
            fail "$unit missing After=$dep"
        fi
    done
}

# Verify the chain
verify_after "postgresql.service" "tailscaled.service"
verify_after "ollama.service" "tailscaled.service"
verify_after "syncthing@nwl-svc.service" "tailscaled.service"
verify_after "nwl-node-health.service" "tailscaled.service"
verify_after "nwl-rag-indexer.service" "postgresql.service" "ollama.service" "syncthing@nwl-svc.service"
verify_after "nwl-rag-search.service" "postgresql.service" "ollama.service"
verify_after "nwl-homeassistant.service" "docker.service" "tailscaled.service"
verify_after "nwl-browser.service" "docker.service" "tailscaled.service"

echo ""

# --- 3. Verify restart policies ---
echo "3. Restart policies:"

verify_restart() {
    local unit="$1"
    local expected_restart="$2"
    local expected_sec="$3"

    local actual_restart
    actual_restart=$(systemctl show "$unit" --property=Restart 2>/dev/null | cut -d= -f2)
    local actual_sec
    actual_sec=$(systemctl show "$unit" --property=RestartUSec 2>/dev/null | cut -d= -f2)

    if [ "$actual_restart" = "$expected_restart" ]; then
        pass "$unit Restart=$expected_restart"
    else
        fail "$unit Restart=$actual_restart (expected $expected_restart)"
    fi
}

verify_restart "nwl-node-health.service" "always" "5s"
verify_restart "nwl-rag-indexer.service" "on-failure" "30s"
verify_restart "nwl-rag-search.service" "on-failure" "10s"
verify_restart "nwl-homeassistant.service" "on-failure" "30s"
verify_restart "nwl-browser.service" "on-failure" "15s"

echo ""

# --- 4. Verify security hardening ---
echo "4. Security hardening:"

verify_security() {
    local unit="$1"
    local props=("NoNewPrivileges" "ProtectHome" "ProtectSystem")

    for prop in "${props[@]}"; do
        local val
        val=$(systemctl show "$unit" --property="$prop" 2>/dev/null | cut -d= -f2)
        if [ "$val" = "yes" ] || [ "$val" = "strict" ] || [ "$val" = "true" ]; then
            pass "$unit $prop=$val"
        else
            warn "$unit $prop=$val (consider enabling)"
        fi
    done
}

for unit in "${UNITS[@]}"; do
    verify_security "$unit"
done

echo ""

# --- 5. Verify boot order with systemd-analyze ---
echo "5. Boot order (systemd-analyze):"

if command -v systemd-analyze &>/dev/null; then
    # Check for circular dependencies
    if systemd-analyze verify nwl-*.service 2>&1 | grep -i "cycle"; then
        fail "Circular dependency detected!"
    else
        pass "No circular dependencies"
    fi

    # Show critical chain
    echo ""
    echo "  Critical chain (time to reach multi-user.target):"
    systemd-analyze critical-chain multi-user.target 2>/dev/null | head -20 | sed 's/^/    /'
else
    warn "systemd-analyze not available"
fi

echo ""

# --- 6. Simulate postgres failure cascade ---
echo "6. Dependency cascade simulation:"
echo "  (Checking what happens when postgresql stops)"

BOUND=$(systemctl show nwl-rag-indexer.service --property=BindsTo 2>/dev/null | cut -d= -f2)
if echo "$BOUND" | grep -q "postgresql.service"; then
    pass "rag-indexer BindsTo=postgresql (will stop with postgres)"
else
    fail "rag-indexer not bound to postgresql"
fi

BOUND=$(systemctl show nwl-rag-search.service --property=BindsTo 2>/dev/null | cut -d= -f2)
if echo "$BOUND" | grep -q "postgresql.service"; then
    pass "rag-search BindsTo=postgresql (will stop with postgres)"
else
    fail "rag-search not bound to postgresql"
fi

echo ""

# --- Summary ---
echo "=== SUMMARY ==="
if [ "$FAILURES" -eq 0 ]; then
    echo -e "${GREEN}All checks passed.${NC} Boot dependency chain is correct."
else
    echo -e "${RED}$FAILURES check(s) failed.${NC} Review and fix before deploying."
fi

exit "$FAILURES"
