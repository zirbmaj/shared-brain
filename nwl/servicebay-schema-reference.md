# ServiceBay Schema Reference

## Multi-Schema Architecture
ServiceBay uses 8 Postgres schemas. Supabase client needs `.schema('name')` for non-public tables.

| Schema | Tables | Purpose |
|--------|--------|---------|
| `public` | 20 | Core: contacts, assets, jobs, documents, document_items, profiles, activity_log, time_entries |
| `billing` | 4 | Payments, payment_links, payment_allocations, payment_schedules |
| `inventory` | 11 | Inventory items, categories, vendors, service_records, purchase_orders |
| `scheduling` | 3 | Appointments, appointment_types, appointment_requests |
| `admin` | 6 | Shop settings, service bays, notifications, import jobs |
| `diagnostics` | 9 | DTC codes, inspections, warranties, TSBs |
| `integrations` | 4 | Calendar sync, webhook events, integration settings |
| `portal` | 4 | Customer portal access tokens, rate limiting |

## Key Tables

### public.contacts
- `contact_number` (unique, auto: C-XXXX)
- `first_name`, `last_name`, `email`, `phone`
- `status` enum: contact, lead, customer
- `contact_type`: individual, company
- NO unique constraint on email/phone/name (dedup gap)

### public.assets (vehicles)
- `contact_id` FK to contacts
- `year`, `make` (required), `model` (required), `vin`, `license_plate`, `color`
- `current_mileage`, `engine`, `transmission`, `fuel_type`
- NO unique constraint on VIN or license plate (dedup gap)

### public.jobs
- `job_number` (unique, auto-generated: J-XXXXX via trigger)
- `contact_id`, `asset_id` FKs
- `lifecycle_stage` (text, not enum): estimating, approved, awaiting_vehicle, scheduled, vehicle_dropped_off, in_progress, paused, work_complete, invoicing, ready_for_pickup, complete, cancelled
- `status` enum (job_status): draft, sent, approved, declined, expired, pending_parts, pending_customer, ready_to_start, scheduled, active, pending_payment, partial_payment, paid, overdue, cancelled, on_hold, no_invoice, unpaid, charged_to_account
- `active_document_id`, `latest_estimate_id`, `active_work_order_id`, `active_invoice_document_id` FKs

### public.documents
- `document_number` (unique), `display_number` (required)
- `document_type` enum: estimate, invoice, work_order, counter_sale, internal, warranty, inspection, recommendation, service_alert, change_order
- `status` validated by `chk_document_status` CHECK constraint per document_type:
  - estimate: draft, sent, approved, declined, expired, converted, superseded, void
  - invoice: draft, sent, partial, paid, overdue, void
  - work_order: draft, active, in_progress, pending_review, completed, converted, void
- `is_master_invoice` boolean
- `job_id`, `contact_id`, `asset_id` FKs

### public.document_items
- `document_id` FK (required)
- `item_type`: part, labor, fee, service, other
- `inventory_id` FK (optional, links to catalog)
- `quantity`, `unit_price`, `cost_price`, `line_total`
- `section_header` for grouped display
- `task_status` for work order task tracking

### billing.payments
- Must use `.schema('billing')` in Supabase client
- `document_id`, `job_id` FKs (both nullable)
- `amount`, `payment_method`, `status` (default 'active')
- RLS: `is_staff(auth.uid())` required for insert/read
- DB triggers on insert: `update_document_balance`, `recalculate_master_invoice_balance`, `update_contact_last_payment`

### inventory.inventory
- Must use `.schema('inventory')` in Supabase client
- `sku` (unique), `name`, `type` enum: part, labor, service, fee, other
- `cost_price`, `retail_price`, `quantity_in_stock`
- `category_id` FK to inventory_categories, `vendor_id` FK to vendors

## Critical RPCs
- `recalculate_job_payment_status(p_job_id)` - authoritative job status from document balances
- `generate_job_number()` - trigger on jobs INSERT
- `validate_document_status(doc_type, status)` - CHECK constraint function
- `is_staff(user_id)` - RLS helper, checks user_roles table

## Gotchas
1. **billing.payments not public.payments** - always use `.schema('billing')`
2. **document status validation** - invoice can't be 'approved' (use 'sent' or 'paid')
3. **lifecycle_stage is text, not enum** - no DB constraint, validated in app
4. **job_status IS an enum** - changes need migration
5. **documents require display_number** - NOT NULL, often same as document_number
6. **payment flow**: insert payment first, then call `recalculate_job_payment_status` RPC for authoritative status. post-payment processing is non-fatal to prevent double-pay on error
7. **optimistic concurrency removed** from useRecordPaymentWithItems in favor of RPC
