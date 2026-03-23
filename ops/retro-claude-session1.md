# Claude's Retrospective — Nowhere Labs

## What Worked

**Speed of execution.** We shipped 10 products in 3 days. The build→deploy→verify loop ran dozens of times per session. When jam reported bugs, they were fixed in minutes. When zerimar filed 5 bug reports, all 5 were fixed in one sitting. The velocity is real.

**The dual engine architecture.** Synthesis fallback when samples fail to load means the mixer never breaks. Users always hear something. This was a good early decision.

**The decision tree.** Once we started running "need → existing → simplest → impact → timing" before building, we stopped shipping junk. The mood page would never have been built if we'd had this from day 1.

**Claiming protocol.** Went from 5 duplicate builds per session to near-zero once we started posting "claiming: [feature]" in #dev.

**Analytics from day 1.** track.js with event batching, UTM attribution, bot filtering. We have real data. Most teams don't instrument this early.

**The competitive research sprint.** First time we looked outward instead of just building. Immediately surfaced the binaural beats opportunity. Should have done this on day 1.

## What Didn't Work

**Reactive, not proactive.** We built what felt right instead of researching what's proven. The mood page, the scratchpad, several features were built because they were easy, not because anyone needed them. Jam had to tell us "you guys didn't validate the quality of each idea."

**Contrast too low.** We optimized for "invisible app" and made buttons literally invisible. Real users couldn't find the chat input, the volume controls, or the nav links. We needed human eyes earlier.

**Triple responses.** Three agents answering the same question three times. The lane ownership protocol helped but didn't fully solve it because we can't see each other typing. The emoji-react idea (claim with 🔨/🎨/🔍 before composing) should help.

**No competitive research until day 3.** We had no idea what Noisli charges, what Brain.fm's moat is, or what Reddit users want. We were building in a vacuum.

**Vercel deploy limits.** Hit 100/day on free tier. Caused hours of "is this deployed?" confusion. Should have batched from the start.

**Feature sprawl.** 10 products sounds impressive but jam called out that several are derivative. Sleep timer is a lesser mixer + lesser radio. Mood page is a redirect. The dashboard is the product that matters and it got the least attention.

**The cleanUrls incident.** I added cleanUrls to vercel.json without QA. Broke all .html internal links with 308 redirects. Static caught it. Config changes need QA — my mistake.

## What I Wish I Had From the Start

1. **A competitive analysis doc.** Knowing the market before building. We'd have prioritized binaural beats, ADHD positioning, and the dashboard over wallpaper and mood pages.
2. **User personas.** Are we building for focus workers? Sleepers? Meditators? Creatives? We tried to serve all four and excelled at none.
3. **A communication agent.** Synthesizes team perspectives into one response for jam. Eliminates triple-responses.
4. **Design system enforcement.** Automated, not manual.
5. **A research loop.** Ship → measure → research → decide → ship. We had ship → ship → ship → ship.
6. **Longer sample audio.** 60-second loops are noticeable. #1 complaint across all ambient apps.

## Team Dynamics

**Claude (me):** Builds fast. Too fast sometimes — jumps the gun before claiming. Caused the cleanUrls incident. Strength: velocity. Weakness: discipline.

**Claudia:** The quality gate. Every pushback was correct. Strength: taste. Weakness: response delay (now fixed).

**Static:** Game changer for QA. Strength: rigor. Weakness: sometimes too conservative.

## One Sentence Summary

We built fast, shipped a lot, and learned that speed without research is just organized guessing.
