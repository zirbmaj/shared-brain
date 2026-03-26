# Station Evolution Phase A — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Evolve Station from agent management into an agent-native collaborative workspace with a canvas-based Agent Mind view and a Missions system.

**Architecture:** Builds on existing Station Phase 1 scaffold (~40 files, 6 DB tables). Adds 5 new tables (missions, mission_agents, mission_benches, channels, channel_messages) via RPC-first access pattern. Frontend uses existing Zustand + React Query patterns. Agent Mind view uses CSS-positioned graph nodes with region dive-in canvases. Missions system uses card grid + three-zone workspace layout.

**Tech Stack:** React 18, TypeScript, Vite, Tailwind CSS, shadcn/Radix, Zustand, React Query, Supabase PostgreSQL (RPC + PostgREST), Lucide icons

**Spec:** `docs/superpowers/specs/2026-03-24-station-evolution-phase-a-design.md`

**Existing code:** `src/features/station/` (types, services, hooks, stores, components — all patterns to replicate)

---

## File Structure

### Database migrations (new files)
- `supabase/migrations/20260324200000_station_missions_schema.sql` — missions, mission_agents, mission_benches tables + indexes + triggers + RLS
- `supabase/migrations/20260324200001_station_channels_schema.sql` — channels, channel_messages tables + indexes + triggers + RLS
- `supabase/migrations/20260324200002_station_phase_a_rpcs.sql` — All SECURITY DEFINER RPCs for missions, benches, crew, channels
- `supabase/migrations/20260324200003_expose_station_new_tables.sql` — PostgREST exposure for mission_benches (missions/channels go RPC-only)

### Types (modify existing)
- `src/features/station/types/station.types.ts` — Add Mission, MissionAgent, MissionBench, Channel, ChannelMessage interfaces + enums + UI configs

### Services (new files)
- `src/features/station/services/stationMissionService.ts` — Mission CRUD, crew, bench operations via RPCs
- `src/features/station/services/stationChannelService.ts` — Channel + message operations via RPCs

### Hooks (new files)
- `src/features/station/hooks/useMissions.ts` — useListMissions, useMission
- `src/features/station/hooks/useMissionMutations.ts` — useCreateMission, useUpdateMission, useDeleteMission
- `src/features/station/hooks/useMissionCrew.ts` — useMissionCrew, useAssignAgent, useRemoveAgent
- `src/features/station/hooks/useMissionBenches.ts` — useMissionBenches, useCreateBench, useUpdateBench, useDeleteBench
- `src/features/station/hooks/useChannels.ts` — useChannels, useChannelMessages, useSendMessage, useCreateChannel

### Store (modify existing)
- `src/features/station/stores/stationUIStore.ts` — Add mission state (filters, selected mission, active bench, channel state)

### Constants (modify existing)
- `src/features/station/constants.ts` — Update STATION_TABS to new 3-tab + settings structure

### Components — Agent Mind View (new files)
- `src/features/station/components/mind/AgentMindView.tsx` — Main container, level state (graph vs region)
- `src/features/station/components/mind/MindGraph.tsx` — Level 1 CSS-positioned graph with center agent + 8 region nodes
- `src/features/station/components/mind/MindGraphNode.tsx` — Individual region node (circle, icon, label, count badge, glow)
- `src/features/station/components/mind/MindSidePanel.tsx` — Stats, missions list, live session panel
- `src/features/station/components/mind/regions/IdentityRegion.tsx` — Name, avatar, system prompt editor
- `src/features/station/components/mind/regions/KnowledgeRegion.tsx` — Document/codex card grid with attach
- `src/features/station/components/mind/regions/LogicRegion.tsx` — Flow preview cards with link-to-editor
- `src/features/station/components/mind/regions/ToolsRegion.tsx` — Tool cards with toggles
- `src/features/station/components/mind/regions/MemoriesRegion.tsx` — Grouped memory cards by type
- `src/features/station/components/mind/regions/PlanningRegion.tsx` — Project cards + milestones
- `src/features/station/components/mind/regions/OutputRegion.tsx` — Reuses ArtifactGallery
- `src/features/station/components/mind/regions/GuardrailsRegion.tsx` — Rule cards with toggles
- `src/features/station/components/mind/shared/RegionHeader.tsx` — Breadcrumb + back navigation
- `src/features/station/components/mind/shared/RegionEmptyState.tsx` — Empty region invitation

### Components — Missions (new files)
- `src/features/station/components/missions/MissionsGrid.tsx` — Card grid with filters
- `src/features/station/components/missions/MissionCard.tsx` — Individual mission card
- `src/features/station/components/missions/MissionFiltersBar.tsx` — Status filter, search, sort
- `src/features/station/components/missions/MissionCreateForm.tsx` — Lightweight creation form
- `src/features/station/components/missions/MissionWorkspace.tsx` — Three-zone workspace container
- `src/features/station/components/missions/MissionTopBar.tsx` — Name, status, progress, actions
- `src/features/station/components/missions/MissionSidebar.tsx` — Crew + benches sidebar
- `src/features/station/components/missions/BenchPreview.tsx` — Bench content preview in main area
- `src/features/station/components/missions/CrewCard.tsx` — Agent card in crew sidebar
- `src/features/station/components/missions/BenchCard.tsx` — Bench card in sidebar

### Components — Channels (new files)
- `src/features/station/components/channels/ChannelThread.tsx` — Message list + input
- `src/features/station/components/channels/ChannelMessage.tsx` — Individual message bubble
- `src/features/station/components/channels/ChannelSlideOver.tsx` — Slide-over panel for mission chat

### Components — Activity (new file)
- `src/features/station/components/activity/ActivityView.tsx` — Merged monitoring + artifacts

### Routing (modify existing)
- `src/features/station/components/StationShell.tsx` — Add missions, activity routing + lazy imports
- `src/shared/hooks/useAccountRouting.tsx` — Add mission navigation helpers
- `src/App.tsx` — Add mission routes

### Barrel export (modify existing)
- `src/features/station/index.ts` — Export new components, hooks, types

---

## Tasks

### Task 1: Database Migration — Missions Tables

**Files:**
- Create: `supabase/migrations/20260324200000_station_missions_schema.sql`

- [ ] **Step 1: Write the missions migration**

