# Lesson: don't `--delete-branch` a stacked-PR base mid-train

**Date:** 2026-05-27 · **Context:** ANR Tires merge train (6 stacked PRs) · **Logged by:** relay (from Claude's report)

## What happened
Merge train of 6 stacked PRs (#1→#2→#6→#3→#4→#5). Running `gh pr merge #1 --delete-branch` deleted the base branch `feature/bc-import`. Because #2 and #3 were **stacked on that base**, GitHub **cascade-closed them** (a PR whose base branch is deleted gets auto-closed), and **GitHub will not reopen a PR whose base branch is gone**. Result: #2/#3 showed CLOSED instead of MERGED.

## Impact
Cosmetic only — **no code lost.** Claude completed the train via local merge + push; #2/#3 code landed on `main`. Verified two ways: `git branch --contains` + relay independently grepped `origin/main` for #2 (sku fix `SVC-`) and #3 (`#6B8CAE`) signatures — both present. Final state: #1/#4/#5/#6 MERGED, #2/#3 CLOSED-but-integrated.

## Rule
- **Do NOT pass `--delete-branch` when merging the base of a still-open stacked PR.** Merge bases without deleting; retarget the children to `main` first, or merge children before deleting any base.
- Safer pattern for stacked trains: merge bottom-up, **retarget each child PR to `main` as its parent merges** (GitHub does this automatically only if the base still exists at merge time), THEN delete branches at the end.
- When a train completes via local merge (bypassing PR UI), **independently verify integration on `origin/main`** (grep for each PR's signature) before declaring clean — don't rely on PR status, which can lie after a cascade-close.
