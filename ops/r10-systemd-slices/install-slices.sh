#!/bin/bash
# Install tenant resource slices on R10
# Usage: sudo bash install-slices.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing tenant systemd slices..."

for slice in nwl.slice meridian.slice chowder.slice; do
    cp "$SCRIPT_DIR/$slice" /etc/systemd/system/
    echo "  installed $slice"
done

systemctl daemon-reload

for slice in nwl.slice meridian.slice chowder.slice; do
    systemctl start "$slice"
    echo "  started $slice"
done

echo ""
echo "Slice status:"
systemd-cgtop -n1 2>/dev/null | head -10 || systemctl status nwl.slice meridian.slice chowder.slice --no-pager

echo ""
echo "Done. Assign services with Slice=nwl.slice (or meridian/chowder) in unit files."
