---
title: ServiceBay UX Audit
date: 2026-04-04
author: claudia
type: design-reference
---

# ServiceBay UX Audit - Design Lead Findings

## Design System Assessment (9/10)

Strong foundation:
- Dual theme: "Midnight Mechanic" (dark) + "Steel Mechanic" (light)
- Full CSS variable token system in HSL, semantic naming
- 63+ shadcn/ui components, 8 button variants including FUI variant
- Inter + JetBrains Mono fonts, tabular numbers for data
- Noise texture overlay + glass-morphism brand direction

## What's Been Shipped (Session 15, 9 PRs)

### PR #42 - Responsive Dialog Grids
- CompanyFormDialog, ContactFormDialog, StandaloneAssetFormDialog: tabs 4-col to 2-col on mobile
- BulkLabelPrintDialog: print settings 3-col to 1-col on mobile

### PR #47 - Portal Badge Readability
- PortalGarageTab, PortalHistoryTab, PortalBookTab: all text-[10px] bumped to text-xs
- Button heights h-8 to h-10 on mobile, sm:h-8 for desktop density

### PR #51 - Filter Consolidation
- Sort + Group dropdowns merged into single "View" dropdown
- Removed low-value options (Customer Z-A, Promised date, Group by Vehicle)
- 3 controls reduced to 2

### PR #57 - Dynamic Action Buttons
- Job cards show contextual button per lifecycle stage
- estimating: "Send Estimate", in_progress: "Mark Complete", invoicing: "Record Payment", ready_for_pickup: "Check Out"
- Wired with inline mutations by Claude (PR #61)

### PRs #65, #66, #68 - Stage Colors Consolidation
- Created shared src/lib/stage-colors.ts constant
- Migrated 6 components, removed ~250 lines of duplicated color definitions
- in_progress now consistently indigo across the entire app

### PR #72 - 404 + Kanban Badge
- NotFound page: bg-muted to bg-background for dark theme
- TechJobBoard kanban column badge: text-[10px] to text-xs

## Remaining Design Opportunities

### High Priority
1. **JobsListView stage colors** - last file with inline color defs. Icons coupled to config, needs careful migration
2. **Dedup UX** - inline warning banner when creating contacts/vehicles with fuzzy match suggestions. Soft yellow warning, "Use Existing" or "Create Anyway" buttons. Must not block workflow
3. **Sound settings UI** - mute toggle + volume slider for the 25-sound audio system (collaborate with Hum)

### Medium Priority
4. **Tech view kanban column widths** - columns feel narrow on smaller desktops, could benefit from wider min-width or horizontal scroll
5. **Tech view mobile header density** - search bar + toggle take up vertical space before useful content
6. **Catalog table mobile card view** - table works on desktop but needs card-based mobile layout
7. **Photo grid responsive** - WorkApproval photo grid could go grid-cols-1 sm:grid-cols-2 on very small phones
8. **Photo captions** - WorkApproval photos have no visible captions (data exists in DB)

### Low Priority
9. **Contact filter tab loading skeletons** - no skeleton when switching between filter tabs
10. **Empty state icon scaling** - some empty states use h-12 icons that could scale with h-8 sm:h-12
11. **Dialog padding responsive** - VehicleFormDialog could use p-3 sm:p-6

## UX Patterns Established

### Responsive Pattern
`grid-cols-{mobile} sm:grid-cols-{desktop}` for all grids in dialogs and forms

### Touch Target Standard  
44px minimum (h-10) on mobile, h-8 for desktop density via `h-10 sm:h-8`

### Badge Readability
text-xs minimum for customer-facing pages. text-[10px] acceptable in tech view (dense data interface for technicians)

### Action Buttons
One contextual action per card, changes based on lifecycle stage. Green accent for money actions.

### Filter UX
Combined Sort + Group into single "View" dropdown. Default to "Active" filter (hide complete/cancelled).

## Key Files for Design Work

| Component | Path | Notes |
|-----------|------|-------|
| Stage colors | src/lib/stage-colors.ts | Single source of truth |
| Job cards | src/components/jobs/JobsListView.tsx | Has action buttons + filter UX |
| Portal sections | src/components/portal/portal-sections/ | Customer-facing, text-xs badges |
| Tech kanban | src/components/tech/TechJobBoard.tsx | Dense data, text-[10px] intentional |
| 404 page | src/pages/NotFound.tsx | Dark theme fixed |
| Public pages | src/pages/public/ | Light bg-muted/5, safe-area handled |

## Design Principles for ServiceBay

1. **Don't block workflows** - warnings not modals, "Create Anyway" always available
2. **Information density is a feature** for tech/staff views, readability for customer views
3. **Midnight Mechanic identity** - dark theme, noise texture, glass-morphism, precision feel
4. **Audio reinforces milestones** - sounds on achievements (payment, completion), not navigation
5. **Mobile first for portal** - customers are on phones. Desktop first for staff views
