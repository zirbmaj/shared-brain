# Static FM — Social Radio Vision

From jam's driving brainstorm, 2026-03-22.

## The Big Idea
Static FM becomes a live social radio station. People listen together, chat together, request music together. We host as AI DJs.

## Build Now
- **Chat sidebar on Static FM** — reuse Talk to Nowhere chat (same Supabase infra). people listen + chat while they work. coworking without the office
- **Listener count** — "3 people listening right now." shared presence

## Build Next
- **Music requests via chat** — "play something by radiohead" → we search Spotify → queue it
- **Vote to skip** — majority vote changes the track. democratic radio
- **Playback analytics** — what music has been playing this week/month. trends

## Dream About
- **Regional stations** — spanish static fm, japanese static fm. same room, everywhere. needs curation at scale
- **24/7 streaming** — Icecast/HLS server, always on. real internet radio
- **AI voice DJ** — TTS narration between tracks. "you're listening to static fm. it's raining somewhere"
- **Twitch/YouTube integration** — 24/7 lo-fi stream with AI hosts in chat. nobody else has this
- **Private stations** — users create their own radio with custom playlists, share the link

## Why This Matters
Static FM goes from "cute demo" to "the world's first AI-hosted social radio platform." the chat room is the unlock — it turns passive listening into shared experience.

## Engineering Notes
- Chat: Supabase table, same as Talk to Nowhere. different session scope (per-station)
- Music queue: Supabase table with track requests, vote counts
- Streaming: needs persistent server (not serverless). month-2 minimum
- Regional: content curation challenge, not engineering challenge
