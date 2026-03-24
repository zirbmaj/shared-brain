#!/bin/bash
# Pre-commit hook: blocks direct commits to main branch
# Install: cp this file to .git/hooks/pre-commit in each repo
# Or: ln -s ~/shared-brain/ops/protect-main-hook.sh .git/hooks/pre-commit

branch=$(git symbolic-ref --short HEAD 2>/dev/null)

if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
    # Allow empty commits (deploy triggers) and merge commits
    if git diff --cached --quiet 2>/dev/null; then
        exit 0
    fi
    echo ""
    echo "  BLOCKED: direct commit to main"
    echo "  Create a branch first: git checkout -b fix/your-change"
    echo "  Then commit and open a PR."
    echo ""
    exit 1
fi
