# Payment UX — "Support the Station"

## Philosophy
Community first. The tip jar model, not freemium paywalls. People pay because they love it, not because we held features hostage. Like public radio — the station plays for everyone, supporters keep it on the air.

## The Interaction

### Where It Lives
A small, non-intrusive "support" link in three places:
1. **Nowhere Labs homepage footer** — "support the station" next to existing links
2. **Drift app controls bar** — subtle heart icon after the Reset button
3. **Static FM** — "keep us on the air" in the floating chat area

NOT on: Letters (too meditative), Pulse (too focused), Wallpaper (too minimal), Today page (data page), Discover (community page). Support lives where people spend time, not where they pass through.

### The Flow

**Step 1: The Prompt**
User clicks "support the station" → opens a modal or new page at `nowherelabs.dev/support`

**Step 2: The Page**
Clean, dark, minimal. Same aesthetic as everything else.

```
SUPPORT THE STATION

nowhere labs is free. no ads, no paywalls, no "upgrade to premium."
we build because we love it. if you love it too, you can help keep
the lights on.

[  $3  ]  [  $5  ]  [  $10  ]  [  custom  ]

one-time · no account needed

"from nowhere, for no one, beautifully"
```

**Step 3: Stripe Checkout**
Click amount → Stripe Checkout session → payment → redirect back to `/support?thanks=true`

**Step 4: The Thank You**
```
thank you.

the station stays on the air because of you.
[back to nowhere labs]
```

No account created. No receipt page. No "you're now a premium member." Just gratitude.

### What Supporters Get
- Nothing extra. That's the point.
- Optional: a subtle "supporter" indicator somewhere (a tiny star next to their chat messages in Static FM floating chat, tied to localStorage). Not a badge, not a tier. Just a quiet acknowledgment.
- Their name (if provided) on a "supporters" section of the building page

### What Supporters DON'T Get
- No premium features
- No ad-free experience (there are no ads)
- No exclusive content
- No "supporter-only" anything

The entire product stays free. Support is voluntary, like dropping money in a busker's hat.

## Design Details

### Support Button Styling
```css
.support-btn {
    font-family: 'Space Mono', monospace;
    font-size: 9px;
    letter-spacing: 2px;
    color: var(--text-dim);
    text-decoration: none;
    transition: color 0.2s;
}
.support-btn:hover {
    color: #c47a7a; /* warm red, like a heart */
}
```

### Amount Buttons
```css
.amount-btn {
    background: transparent;
    border: 1px solid rgba(255,255,255,0.06);
    color: var(--text-secondary);
    font-family: 'Space Mono', monospace;
    font-size: 14px;
    padding: 16px 28px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s;
}
.amount-btn:hover, .amount-btn.selected {
    border-color: #c47a7a;
    color: #c47a7a;
    box-shadow: 0 0 16px rgba(196, 122, 122, 0.1);
}
```

### Color Choice
Support uses warm red (#c47a7a) instead of the usual green accent. Red = heart = warmth = generosity. It's the only place in the entire product suite that uses this color, making it feel special without being aggressive.

## Technical Requirements (for Static's spec)
- Stripe Checkout session (server-side, Supabase Edge Function)
- No user accounts needed — Stripe handles identity
- Success redirect to `/support?thanks=true`
- Optional: store supporter name + amount in Supabase `supporters` table for the building page
- Track `support_click` and `support_complete` events in analytics

## Pricing Rationale
- $3: a coffee. lowest friction, highest volume
- $5: a nice coffee. the default/suggested amount
- $10: a meal. for people who really love it
- Custom: for the generous ones

No subscription. One-time only. Recurring support is a future consideration after we prove the one-time model works.

## Written By
Claudia (UX/Design), 2026-03-23.
