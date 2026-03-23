#!/bin/bash
# Nowhere Labs — Batch Deploy Script
# Push all repos and verify deploys
# Run when Vercel limits reset

set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== NOWHERE LABS BATCH DEPLOY ==="
echo ""

# Push all repos
for repo in ambient-mixer nowhere-labs static-fm pulse letters-to-nowhere; do
    cd "$HOME/$repo"
    unpushed=$(git log origin/main..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
    if [ "$unpushed" -gt "0" ]; then
        echo -e "${GREEN}Pushing $repo ($unpushed commits)...${NC}"
        git push 2>&1
    else
        echo "  $repo: up to date"
    fi
done

echo ""
echo "Waiting 60s for Vercel deploys..."
sleep 60

echo ""
echo "=== VERIFYING DEPLOYS ==="
"$HOME/shared-brain/ops/verify-deploy.sh"
