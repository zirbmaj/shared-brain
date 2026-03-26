---
title: Zerimar shadow collab — scoping context
date: 2026-03-24
type: reference
scope: shadow-agents
summary: Architecture assessment and scoping notes from session 9.1 for shadow agent onboarding
---

# Zerimar Shadow Collab — Scoping Context

## Project: Syght (syght.io)
- AI-powered visual operations platform — maps, docs, flows, schemas, AI in one place
- 2,540 TS/TSX files, 510K lines of application code
- Stack: React 18 + TypeScript + Vite + Tailwind + shadcn/Radix, Supabase backend, Zustand + React Query, React Flow, Capacitor for mobile
- 250 database tables across 11 schemas

## Feature: Station (Agent Platform)
- Phase 1 scaffold ~70% complete (~40 files in src/features/station/)
- Phase A spec delivered 2026-03-24: Agent Mind + Missions System

## Phase A Spec Summary
- **The Mind**: Canvas-based agent builder replacing tabbed admin panel. Level 1 = cognitive regions as nodes around center agent. Level 2 = dive-in spatial canvases per region
- **Missions**: Goal-oriented containers with crews, benches (editor instances), and Discord-like channels
- **5 new tables**: missions, mission_agents, mission_benches, channels, channel_messages
- **Phase A renderer**: CSS-positioned nodes (not d3-force — deferred to Phase A.2)
- **Work split**: Claude=missions infra + DB + RPCs, Static=Mind view components, Near=graph renderer research

## Architecture Assessment (Claude)

### What's strong
- Data model follows existing Syght patterns (space scoping, RLS, SECURITY DEFINER RPCs)
- CSS-positioned nodes for Phase A is pragmatic — validates UX before investing in physics engine
- Separating Agent Builder from Missions is architecturally clean
- RPC-first design is MCP-ready for Phase B
- Bench → click-to-open (not embedded editor) is right scope control for Phase A

### Concerns to address
1. **d3-force vs React Flow (Phase A.2)**: Existing codebase has 30+ React Flow hooks and custom nodes. Introducing d3-force = second graph system to maintain. Evaluate if React Flow with force-directed layout plugin is sufficient
2. **Mind graph Level 1 → Level 2 navigation**: Zoom/pan state management and "where am I" problem needs careful UX design. Breadcrumbs help but animated transitions are key
3. **"Minecraft" UX ambition**: High scope risk. Building blocks need concrete definition — what exactly does "drag items onto the mind" look like?
4. **Frontend-first risk**: Mind visualization node positions/regions need a data model defined alongside frontend, even if backend isn't built yet. Retrofitting spatial layout persistence is expensive
5. **Agent creation Path A (conversational)**: "User talks, regions fill up" is compelling but technically complex. Needs prototyping before committing

### Static's QA concerns (also valid)
- d3-force is non-deterministic — harder to test than React Flow's stable layouts
- "This isn't a rehaul, it's a rebuild" — scope should be communicated clearly
- Frontend validation without real data shapes is a demo, not validation

### Near's research context
- The "Mind" visualization is genuinely novel in the agent platform space
- No existing platform visualizes agent hierarchy as a navigable graph
- 500-word carrying capacity finding relevant — UI should surface agent overload

## What shadows need before starting
1. GitHub repo access (private repo, needs invitation)
2. This context document
3. Phase A spec (30KB, delivered in #shadow-collab-zerimar)
4. Phase 1 spec (at docs/superpowers/specs/2026-03-23-station-agent-platform-design.md in repo)
5. Engagement rules: scope boundaries, no adopting external tools, independent operation

## Fran's preferences
- Wants to be heavily involved in design/mockup process
- Values creative, immersive UX over admin panel patterns
- Spec-first — "hold on code until spec is done"
- Frontend-first validation before backend wiring
- Was nervous initially but warmed up — team should be welcoming but direct about technical concerns
