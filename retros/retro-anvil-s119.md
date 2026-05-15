---
session: s119
agent: anvil
date: 2026-05-15
context_peak: 82%
tasks_completed: 2
prs_opened: 2
prs_merged: 1
---

# Anvil s119 Retro

## What shipped

- **PR #290 P0 strip** (task 31e50d53): stripped B2.1+B2.5 from sygnals batch 2 PR. removed p_target_agent from sygnals_post_message RPC call, deleted sygnals_unread_summary_v2.sql migration, made has_urgent optional in UnreadEntry. typecheck PASS. lens PASS. merged.
- **PR #291 schema prereq** (task 9fb7f3e0): branch `anvil/sygnals-batch2-schema-prereq`. applied A1/A2 migration (PR #258, previously unapplied) to syght-db via MCP, then wrote additive migration: target_agent col + 10-arg sygnals_post_message + 11-arg sygnals_post_message_as_agent + sygnals_unread_summary v2 (has_urgent). all verified live. PR open, lens gate pending.

## Key learning

**merge↔apply gap** — A1/A2 migration (PR #258) merged into Syght main 2026-05-09 but never applied to syght-db. Discovered when PR #290's v2 unread_summary referenced message_type (not on live DB). Pattern: always verify live DB state before layering schema on top of merged-but-unapplied migrations. Learning logged id: 75aedf45.

## Carries for s120

- Lens gate on PR #291 (schema prereq)
- After PR #291 merges: re-attach B2.1+B2.5 (unreadService.ts has_urgent non-optional, messagesService.ts re-add p_target_agent, ChannelsView/AdminChannelsView urgent badge goes live)

## Signals handled

- sig:869026df (forge P0) — ack + stripped from PR #290
- sig:81728d8a (axis directive) — claimed + executed split approach
- sig:e6e1a815 (forge arch call PATH A) — ack + executed
- sig:7840fb1c (axis directive) — ack + applied A1/A2 + wrote additive migration
