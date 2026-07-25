#!/bin/bash
# ups-notify.sh — Sends UPS status changes to vigil chat
# Location on R10: /srv/shared/bin/ups-notify.sh
# Location on Mini: /usr/local/bin/ups-notify.sh
# Owner: static

EVENT="$NOTIFYTYPE"
LOG="/var/log/ups-notify.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') UPS event: $EVENT" >> "$LOG"

case "$EVENT" in
    ONBATT)
        MSG="UPS: running on battery. monitoring power state."
        ;;
    LOWBATT)
        MSG="UPS: LOW BATTERY. initiating graceful cluster shutdown."
        ;;
    ONLINE)
        MSG="UPS: power restored. all clear."
        ;;
    SHUTDOWN)
        MSG="UPS: shutdown in progress."
        ;;
    *)
        MSG="UPS event: $EVENT"
        ;;
esac

# Post to vigil chat (if vigil is still running)
curl -s -o /dev/null -m 5 \
    -u "system:nwl-mission-control" \
    -X POST "http://localhost:3847/api/chat" \
    -H "Content-Type: application/json" \
    -d "{\"sender\":\"ups\",\"text\":\"$MSG\"}" 2>/dev/null