```sql
-- Station Phase A: Missions, Crew, Benches
-- Builds on: 20260323200000_station_schema.sql

-- ============================================================
-- station.missions — Goal-oriented collaborative containers
-- ============================================================
CREATE TABLE station.missions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
  team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
  personal_space_id UUID REFERENCES public.personal_spaces(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  slug TEXT UNIQUE,
  description TEXT,
  objective TEXT,
  status TEXT NOT NULL DEFAULT 'planning'
    CHECK (status IN ('planning', 'active', 'review', 'deployed', 'archived')),
  project_id UUID REFERENCES content.items(id) ON DELETE SET NULL,
  config JSONB DEFAULT '{}',
  progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
  search_vector TSVECTOR,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  CHECK (
    (personal_space_id IS NOT NULL)::int +
    (team_id IS NOT NULL)::int +
    (organization_id IS NOT NULL)::int = 1
  )
);

COMMENT ON TABLE station.missions IS 'Goal-oriented collaborative containers where agent crews work toward objectives';

-- Indexes
CREATE INDEX idx_station_missions_user_id ON station.missions(user_id);
CREATE INDEX idx_station_missions_organization_id ON station.missions(organization_id);
CREATE INDEX idx_station_missions_status ON station.missions(status);
CREATE INDEX idx_station_missions_slug ON station.missions(slug);
CREATE INDEX idx_station_missions_project_id ON station.missions(project_id);
CREATE INDEX idx_station_missions_search ON station.missions USING gin(search_vector);
CREATE INDEX idx_station_missions_deleted_at ON station.missions(deleted_at) WHERE deleted_at IS NULL;

-- Triggers: updated_at
CREATE TRIGGER trigger_missions_updated_at
  BEFORE UPDATE ON station.missions
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

-- Triggers: slug generation
CREATE TRIGGER trigger_missions_slug
  BEFORE INSERT ON station.missions
  FOR EACH ROW EXECUTE FUNCTION trigger_generate_slug();

-- Triggers: search vector
CREATE OR REPLACE FUNCTION station.missions_search_vector_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := to_tsvector('english',
    COALESCE(NEW.name, '') || ' ' ||
    COALESCE(NEW.description, '') || ' ' ||
    COALESCE(NEW.objective, '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_missions_search_vector
  BEFORE INSERT OR UPDATE OF name, description, objective ON station.missions
  FOR EACH ROW EXECUTE FUNCTION station.missions_search_vector_update();

-- RLS
ALTER TABLE station.missions ENABLE ROW LEVEL SECURITY;

CREATE POLICY missions_select ON station.missions FOR SELECT TO authenticated
  USING (
    deleted_at IS NULL AND (
      user_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM public.organization_members
        WHERE organization_id = missions.organization_id
        AND user_id = auth.uid()
      )
    )
  );

CREATE POLICY missions_insert ON station.missions FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY missions_update ON station.missions FOR UPDATE TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.organization_members
      WHERE organization_id = missions.organization_id
      AND user_id = auth.uid()
      AND role IN ('org_admin', 'team_lead')
    )
  );

CREATE POLICY missions_delete ON station.missions FOR DELETE TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.organization_members
      WHERE organization_id = missions.organization_id
      AND user_id = auth.uid()
      AND role = 'org_admin'
    )
  );

-- ============================================================
-- station.mission_agents — Crew assignment
-- ============================================================
CREATE TABLE station.mission_agents (
  mission_id UUID NOT NULL REFERENCES station.missions(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL REFERENCES station.agents(id) ON DELETE CASCADE,
  role TEXT,
  config JSONB DEFAULT '{}',
  joined_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (mission_id, agent_id)
);

COMMENT ON TABLE station.mission_agents IS 'Junction: agents assigned to missions as crew members';

CREATE INDEX idx_station_mission_agents_agent ON station.mission_agents(agent_id);

ALTER TABLE station.mission_agents ENABLE ROW LEVEL SECURITY;

CREATE POLICY mission_agents_select ON station.mission_agents FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = mission_agents.mission_id
      AND m.deleted_at IS NULL
      AND (
        m.user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.organization_members
          WHERE organization_id = m.organization_id
          AND user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY mission_agents_insert ON station.mission_agents FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = mission_agents.mission_id
      AND m.user_id = auth.uid()
    )
  );

CREATE POLICY mission_agents_delete ON station.mission_agents FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = mission_agents.mission_id
      AND m.user_id = auth.uid()
    )
  );

-- ============================================================
-- station.mission_benches — Editor instances within missions
-- ============================================================
CREATE TABLE station.mission_benches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mission_id UUID NOT NULL REFERENCES station.missions(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  item_type TEXT NOT NULL,
  item_id UUID REFERENCES content.items(id) ON DELETE SET NULL,
  assigned_agent_ids UUID[] DEFAULT '{}',
  config JSONB DEFAULT '{}',
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE station.mission_benches IS 'Editor instances within missions — each bench links to a content item';

CREATE INDEX idx_station_mission_benches_mission ON station.mission_benches(mission_id);
CREATE INDEX idx_station_mission_benches_item ON station.mission_benches(item_id);

CREATE TRIGGER trigger_mission_benches_updated_at
  BEFORE UPDATE ON station.mission_benches
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

ALTER TABLE station.mission_benches ENABLE ROW LEVEL SECURITY;

CREATE POLICY mission_benches_select ON station.mission_benches FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = mission_benches.mission_id
      AND m.deleted_at IS NULL
      AND (
        m.user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.organization_members
          WHERE organization_id = m.organization_id
          AND user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY mission_benches_insert ON station.mission_benches FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = mission_benches.mission_id
      AND m.user_id = auth.uid()
    )
  );

CREATE POLICY mission_benches_update ON station.mission_benches FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = mission_benches.mission_id
      AND m.user_id = auth.uid()
    )
  );

CREATE POLICY mission_benches_delete ON station.mission_benches FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = mission_benches.mission_id
      AND m.user_id = auth.uid()
    )
  );
```

**Note:** The `trigger_generate_slug()` function may need to be extended to handle `station.missions` if it uses a registration table. Check the existing trigger function body and add the `station.missions` entry if required (same pattern as codices/templates/courses extensions documented in CLAUDE.md).

- [ ] **Step 2: Add PostgREST exposure for new tables**

Append to the same migration file (or create `20260324200003_expose_station_new_tables.sql`):

```sql
-- Expose new station tables to PostgREST (mission_benches is PostgREST-accessible;
-- missions/channels go through RPCs but need schema grants for RPC return types)
-- The station schema is already in pgrst.db_schemas from Phase 1 migration.
-- Just grant access to new tables:
GRANT ALL ON station.missions TO anon, authenticated, service_role;
GRANT ALL ON station.mission_agents TO anon, authenticated, service_role;
GRANT ALL ON station.mission_benches TO anon, authenticated, service_role;
GRANT ALL ON station.channels TO anon, authenticated, service_role;
GRANT ALL ON station.channel_messages TO anon, authenticated, service_role;
```

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/20260324200000_station_missions_schema.sql
git commit -m "feat(station): add missions, mission_agents, mission_benches tables"
```

---

### Task 2: Database Migration — Channels Tables

**Files:**
- Create: `supabase/migrations/20260324200001_station_channels_schema.sql`

- [ ] **Step 1: Write the channels migration**

```sql
-- Station Phase A: Channels & Messages
-- Discord-like communication within missions

