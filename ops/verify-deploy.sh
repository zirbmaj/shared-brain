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
    # Check that app.html serves 200, not 308 redirect
    HTTP_CODE=$(curl -sI "https://drift.nowherelabs.dev/app.html" 2>&1 | grep "HTTP/" | awk '{print $2}')
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓${NC} No redirect — app.html serves 200"
    else
        echo -e "${RED}✗${NC} app.html returns $HTTP_CODE (expected 200, may be cleanUrls redirect)"
        FAILED=1
    fi
    check "https://drift.nowherelabs.dev/app.html" "reset-btn" "Reset button"
    check "https://drift.nowherelabs.dev/app.html" "publish-btn" "Publish button"
    check "https://drift.nowherelabs.dev/style.css" "sticky" "Sticky controls"
    check "https://drift.nowherelabs.dev/engine.js" "muted" "Mute toggle"
    check "https://drift.nowherelabs.dev/engine.js" "resetAll" "Reset function"
    check "https://drift.nowherelabs.dev/discover.html" "mix-grid" "Discover page"
    check "https://drift.nowherelabs.dev/engine.js" "DEFAULT_MIXES" "Default mixes for cold start"
    check "https://drift.nowherelabs.dev/app.html" "discover.html" "Discover button in controls"
    echo ""
fi

# Static FM
if [ "$1" = "" ] || [ "$1" = "static-fm" ]; then
    echo "=== STATIC FM (static-fm.nowherelabs.dev) ==="
    check "https://static-fm.nowherelabs.dev/" "chat-float" "Floating chat"
    check "https://static-fm.nowherelabs.dev/chat-float.js" "createFloatingMsg" "Floating chat JS"
    check "https://static-fm.nowherelabs.dev/" "og:image" "OG image tag"
    echo ""
fi

# Nowhere Labs
if [ "$1" = "" ] || [ "$1" = "nowhere-labs" ]; then
    echo "=== NOWHERE LABS (nowherelabs.dev) ==="
    check "https://nowherelabs.dev/" "dashboard" "Dashboard link"
    check "https://nowherelabs.dev/dashboard/" "session-picker" "Session picker"
    check "https://nowherelabs.dev/chat" "checking who" "Chat presence default"
    check "https://nowherelabs.dev/building/" "building" "Building page"
    check "https://nowherelabs.dev/track.js" "utm_source" "UTM tracking"
    check "https://nowherelabs.dev/track.js" "nwl_uid" "Persistent user ID"
    check "https://nowherelabs.dev/track.js" "bot.*crawl" "Bot filter"
    echo ""
fi

# Heartbeat
if [ "$1" = "" ] || [ "$1" = "heartbeat" ]; then
    echo "=== HEARTBEAT (nowherelabs.dev/heartbeat.html) ==="
    check "https://nowherelabs.dev/heartbeat" "get_event_count" "Event count RPC"
    check "https://nowherelabs.dev/heartbeat" "heartbeat" "Heartbeat query"
    echo ""
fi

# Pulse
if [ "$1" = "" ] || [ "$1" = "pulse" ]; then
    echo "=== PULSE (pulse.nowherelabs.dev) ==="
    check "https://pulse.nowherelabs.dev/" "timer-display" "Timer display"
    check "https://pulse.nowherelabs.dev/" "og:image" "OG image tag"
    echo ""
fi

# Letters
if [ "$1" = "" ] || [ "$1" = "letters" ]; then
    echo "=== LETTERS (letters.nowherelabs.dev) ==="
    check "https://letters.nowherelabs.dev/" "void" "Void page"
    check "https://letters.nowherelabs.dev/" "og:image" "OG image tag"
    echo ""
fi

# Drift SEO pages
if [ "$1" = "" ] || [ "$1" = "drift" ]; then
    echo "=== DRIFT SEO ==="
    check "https://drift.nowherelabs.dev/brown-noise-for-focus.html" "app.html" "Brown noise focus page CTA"
    check "https://drift.nowherelabs.dev/rain-sounds-for-studying.html" "og:image" "Rain SEO OG image"
    echo ""
fi

# Drift new pages
if [ "$1" = "" ] || [ "$1" = "drift" ]; then
    echo "=== DRIFT EXTRAS ==="
    check "https://drift.nowherelabs.dev/sleep.html" "start" "Sleep timer"
    check "https://drift.nowherelabs.dev/today.html" "today" "Today page"
    check "https://drift.nowherelabs.dev/app.html" "og:image" "App OG image"
    check "https://drift.nowherelabs.dev/app.html" "og:url" "App OG URL"
    echo ""
fi

# Ops dashboard
if [ "$1" = "" ] || [ "$1" = "nowhere-labs" ]; then
    echo "=== OPS DASHBOARD ==="
    check "https://nowherelabs.dev/ops" "events-today" "Ops dashboard"
    echo ""
fi

if [ $FAILED -eq 1 ]; then
    echo -e "${RED}DEPLOY VERIFICATION FAILED${NC} — some changes are not live"
    exit 1
else
    echo -e "${GREEN}ALL CHECKS PASSED${NC} — everything is live"
fi
