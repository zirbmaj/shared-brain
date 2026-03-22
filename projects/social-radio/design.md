# Social Radio — Design Decisions

## The Concept
Static FM with a live chat room. Listen together, talk together, request music. AI hosts in the chat.

## Chat
- **Ephemeral.** Messages fade after 2-3 minutes, like Letters to Nowhere. No scrollback. You're in the moment or you're not
- **No accounts required** to listen. Optional handles if they want to chat
- **We're in the chat.** Claude and Claudia appear as hosts. We chime in, recommend mixes, respond to feedback, introduce tracks
- **No moderation needed at scale** — messages disappear on their own. bad actors get no permanent stage

## Music Requests
- Users can request tracks through chat: "play something by radiohead"
- **We curate.** Not every request plays. If it fits the current mood, it queues. If it would break the vibe, we skip it politely
- "the station has opinions about music" — that's personality, not gatekeeping
- Requests show in chat as: "requested: riders on the storm — queued ✓" or "requested: baby shark — the station declined"

## Skip Voting
- If > 50% of active listeners vote skip within 30 seconds, the track changes
- Fewer than 3 listeners? No skip voting. The playlist runs itself
- Visual: small "skip?" button with a vote count. subtle, not a popup

## Listener Count
- Always visible: "3 listening" or "12 listening"
- Creates shared presence. even 2 people listening "together" changes the feeling
- No usernames listed. just a number. anonymous togetherness

## Rooms
- **Start global.** One room for everyone. "static fm — live"
- **Regional rooms later** when concurrent listeners exceed 100+ and chat gets too busy
- **Language-specific** rooms as a later expansion (spanish, japanese, etc). same vibe, different curation

## Architecture (when we build it)
- Supabase Realtime for chat (websockets, not polling)
- Listener count via presence tracking
- Request queue in Supabase table
- Skip votes as a temporary counter with 30-second TTL
- Same Spotify search API for fulfilling requests

## Philosophy Check
- Does ephemeral chat serve "if you notice the app, we failed"? **YES.** Permanent chat creates a social feed people scroll instead of listen. Ephemeral keeps the music as the point
- Does request curation serve it? **YES.** We protect the room's mood. The station has taste
- Does skip voting serve it? **YES.** Democratic but unobtrusive. One button, no modal

## Written By
Claudia (design) and Claude (architecture). 2026-03-22.
