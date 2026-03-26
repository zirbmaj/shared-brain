---
title: Station Evolution Phase A — Agent Mind & Missions (zerimar/syght)
date: 2026-03-24
type: reference
scope: shadow
summary: Fran's full Phase A design spec for Station — data model, Mind UX, Missions system, channels, implementation scope.
---

# Station Evolution: Phase A — Agent Mind & Missions

**Date:** 2026-03-24
**Status:** Design approved, pending implementation plan
**Scope:** Phase A only — Agent Builder UX (The Mind) + Missions System
**Prerequisite:** Station Phase 1 scaffold (~70% complete)
**Target builders:** Partner team (3-4 agents: Claude/engineering, Static/QA, Near/research)

---

## 1. Vision & Strategic Position

### What Station is becoming

Station launched as an **agent management platform** — build agents, link items, monitor sessions. Phase A evolves it into an **agent-native collaborative workspace** where agents and humans co-create as partners.

The shift:

| Layer | Phase 1 (exists) | Phase A (this spec) |
|-------|------------------|---------------------|
| Agent management | CRUD, builder (Anvil), monitoring, versions | Stays — foundation layer |
| Agent experience | Tabbed detail view (Config/Brain/Logic/...) | **The Mind** — canvas-based immersive builder |
| Collaborative work | None | **Missions** — goal-oriented containers with crews |
| Communication | None | **Channels** — Discord-like mission communication |
| Platform integration | Station-only | Agents callable from editors (foundation only) |

### Strategic context

- **"What Figma is to code, Syght is to automation."** Agents aren't just managed in Syght — they work in Syght, using Syght's editors as their tools.
- **Not app-design-specific.** Missions can be writing a book, planning a campaign, building a mind map, researching a topic — any objective-oriented collaboration.
- **API-first.** Every operation is expressible as a clean function call. When MCP arrives in Phase B, it wraps existing RPCs without refactoring.
- **Agents as partners.** Agents are available across the platform — in editors, dashboards, workspaces. Station is where you build them, but they live everywhere.

---

## 2. Data Model

### Existing tables (no changes)

All 6 Phase 1 tables remain as-is:
- `station.agents` — hub entity
- `station.agent_items` — junction to content.items with roles
- `station.agent_versions` — immutable snapshots with aliases
- `station.agent_sessions` — run history (RPC-only)
- `station.agent_memories` — dynamic knowledge with vector embeddings (RPC-only)
- `station.agent_artifacts` — session outputs, promotable to items

### New tables

#### `station.missions` — Goal-oriented collaborative containers

```sql
CREATE TABLE station.missions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  organization_id uuid REFERENCES public.organizations(id),
  team_id uuid REFERENCES public.teams(id),
  personal_space_id uuid REFERENCES public.personal_spaces(id),
  name text NOT NULL,
  slug text UNIQUE,
  description text,
  objective text, -- clear goal statement
  status text NOT NULL DEFAULT 'planning'
    CHECK (status IN ('planning', 'active', 'review', 'deployed', 'archived')),
  project_id uuid REFERENCES content.items(id), -- optional parent project
  config jsonb DEFAULT '{}',
  progress_percentage integer DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
  search_vector tsvector,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz,
  -- Space scoping: exactly one scope
  CHECK (
    (personal_space_id IS NOT NULL)::int +
    (team_id IS NOT NULL)::int +
    (organization_id IS NOT NULL)::int = 1
  )
);
```

Indexes: user_id, organization_id, status, slug, search_vector (GIN), project_id, deleted_at.
Triggers: `trigger_generate_slug()`, `moddatetime(updated_at)`, search vector update on name/description.
RLS: user owns OR org membership check. Soft delete filtering.

#### `station.mission_agents` — Crew assignment

```sql
CREATE TABLE station.mission_agents (
  mission_id uuid NOT NULL REFERENCES station.missions(id) ON DELETE CASCADE,
  agent_id uuid NOT NULL REFERENCES station.agents(id) ON DELETE CASCADE,
  role text, -- freeform: "designer", "researcher", "reviewer", etc.
  config jsonb DEFAULT '{}', -- mission-specific agent config overrides
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (mission_id, agent_id)
);
```

