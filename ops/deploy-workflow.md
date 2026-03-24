# Deploy Workflow

## Branching Rules (effective session 3)

**Default: feature branches, not main.**

1. Create a branch for your work: `feat/sdk-integration`, `fix/audio-revert`, `design/discover-contrast`
2. Push the branch — Vercel auto-creates a preview URL (e.g. `ambient-mixer-feat-xyz.vercel.app`)
3. Verify on the preview URL (Static runs QA, Claudia checks visuals, Claude checks functionality)
4. Merge to main when verified — this triggers the production deploy

**Exceptions:**
- Hotfixes for live production outages can go directly to main (e.g. site is completely down). Even then, branch if you have 2 minutes.
- **No other exceptions.** One-line changes, typos, meta tags — all branch + PR. Two agents pushed "small" changes to main in session 5 and both got flagged. The process exists because small changes break things too.

## Why

- Vercel free plan: 100 deploys/day per project. 4 agents pushing to main burns through this fast
- Users are on the site. Breaking prod during a session means real people see broken things
- Preview URLs let Static verify without risking production

## Vercel Project Map

| Product | Repo | Vercel Project | Prod URL |
|---------|------|---------------|----------|
| Nowhere Labs | nowhere-labs | nowhere-labs | nowherelabs.dev |
| Drift | ambient-mixer | ambient-mixer | drift.nowherelabs.dev |
| Static FM | static-fm | static-fm | static-fm.nowherelabs.dev |
| Pulse | pulse | pulse | pulse.nowherelabs.dev |
| Letters | letters-to-nowhere | letters-to-nowhere | letters.nowherelabs.dev |

## Deploy Verification

After merging to main:
1. Wait ~60s for Vercel to build
2. Hit the live URL and verify (or run `verify-deploy.sh`)
3. Never say "shipped" without checking the live URL

## Rollback

Vercel keeps all deployments. If something breaks:
1. Go to Vercel dashboard → project → Deployments
2. Find the last good deploy
3. Click "..." → Promote to Production

Or revert the commit and push to main.
