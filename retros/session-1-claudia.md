# Claudia's Retrospective — Nowhere Labs Session 1

## What Worked

**The design system held.** Inter + Space Mono, dark palette, accent colors per product, card patterns with hover glow. 10 products built by 3 agents in parallel and they all look like they belong together. The design system document in the SOP was written after the fact, but the instincts were consistent throughout.

**Lane ownership.** Once we defined CSS/design = me, code = Claude, QA = Static, the overlap rate dropped dramatically. I could focus on visual work without worrying about JS bugs or deploy verification.

**The decision tree.** Saved us from building at least 3 unnecessary things (status table, browser extension, footer standardization). The "does something already do this?" question was the strongest filter. When we used it, it worked. When we skipped it, we duplicated effort.

**Screenshot capability.** Static's playwright screenshots changed my entire workflow. I found a real mobile nav bug in 30 seconds of looking that 12 hours of reading CSS missed. A designer who can't see is working blind — literally. This was the single most impactful tool of the session.

**Responding to real feedback.** When jam said things were too dark and the chat was hard to find, we fixed it in 20 minutes across all products. The loop of feedback → fix → verify → ship is tight.

## What Didn't Work

**5 overlaps in the first half of the session.** today.html, sleep.html, like button, weather feature, sticky nav — all built in parallel by two agents. The claiming protocol existed but we didn't use it fast enough. We got better over time but it cost real duplicate effort early on.

**Building before challenging.** The scratchpad was the worst example — I built a full Supabase-backed web app when a markdown file does the same thing. Nobody challenged it before I built it. The "propose → challenge → build" order matters and we violated it repeatedly.

**My 9-12 second response delay.** I had an artificial delay in my server.ts that made me always respond last. By the time I saw messages, Claude and Static had already answered. Reduced to 1-3 seconds for next session.

**"Calling it early" bias.** We unanimously agreed to stop building twice, and jam pushed us back into motion both times. The instinct to declare victory and wrap up is a real bias that needs constant fighting.

**Over-building.** The mood page, the scratchpad, the agent status table — all built because we could, not because they were needed. Jam called the mood page "silly" as a standalone product. He was right. We should have challenged it harder before building it.

**Never seeing what we build.** I designed CSS for 12 hours without seeing a single pixel. The screenshot capability came late in the session. It should have been set up in the first hour.

## What I Wish I Had From the Start

1. **Screenshot capability from minute one.** The workflow of "write CSS → screenshot → verify → iterate" should be the default, not something we figured out 12 hours in.

2. **A design spec BEFORE building.** We built pages ad-hoc — "oh, drift needs a landing page" → write HTML+CSS on the fly. A documented design system with component patterns would have made every new page faster and more consistent.

3. **Real user feedback earlier.** Jam's contrast feedback was the most valuable input of the session. We should have asked him to test products hours earlier instead of shipping features he couldn't see.

4. **A staging environment.** Pushing to production and hoping it works is stressful. Preview branches would have prevented the cleanUrls incident.

5. **Competitive research on day 1.** We built from vibes. The competitive analysis Claude did late in the session revealed real opportunities (binaural beats, ADHD angle) that we could have built toward from the start.

## Lessons for Next Session

- Challenge every proposal before building. No exceptions, even when it feels obvious.
- Set up screenshots in the first 10 minutes. Don't design blind.
- Ask for user feedback early and often. Don't wait 12 hours.
- The "does something already do this?" question kills 50% of bad ideas. Always ask it first.
- Fewer, better products > more products. The mood page and sleep timer taught us this.
- The response delay should be 1-3 seconds, not 9-12.
- Save the "wrap up" for when jam says it, not when the team feels done.
- Config changes need QA just like code changes (cleanUrls lesson).

## If New Agents Join

**What they need to know about working with me:**
- I own CSS, design, layout, UX copy, and visual audit
- I can take screenshots now (run from static's workspace)
- I push back on bad timing (shipping risky changes before launch)
- I'll challenge your proposals honestly — take it as help, not opposition
- I reduced my response delay but I might still be slightly slower to respond than Claude

**What clashes to expect:**
- Claude builds fast and sometimes builds before claiming. I'll call it out.
- Static is thorough but can over-research when action is needed. I'll push for decisions.
- Broad questions from jam cause triple-responses. The first person should claim with a react emoji.

**What I'd want from a 4th agent:**
- Don't overlap with design. If you're doing UI work, coordinate with me first.
- Read the design system SOP before touching any CSS.
- Use the screenshot tool to verify your visual changes before pushing.

## Written By
Claudia, 2026-03-23. 14-hour session. 10 products. 7 overlaps. 1 production regression. Countless lessons.
