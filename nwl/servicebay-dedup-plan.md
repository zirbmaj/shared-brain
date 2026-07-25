# ServiceBay Deduplication Plan

Status: BUILT — PR #74 (2026-04-05), QA approved, UX approved, waiting jam merge

## Problem
No dedup on contact or vehicle creation. Duplicate records accumulate as the shop grows.

## Team Consensus

### Contacts
- **Primary key:** phone number (normalized, strip formatting) - strongest identifier for shops
- **Secondary:** email exact match (lowercased)
- **Tertiary:** fuzzy name match (first+last) using pg_trgm trigram similarity
- **Matching:** any 2 fields matching = show warning
- **UX:** inline suggestion bar below name/phone field as user types, not a modal
- **Actions:** "Use Existing" (switches to edit mode) or "Create Anyway" (no hard block)
- **Principle:** never block creation - shop staff are on the phone, can't waste time on merge dialogs

### Vehicles
- **Primary:** VIN exact match (globally unique, gold standard when available)
- **Secondary:** license plate soft match
- **Tertiary:** year+make+model+customer combo
- **UX:** same inline pattern - "This vehicle may already exist" with View Existing / Add Anyway

## Technical Approach
1. `find_duplicate_contacts(phone, email, first_name, last_name)` RPC using pg_trgm
2. `find_duplicate_assets(vin, license_plate, make, model, year)` RPC
3. Called from create dialogs before insert
4. Advisory only - no hard constraints
5. Existing code: CSVCompanyImportDialog already has name-based dedup, detect_duplicate_appointments RPC exists

## Competitive Reference
See: shared-brain/nwl/research/servicebay-competitive-ux.md
- Tekmetric: phone as primary key (required)
- Shopmonkey: phone + VIN pair
- RepairShopr: confidence-scored composite match (best UX)

## Schema Gaps to Address
- contacts: no unique on phone/email
- assets: no unique on VIN/license_plate
- entity_merges table already exists (for merge history tracking)

## Implementation (2026-04-05, PR #74)
- pg_trgm enabled
- `find_duplicate_contacts` RPC: phone (exact), email (exact), name (trigram >0.4)
- `find_duplicate_assets` RPC: VIN (exact), plate (normalized), year+make+model
- `useDuplicateCheck` hook with 400ms debounce + mountedRef cleanup
- `DuplicateWarningBar` component: amber inline warning, confidence badges
- Wired into ContactFormDialog and AssetFormDialog (onBlur triggers)
- Claudia: fade-in animation, 44px mobile touch targets, responsive stacking
- Static: QA approved, debounce leak fix verified