-- ============================================================
-- station.channels — Communication threads
-- ============================================================
CREATE TABLE station.channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mission_id UUID REFERENCES station.missions(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  channel_type TEXT NOT NULL DEFAULT 'internal'
    CHECK (channel_type IN ('internal', 'discord_bridge')),
  external_id TEXT,
  participant_agent_ids UUID[] DEFAULT '{}',
  config JSONB DEFAULT '{}',
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE station.channels IS 'Discord-like communication channels within missions';

CREATE INDEX idx_station_channels_mission ON station.channels(mission_id);

CREATE TRIGGER trigger_channels_updated_at
  BEFORE UPDATE ON station.channels
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

ALTER TABLE station.channels ENABLE ROW LEVEL SECURITY;

CREATE POLICY channels_select ON station.channels FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = channels.mission_id
      AND m.deleted_at IS NULL
      AND (
        m.user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.organization_members
          WHERE organization_id = m.organization_id
          AND user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY channels_insert ON station.channels FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = channels.mission_id
      AND m.user_id = auth.uid()
    )
  );

CREATE POLICY channels_update ON station.channels FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = channels.mission_id
      AND m.user_id = auth.uid()
    )
  );

CREATE POLICY channels_delete ON station.channels FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.missions m
      WHERE m.id = channels.mission_id
      AND m.user_id = auth.uid()
    )
  );

-- ============================================================
-- station.channel_messages — Messages in channels
-- ============================================================
CREATE TABLE station.channel_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  channel_id UUID NOT NULL REFERENCES station.channels(id) ON DELETE CASCADE,
  sender_type TEXT NOT NULL CHECK (sender_type IN ('human', 'agent')),
  sender_id UUID NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE station.channel_messages IS 'Messages within channels — human and agent senders';

CREATE INDEX idx_station_channel_messages_channel ON station.channel_messages(channel_id, created_at);

ALTER TABLE station.channel_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY channel_messages_select ON station.channel_messages FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM station.channels c
      JOIN station.missions m ON m.id = c.mission_id
      WHERE c.id = channel_messages.channel_id
      AND m.deleted_at IS NULL
      AND (
        m.user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.organization_members
          WHERE organization_id = m.organization_id
          AND user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY channel_messages_insert ON station.channel_messages FOR INSERT TO authenticated
  WITH CHECK (
    sender_type = 'human' AND sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM station.channels c
      JOIN station.missions m ON m.id = c.mission_id
      WHERE c.id = channel_messages.channel_id
      AND m.deleted_at IS NULL
      AND (
        m.user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.organization_members
          WHERE organization_id = m.organization_id
          AND user_id = auth.uid()
        )
      )
    )
  );

-- Enable Realtime for channel messages
ALTER PUBLICATION supabase_realtime ADD TABLE station.channel_messages;
```

- [ ] **Step 2: Commit**

```bash
git add supabase/migrations/20260324200001_station_channels_schema.sql
git commit -m "feat(station): add channels and channel_messages tables with Realtime"
```

---

### Task 3: Database Migration — RPCs

**Files:**
- Create: `supabase/migrations/20260324200002_station_phase_a_rpcs.sql`

- [ ] **Step 1: Write all Phase A RPCs**

Follow the exact pattern from `20260323210000_station_phase2_rpcs.sql`:
- All functions are `SECURITY DEFINER` in `public` schema
- Parameter naming: `p_param_name`
- Auth checks via `auth.uid()` + org membership joins
- `RETURNS SETOF` for list operations, single table type for mutations, `JSON` for aggregations, `VOID` for deletes

RPCs to implement (16 total):

**Mission RPCs (5):**
- `create_mission(p_name, p_description, p_objective, p_organization_id, p_team_id, p_personal_space_id, p_project_id, p_config)` — INSERT + auto-create #general channel, RETURNS station.missions
- `update_mission(p_mission_id, p_name, p_description, p_objective, p_status, p_progress_percentage, p_config)` — UPDATE with auth check, RETURNS station.missions
- `delete_mission(p_mission_id)` — Soft delete (SET deleted_at), RETURNS VOID
- `list_missions(p_organization_id, p_status, p_project_id, p_limit, p_offset)` — RETURNS SETOF station.missions
- `get_mission(p_mission_id)` — RETURNS JSON (mission + crew_count + bench_count)

**Crew RPCs (3):**
- `assign_agent_to_mission(p_mission_id, p_agent_id, p_role)` — INSERT, RETURNS station.mission_agents
- `remove_agent_from_mission(p_mission_id, p_agent_id)` — DELETE, RETURNS VOID
- `list_mission_crew(p_mission_id)` — RETURNS JSON[] (agents with roles + agent details)

**Bench RPCs (4):**
- `create_bench(p_mission_id, p_name, p_item_type, p_item_id)` — INSERT, RETURNS station.mission_benches
- `update_bench(p_bench_id, p_name, p_assigned_agent_ids, p_sort_order)` — UPDATE, RETURNS station.mission_benches
- `delete_bench(p_bench_id)` — DELETE, RETURNS VOID
- `list_mission_benches(p_mission_id)` — RETURNS SETOF station.mission_benches

**Channel RPCs (4):**
- `create_channel(p_mission_id, p_name, p_description, p_participant_agent_ids)` — INSERT, RETURNS station.channels
- `send_channel_message(p_channel_id, p_content, p_metadata)` — INSERT with sender_id = auth.uid(), RETURNS station.channel_messages
- `list_channel_messages(p_channel_id, p_limit, p_before)` — RETURNS SETOF station.channel_messages (ordered by created_at DESC)
- `list_mission_channels(p_mission_id)` — RETURNS SETOF station.channels

All RPCs: `GRANT EXECUTE ON FUNCTION public.{name} TO authenticated;`

- [ ] **Step 2: Commit**

```bash
git add supabase/migrations/20260324200002_station_phase_a_rpcs.sql
git commit -m "feat(station): add 16 SECURITY DEFINER RPCs for missions, crew, benches, channels"
```

---

### Task 4: TypeScript Types

**Files:**
- Modify: `src/features/station/types/station.types.ts`

- [ ] **Step 1: Add Mission, Bench, Channel types and UI configs**

Add after existing types in the file:

```typescript
// ============================================================
// Missions
// ============================================================

export type MissionStatus = 'planning' | 'active' | 'review' | 'deployed' | 'archived';

export interface Mission {
  id: string;
  user_id: string;
  organization_id: string | null;
  team_id: string | null;
  personal_space_id: string | null;
  name: string;
  slug: string;
  description: string | null;
  objective: string | null;
  status: MissionStatus;
  project_id: string | null;
  config: Record<string, unknown>;
  progress_percentage: number;
  search_vector: string | null;
  created_at: string;
  updated_at: string;
  deleted_at: string | null;
}

export interface MissionWithCounts extends Mission {
  crew_count: number;
  bench_count: number;
}

export interface MissionAgent {
  mission_id: string;
  agent_id: string;
  role: string | null;
  config: Record<string, unknown>;
  joined_at: string;
}

