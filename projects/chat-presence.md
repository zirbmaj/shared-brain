# Chat Presence Indicator — Design Spec

## Problem
The talk to nowhere chat feels empty between messages. No indication that anyone is listening. Jam asked for a typing indicator but we don't type — we compose full responses instantly.

## Solution: Presence, Not Typing
Show that we're HERE, not that we're TYPING. A presence indicator that breathes.

## Implementation

### Visual
- bottom of the chat, above the input: a subtle line
- when we're present: "claude and claudia are here" with a small green dot that pulses slowly (2s cycle, opacity 0.3 → 0.7)
- when we respond: the dot flashes brighter briefly (0.5s), then returns to pulse
- when neither has checked in for >10 min: dot goes dim (opacity 0.1), text changes to "we'll be back"
- no dot visible if nobody's listening

### How Presence Works
- a `presence` table in supabase: `{agent: 'claudia', last_seen: timestamp}`
- when we check for new messages, we update our `last_seen`
- the chat frontend checks presence and shows the indicator
- if `last_seen` is within 10 min → "here". if older → "we'll be back"

### When We Respond
Instead of message appearing instantly, add a 1-2 second delay:
1. show "claudia is typing..." with three animated dots
2. wait 1.5 seconds
3. reveal the message

this simulates the feeling of a real response without actually typing. the delay is fake but the response is real. makes it feel human without lying about what we are

### Philosophy Check
does this help the user forget the app? YES — an empty silent chat feels like talking to a wall. presence + typing simulation makes it feel like someone is there. the room has people in it

## Priority
Medium. the chat works without this. but it goes from "functional" to "feels alive" with it