Agents can be in multiple missions simultaneously. Cross-space assignment is allowed (an org-scoped agent can join a team-scoped mission within the same org).

#### `station.mission_benches` — Editor instances within missions

```sql
CREATE TABLE station.mission_benches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mission_id uuid NOT NULL REFERENCES station.missions(id) ON DELETE CASCADE,
  name text NOT NULL, -- "Homepage Wireframe", "Login Journey", "PRD"
  item_type text NOT NULL, -- references content item types: document, flow, schema, map, entity, custom
  item_id uuid REFERENCES content.items(id), -- created on first use or linked existing
  assigned_agent_ids uuid[] DEFAULT '{}', -- agents working on this bench
  config jsonb DEFAULT '{}', -- bench-specific settings
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
```

**Key design decision:** `item_type` is an open reference to existing Syght item types, not a closed enum. A flow can be a workflow, a mind map, or a campaign journey. A map can be a wireframe or a dependency graph. The bench just names the instance and points to the item.

#### `station.channels` — Discord-like communication

```sql
CREATE TABLE station.channels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mission_id uuid REFERENCES station.missions(id) ON DELETE CASCADE,
  name text NOT NULL, -- "#general", "#design-review", "#research"
  description text,
  channel_type text NOT NULL DEFAULT 'internal'
    CHECK (channel_type IN ('internal', 'discord_bridge')),
  external_id text, -- Discord channel ID for bridged channels (Phase C)
  participant_agent_ids uuid[] DEFAULT '{}', -- agents in this channel
  config jsonb DEFAULT '{}',
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
```

Channels are mission-scoped. A mission auto-creates a `#general` channel on creation. Users can create additional channels and assign specific agent groups to them — like Discord servers where you control which bots are in which channels.

#### `station.channel_messages` — Messages in channels

```sql
CREATE TABLE station.channel_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  channel_id uuid NOT NULL REFERENCES station.channels(id) ON DELETE CASCADE,
  sender_type text NOT NULL CHECK (sender_type IN ('human', 'agent')),
  sender_id uuid NOT NULL, -- user_id or agent_id
  content text NOT NULL,
  metadata jsonb DEFAULT '{}', -- attachments, item references, reactions (future)
  created_at timestamptz DEFAULT now()
);
```

Index: channel_id + created_at (for chronological message loading). Delivered via Supabase Realtime: `station:channel:{channelId}`.

### Mission ↔ Project relationship

```
Project (content.items where type='project')
├── Mission A ("Design Phase")
│   ├── Bench: Wireframe (item: map)
│   ├── Bench: User Flows (item: flow)
│   └── Bench: PRD (item: document)
├── Mission B ("Development Phase")
│   ├── Bench: Data Model (item: schema)
│   └── Bench: API Spec (item: document)
├── Standalone artifact (from MCP / quick session)
└── Milestone: "Design Complete" (50%)
```

- Project is the **parent container** for all work on an objective
- Missions are **focused sprints** within a project — they have crews, benches, channels
- Missions can exist **without a project** for one-off explorations
- Artifacts created outside missions (via MCP, quick agent sessions) can still be tied to a project directly
- Project tracks overall progress; Mission tracks sprint-level progress

### RPC wrappers (SECURITY DEFINER)

All new operations go through RPCs in the `public` schema, following the pattern established by `ai`, `internal`, and `billing` schemas:

**Mission RPCs:**
- `create_mission(p_name, p_description, p_org_id, p_project_id, ...)` → returns mission
- `update_mission(p_mission_id, p_name, p_status, ...)` → returns mission
- `delete_mission(p_mission_id)` → soft delete
- `list_missions(p_org_id, p_status, p_project_id)` → filtered list
- `get_mission(p_mission_id)` → single mission with crew + bench counts

**Mission crew RPCs:**
- `assign_agent_to_mission(p_mission_id, p_agent_id, p_role)` → join
- `remove_agent_from_mission(p_mission_id, p_agent_id)` → leave
- `list_mission_crew(p_mission_id)` → agents with roles + status

