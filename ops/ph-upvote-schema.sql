-- Product Hunt Upvote Tracking Schema
-- Created: 2026-03-24, session 7 (static)
-- Purpose: launch day upvote monitoring + traffic correlation
-- Tracker script: static-workspace/ph-upvote-tracker.mjs

-- Table: raw upvote polls
CREATE TABLE ph_upvotes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  upvotes INT NOT NULL,
  comments INT DEFAULT 0,
  rank INT,
  milestone TEXT,
  raw_json JSONB
);

ALTER TABLE ph_upvotes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon can insert" ON ph_upvotes FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon can read" ON ph_upvotes FOR SELECT TO anon USING (true);
CREATE INDEX idx_ph_upvotes_recorded_at ON ph_upvotes (recorded_at DESC);

-- View: upvotes vs site traffic in 5-min buckets (launch day correlation)
CREATE OR REPLACE VIEW ph_launch_correlation AS
WITH upvote_windows AS (
  SELECT
    DATE_TRUNC('hour', recorded_at) +
      (FLOOR(EXTRACT(MINUTE FROM recorded_at) / 5) * INTERVAL '5 minutes') AS time_bucket,
    MAX(upvotes) AS upvotes,
    MAX(comments) AS comments,
    MAX(upvotes) - LAG(MAX(upvotes)) OVER (ORDER BY DATE_TRUNC('hour', recorded_at) +
      (FLOOR(EXTRACT(MINUTE FROM recorded_at) / 5) * INTERVAL '5 minutes')) AS upvote_delta
  FROM ph_upvotes
  GROUP BY 1
),
traffic_windows AS (
  SELECT
    DATE_TRUNC('hour', created_at) +
      (FLOOR(EXTRACT(MINUTE FROM created_at) / 5) * INTERVAL '5 minutes') AS time_bucket,
    COUNT(*) AS events,
    COUNT(DISTINCT session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN event = 'layer_activate' THEN session_id END) AS activated,
    COUNT(DISTINCT CASE WHEN data->>'utm_source' = 'producthunt' THEN session_id END) AS ph_sessions
  FROM analytics_events
  WHERE created_at >= CURRENT_DATE
  GROUP BY 1
)
SELECT
  COALESCE(u.time_bucket, t.time_bucket) AS time_bucket,
  u.upvotes,
  u.comments,
  u.upvote_delta,
  t.events,
  t.sessions,
  t.activated,
  t.ph_sessions
FROM upvote_windows u
FULL OUTER JOIN traffic_windows t ON u.time_bucket = t.time_bucket
ORDER BY time_bucket;
