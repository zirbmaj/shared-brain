# NWL Supabase (Syght) Database Audit — 2026-04-05

## Summary
- **37 tables**, all with RLS enabled (no security gaps)
- **18 dormant tables** (0 rows) — cleanup candidates post-launch
- **564 RPCs** — large surface area, many tied to unused subsystems
- **264 indexes** — some over-indexing on empty tables
- **R10 postgres not audited** — needs SSH browser auth from jam

## Tables & Row Counts

| Table | Rows | Notes |
|-------|-----:|-------|
| accounts | 1 | |
| account_members | 3 | |
| asset_document_references | 1 | |
| asset_folders | 1 | |
| brand_logo_cache | 136 | highest row count |
| classification_access_grants | 0 | DORMANT |
| classification_access_requests | 0 | DORMANT |
| dashboard_layouts | 17 | |
| invitations | 2 | |
| join_links | 0 | DORMANT |
| notifications | 1 | |
| org_member_roles | 0 | DORMANT |
| org_notification_settings | 0 | DORMANT |
| org_roles | 0 | DORMANT |
| org_shared_items | 0 | DORMANT |
| org_workflow_assignments | 0 | DORMANT |
| org_workflow_executions | 0 | DORMANT |
| org_workflow_steps | 0 | DORMANT |
| org_workflows | 0 | DORMANT |
| organization_assets | 4 | |
| organization_members | 5 | |
| organizations | 3 | |
| personal_space_references | 0 | DORMANT |
| personal_space_shares | 0 | DORMANT |
| personal_spaces | 8 | |
| profiles | 3 | |
| resource_permissions | 0 | DORMANT — 16 indexes on 0 rows |
| roles | 2 | |
| share_links | 2 | |
| team_default_permissions | 0 | DORMANT |
| team_members | 3 | |
| teams | 2 | |
| workspace_folders | 8 | |
| workspace_item_folders | 0 | DORMANT |
| workspace_relationships | 0 | DORMANT |
| workspace_schemas | 0 | DORMANT |
| workspaces | 4 | 34 indexes (over-indexed for 4 rows) |

## Dormant Table Groups

1. **Workflow engine** (4 tables, ~15 indexes): org_workflows, org_workflow_steps, org_workflow_executions, org_workflow_assignments — never used
2. **Custom roles** (2 tables): org_roles, org_member_roles — redundant with roles table
3. **Sharing/permissions** (5 tables): classification_access_*, resource_permissions, team_default_permissions, personal_space_*
4. **Workspace metadata** (3 tables): workspace_item_folders, workspace_relationships, workspace_schemas

## RLS Status
All 37 tables: RLS enabled. No gaps.

## Recommendation
Don't drop anything pre-launch. Post-launch (30 days), audit which dormant tables got populated and prune the rest with their RPCs and indexes.

## Remaining
- R10 postgres audit blocked on SSH browser auth — jam needs to approve tailscale SSH session
- ServiceBay DB already documented at shared-brain/nwl/servicebay-schema-reference.md