export interface MissionCrewMember extends MissionAgent {
  agent_name: string;
  agent_type: AgentType;
  agent_status: AgentStatus;
  agent_avatar_url: string | null;
}

export interface MissionBench {
  id: string;
  mission_id: string;
  name: string;
  item_type: string;
  item_id: string | null;
  assigned_agent_ids: string[];
  config: Record<string, unknown>;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

export interface CreateMissionInput {
  name: string;
  description?: string;
  objective?: string;
  organization_id?: string;
  team_id?: string;
  personal_space_id?: string;
  project_id?: string;
  config?: Record<string, unknown>;
}

export interface UpdateMissionInput {
  name?: string;
  description?: string;
  objective?: string;
  status?: MissionStatus;
  progress_percentage?: number;
  config?: Record<string, unknown>;
}

export interface MissionFilters {
  search: string;
  status: MissionStatus | 'all';
  sortBy: 'updated_at' | 'name' | 'status' | 'progress_percentage';
  sortDir: 'asc' | 'desc';
}

export const DEFAULT_MISSION_FILTERS: MissionFilters = {
  search: '',
  status: 'all',
  sortBy: 'updated_at',
  sortDir: 'desc',
};

export const MISSION_STATUS_CONFIG: Record<MissionStatus, { label: string; color: string; dotColor: string }> = {
  planning: { label: 'Planning', color: 'text-indigo-500', dotColor: 'bg-indigo-500' },
  active: { label: 'Active', color: 'text-emerald-500', dotColor: 'bg-emerald-500' },
  review: { label: 'Review', color: 'text-amber-500', dotColor: 'bg-amber-500' },
  deployed: { label: 'Deployed', color: 'text-primary', dotColor: 'bg-primary' },
  archived: { label: 'Archived', color: 'text-muted-foreground', dotColor: 'bg-muted-foreground' },
};

// ============================================================
// Channels
// ============================================================

export type ChannelType = 'internal' | 'discord_bridge';
export type SenderType = 'human' | 'agent';

export interface Channel {
  id: string;
  mission_id: string;
  name: string;
  description: string | null;
  channel_type: ChannelType;
  external_id: string | null;
  participant_agent_ids: string[];
  config: Record<string, unknown>;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

export interface ChannelMessage {
  id: string;
  channel_id: string;
  sender_type: SenderType;
  sender_id: string;
  content: string;
  metadata: Record<string, unknown>;
  created_at: string;
}

// ============================================================
// Mind View
// ============================================================

export type MindRegion = 'identity' | 'knowledge' | 'logic' | 'tools' | 'memories' | 'planning' | 'output' | 'guardrails';

export interface MindRegionConfig {
  id: MindRegion;
  label: string;
  icon: string; // emoji for Phase A
  color: string; // tailwind color class
  bgGradient: string; // CSS gradient for node
  description: string;
}

export const MIND_REGIONS: MindRegionConfig[] = [
  { id: 'identity', label: 'Identity', icon: '🎭', color: 'text-violet-500', bgGradient: 'radial-gradient(circle, #7C3AED, #4c1d95)', description: 'Personality, instructions, tone' },
  { id: 'knowledge', label: 'Knowledge', icon: '📚', color: 'text-pink-500', bgGradient: 'radial-gradient(circle, #ec4899, #9d174d)', description: 'Documents, codex items' },
  { id: 'logic', label: 'Logic', icon: '🧠', color: 'text-indigo-500', bgGradient: 'radial-gradient(circle, #6366f1, #3730a3)', description: 'Decision flows, triggers' },
  { id: 'tools', label: 'Tools', icon: '🛠️', color: 'text-primary', bgGradient: 'radial-gradient(circle, #2EC4D4, #0e7490)', description: 'Integrations, API endpoints' },
  { id: 'memories', label: 'Memories', icon: '💭', color: 'text-amber-500', bgGradient: 'radial-gradient(circle, #f59e0b, #b45309)', description: 'Learned knowledge, context' },
  { id: 'planning', label: 'Planning', icon: '📋', color: 'text-teal-500', bgGradient: 'radial-gradient(circle, #14b8a6, #0f766e)', description: 'Projects, milestones' },
  { id: 'output', label: 'Output', icon: '📦', color: 'text-emerald-500', bgGradient: 'radial-gradient(circle, #10b981, #065f46)', description: 'Artifacts, generated items' },
  { id: 'guardrails', label: 'Guardrails', icon: '🛡️', color: 'text-orange-500', bgGradient: 'radial-gradient(circle, #f97316, #c2410c)', description: 'Limits, rules, boundaries' },
];

// ============================================================
// Updated Station Sections
// ============================================================

export type StationSection = 'agents' | 'missions' | 'activity' | 'settings';
```

- [ ] **Step 2: Commit**

```bash
git add src/features/station/types/station.types.ts
git commit -m "feat(station): add Mission, Bench, Channel, MindRegion types + UI configs"
```

---

### Task 5: Mission Service Layer

**Files:**
- Create: `src/features/station/services/stationMissionService.ts`

- [ ] **Step 1: Implement mission service with RPC calls**

Follow the exact pattern from `stationSessionService.ts` — all operations via `supabase.rpc()`:

```typescript
import { supabase } from '@/integrations/supabase/client';
import { logger } from '@/lib/logger';
import type {
  Mission, MissionWithCounts, MissionAgent, MissionCrewMember,
  MissionBench, CreateMissionInput, UpdateMissionInput, MissionFilters,
} from '../types/station.types';

export const stationMissionService = {
  // Mission CRUD
  async createMission(input: CreateMissionInput & { user_id: string }): Promise<Mission | null> { /* supabase.rpc('create_mission', ...) */ },
  async updateMission(missionId: string, input: UpdateMissionInput): Promise<Mission | null> { /* ... */ },
  async deleteMission(missionId: string): Promise<void> { /* ... */ },
  async listMissions(orgId: string, filters?: MissionFilters): Promise<Mission[]> { /* ... */ },
  async getMission(missionId: string): Promise<MissionWithCounts | null> { /* ... */ },

  // Crew
  async assignAgent(missionId: string, agentId: string, role?: string): Promise<MissionAgent | null> { /* ... */ },
  async removeAgent(missionId: string, agentId: string): Promise<void> { /* ... */ },
  async listCrew(missionId: string): Promise<MissionCrewMember[]> { /* ... */ },

  // Benches
  async createBench(missionId: string, name: string, itemType: string, itemId?: string): Promise<MissionBench | null> { /* ... */ },
  async updateBench(benchId: string, updates: Partial<Pick<MissionBench, 'name' | 'assigned_agent_ids' | 'sort_order'>>): Promise<MissionBench | null> { /* ... */ },
  async deleteBench(benchId: string): Promise<void> { /* ... */ },
  async listBenches(missionId: string): Promise<MissionBench[]> { /* ... */ },
};
```

Each method follows the try/catch + logger.error pattern from existing services. Parameter objects use `p_` prefix for RPC calls.

- [ ] **Step 2: Commit**

```bash
git add src/features/station/services/stationMissionService.ts
git commit -m "feat(station): add stationMissionService with RPC-based CRUD"
```

---

### Task 6: Channel Service Layer

**Files:**
- Create: `src/features/station/services/stationChannelService.ts`

- [ ] **Step 1: Implement channel service**

Same RPC pattern. Methods: `createChannel`, `listChannels`, `sendMessage`, `listMessages`.

- [ ] **Step 2: Commit**

```bash
git add src/features/station/services/stationChannelService.ts
git commit -m "feat(station): add stationChannelService for channels + messages"
```

---

### Task 7: React Query Hooks — Missions

**Files:**
- Create: `src/features/station/hooks/useMissions.ts`
- Create: `src/features/station/hooks/useMissionMutations.ts`
- Create: `src/features/station/hooks/useMissionCrew.ts`
- Create: `src/features/station/hooks/useMissionBenches.ts`

- [ ] **Step 1: Write query hooks**

Follow exact pattern from `useAgents.ts` and `useAgentMutations.ts`:
- `useListMissions()` — queryKey: `['station-missions', orgId, missionFilters]`, staleTime: 30_000
- `useMission(missionId)` — queryKey: `['station-mission', missionId]`
- `useCreateMission()` — invalidates `['station-missions']`, navigates to mission workspace
- `useUpdateMission()` — invalidates `['station-missions']` + `['station-mission', id]`
- `useDeleteMission()` — invalidates `['station-missions']`
- `useMissionCrew(missionId)` — queryKey: `['station-mission-crew', missionId]`
- `useAssignAgent()` — invalidates crew query
- `useRemoveAgent()` — invalidates crew query
- `useMissionBenches(missionId)` — queryKey: `['station-mission-benches', missionId]`
- `useCreateBench()`, `useUpdateBench()`, `useDeleteBench()` — invalidate benches query

- [ ] **Step 2: Commit**

```bash
git add src/features/station/hooks/useMissions.ts src/features/station/hooks/useMissionMutations.ts src/features/station/hooks/useMissionCrew.ts src/features/station/hooks/useMissionBenches.ts
git commit -m "feat(station): add React Query hooks for missions, crew, benches"
```

---

### Task 8: React Query Hooks — Channels

**Files:**
- Create: `src/features/station/hooks/useChannels.ts`

- [ ] **Step 1: Write channel hooks**

- `useChannels(missionId)` — queryKey: `['station-channels', missionId]`
- `useChannelMessages(channelId)` — queryKey: `['station-channel-messages', channelId]`, staleTime: 5_000 (messages refresh faster)
- `useSendMessage()` — invalidates messages query
- `useCreateChannel()` — invalidates channels query

- [ ] **Step 2: Commit**

```bash
git add src/features/station/hooks/useChannels.ts
git commit -m "feat(station): add React Query hooks for channels + messages"
```

---

### Task 9: Zustand Store Extensions

**Files:**
- Modify: `src/features/station/stores/stationUIStore.ts`

- [ ] **Step 1: Add mission UI state**

Add to existing store interface and implementation:

```typescript
// Mission state
missionFilters: MissionFilters;
selectedMissionId: string | null;
activeBenchId: string | null;
channelSlideOverOpen: boolean;
activeChannelId: string | null;

// Mission actions
setMissionFilters: (filters: Partial<MissionFilters>) => void;
resetMissionFilters: () => void;
setSelectedMission: (id: string | null) => void;
setActiveBench: (id: string | null) => void;
toggleChannelSlideOver: () => void;
setActiveChannel: (id: string | null) => void;

// Mind view state
activeMindRegion: MindRegion | null;
setActiveMindRegion: (region: MindRegion | null) => void;
```

Update `activeSection` type to use new `StationSection` type. Update reset function.

- [ ] **Step 2: Commit**

```bash
git add src/features/station/stores/stationUIStore.ts
git commit -m "feat(station): extend Zustand store with mission + mind view state"
```

---

### Task 10: Constants + Navigation Updates

**Files:**
- Modify: `src/features/station/constants.ts`
- Modify: `src/shared/hooks/useAccountRouting.tsx`
- Modify: `src/App.tsx`

- [ ] **Step 1: Update STATION_TABS to new 3+settings structure**

```typescript
export const STATION_TABS = [
  { id: 'agents', label: 'Agents', icon: Bot },
  { id: 'missions', label: 'Missions', icon: Target },
  { id: 'activity', label: 'Activity', icon: Activity },
] as const;
```

- [ ] **Step 2: Add mission navigation helpers to useAccountRouting**

Add to `navigateTo` and `getUrl` objects:
- `stationMissions()`, `stationMission(missionId)`, `stationMissionNew()`
- `stationActivity()`

- [ ] **Step 3: Add mission routes to App.tsx**

```typescript
<Route path="station/missions" element={<StationPage section="missions" />} />
<Route path="station/missions/new" element={<StationPage section="missions" />} />
<Route path="station/missions/:missionId" element={<StationPage section="missions" />} />
<Route path="station/missions/:missionId/bench/:benchId" element={<StationPage section="missions" />} />
<Route path="station/activity" element={<StationPage section="activity" />} />
```

Replace existing `monitoring` and `artifacts` routes with `activity`.

- [ ] **Step 4: Commit**

```bash
git add src/features/station/constants.ts src/shared/hooks/useAccountRouting.tsx src/App.tsx
git commit -m "feat(station): update tabs, navigation, and routes for Phase A"
```

---

### Task 11: StationShell Routing Updates

**Files:**
- Modify: `src/features/station/components/StationShell.tsx`

- [ ] **Step 1: Add lazy imports for new sections**

```typescript
const MissionsGrid = React.lazy(() => import('./missions/MissionsGrid').then(m => ({ default: m.MissionsGrid })));
const MissionWorkspace = React.lazy(() => import('./missions/MissionWorkspace').then(m => ({ default: m.MissionWorkspace })));
const ActivityView = React.lazy(() => import('./activity/ActivityView').then(m => ({ default: m.ActivityView })));
const AgentMindView = React.lazy(() => import('./mind/AgentMindView').then(m => ({ default: m.AgentMindView })));
```

- [ ] **Step 2: Update section routing logic**

Add `missions` and `activity` cases to the section renderer. When `section === 'missions'`, check for `:missionId` param to decide between MissionsGrid and MissionWorkspace. When `section === 'agents'` and `:agentId` param exists, render AgentMindView instead of AgentDetail.

- [ ] **Step 3: Commit**

```bash
git add src/features/station/components/StationShell.tsx
git commit -m "feat(station): update StationShell routing for missions, activity, mind view"
```

---

### Task 12: Agent Mind View — Level 1 Graph

**Files:**
- Create: `src/features/station/components/mind/AgentMindView.tsx`
- Create: `src/features/station/components/mind/MindGraph.tsx`
- Create: `src/features/station/components/mind/MindGraphNode.tsx`

- [ ] **Step 1: Build AgentMindView container**

Main container that:
- Fetches agent detail via `useAgentDetail(agentId)`
- Manages level state: `'graph' | MindRegion`
- When `level === 'graph'`: renders MindGraph + MindSidePanel
- When `level === region`: renders the appropriate region component + RegionHeader
- CSS transition between levels (opacity fade)

- [ ] **Step 2: Build MindGraph component**

CSS-positioned layout:
- Dark radial-gradient background (`bg-[radial-gradient(circle_at_50%_50%,#1a1a3a_0%,_var(--background)_70%)]`)
- Center: agent avatar circle (80px, teal gradient, agent emoji/avatar)
- 8 region nodes positioned in a circle around center using absolute positioning with `top`/`left` percentages
- SVG lines connecting each region to center (subtle, 1px, matching region color at 30% opacity)
- Click handler on each node → `setLevel(region.id)`

Node positions (percentages relative to container):
```typescript
const REGION_POSITIONS: Record<MindRegion, { top: string; left: string }> = {
  identity: { top: '15%', left: '20%' },
  knowledge: { top: '10%', left: '45%' },
  logic: { top: '15%', left: '70%' },
  tools: { top: '45%', left: '80%' },
  memories: { top: '75%', left: '70%' },
  planning: { top: '80%', left: '45%' },
  output: { top: '75%', left: '20%' },
  guardrails: { top: '45%', left: '10%' },
};
```

- [ ] **Step 3: Build MindGraphNode component**

Individual region node:
- Circular div with gradient background from `MindRegionConfig.bgGradient`
- Size: base 60px, scales up slightly based on content count (max 80px)
- Emoji icon centered
- Label below
- Count badge (top-right, small circle with number)
- `box-shadow` glow matching region color at 20% opacity
- Hover: scale 1.1, glow intensifies
- Click handler prop

- [ ] **Step 4: Commit**

```bash
git add src/features/station/components/mind/
git commit -m "feat(station): add AgentMindView with Level 1 CSS-positioned graph"
```

---

### Task 13: Agent Mind View — Side Panel

**Files:**
- Create: `src/features/station/components/mind/MindSidePanel.tsx`

- [ ] **Step 1: Build side panel**

Right panel (240px, collapsible) showing:
- **Quick stats section:** 3 glass-card stat boxes (Knowledge Items count from `useAgentItems`, Sessions 7d from `useAgentSessionStats`, Memories count from `useAgentMemories`)
- **Missions section:** List of missions this agent is in. Preferred approach: use `useListMissions(orgId)` and filter client-side where `mission_agents` includes this `agentId` (data is small enough — typically <20 missions per org). Each mission card shows name + status badge, clickable → navigateTo.stationMission.
- **Live session section:** If agent has a running session (from `useAgentSessions` filtered to status='running'), show streaming indicator + last log entry + token count. Otherwise show "Start session" button (placeholder for Phase A — no session runner yet).

- [ ] **Step 2: Commit**

```bash
git add src/features/station/components/mind/MindSidePanel.tsx
git commit -m "feat(station): add MindSidePanel with stats, missions, live session"
```

---

### Task 14: Agent Mind View — Region Components (Identity + Knowledge)

**Files:**
- Create: `src/features/station/components/mind/regions/IdentityRegion.tsx`
- Create: `src/features/station/components/mind/regions/KnowledgeRegion.tsx`
- Create: `src/features/station/components/mind/shared/RegionHeader.tsx`
- Create: `src/features/station/components/mind/shared/RegionEmptyState.tsx`

- [ ] **Step 1: Build RegionHeader**

Breadcrumb: `Station > Agents > {agentName} > {regionLabel}`. Back button (← or Escape) calls `onBack()` prop to return to Level 1.

- [ ] **Step 2: Build RegionEmptyState**

Centered empty state with region icon, "No {items} yet" message, and CTA button ("Add {item type}" or "Configure {region}").

- [ ] **Step 3: Build IdentityRegion**

Form-canvas for agent identity:
- Name field (text input, saves via `useUpdateAgent`)
- Avatar URL field (text input or upload placeholder)
- System prompt editor (textarea with monospace font, saves to agent.instructions)
- Status toggle (draft/active/paused)
- Guardrails summary (read-only cards showing current guardrail rules from agent.guardrails JSONB)

Uses glass-card styling, responsive layout.

- [ ] **Step 4: Build KnowledgeRegion**

Card grid of knowledge items:
- Fetches via `useAgentItems(agentId)` filtered to role='knowledge'
- Each card: item icon (based on type), title, type badge, created_at
- "+ Add Knowledge" button opens the existing `ItemLinker` component (from `src/features/station/components/shared/ItemLinker.tsx`) scoped to knowledge role
- "Remove" action on each card via `useUnlinkAgentItem`

- [ ] **Step 5: Commit**

```bash
git add src/features/station/components/mind/regions/ src/features/station/components/mind/shared/
git commit -m "feat(station): add Identity + Knowledge regions with shared RegionHeader"
```

---

### Task 15: Agent Mind View — Remaining Region Components

**Files:**
- Create: `src/features/station/components/mind/regions/LogicRegion.tsx`
- Create: `src/features/station/components/mind/regions/ToolsRegion.tsx`
- Create: `src/features/station/components/mind/regions/MemoriesRegion.tsx`
- Create: `src/features/station/components/mind/regions/PlanningRegion.tsx`
- Create: `src/features/station/components/mind/regions/OutputRegion.tsx`
- Create: `src/features/station/components/mind/regions/GuardrailsRegion.tsx`

- [ ] **Step 1: Build LogicRegion**

Same pattern as KnowledgeRegion but filtered to role='logic'. Shows flow items as cards with a "Open in Flow Editor" link that navigates via `navigateTo.flowEditor(itemId)`.

- [ ] **Step 2: Build ToolsRegion**

Card grid of tool items (role='targeting'). Each card has enable/disable toggle (visual only in Phase A — no actual tool integration yet). + button to attach tools.

- [ ] **Step 3: Build MemoriesRegion**

Uses existing `useAgentMemories(agentId)`. Groups memories by type (tabs or sections: long_term, short_term, entity, contextual). Short-term memories render with reduced opacity. Each memory is an expandable card (click to read full content). Manual add via `useAddMemory`. Delete via `useDeleteMemory`. Search input filters client-side.

- [ ] **Step 4: Build PlanningRegion**

Card grid of planning items (role='planning'). Shows project cards with status, progress bar, due dates. + button to link projects.

- [ ] **Step 5: Build OutputRegion**

Reuses the existing `ArtifactGallery` component from `src/features/station/components/artifacts/ArtifactGallery.tsx`, passing `agentId` prop to filter artifacts for this agent.

- [ ] **Step 6: Build GuardrailsRegion**

Renders `agent.guardrails` JSONB as rule cards. Each rule has a toggle (enabled/disabled) and threshold inputs. Changes save via `useUpdateAgent` updating the guardrails field. Predefined rule templates: token_limit, max_sessions_per_day, forbidden_topics, data_access_scope.

- [ ] **Step 7: Commit**

```bash
git add src/features/station/components/mind/regions/
git commit -m "feat(station): add Logic, Tools, Memories, Planning, Output, Guardrails regions"
```

---

### Task 16: Missions Grid

**Files:**
- Create: `src/features/station/components/missions/MissionsGrid.tsx`
- Create: `src/features/station/components/missions/MissionCard.tsx`
- Create: `src/features/station/components/missions/MissionFiltersBar.tsx`

- [ ] **Step 1: Build MissionCard**

Glass-card component showing:
- Name (font-semibold) + status badge (using MISSION_STATUS_CONFIG)
- Description (text-sm, truncated to 2 lines)
- Crew avatars (3 max, then "+N" overflow)
- Bench type badges (small pills)
- Progress bar (gradient fill)
- Click → navigateTo.stationMission(id)

Follow the exact pattern from `AgentCard.tsx`.

- [ ] **Step 2: Build MissionFiltersBar**

Search input + status dropdown + sort dropdown. Same pattern as `AgentFiltersBar.tsx`. Uses `useStationUI().missionFilters` and `setMissionFilters`.

- [ ] **Step 3: Build MissionsGrid**

Container with:
- Header row: "Missions" title + "+ New Mission" button
- MissionFiltersBar
- Card grid: `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3`
- Skeleton loader (6 placeholder cards)
- Empty state with "Create your first mission" CTA
- Uses `useListMissions()`

Follow the exact pattern from `AgentsGrid.tsx`.

- [ ] **Step 4: Commit**

```bash
git add src/features/station/components/missions/
git commit -m "feat(station): add MissionsGrid with MissionCard and filters"
```

---

### Task 17: Mission Creation Form

**Files:**
- Create: `src/features/station/components/missions/MissionCreateForm.tsx`

- [ ] **Step 1: Build creation form**

Simple form (not a wizard):
- Name input (required)
- Description textarea
- Objective textarea
- Project selector (optional — dropdown searching content.items where type='project')
- "Create Mission" button → `useCreateMission()` → navigate to workspace

Rendered as a glass-card dialog or inline form within the missions grid when route matches `/missions/new`.

- [ ] **Step 2: Commit**

```bash
git add src/features/station/components/missions/MissionCreateForm.tsx
git commit -m "feat(station): add MissionCreateForm with project linking"
```

---

### Task 18: Mission Workspace

**Files:**
- Create: `src/features/station/components/missions/MissionWorkspace.tsx`
- Create: `src/features/station/components/missions/MissionTopBar.tsx`
- Create: `src/features/station/components/missions/MissionSidebar.tsx`
- Create: `src/features/station/components/missions/CrewCard.tsx`
- Create: `src/features/station/components/missions/BenchCard.tsx`
- Create: `src/features/station/components/missions/BenchPreview.tsx`

- [ ] **Step 1: Build CrewCard**

Small card for crew sidebar: agent avatar (circular, gradient), name, role label (text-xs), status dot (working/idle). Click → `navigateTo.stationAgent(agentId)`.

- [ ] **Step 2: Build BenchCard**

Small card for bench sidebar: icon (based on item_type — use existing item type icons), name, assigned agent indicator. Active bench highlighted with accent border. Click → `setActiveBench(benchId)`.

- [ ] **Step 3: Build MissionSidebar**

Left sidebar (~200px):
- Crew section: header "Crew" + crew cards + "+ Add agent" button (opens agent search popover using existing `ItemLinker` pattern adapted for agents)
- Bench section: header "Benches" + bench cards + "+ Add bench" button (opens form: name + item_type selector)
- Collapsible via button

- [ ] **Step 4: Build MissionTopBar**

Top bar:
- Back arrow + "Missions" link
- Mission name (inline editable via click → input)
- Status badge (dropdown to change status)
- Progress bar
- Chat button (toggles `channelSlideOverOpen`)
- Deploy button (disabled with "Coming soon" tooltip)

- [ ] **Step 5: Build BenchPreview**

Main area content for the active bench:
- Bench header: name, item_type badge, version indicator (placeholder), "Open in Editor" button, "Approve" button (placeholder)
- Content area: If `item_id` exists, show a preview card with item title and thumbnail (or "Click to open in editor" CTA). If no `item_id`, show "Create or link an item for this bench" CTA.
- "Open in Editor" navigates to the appropriate editor route based on item_type

- [ ] **Step 6: Build MissionWorkspace container**

Three-zone layout:
- Fetches mission via `useMission(missionId)`, crew via `useMissionCrew(missionId)`, benches via `useMissionBenches(missionId)`
- Renders MissionTopBar + MissionSidebar + BenchPreview (or empty state if no bench selected)
- Layout: `flex` with sidebar + main area

- [ ] **Step 7: Commit**

```bash
git add src/features/station/components/missions/
git commit -m "feat(station): add MissionWorkspace with sidebar, crew, benches, preview"
```

---

### Task 19: Channel Slide-Over

**Files:**
- Create: `src/features/station/components/channels/ChannelSlideOver.tsx`
- Create: `src/features/station/components/channels/ChannelThread.tsx`
- Create: `src/features/station/components/channels/ChannelMessage.tsx`

- [ ] **Step 1: Build ChannelMessage**

Message bubble: avatar (user or agent icon), sender name, timestamp, content. Human messages right-aligned, agent messages left-aligned (or distinguished by background color).

- [ ] **Step 2: Build ChannelThread**

Message list + input:
- Scrollable message list (auto-scroll to bottom)
- Text input + send button
- Uses `useChannelMessages(channelId)` for data, `useSendMessage()` for posting
- Supabase Realtime subscription for live updates (subscribe to `station:channel:{channelId}` on mount, invalidate query on new message)

- [ ] **Step 3: Build ChannelSlideOver**

Slide-over panel (right side, ~320px):
- Channel tabs at top (list from `useChannels(missionId)`)
- Active channel's ChannelThread below
- "+ New Channel" button
- Close button

Visible when `channelSlideOverOpen` is true in store.

- [ ] **Step 4: Commit**

```bash
git add src/features/station/components/channels/
git commit -m "feat(station): add ChannelSlideOver with message thread and Realtime"
```

---

### Task 20: Activity View

**Files:**
- Create: `src/features/station/components/activity/ActivityView.tsx`

- [ ] **Step 1: Build merged monitoring + artifacts view**

Two-section layout:
- **Top: Metrics** — Reuses existing `MetricCard` components from `src/features/station/components/monitoring/`. Shows 4 stat cards (active agents, sessions, artifacts, cost). Uses `useStationMetrics()`.
- **Bottom: Recent activity** — Two-column grid:
  - Left: Recent sessions table (reuses existing `SessionsTable` from monitoring)
  - Right: Recent artifacts grid (reuses existing `ArtifactGallery` with limit)

This is primarily a composition component reusing existing monitoring + artifact components.

- [ ] **Step 2: Commit**

```bash
git add src/features/station/components/activity/ActivityView.tsx
git commit -m "feat(station): add ActivityView merging monitoring + artifacts"
```

---

### Task 21: Barrel Exports + Integration

**Files:**
- Modify: `src/features/station/index.ts`
- Modify: `src/features/station/components/StationShell.tsx` (if not done in Task 11)

- [ ] **Step 1: Update barrel exports**

Add exports for all new components, hooks, types, and services.

- [ ] **Step 2: Verify build**

```bash
npm run typecheck
```

Fix any TypeScript errors.

- [ ] **Step 3: Commit**

```bash
git add src/features/station/index.ts
git commit -m "feat(station): update barrel exports for Phase A components"
```

---

### Task 22: Header Tab Integration

**Files:**
- Modify: `src/features/dashboard/components/UnifiedDashboardHeader.tsx` (or wherever Station tabs are rendered)

- [ ] **Step 1: Update Station sub-tabs**

Update the Station tab's sub-tab list to use the new `STATION_TABS` constant (Agents, Missions, Activity). Remove the old tabs (Overview, Monitoring, Artifacts, Channels). Settings becomes a gear icon button rather than a tab.

- [ ] **Step 2: Verify navigation works end-to-end**

Test: Station tab → Agents sub-tab → click agent → Mind view loads. Station tab → Missions sub-tab → grid loads. Station tab → Activity sub-tab → merged view loads.

- [ ] **Step 3: Commit**

```bash
git add src/features/dashboard/components/UnifiedDashboardHeader.tsx
git commit -m "feat(station): consolidate header sub-tabs to Agents, Missions, Activity"
```

---

### Task 23: Final Integration + Smoke Test

- [ ] **Step 1: Run full type check**

```bash
npm run typecheck
```

- [ ] **Step 2: Run build**

```bash
npm run build
```

- [ ] **Step 3: Run dev server and manual smoke test**

```bash
npm run dev
```

Verify:
- Station tab shows 3 sub-tabs
- Agents grid loads, clicking agent shows Mind view with 8 regions
- Clicking a region shows the region content (or empty state)
- Side panel shows stats
- Missions grid loads, "+ New Mission" form works
- Mission workspace shows sidebar (crew + benches), main area shows bench preview
- Activity tab shows metrics + recent sessions/artifacts
- All navigation cross-links work (agent → mission, mission → agent)

- [ ] **Step 4: Fix any issues found**

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat(station): Phase A integration — Agent Mind + Missions system complete"
```

---

### Task 24: Drag-to-Attach Interaction (P1)

**Files:**
- Create: `src/features/station/components/mind/shared/ItemDropTarget.tsx`

- [ ] **Step 1: Build ItemDropTarget component**

A wrapper that handles HTML5 drag-and-drop events for attaching items to agent regions:
- `onDragOver` → highlight the region node (scale up, glow brighter)
- `onDrop` → extract item data from `dataTransfer`, call `useLinkAgentItem()` with the appropriate role based on the target region
- `onDragLeave` → reset visual state

The MindGraphNode component wraps its children in `ItemDropTarget` with the region's role mapping.

For the drag source: add `draggable` attribute to item cards in the MindSidePanel search results and in region dive-in views. Set `dataTransfer` with item id + type on `onDragStart`.

- [ ] **Step 2: Wire into MindGraph**

Update `MindGraphNode` to wrap in `ItemDropTarget`. Update `MindSidePanel` to make search results draggable.

- [ ] **Step 3: Commit**

```bash
git add src/features/station/components/mind/shared/ItemDropTarget.tsx src/features/station/components/mind/MindGraphNode.tsx src/features/station/components/mind/MindSidePanel.tsx
git commit -m "feat(station): add drag-to-attach interaction for Mind view regions"
```

---

### Task 25: Flow Canvas AI Mode — Agent Selection (P2, deferred if needed)

**Files:**
- Modify: `src/features/flows/hooks/useFlowCanvasAI.ts`
- Modify: `src/features/flows/contexts/FlowViewModeContext.tsx`

- [ ] **Step 1: Add agent selector to AI mode**

When AI mode is activated on the flow canvas, show a dropdown/popover that lets the user select an agent from their roster (fetched via `useAgents()`). The selected agent's id is passed to the chat session so it uses that agent's instructions and knowledge.

This is a lightweight change — the existing `useFlowCanvasAI` hook already manages chat sessions. Add an `agentId` parameter that gets passed to the session initialization. If no agent is selected, fall back to the generic AI session (current behavior).

- [ ] **Step 2: Commit**

```bash
git add src/features/flows/hooks/useFlowCanvasAI.ts src/features/flows/contexts/FlowViewModeContext.tsx
git commit -m "feat(station): connect flow canvas AI mode to agent roster selection"
```

---

### Task 26: Agent Conversational Creation — Path A (P2, deferred if needed)

**Files:**
- Modify: `src/features/station/components/mind/AgentMindView.tsx`

- [ ] **Step 1: Add conversational creation mode**

When `AgentMindView` loads for a brand new agent (no items, empty instructions):
- Identity region glows (animated border or pulsing opacity)
- Side panel auto-opens with a chat interface (reuse `ChannelThread` component pattern)
- Chat pre-populates with: "Tell me about this agent. What should it do?"
- User responses are saved as agent instructions (updates `agent.instructions` via `useUpdateAgent`)

This is a UX enhancement on top of the existing Mind view — not a separate component. The chat uses the existing agent session infrastructure.

- [ ] **Step 2: Commit**

```bash
git add src/features/station/components/mind/AgentMindView.tsx
git commit -m "feat(station): add conversational agent creation (Path A) in Mind view"
```

---

## Execution Notes

### Build Order

Tasks 1-3 (migrations) can run in parallel. Tasks 4-9 (types, services, hooks, store) depend on migrations being applied but can be built before applying them (types are frontend-only). Tasks 10-11 (routing) should come next. Tasks 12-20 (components) can be parallelized across the partner team:
- **Claude:** Tasks 1-3, 5-8, 10-11, 16-18 (backend + missions)
- **Static:** Tasks 12-15 (Agent Mind View)
- **4th agent:** Tasks 19-20 (channels + activity)
- **Near:** Research task (not in this plan — evaluating graph renderers)

Task 4 (types) and Task 9 (store) should be done first by whoever starts, as all other tasks depend on them.

### Testing

This plan focuses on building the functional skeleton. Tests should be added per the project's testing patterns (`src/test/` directory). Priority test targets:
- Service layer methods (mock Supabase RPC calls)
- Hook behavior (React Query setup, cache invalidation)
- Component rendering (Mind graph with mock agent data, mission cards)

### Design Iteration

Phase A delivers the structural skeleton. Visual polish (animations, glow effects, transitions) will be iterated in subsequent passes once Franc validates the UX flow.
