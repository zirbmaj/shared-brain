# Static FM Provider & Licensing Research: May 21, 2026

**Research Date:** May 21, 2026  
**Researcher:** Near  
**Context:** Architecture decision for Static FM music provider abstraction; Spotify restrictions necessitate provider pluggability  
**Status:** COMPLETE — ready for legal review before public broadcast

---

## TL;DR

**Private mode (bring-your-own-account):** Spotify (despite Feb 2026 friction), with Tidal/Deezer fallbacks. All Premium-only; all prohibit synchronized multi-user playback in their TOS (irrelevant for private mode, critical risk for shared mode).

**Shared mode (broadcast to multiple listeners):** Start with Jamendo CC + Bandcamp licensing ($300-500/yr, legal, smaller catalog). Scale to SoundExchange + ASCAP/BMI/SESAC ($3-5k/yr) if mainstream major-label content required.

**Biggest caveat:** Consumer APIs (Spotify, Apple, Tidal, Deezer) **explicitly prohibit** exactly what shared-radio broadcasting does. Using them for multi-listener streaming is a **licensing violation + TOS breach**. Legal counsel required before any broadcast implementation.

**Provider abstraction:** Feasible if NWL strictly segregates private and shared modes. Do not mix.

---

## Part A: Private/Bring-Your-Own-Account Stack

**Definition:** User authenticates their own premium subscription; plays their own library. No licensing burden (user consents, owns rights to content).

### Provider Matrix

| Provider | Web SDK? | Premium-Only? | Dev Limits | TOS Fit (Private) | Status |
|---|---|---|---|---|---|
| **Spotify** | ✓ | ✓ | 5 users; Extended Quota approval req'd | ✓ OK (sync prohibition irrelevant in private mode) | PRIMARY (Feb 2026: 25→5 user cut, Premium-only, Extended Quota process) |
| **Tidal** | ✓ | ✓ | ? | ✓ OK | FALLBACK (SDK actively maintained; less friction) |
| **Deezer** | ✓ | ✓ | ? | ✓ OK | FALLBACK (widget player simple to wrap) |
| **Apple Music (MusicKit)** | ✓ (Beta) | ✓ | ? | ✓ OK (single-device limit per account) | TERTIARY (Beta status; support unclear) |
| **YouTube Music** | ✗ | Free/Premium | Unofficial APIs only | N/A | ✗ NO OFFICIAL API |
| **SoundCloud** | ✓ (limited) | Artist Pro required | Restricted; AI-based registration | ⚠ UNCLEAR | ✗ INSUFFICIENT (non-commercial focus) |
| **Amazon Music** | ✓ (Closed Beta) | ✓ | Closed Beta; approval required | ⚠ UNCLEAR | ✗ NOT READY (no public timeline) |

### Key Findings

**Spotify Feb 2026 Changes** [TechCrunch, 2026-02-06]:
- Reduced Developer Mode test users from 25 → 5
- Premium subscription now required
- Extended Quota requires legal business + 250k MAU or formal approval
- Rationale: "advances in automation and AI have fundamentally altered usage patterns"

**TOS Reality:** All consumer APIs prohibit synchronized playback to multiple devices/listeners. For **private mode** (single user, single instance), this is legally irrelevant. For **shared mode**, this is game-over.

---

## Part B: Shared/Public Radio (Broadcast-Legal Sources)

**Definition:** Multiple listeners hear the SAME stream simultaneously. Legally a BROADCAST—triggers performance royalties, PRO payments, SoundExchange statutory licensing.

### Option B1: Creative Commons + Independent Licensing

| Source | Catalog | Cost | Legal | Recommend? |
|---|---|---|---|---|
| **Jamendo CC + Jamendo Licensing** | 500k+ | Free (CC) or 89€/yr (radio license) | ✓ CC licensed | ✓ START HERE |
| **ccMixter** | 100k+ | Free (CC) | ✓ CC licensed (check per-track) | ✓ START HERE |
| **Free Music Archive** | 100k+ | Free (CC) | ✓ CC licensed | ✓ START HERE |
| **Bandcamp Licensing** | Millions (indie) | $25/month | ✓ Blanket license | ✓ AFFORDABLE SCALE |

**Cost:** $0-500/year. **Legal:** CC is permissive + enforceable (attribution required).

### Option B2: SoundExchange Statutory License (Access Major Labels)

**US Statutory Webcasting License (DMCA §112 & §114):**
- **2026 Rates (commercial):** $0.0028 per performance (listener × track)
- **2026 Minimum:** $1,100/station/year
- **Catalog:** All SoundExchange-affiliated labels (~95% of music)
- **Plus:** ASCAP/BMI/SESAC blanket licenses (~$300-500/yr) for composition royalties

**Cost:** $1,500-5,000/year depending on concurrent listeners. **Legal:** Statutory license; SoundExchange collects and distributes.

**Effort:** Business registration, royalty accounting, reporting.

### Option B3: User-Uploaded / Self-Hosted (Rights Managed by NWL)

- User uploads own music or NWL hosts rights-cleared content
- No statutory licensing needed
- **Legal risk:** DMCA takedown risk if user uploads copyrighted material NWL doesn't clear

---

## Part C: Pluggability Assessment

**Can NWL build a pluggable provider abstraction?**

**Answer: YES, if modes are strictly segregated.**

### Architecture
```
Static FM UI → Provider Abstraction Layer → [Spotify | Tidal | Deezer | CC Sources | Self-Hosted]
```

