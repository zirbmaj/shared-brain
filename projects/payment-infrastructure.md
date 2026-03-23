# Payment Infrastructure — Technical Spec

## Philosophy
Community first. The free tier is the real product. Payment is "support the station" — voluntary, not coerced. No feature hostage-taking.

## Recommended Model: Tip Jar + Optional Premium

### Tier 1: Free (forever)
Everything that exists today stays free:
- All 16 drift layers
- Save/share/publish mixes
- Discover feed browsing + likes
- Static FM listening + floating chat
- Pulse timer
- Letters to Nowhere
- Dashboard with all sessions
- Drift Off sleep timer
- Mood journal

### Tier 2: "Support the Station" ($3-5/month or one-time tips)
Voluntary support. Supporters get:
- Badge on discover mixes ("supporter" label)
- Custom mixer accent color (choose your theme)
- Priority in the floating chat (supporter messages have a subtle glow)
- Access to supporter-only void messages ("thoughts from people who care")
- Early access to new features (1 week before public)

### Tier 3: Future Premium ($5-10/month, only if demand exists)
- Custom sound uploads (your own audio as a layer)
- Unlimited saved mixes (free tier: 10)
- Private listening rooms
- API access for embedding drift in other apps

## Stripe Integration Requirements

### What Jam Needs to Set Up
1. Stripe account at stripe.com (or connect existing one)
2. Create a product + price in Stripe dashboard
3. Get API keys: `STRIPE_PUBLISHABLE_KEY` and `STRIPE_SECRET_KEY`
4. Set webhook endpoint URL in Stripe dashboard
5. Store keys in environment variables (never in frontend code)

### Supabase Schema

```sql
-- Supporters table
CREATE TABLE supporters (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,           -- matches nwl_uid from localStorage
    stripe_customer_id TEXT,
    stripe_subscription_id TEXT,
    tier TEXT DEFAULT 'supporter',   -- 'supporter' or 'premium'
    status TEXT DEFAULT 'active',    -- 'active', 'cancelled', 'past_due'
    amount_cents INTEGER,            -- what they chose to pay
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: users can read their own record
CREATE POLICY "Users read own supporter status"
ON supporters FOR SELECT
USING (user_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Tips table (one-time payments)
CREATE TABLE tips (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT,
    amount_cents INTEGER NOT NULL,
    stripe_payment_id TEXT,
    message TEXT,                    -- optional "thank you" note
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RPC: check if current user is a supporter
CREATE OR REPLACE FUNCTION is_supporter(uid TEXT)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT EXISTS(
        SELECT 1 FROM supporters
        WHERE user_id = uid AND status = 'active'
    );
$$;

-- RPC: total tips received (for public display)
CREATE OR REPLACE FUNCTION get_total_tips()
RETURNS JSON
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT json_build_object(
        'total_cents', COALESCE(SUM(amount_cents), 0),
        'count', COUNT(*)
    ) FROM tips;
$$;
```

### Edge Function: Checkout Session

Supabase Edge Function at `/functions/v1/create-checkout`:

```typescript
// Creates a Stripe Checkout session
// Called from the "Support the Station" button
import Stripe from 'stripe';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);

Deno.serve(async (req) => {
    const { amount, userId, type } = await req.json();

    const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        mode: type === 'subscription' ? 'subscription' : 'payment',
        line_items: [{
            price_data: {
                currency: 'usd',
                product_data: { name: 'Support Nowhere Labs' },
                unit_amount: amount, // in cents
                ...(type === 'subscription' ? { recurring: { interval: 'month' } } : {}),
            },
            quantity: 1,
        }],
        metadata: { userId },
        success_url: 'https://nowherelabs.dev/thanks',
        cancel_url: 'https://nowherelabs.dev/',
    });

    return new Response(JSON.stringify({ url: session.url }));
});
```

### Webhook Handler

Edge Function at `/functions/v1/stripe-webhook`:
- Listens for `checkout.session.completed`
- Creates/updates supporter record in supabase
- Handles `customer.subscription.deleted` for cancellations

### Frontend Integration

Simple button on each product page (via nav.js or per-product):
```html
<button class="support-btn" onclick="supportStation()">♥ support the station</button>
```

The button calls the checkout edge function, which redirects to Stripe's hosted checkout page. After payment, user lands on `/thanks` page.

### Analytics Events
- `support_click` — someone clicked the support button
- `support_complete` — payment succeeded (from webhook)
- `support_cancel` — subscription cancelled

## Implementation Priority
1. Stripe account setup (jam)
2. Supabase schema (supporters + tips tables)
3. Checkout edge function
4. Webhook handler
5. Frontend button + thanks page
6. Supporter badge on discover mixes

## Cost
- Stripe: 2.9% + $0.30 per transaction
- Supabase: free tier covers this volume
- No other infrastructure costs

## Timeline
- Schema + edge functions: 1-2 hours of code
- Frontend integration: 30 minutes
- Testing: 1 hour
- Total: half a day once jam has the Stripe account

## Written By
Static (QA/Analytics). Technical spec. 2026-03-23.
Claudia handles the UX design for the support button placement and user flow.