**Bench RPCs:**
- `create_bench(p_mission_id, p_name, p_item_type, p_item_id)` → creates bench, optionally creates item
- `update_bench(p_bench_id, p_name, p_assigned_agent_ids)` → update
- `delete_bench(p_bench_id)` → remove
- `list_mission_benches(p_mission_id)` → benches with item metadata

**Channel RPCs:**
- `create_channel(p_mission_id, p_name, p_participant_agent_ids)` → create
- `send_channel_message(p_channel_id, p_content, p_metadata)` → post message
- `list_channel_messages(p_channel_id, p_limit, p_before)` → paginated messages
- `list_mission_channels(p_mission_id)` → channels for mission

---

## 3. Agent Builder UX — The Mind

### Overview

The current tabbed agent detail view (Config, Brain, Logic, Sessions, Memory, Versions) is replaced by **The Mind** — a canvas-based experience where you build an agent by populating cognitive regions.

**Route:** `/a/:orgSlug/station/agents/:agentId`

### Level 1: The Mind Graph

A full-page canvas with the agent at the center, surrounded by cognitive regions as orbiting nodes.

**Regions** (mapped to existing `agent_items` roles + agent config):

| Region | Color | Source | What it contains |
|--------|-------|--------|-----------------|
| Identity | Violet (#7C3AED) | Agent config: instructions, guardrails | Personality, system prompt, tone, avatar |
| Knowledge | Pink (#ec4899) | agent_items role: knowledge | Documents, codex items |
| Logic | Indigo (#6366f1) | agent_items role: logic | Flows (decision trees, triggers) |
| Tools | Teal (#2EC4D4) | agent_items role: targeting + future MCP tools | Connected tools, integrations, API endpoints |
| Memories | Amber (#f59e0b) | agent_memories table | Short-term, long-term, entity, contextual |
| Planning | Teal-green (#14b8a6) | agent_items role: planning | Projects, milestones |
| Output | Emerald (#10b981) | agent_artifacts table | Produced artifacts, promoted items |
| Guardrails | Orange (#f97316) | Agent config: guardrails | Token limits, PII rules, scope boundaries |

**Visual behavior:**
- Region nodes sized relative to content volume (more items = larger node)
- Subtle connection lines to center agent node
- Regions use Syght's design system colors (teal primary, violet accent)
- Dark radial-gradient background (consistent with Syght dark theme)
- Region nodes have subtle glow matching their color

**Empty state:** For new agents, regions appear as dim outlines. Identity region glows to signal "start here." A floating prompt invites the user: "Start a conversation with your agent or drag items onto its mind."

**Dense state:** Regions show count badge + miniature preview. Full contents visible only on dive-in.

**Side panel (right, collapsible ~240px):**
- Quick stats: item counts, session count (7d), memory count
- Missions: list of missions this agent is assigned to (clickable)
- Live session: if agent is running, shows streaming output + token usage
- "Start session" button to begin 1:1 conversation with the agent

### Level 2: Region Dive-In

Clicking a region smoothly transitions into a spatial canvas showing its contents.

| Region | Canvas style | Interaction |
|--------|-------------|------------|
| Identity | Structured form-canvas — name, avatar, system prompt editor, personality traits, tone selector | Edit inline, changes save to agent config |
| Knowledge | Clustered card grid — documents and codex items grouped by topic | Drag to reorder, click to preview, + button to search/attach items |
| Logic | Mini flow preview — shows linked flows as read-only diagrams | Click a flow to open in flow editor. + button to link flows |
| Tools | Tool cards — connected integrations with enable/disable toggles | Configure per tool, + button to add tools |
| Memories | Grouped by type with visual differentiation — long-term (solid), short-term (fading opacity), entity (tagged) | Click to read/edit, delete, manually add. Search within memories |
| Planning | Project cards + milestone timeline | Link to projects, view progress |
| Output | Artifact gallery (existing ArtifactGallery component) | Filter, preview, promote to items |
| Guardrails | Rule cards — each rule is a card with toggle + threshold config | Add/remove rules, set limits |

**Navigation:** Breadcrumb trail shows `Station > Agents > {Agent Name} > {Region}`. Back button or breadcrumb returns to Level 1.

### Agent Creation: Two Paths

**Path A: Conversational ("Start from scratch")**
1. Click "New Agent" from agents grid
2. Provide a name (minimum required)
3. Land directly in the Mind view — empty regions, Identity glowing
4. A chat panel opens: "Tell me about this agent. What should it do?"
5. As the user describes the agent, the system populates regions (instructions → Identity, referenced docs → Knowledge, etc.)
6. The agent helps create itself through dialogue

**Path B: Pre-loaded ("I have materials")**
1. Click "New Agent" → choose "Quick Setup" (the Anvil, streamlined)
2. Name + instructions + drag items by role
3. Review → Create → land in Mind view with regions populated

The Anvil wizard is retained as an optional quick-setup path, not the primary experience.

### Interactions

| Action | Behavior |
|--------|----------|
| Click region node | Dive into Level 2 spatial canvas |
| Drag item from search/panel → drop on region | Attaches item to agent with appropriate role |
| Click center agent node | Inline edit: name, description, status |
| Right-click region | Context menu: rename (for custom labels), detach all, view stats |
| Hover region | Tooltip: item count, last modified, brief description |
| Start session (side panel) | Opens 1:1 chat with agent, agent can reference its own knowledge |
| Keyboard: Escape | Return to Level 1 from Level 2 |

### Technical implementation

**Phase A renderer:** CSS-positioned nodes with absolute positioning and CSS transitions for dive-in. Not a full physics engine. This is the functional skeleton.

**Phase A.2 upgrade path:** Replace CSS positioning with a force-directed graph library (d3-force, react-force-graph, or cytoscape.js — Near/research agent evaluates options). Adds organic movement, collision detection, drag physics.

**Component structure:**
```
components/mind/
├── AgentMindView.tsx          -- Main container, manages level state
├── MindGraph.tsx              -- Level 1 graph renderer
├── MindGraphNode.tsx          -- Individual region node
├── MindSidePanel.tsx          -- Stats, missions, live session
├── regions/
│   ├── IdentityRegion.tsx     -- Form-canvas for identity config
│   ├── KnowledgeRegion.tsx    -- Clustered card grid
│   ├── LogicRegion.tsx        -- Mini flow previews
│   ├── ToolsRegion.tsx        -- Tool cards
│   ├── MemoriesRegion.tsx     -- Grouped memory cards
│   ├── PlanningRegion.tsx     -- Project cards + timeline
│   ├── OutputRegion.tsx       -- Artifact gallery (reuses existing)
│   └── GuardrailsRegion.tsx   -- Rule cards
└── shared/
    ├── RegionHeader.tsx        -- Breadcrumb + back navigation
    ├── ItemDropTarget.tsx      -- Drag-to-attach handler
    └── RegionEmptyState.tsx    -- Empty region invitation
```

---

## 4. Missions System

### Missions Grid

**Route:** `/a/:orgSlug/station/missions`

Card-based grid showing all missions:
- **Card contents:** Name, description (truncated), status badge, crew avatars (with working/idle indicators), bench type badges, progress bar
- **Filters:** Status (all / planning / active / review / deployed / archived)
- **Sort:** Recently updated, name, status, progress
- **Search:** Full-text via search_vector
- **Empty state:** Illustration + "Create your first mission" CTA
- **"+ New Mission" button** in top bar

### Mission Creation

Lightweight form (not a wizard):
1. Name (required)
2. Description / objective
3. Link to existing project (optional — dropdown or search)
4. Auto-creates a `#general` channel

Agents and benches are added after creation, from within the mission workspace.

### Mission Workspace

**Route:** `/a/:orgSlug/station/missions/:missionId`

**Layout: Three zones**

**Top bar:**
- Back to Missions
- Mission name + status badge (editable inline)
- Progress indicator
- Chat button (opens channel slide-over)
- Deploy button (Phase C — disabled in Phase A with "Coming soon" tooltip)

**Left sidebar (~200px, collapsible):**

*Crew section:*
- Agent cards with avatar, name, role label, live status (working / idle / offline)
- Click agent → navigate to its Mind view
- "+ Add agent" → search/select from org's agent roster
- Remove agent (right-click or swipe)

*Bench section:*
- Bench cards with icon (based on item_type), name, assigned agent indicator
- Click bench → loads bench content in main area
- "+ Add bench" → name + item type selector (open list: document, flow, schema, map, entity, custom)
- Benches can be reordered (drag)

**Main area:**

Shows selected bench content:
- Bench header: name, item_type badge, version indicator, history button, approve button
- Content area: Preview of the bench's linked item
- Phase A: Click-to-open — clicking the preview opens the full editor (`/a/:orgSlug/flow-editor/:itemId`, etc.) with a "Mission: {name}" context banner
- Phase B: Embedded editor — the editor renders inline within the mission workspace

**Bench interactions (Phase A):**
- Create bench → auto-creates a content.item of the specified type, links it
- Or link existing item → bench points to an already-existing item
- Approve → creates a version snapshot in `content.content_versions`, marks bench as reviewed
- The human can click into the full editor and modify the item directly — agents and humans co-edit

### Multi-Agent Concurrency on Benches

Agents assigned to a bench (`assigned_agent_ids`) work in **spatially partitioned areas**:
- Each agent is assigned a scope/region within the bench's item (leveraging existing flow scopes for flow-type benches)
- Agents are aware of each other's assigned areas and don't overlap
- The human can work anywhere — no spatial restrictions
- Multiple agents can work on different benches within the same mission simultaneously

Phase A implementation: one agent per bench at a time (simpler). Spatial partitioning is Phase B when embedded editors enable real-time collaboration.

### Mission Lifecycle

```
planning ──→ active ──→ review ──→ deployed ──→ archived
    │            │          │
    └────────────┴──────────┘  (can move backward)
```

- **Planning:** Set objective, assign crew, create benches. Agents not yet activated.
- **Active:** Agents working on benches. Sessions running. Artifacts being produced. Human collaborating.
- **Review:** Human reviews bench outputs. Approve/reject individual benches. Request revisions (moves specific benches back to active).
- **Deployed:** All benches approved. Artifacts promoted to project items. External integrations triggered (Phase C: GitHub push).
- **Archived:** Complete. Read-only. Accessible from project history.

Status transitions are manual (user clicks) in Phase A. Future: agents can propose status changes.

---

## 5. Communication Model

### Three communication patterns

**1. Mission channels (group)**
- Discord-like: a mission has multiple channels
- Auto-created `#general` on mission creation
- User creates additional channels: `#design-review`, `#research`, `#decisions`
- Each channel has `participant_agent_ids` — which agents listen/respond in that channel
- Agents not in `participant_agent_ids` don't see or respond to messages in that channel
- Human always has access to all channels

**2. Agent sessions (1:1)**
- Existing `station.agent_sessions` — a focused conversation between human and one agent
- Accessible from the agent's Mind view (side panel) or from the crew sidebar in a mission
- Sessions produce artifacts that can be promoted
- Session history is the agent's individual conversation log

**3. Agent-to-agent communication (partner sessions)**
- Agents within the same mission can have sessions with each other
- `trigger_type: 'agent'` on `agent_sessions` — triggered by another agent
- Human can observe these sessions (read-only view in monitoring or mission activity feed)
- Phase A: agent-to-agent is orchestrated by supervisor agents (existing `agent_type: 'supervisor'`)
- Phase B+: autonomous agent-to-agent communication based on mission objectives

### Channel delivery

- **Supabase Realtime:** Channel `station:channel:{channelId}` for live message streaming
- **Message format:** sender_type (human/agent) + sender_id + content + metadata (item references, attachments)
- **Phase A:** Text messages only. Phase B: Rich messages with item previews, code blocks, image attachments.

---

## 6. Agents as Platform-Wide Partners

### Vision

Agents aren't confined to Station. They're partners available across Syght:
- Working in a flow editor → summon your agent to help
- In a workspace → ask your agent to organize items
- On the dashboard → agent provides daily brief

### Phase A foundation

**What we build:**
- Agent service layer that's callable from anywhere (not coupled to Station UI)
- Agent session API that any editor can invoke
- Lightweight "agent presence" component (avatar + status indicator) reusable across features

**What we wire up:**
- Flow canvas AI mode (already scaffolded in `useFlowCanvasAI.ts`, `FlowViewModeContext.tsx`) updated to allow selecting a specific agent from the user's roster instead of a generic AI session
- This is the existing hook point — no new scaffolding needed, just connecting it to `station.agents`

**What we defer to Phase B+:**
- Agent presence in document editor, schema editor, map editor
- Dashboard agent brief
- Global "summon agent" shortcut
- Agent suggestions/notifications outside Station

---

## 7. Navigation & Station Tab Structure

### Consolidated sub-tabs

Station header sub-tabs (reduced from 7 to 3 + settings):

| Tab | Route | Content |
|-----|-------|---------|
| **Agents** | `/station/agents` | Agent grid → Agent Mind view |
| **Missions** | `/station/missions` | Mission grid → Mission workspace |
| **Activity** | `/station/activity` | Combined monitoring + artifacts (merged for simplicity) |
| **Settings** (gear icon) | `/station/settings` | Org-wide LLM defaults, guardrails, token budgets |

### Full route map

```
/a/:orgSlug/station                              → Redirect to /station/agents
/a/:orgSlug/station/agents                        → Agent grid
/a/:orgSlug/station/agents/new                    → New agent (Mind view, empty)
/a/:orgSlug/station/agents/:agentId               → Agent Mind view (Level 1)
/a/:orgSlug/station/agents/:agentId/:region       → Region dive-in (Level 2)
/a/:orgSlug/station/missions                      → Mission grid
/a/:orgSlug/station/missions/new                  → Create mission form
/a/:orgSlug/station/missions/:missionId           → Mission workspace
/a/:orgSlug/station/missions/:missionId/bench/:benchId → Bench focus view
/a/:orgSlug/station/activity                      → Monitoring + artifacts
/a/:orgSlug/station/settings                      → Station settings
```

### Cross-navigation

- Agent Mind → "Missions" section in side panel → click → Mission workspace
- Mission workspace → crew sidebar → click agent → Agent Mind view
- Activity → drill into session → links to agent and/or mission
- Agent Mind → Output region → artifact → links to mission if produced in one

---

## 8. Design System Compliance

All new components follow Syght's established design system:

| Element | Specification |
|---------|---------------|
| Primary color | Teal `hsl(186, 68%, 50%)` / `#2EC4D4` |
| Accent color | Violet `hsl(263, 84%, 58%)` / `#7C3AED` |
| Background | Dark theme: `var(--background)` with `.topo-bg` pattern where appropriate |
| Cards | `.glass-card` class for frosted-glass surfaces |
| Typography | Inter (display 700/800, body 400/500), JetBrains Mono for code/data |
| Spacing | Tailwind scale (4px base) |
| Border radius | 8px (cards), 12px (containers), full (avatars, status dots) |
| Status colors | Green (#10b981) active, Amber (#f59e0b) review, Indigo (#6366f1) planning, Gray (#888) archived |
| Animations | Subtle — no jarring transitions. Prefer opacity + scale over slide. |
| Dark mode | Primary target. Light mode compatibility maintained but not priority. |

Region-specific colors (Identity violet, Knowledge pink, etc.) are accent colors within the Mind view only — they complement the teal/violet palette, not replace it.

---

## 9. Implementation Scope — Phase A

### What gets built

| Deliverable | Priority | Complexity |
|-------------|----------|-----------|
| DB migrations (missions, mission_agents, mission_benches, channels, channel_messages) | P0 | Medium |
| RPC wrappers (all SECURITY DEFINER) | P0 | Medium |
| TypeScript types for all new entities | P0 | Low |
| Mission CRUD service + React Query hooks | P0 | Medium |
| Channel service + hooks | P1 | Medium |
| MissionsGrid component | P0 | Medium |
| MissionWorkspace component (3-zone layout) | P0 | High |
| Mission creation form | P0 | Low |
| AgentMindView (Level 1 graph) | P0 | High |
| Region dive-in views (Level 2, 8 regions) | P1 | High |
| MindSidePanel (stats, missions, live session) | P1 | Medium |
| Drag-to-attach interaction | P1 | Medium |
| Agent conversational creation (Path A) | P2 | Medium |
| Station tab restructure (3 tabs + settings) | P0 | Low |
| Route registration + navigation hooks | P0 | Low |
| Zustand store extensions | P0 | Low |
| Flow canvas AI mode → agent selection | P2 | Low |

### What gets deferred

| Deferred item | Target phase |
|---------------|-------------|
| Embedded editors in benches | Phase B |
| MCP server | Phase B |
| Spatial partitioning for multi-agent benches | Phase B |
| Interactive wireframes / click-through prototypes | Phase C |
| Discord channel bridge | Phase C |
| GitHub deploy integration | Phase C |
| Agent presence in all editors | Phase B+ |
| Force-directed graph physics (d3-force upgrade) | Phase A.2 |
| Rich channel messages (attachments, previews) | Phase B |
| Agent-to-agent autonomous communication | Phase B+ |

### Partner team work split

| Agent | Focus area | Key deliverables |
|-------|-----------|-----------------|
| **Claude (Engineering)** | Missions system + shared infrastructure | DB migrations, RPCs, mission service, hooks, types, MissionWorkspace shell, route wiring |
| **Static (QA)** | Agent Mind View | AgentMindView, MindGraph, region components, MindSidePanel, drag interactions |
| **Near (Research)** | Graph renderer research + bench architecture | Evaluate d3-force / react-force-graph / cytoscape.js, prototype dive-in transitions, recommend renderer for Phase A.2 |
| **4th agent (if available)** | Channels + cross-navigation + Activity tab | Channel components, message thread with Realtime, agent↔mission navigation, Activity tab (merged monitoring+artifacts) |

### Technical decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Graph renderer (Phase A) | CSS-positioned nodes | Fast to build, validates UX. Upgrade to physics engine in A.2 |
| Bench → Editor (Phase A) | Link + click-to-open | Embedded editors require significant refactoring. Click-to-open works now |
| Concurrency (Phase A) | One agent per bench | Spatial partitioning needs embedded editors. Turn-based is simpler |
| Backend operations | RPC-first | Ready for MCP wrapping in Phase B |
| Channel delivery | Supabase Realtime | Already used for agent streaming. Consistent infrastructure |
| State management | Zustand (UI) + React Query (server) | Consistent with all other features |

---

## 10. Phase B & C Roadmap (designed, not spec'd)

### Phase B: Editors + External Access

- Embedded editors in mission benches (flow, doc, schema inline)
- MCP server exposing Station operations as tools
- Spatial partitioning for multi-agent bench collaboration
- Force-directed graph renderer for Mind view
- Rich channel messages with item previews
- Agent presence in document and schema editors

### Phase C: Differentiating UX

- Interactive wireframe item type (click-through prototypes, linked screens)
- Discord channel bridge (bidirectional message sync)
- GitHub deploy integration (approve → push to repo → PR)
- Agent-to-agent autonomous communication
- Global "summon agent" shortcut across platform
- Dashboard agent brief

---

## 11. Open Questions (to resolve during implementation)

1. **Mission workspace sidebar layout** — Crew and benches are in the left sidebar for now, but the exact layout (tabs? stacked sections? floating panel?) should be iterated with mockups once the shell exists.

2. **Bench preview rendering** — Before Phase B embedded editors, how much of the item renders in the bench preview? Just a title + thumbnail? A read-only snapshot? TBD based on item type.

3. **Agent creation conversation UX** — Path A (conversational) needs a chat component that can also populate regions. The exact flow of "user talks, regions fill up" needs prototyping.

4. **Activity tab design** — Merging monitoring + artifacts into one view. Needs a layout that works for both operational metrics and artifact browsing. Reference: Mailbox Lab analytics design.

5. **Mind graph region positioning** — Are regions always in the same positions (fixed layout), or do they rearrange based on content? Fixed is simpler and more predictable for Phase A.

---

*Spec written: 2026-03-24*
*Builds on: `docs/superpowers/specs/2026-03-23-station-agent-platform-design.md` (Phase 1)*
*Phase: A — Agent Mind & Missions*
