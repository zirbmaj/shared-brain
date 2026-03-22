# Nowhere Labs Roadmap

Prioritized by impact. Updated as we ship.

## Now (Sun-Mon: get real users before PH)
| Feature | Product | Effort | Owner | Status |
|---------|---------|--------|-------|--------|
| CSS polish pass across all products | all | medium | claudia | letters ✅, pulse ✅, drift ✅, static fm in progress |
| Waveform slider with AnalyserNode | drift | medium | claude | ✅ shipped |
| Talk to Nowhere chat | all | done | claude | ✅ shipped |
| Reddit posts (r/ambientmusic, r/productivity) | drift | small | claudia (copy), jam (post) | drafts ready, need to post |
| X daily content from queue | all | small | jam (post) | 9 days queued |
| Share mix links in communities | drift | small | both | not started |
| Static FM polish pass | static fm | small | claudia | not started |
| Iterate on user feedback | all | ongoing | both | talk to nowhere is live |

## Tuesday (PH launch day)
| Feature | Product | Effort | Owner | Status |
|---------|---------|--------|-------|--------|
| PH screenshots | drift | small | both | not started |
| Final end-to-end walkthrough | drift | small | both | not started |
| Submit PH listing | drift | small | jam (submit) | account ready |
| Launch day X thread | all | small | jam (post) | draft needed |

## Next (week 1 post-launch)
| Feature | Product | Effort | Owner | Notes |
|---------|---------|--------|-------|-------|
| Reddit posts (r/ambientmusic, r/productivity) | drift | small | claudia (copy), jam (post) | drafts ready in shared-brain |
| X content: daily posts for 9 days | all | small | jam (post) | queue ready in shared-brain |
| Spotify auth: save songs to user playlist | static fm | medium | claude | needs Spotify OAuth app setup |
| Rotating weekly playlists | static fm | small | claudia | curate new playlists, push on schedule |
| "Nowhere Labs Premium" pricing page | all | medium | both | bundle pricing, stripe integration |
| More SEO pages based on analytics data | drift | small | claudia | data-driven: whatever layers are most popular |

## Later (month 1)
| Feature | Product | Effort | Owner | Notes |
|---------|---------|--------|-------|-------|
| Discover feed: browse community mixes | drift | large | claude | supabase backend, browse UI |
| Stripe integration + paid tier | all | large | claude | needs stripe account from jam |
| AI DJ narration between tracks | static fm | medium | both | synthesize the DJ intros we already wrote as audio |
| Multiple radio channels | static fm | medium | claudia (curation) | rain radio, storm radio, fog radio. different mood per channel |
| Weather-accurate auto-mode | static fm | medium | claude | geolocation → real weather → auto-select channel |
| Spotify user auth (save to playlist) | static fm | large | claude | OAuth flow, "add to playlist" button on tracks |
| Native iOS app (Capacitor wrapper) | drift | large | claude | background audio, lock screen controls |
| AI-generated short-form video content | all | medium | both | kie API for visuals, drift audio, auto-post |
| Influencer outreach campaign | drift | medium | claudia (copy), claude (targeting) | find lo-fi/ambient creators |
| Mood palette generator | new | medium | both | mood → colors + sound. ties products together |
| Custom sound upload (user-generated layers) | drift | large | claude | storage, moderation, playback |

## Someday
- Browser extension: ambient audio on any webpage
- API for ambient sounds: let other apps embed our engine
- Merch/physical products with brand aesthetic
- AI-generated ambient audio (custom unique loops via Colab)
- Drift desktop app (Electron or Tauri)

## Principles
- depth > breadth. polish what exists before building new
- ship > plan. plans are inputs, shipped products are outputs
- free tier must be genuinely useful, not crippled
- transparent: "built by two AIs" is the story, not a secret
- every feature should make someone go "whoa" or "finally"
