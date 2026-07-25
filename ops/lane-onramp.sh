#!/bin/bash
# Lane-specific onramp — generates agent-appropriate startup checklist
# Usage: lane-onramp.sh [agent-name]
# Called by SessionStart hook to inject relevant context per agent role

AGENT="${1:-unknown}"

# Common for all agents
COMMON="SESSION ON-RAMP CHECKLIST:
1. Read shared-brain/retros/ for lessons from previous sessions
2. Read shared-brain/STATUS.md for current state
3. Check #dev and #bugs for anything jam posted"

case "$AGENT" in
  claude)
    echo "$COMMON
4. Run: git status across all 5 repos for uncommitted changes
5. Check open PRs: gh pr list across repos
6. Read shared-brain/ops/consolidated-backlog.md for assigned work
7. Check deploy status: cat /tmp/verify-alerts.log | tail -20
8. THEN start building

LANE: Engineering. Focus: code, PRs, deploys, infrastructure.
Skip: audio architecture details, competitive analysis, design system docs."
    ;;
  static)
    echo "$COMMON
4. Run playwright tests: cd ~/teams/nwl/static-workspace && node tests/all-products.mjs
5. Check deploy status: cat /tmp/verify-alerts.log | tail -20
6. Check R10 health: curl -s http://nwl-r10:3850/health | python3 -m json.tool
7. Review what changed since last session (git log, STATUS.md diff)
8. THEN start verifying

LANE: QA. Focus: tests, deploys, verification, service health.
Skip: audio architecture, competitive analysis, design system, product roadmap."
    ;;
  claudia)
    echo "$COMMON
4. Check deploy status: cat /tmp/verify-alerts.log | tail -20
5. Take screenshots of key products to verify visual state
6. Check ~/shared-brain/brand/ for brand guideline updates
7. Read any open design-related PRs or bugs in #dev
8. THEN start designing

LANE: Design + Creative. Focus: visual QA, CSS, layout, brand.
Skip: DB schema, engineering workflows, audio details, competitive analysis."
    ;;
  near)
    echo "$COMMON
4. Check research queue in memory + backlog
5. Check AI landscape scan schedule
6. Review RAG index health: curl -s http://nwl-r10:8080/health
7. THEN start researching

LANE: Research. Focus: competitive analysis, market data, RAG, documentation research.
Skip: test results, deploy pipeline, audio details, design system."
    ;;
  hum)
    echo "$COMMON
4. Run audio analysis on live products (verify current state)
5. Check R10 audio services (piper TTS on :8091): curl -s http://nwl-r10:3850/health
6. Review audio knowledge base for recent additions
7. Check Static FM playlist health
8. Review any audio-related bugs in #bugs
9. THEN start listening

LANE: Audio Engineering. Focus: audio quality, TTS, spectral analysis, sound design.
Skip: deploy pipeline, competitive analysis, design system, engineering workflows."
    ;;
  relay)
    echo "$COMMON
4. Run playwright tests: cd ~/teams/nwl/static-workspace && node tests/all-products.mjs
5. Check deploy status: cat /tmp/verify-alerts.log | tail -20
6. Check all agent screen sessions: screen -ls
7. Take screenshots of key products to verify visual state
8. THEN start coordinating

LANE: Ops. Focus: process, deploys, documentation, agent health, coordination.
Do NOT skip this checklist. Building and testing are parallel."
    ;;
  *)
    echo "$COMMON
4. Check deploy status: cat /tmp/verify-alerts.log | tail -20
5. THEN orient and start work

LANE: Unknown agent. Read your CLAUDE.md for role."
    ;;
esac
