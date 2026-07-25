# XPS Test Runner Integration Spec
**Author:** Static (QA Lead)
**Date:** 2026-03-31
**Status:** Draft — pending jam approval

## Purpose
Dedicated test runner on the Dell XPS 9305 that feeds results into Vigil v4's bottom bar. Independent from the Mac Mini so tests don't compete with agent workloads and verification comes from a separate network origin.

## What Runs on the XPS

### 1. Scheduled Product Suite (every 30 min)
- Full 45-test Playwright suite (`tests/all-products.mjs`)
- Results written to `/tmp/test-results/latest.json`
- Format: `{ timestamp, total, passed, failed, failures: [{ product, test, error }] }`

### 2. Uptime Monitor (every 5 min)
- HTTP GET to all product URLs, record status code + response time
- Products: drift, static-fm, homepage, dashboard, pulse, letters, discover, sleep, wallpaper, support
- Results: `/tmp/uptime/latest.json`
- Format: `{ timestamp, products: [{ name, url, status, responseMs }] }`

### 3. Accessibility Audit (every 6 hours)
- axe-core scan on launch-critical products (drift app, static fm, homepage)
- Results: `/tmp/a11y/latest.json`
- Format: `{ timestamp, products: [{ name, violations, passes }] }`

### 4. Deploy Watcher (event-driven)
- Poll Vercel API for new deployments (every 2 min)
- On new deploy detected: trigger full test suite + screenshot comparison
- Results: `/tmp/deploy-verify/latest.json`

## Vigil Integration

### Data Feed
Vigil scrapes test results via a lightweight HTTP endpoint on the XPS:

```
GET :3851/test-results    → latest test suite results
GET :3851/uptime          → latest uptime check
GET :3851/a11y            → latest accessibility audit
GET :3851/deploy          → latest deploy verification
GET :3851/health          → runner health (is the test infra itself alive)
```

Served by a simple Node/Express server (~50 lines) that reads the JSON files from `/tmp/`.

### Bottom Bar Display Data
Vigil's bottom bar consumes these endpoints and shows:
- **Test status:** `45/45 PASS` or `43/45 FAIL: [drift-app-mobile, letters-input]` with timestamp
- **Uptime:** green/red dots per product with response time
- **Last deploy:** product name + timestamp of most recent Vercel deploy
- **A11y:** violation count (0 = green, 1+ = amber)
- **Active alerts:** any failures from the last 30 min

### Alert Escalation
- Test failure → Vigil bottom bar turns red
- 2+ consecutive failures → Vigil triggers alert (sentinel agent → SMS via Flip)
- Product down (uptime check fails) → immediate alert

## Resource Requirements
- Playwright + Chromium: ~300-500MB RAM during test runs
- Node.js API server: ~30MB RAM
- Idle between runs: minimal CPU
- Estimated total: 600MB peak, well within 8GB

## Dependencies
- Node.js + Playwright installed on XPS
- Tailscale connected to mesh
- Test suite synced from static-workspace (via syncthing or git pull)
- Vigil v4 backend updated to scrape :3851 endpoints

## Open Questions
- Syncthing vs git pull for keeping test suite in sync?
- Do we want visual regression (screenshot diff against baseline)? Adds storage needs
- Should the test runner have its own workspace or share static-workspace via syncthing?
