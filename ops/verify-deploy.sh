#!/bin/bash
# Nowhere Labs — Post-deploy verification
# Run after pushing to verify changes are live
# Usage: ./verify-deploy.sh [project]

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check() {
    local url="$1"
    local search="$2"
    local label="$3"

    if curl -s "$url" | grep -q "$search"; then
        echo -e "${GREEN}✓${NC} $label — found '$search'"
    else
        echo -e "${RED}✗${NC} $label — '$search' NOT found on live site"
        FAILED=1
    fi
}

FAILED=0

echo "Verifying live deployments..."
echo ""

# Drift
if [ "$1" = "" ] || [ "$1" = "drift" ]; then
    echo "=== DRIFT (drift.nowherelabs.dev) ==="
    check "https://drift.nowherelabs.dev/app.html" "reset-btn" "Reset button"
    check "https://drift.nowherelabs.dev/app.html" "publish-btn" "Publish button"
    check "https://drift.nowherelabs.dev/style.css" "sticky" "Sticky controls"
    check "https://drift.nowherelabs.dev/engine.js" "savedVolume" "Mute toggle (icon click)"
    check "https://drift.nowherelabs.dev/engine.js" "resetAll" "Reset function"
    check "https://drift.nowherelabs.dev/discover.html" "mix-grid" "Discover page"
    echo ""
fi

# Static FM
if [ "$1" = "" ] || [ "$1" = "static-fm" ]; then
    echo "=== STATIC FM (static-fm.nowherelabs.dev) ==="
    check "https://static-fm.nowherelabs.dev/" "chat-sidebar" "Chat sidebar"
    check "https://static-fm.nowherelabs.dev/chat-sidebar.js" "loadMessages" "Chat JS"
    echo ""
fi

# Nowhere Labs
if [ "$1" = "" ] || [ "$1" = "nowhere-labs" ]; then
    echo "=== NOWHERE LABS (nowherelabs.dev) ==="
    check "https://nowherelabs.dev/" "dashboard" "Dashboard link"
    check "https://nowherelabs.dev/dashboard/" "session-picker" "Session picker"
    check "https://nowherelabs.dev/chat.html" "chat" "Chat page"
    check "https://nowherelabs.dev/building/" "building" "Building page"
    echo ""
fi

# Letters
if [ "$1" = "" ] || [ "$1" = "letters" ]; then
    echo "=== LETTERS (letters.nowherelabs.dev) ==="
    check "https://letters.nowherelabs.dev/" "void" "Void page"
    echo ""
fi

if [ $FAILED -eq 1 ]; then
    echo -e "${RED}DEPLOY VERIFICATION FAILED${NC} — some changes are not live"
    exit 1
else
    echo -e "${GREEN}ALL CHECKS PASSED${NC} — everything is live"
fi
