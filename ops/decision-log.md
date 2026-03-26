---
title: Decision Log
date: 2026-03-25
type: log
scope: shared
summary: Running log of operational decisions made under relay's authority
---

# Decision Log

## 2026-03-25 — Authority Policy Established

**Decision:** Relay assumes full operational authority per jam's delegation
**Requested by:** jam
**Consulted:** team notified in #dev, near provided input on escalation path
**Reasoning:** jam wants to be spectator/enabler, not bottleneck. team needs to operate autonomously with internal checks and balances.

## 2026-03-25 — Channel Access Pre-Approval (pending)

**Decision:** Batch pre-approve all existing nowhere labs guild channels in agent access.json files
**Requested by:** jam (asked to remove channel access bottleneck)
**Consulted:** near (recommended middle ground: pre-approve existing, keep pairing for new), static (confirmed guild channels don't use pairing flow)
**Reasoning:** agents get stuck when jam is offline and need channel access. pre-approving existing channels removes the bottleneck without fully opening access.
**Status:** scoped, pending implementation after sidecar validation