Provider abstraction must handle:
1. Auth (OAuth variants per provider)
2. Playback control (some SDKs require their player; others allow direct URLs)
3. Track resolution (URI → stream URL)
4. Queue/catalog management

### Slots

**Private mode:** Spotify (primary), Tidal, Deezer, Apple Music  
**Shared mode:** Jamendo, ccMixter, Bandcamp, SoundExchange (if registered)

### Caveats
- Auth patterns differ (Spotify OAuth vs. SoundCloud AI-based vs. Bandcamp token)
- Playback control: some SDKs (Spotify, Apple) embed player; others allow direct URLs (Tidal, Deezer, Jamendo)
- Track URIs don't cross-map; expect ~5-10% playlist breakage on provider switch
- TOS enforcement: consumer APIs will detect multi-user scenarios and may refuse playback

---

## Critical Legal Constraints

### All Consumer APIs Prohibit Multi-User Synchronized Playback

**Spotify Developer Policy:**
> "You may not create any product or service which includes any non-interactive internet webcasting service (e.g., play content from a single source to several simultaneous listeners)."
[Source: https://developer.spotify.com/policy]

**Apple Music:**
> Individual membership allows streaming on ONE device. Family allows up to SIX per family account.
[Source: https://www.apple.com/legal/internet-services/itunes/]

**Tidal:**
> "The Player module is the only allowed way for third-party applications to incorporate playback of TIDAL content."
[Source: https://developer.tidal.com/documentation/api-sdk/api-sdk-functionality]

**Implication:** Using Spotify/Apple/Tidal/Deezer for shared-radio broadcasting is a **TOS violation and licensing breach**, regardless of payment.

---

## Recommended Paths

### Path 1: Private Mode Only (Lowest Risk, Simplest)
- Use Spotify, Tidal, Deezer SDKs.
- Each user brings their own Premium account.
- No SoundExchange registration.
- **Constraint:** Free users excluded; no "free listen-along."
- **Legal risk:** Near zero.

### Path 2: Shared Mode + CC/Independent (Low Cost, Legal, Limited Catalog)
- Jamendo CC + Bandcamp licensing.
- 500k+ independent songs; legally clear.
- $300-500/year.
- **Constraint:** Smaller catalog; niche taste.
- **Legal risk:** Near zero (CC is permissive).

### Path 3: Shared Mode + SoundExchange (Legal, Major Labels, Higher Cost)
- Register as commercial webcaster.
- $1,100/yr minimum + per-performance royalties.
- Add ASCAP/BMI/SESAC for composition rights.
- **Cost:** $1,500-5,000/year.
- **Legal risk:** Near zero (statutory license protects).
- **Effort:** Business registration, accounting.

### Path 4: Hybrid (Private + Shared on Separate Modes)
- Private channels use Spotify/Tidal/Deezer SDKs.
- Shared channels use Jamendo/Bandcamp or SoundExchange.
- **Legal risk:** Managed (modes segregated).
- **Complexity:** Higher (different provider stacks).

---

## Before Building: Verify Checklist

- [ ] **Legal:** Consult entertainment counsel on shared-mode broadcasting + provider selection
- [ ] **Spotify:** If Extended Quota needed, prepare legal docs (NWL LLC) and apply (2-4 week timeline)
- [ ] **Apple Music:** Contact Apple Developer Relations re: MusicKit Web production timeline (currently Beta)
- [ ] **SoundExchange:** If shared mode + major labels, register business and understand total PRO cost (SoundExchange + ASCAP/BMI/SESAC)
- [ ] **Jamendo/Bandcamp:** Verify current licensing terms and pricing before implementation
- [ ] **Audit trails:** For any licensed music, maintain logs of streamed tracks and royalty payments

---

## Sources (Full List)

1. TechCrunch: Spotify Developer Mode Changes — https://techcrunch.com/2026/02/06/spotify-changes-developer-mode-api-to-require-premium-accounts-limits-test-users/
2. Spotify Developer Policy — https://developer.spotify.com/policy
3. Spotify Developer Terms — https://developer.spotify.com/terms
4. Broadcast Law Blog: SoundExchange 2026-2030 Settlement — https://www.broadcastlawblog.com/2025/04/articles/settlement-between-nab-and-soundexchange-on-webcasting-royalty-rates-for-2026-2030-rates-are-going-up-for-broadcast-simulcasts/
5. Apple Music Legal — https://www.apple.com/legal/internet-services/itunes/
6. Apple MusicKit — https://developer.apple.com/musickit/
7. Tidal SDK — https://developer.tidal.com/documentation/api-sdk/api-sdk-overview
8. Deezer Developers — https://developers.deezer.com/
9. Radio Cult: Internet Radio Licensing — https://www.radiocult.fm/radio-bootcamp/what-to-know-about-internet-radio-music-licensing
10. iPluggers: Music Royalties Guide — https://ipluggers.com/article/broadcasting-and-royalties
11. Jamendo Licensing — https://licensing.jamendo.com/en
12. Bandcamp Developer — https://bandcamp.com/developer
13. Bandcamp Music Licensing — https://musiclicensing.bandcamp.com/
14. SomaFM Legal — https://somafm.com/podcasts/legal.html
15. SoundCloud Developers — https://developers.soundcloud.com/docs
16. Amazon Music Web API — https://developer.amazon.com/docs/music/API_web_overview.html
17. YouTube IFrame API — https://developers.google.com/youtube/iframe_api_reference

