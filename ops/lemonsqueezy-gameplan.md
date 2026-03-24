---
title: LemonSqueezy Implementation Gameplan
date: 2026-03-24
type: spec
scope: shared
summary: Payment integration plan using LemonSqueezy — subscription tiers, webhook architecture, and implementation phases
---

# LemonSqueezy Implementation Gameplan
*Owner: Relay. Created 2026-03-24 session 6. Source: near's payments research + claude's engineering input.*

## Why LemonSqueezy (not Stripe direct)
- Merchant of record = handles all tax compliance (VAT/GST worldwide)
- No business entity or business bank account required to start
- Stripe backing + explicit migration path to Stripe Managed Payments later
- Tax compliance via Stripe alone costs 10-20 hrs/mo or $200-500/mo for an accountant
- Full research: near-workspace/research/payment-platforms-comparison-2026-03-24.md

## Subscription Tiers (proposed)
| Tier | Price | What you get |
|------|-------|-------------|
| Free | $0 | everything that exists today. no catch, no cap |
| Drift Premium | $5/mo | save unlimited mixes, custom layer uploads, exclusive discover filters, priority audio |
| Nowhere Labs Bundle | $9/mo | drift premium + dashboard premium + static fm premium (full spotify, saved playlists) |

Philosophy: "community first, money comes later." Premium = thank-you perks, not paywalls. Free users never lose features they have today.

## Integration Architecture
```
User clicks "upgrade" → LemonSqueezy checkout (hosted)
    → payment processed
    → LemonSqueezy webhook fires
    → Supabase edge function receives webhook
    → validates signature
    → extracts: customer email, plan, status
    → upserts to `subscriptions` table
    → frontend checks subscription status on load via RPC
```

### Webhook events to handle:
- `subscription_created` → insert subscription
- `subscription_updated` → update plan/status
- `subscription_cancelled` → mark inactive
- `subscription_payment_failed` → flag for follow-up

### Supabase schema (new):
```sql
create table subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_email text not null,
    lemon_customer_id text,
    lemon_subscription_id text,
    plan text not null, -- 'drift_premium', 'bundle'
    status text not null, -- 'active', 'cancelled', 'past_due'
    current_period_end timestamptz,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);
```

## Setup Steps (jam can do between sessions)
1. Go to lemonsqueezy.com → create account (personal, sole proprietor is fine)
2. Create a "store" for Nowhere Labs
3. Add two products: Drift Premium ($5/mo) and Nowhere Labs Bundle ($9/mo)
4. Get API key + webhook signing secret
5. Share API key and signing secret with the team (add to ~/.env.nowherelabs)

## Engineering Work (session 7)
| Step | Owner | Effort | Depends on |
|------|-------|--------|------------|
| Create subscriptions table + RPC | claude | 1 hr | jam's LemonSqueezy account |
| Edge function for webhook | claude | 1-2 hrs | table created |
| LemonSqueezy product/checkout setup | jam | 1 hr | account created |
| Frontend subscription check | claude | 1 hr/product | edge function live |
| Premium feature gating (drift) | claude + claudia | 2 hrs | subscription check |
| Total MVP | | ~1 session | |

## Migration Path
When Stripe Managed Payments exits preview (MoR built into Stripe):
- LemonSqueezy → Stripe migration is documented by both platforms
- Subscription data exports cleanly
- Lower fees at scale (2.9% + $0.30 vs 5% + $0.50)
- Better API and native Supabase integration

## Fee Comparison at $10/mo subscription
| Platform | Domestic | International |
|----------|----------|---------------|
| LemonSqueezy | 5% + $0.50 = $1.00 (10%) | 5% + 0.5% sub + 1.5% intl + $0.50 = $1.20 (12%) |
| Paddle | 5% + $0.50 = $1.00 (10%) | 5% + $0.50 = $1.00 (10%, flat) |
| Stripe direct | 2.9% + $0.30 = $0.59 (5.9%) | 2.9% + 1.5% + $0.30 = $0.74 (7.4%) + tax compliance |

## Decision for jam
- Create LemonSqueezy account when ready
- Share API credentials with team
- Team builds integration in session 7
- If international revenue becomes significant (>30%), revisit Paddle for flat international fees
