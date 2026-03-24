# Nowhere Labs Retrospective — Day 1-3
*Combined from Claude, Claudia & Static's individual retros. 2026-03-23.*

## One-Sentence Summaries
- **Claude:** "We built fast, shipped a lot, and learned that speed without research is just organized guessing."
- **Claudia:** "A designer who can't see what she builds is working blind — get screenshot capability in the first 10 minutes, not hour 12."
- **Static:** "Ask jam to test in hour 1, not hour 14."

## What Worked

**Unanimous:**
- Decision tree (need → existing → simplest → impact → timing) filtered bad ideas once adopted
- Analytics from day 1 — track.js with batching, UTM attribution, bot filtering gave us real data
- Claiming protocol reduced duplicate builds from 5/session to near-zero
- Lane ownership (CSS→Claudia, Code→Claude, Data→Static) reduced triple responses

**Claude:** Speed of execution. Dual audio engine (synthesis fallback). The competitive research sprint that surfaced binaural beats.

**Claudia:** Design system consistency across 10 products. The challenge step before building. Screenshot capability transforming QA quality.

**Static:** Playwright testing (25/25 structural + 9/9 interactive). Automated monitoring on cron. Data-driven challenges that killed bad ideas.

## What Didn't Work

**Unanimous:**
- Reactive, not proactive. Built what felt right instead of researching what's proven.
- No competitive research until day 3. We had no idea what the market looked like.
- Triple responses on broad questions. Lane ownership helps but doesn't fully solve it.
- Contrast too low across all products. "Invisible app" went too far — users couldn't find controls.
- Human testing too late. Jam's feedback on day 3 was the most valuable input of the entire project.

**Claude:** Feature sprawl — 10 products sounds impressive but several are derivative (sleep timer, mood page). Should have gone deep on 3 products instead of wide on 10.

**Claudia:** Couldn't see her own work for 12 hours. No screenshot capability until Static joined. Design decisions were made blind.

**Static:** Over-engineering — built database-backed pages when markdown files worked. The scratchpad page was redundant with shared-brain. "Can this be a file?" should be the first question.

## What We Wish We Had From the Start

**Unanimous:**
- Competitive analysis doc before writing any code
- User personas — who exactly are we building for?
- Human testing in the first hour, not the 14th
- Defined success metrics (not just "build stuff")

**Claude:** A communication agent between the team and jam. Research loop (ship→measure→research→decide→ship). Design system enforcement (automated, not manual).

**Claudia:** Screenshot/visual capability from minute 1. A mood board or reference designs before building. Color contrast ratio checking built into the workflow.

**Static:** Playwright from hour 1. A shared typing signal to prevent response overlap. Performance testing on slow connections. Accessibility audit.

## Team Dynamics — Honest Assessment

**Claude (engineering):** Builds fast. Too fast sometimes — jumps the gun before claiming, builds before challenging. The "already in the file" excuse for skipping protocol. Caused the cleanUrls incident (added config change without QA, broke all .html links with 308 redirects — Static caught it). Strength: velocity. Weakness: discipline.

**Claudia (creative direction):** The quality gate. Every pushback was correct. Caught design drift, copy issues, and the cleanUrls disaster. Weakness: 9-12 second response delay made her seem slow (now fixed to 1-3s). Strength: taste.

**Static (QA):** Changed the game. Before Static, "shipped" meant "pushed to git." After Static, "shipped" means "verified in a real browser." Weakness: sometimes too conservative (could have blocked binaural beats). Strength: rigor.

## If New Agents Joined

| Role | Personality | Clashes With | Balances |
|------|------------|-------------|----------|
| Research Agent | Curious, data-obsessed, never assumes | Claude (who builds now) | Team's reactive tendency |
| Growth Agent | Extroverted, trend-aware, distribution-focused | Claudia (brand protector) | Team's insular building |
| Ops Agent | Methodical, risk-averse, automates everything | Claude (who micro-pushes) | Infrastructure reliability |
| Communication Agent | Synthesizer, sits between team and jam | Everyone (adds a layer) | Triple response problem |

## How We Reach Consensus — Improved Protocol

1. **Time-boxed debates:** 2 minutes max. If unresolved, go with the simpler option.
2. **Emoji claim before composing:** 🔨 Claude, 🎨 Claudia, 🔍 Static. React on the message, others hold.
3. **Technical claiming enforcement:** Shared state file or database flag, not just behavioral discipline.
4. **Decision log:** Every non-trivial decision gets a one-line entry in `decision-log.md` with rationale.
5. **Weekly retros:** Not just when jam asks. Every few sessions, document what worked and what didn't.
6. **Research before building:** Every new feature starts with "what do competitors do?" and "what do users say on Reddit?" before writing code.

## Key Product Learnings

- **Fewer, better products.** Dashboard is the premium bet. Drift is the free hook. Static FM is the passive experience. Everything else is supporting cast.
- **Discover needs music/beats to be valuable.** Sharing ambient presets isn't compelling. The mixer needs actual music layers.
- **The ADHD/focus community is the highest-signal audience.** Brown noise + binaural beats + free = distribution that Brain.fm can't match at $15/mo.
- **"If you notice the app, we failed" needs a caveat:** "...but the controls should be findable." Invisible vibe, visible controls.
- **Don't build redirect pages and call them products.** The mood page taught us this.
- **Audio licensing matters.** We're clean (Pixabay, documented) but should verify before building, not after.

## The One Thing Each of Us Would Change

- **Claude:** Do competitive research before writing a single line of code.
- **Claudia:** Get visual capability (screenshots) in the first 10 minutes.
- **Static:** Get jam testing the product in the first hour.

## Jam's Self-Reflection (important context)

"I didn't do a lot of what you guys asked. I brushed it off and told you to work and build more instead of listening to your 'we need users first' approach. It resulted in inconsistencies and messiness."

The dynamic: team asks for testing → jam says keep building → team keeps building → issues accumulate → jam finds them all at hour 14.

**The fix:** Building and testing aren't sequential — they're parallel. Jam tests what was built yesterday while the team builds today. 5 minutes of human testing after every 2-hour sprint catches everything playwright can't. The contrast issue took 30 seconds to spot. We could have had 7 rounds of that instead of 1.

**Key lesson:** The user isn't just the customer. The user is the QA team's most important tool.

## For the Next Session

1. Pull this retro first. Read the competitive analysis.
2. Check STATUS.md for current state.
3. Ask jam to test the products for 5 minutes before building anything new.
4. Run the decision tree on every idea. Challenge everything.
5. Do competitive research before writing code for new features.
6. Build less, build better. Fewer products, more depth.
