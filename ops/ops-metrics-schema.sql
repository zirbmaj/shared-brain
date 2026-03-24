-- Ops Metrics Schema
-- Created: 2026-03-24 session 7
-- Owner: Claude (engineering) + Relay (ops)
-- Purpose: Track team performance, resource usage, and session outcomes
-- Populated by: Relay's ops toolkit (haiku subagent at offramp)

-- Session-level metrics
CREATE TABLE IF NOT EXISTS ops_sessions (
    id SERIAL PRIMARY KEY,
    session_number INTEGER NOT NULL UNIQUE,
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    duration_minutes INTEGER,
    prs_opened INTEGER DEFAULT 0,
    prs_merged INTEGER DEFAULT 0,
    deploy_count INTEGER DEFAULT 0,
    deploy_limit_hit BOOLEAN DEFAULT FALSE,
    deploy_lag_hours NUMERIC(6,2) DEFAULT 0,
    playwright_pass INTEGER DEFAULT 0,
    playwright_total INTEGER DEFAULT 0,
    mobile_viewport_pass INTEGER DEFAULT 0,
    mobile_viewport_total INTEGER DEFAULT 0,
    bugs_found INTEGER DEFAULT 0,
    bugs_fixed INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Per-agent per-session metrics
CREATE TABLE IF NOT EXISTS ops_agent_metrics (
    id SERIAL PRIMARY KEY,
    agent_name TEXT NOT NULL,
    session_number INTEGER NOT NULL REFERENCES ops_sessions(session_number),
    commits INTEGER DEFAULT 0,
    prs_authored INTEGER DEFAULT 0,
    prs_reviewed INTEGER DEFAULT 0,
    bugs_found INTEGER DEFAULT 0,
    bugs_fixed INTEGER DEFAULT 0,
    carries_in INTEGER DEFAULT 0,
    carries_out INTEGER DEFAULT 0,
    carries_blocked INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(agent_name, session_number)
);

-- Resource consumption tracking
CREATE TABLE IF NOT EXISTS ops_resources (
    id SERIAL PRIMARY KEY,
    session_number INTEGER REFERENCES ops_sessions(session_number),
    resource_name TEXT NOT NULL,
    current_usage NUMERIC DEFAULT 0,
    resource_limit NUMERIC DEFAULT 0,
    percentage NUMERIC(5,2) DEFAULT 0,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies (anon read, service role write)
ALTER TABLE ops_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops_agent_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE ops_resources ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ops_sessions_read" ON ops_sessions FOR SELECT TO anon USING (true);
CREATE POLICY "ops_sessions_write" ON ops_sessions FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "ops_sessions_update" ON ops_sessions FOR UPDATE TO anon USING (true);

CREATE POLICY "ops_agent_metrics_read" ON ops_agent_metrics FOR SELECT TO anon USING (true);
CREATE POLICY "ops_agent_metrics_write" ON ops_agent_metrics FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "ops_agent_metrics_update" ON ops_agent_metrics FOR UPDATE TO anon USING (true);

CREATE POLICY "ops_resources_read" ON ops_resources FOR SELECT TO anon USING (true);
CREATE POLICY "ops_resources_write" ON ops_resources FOR INSERT TO anon WITH CHECK (true);

-- Useful queries:
-- Session velocity trend: SELECT session_number, prs_merged, bugs_fixed, deploy_lag_hours FROM ops_sessions ORDER BY session_number;
-- Agent contributions: SELECT agent_name, SUM(prs_authored) as total_prs, SUM(bugs_found) as total_bugs FROM ops_agent_metrics GROUP BY agent_name;
-- Resource burn rate: SELECT resource_name, percentage, recorded_at FROM ops_resources WHERE percentage > 80 ORDER BY recorded_at DESC;
-- Carry rate: SELECT agent_name, SUM(carries_out) as total_carries, SUM(carries_blocked) as blocked FROM ops_agent_metrics GROUP BY agent_name;
