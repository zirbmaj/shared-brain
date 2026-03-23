-- Post-Launch Analytics Queries
-- Run these after 48+ hours of real traffic

-- 1. DAY 1 RETENTION: did people come back?
SELECT
  COUNT(DISTINCT day1.user_id) as day1_users,
  COUNT(DISTINCT day2.user_id) as returned_users,
  ROUND(COUNT(DISTINCT day2.user_id)::numeric / NULLIF(COUNT(DISTINCT day1.user_id), 0) * 100, 1) as retention_pct
FROM (
  SELECT DISTINCT user_id FROM analytics_events
  WHERE created_at::date = CURRENT_DATE - 1 AND user_id IS NOT NULL
) day1
LEFT JOIN (
  SELECT DISTINCT user_id FROM analytics_events
  WHERE created_at::date = CURRENT_DATE AND user_id IS NOT NULL
) day2 ON day1.user_id = day2.user_id;

-- 2. REAL HUMANS ONLY (post bot-filter, but double check)
SELECT project, event, COUNT(*) as total
FROM analytics_events
WHERE user_agent NOT ILIKE '%bot%'
  AND user_agent NOT ILIKE '%headless%'
  AND user_agent NOT ILIKE '%vercel%'
GROUP BY project, event
ORDER BY total DESC;

-- 3. FUNNEL: landing → app → interaction
SELECT
  SUM(CASE WHEN event = 'pageview' AND data->>'page' = '/' THEN 1 ELSE 0 END) as landing_views,
  SUM(CASE WHEN event = 'pageview' AND data->>'page' = '/app.html' THEN 1 ELSE 0 END) as app_views,
  SUM(CASE WHEN event = 'layer_activate' THEN 1 ELSE 0 END) as interactions
FROM analytics_events WHERE project = 'drift';

-- 4. MOST POPULAR LAYERS (post-launch)
SELECT data->>'layer' as layer, COUNT(*) as activations
FROM analytics_events
WHERE event = 'layer_activate' AND project = 'drift'
GROUP BY data->>'layer'
ORDER BY activations DESC;

-- 5. SESSION COMPLETION RATE (north star metric)
SELECT
  COUNT(*) FILTER (WHERE event = 'session_start') as started,
  COUNT(*) FILTER (WHERE event = 'session_complete') as completed,
  ROUND(COUNT(*) FILTER (WHERE event = 'session_complete')::numeric /
    NULLIF(COUNT(*) FILTER (WHERE event = 'session_start'), 0) * 100, 1) as completion_rate
FROM analytics_events WHERE project = 'dashboard';

-- 6. REFERRER BREAKDOWN (where are people coming from?)
SELECT referrer, COUNT(*) as visits
FROM analytics_events
WHERE referrer IS NOT NULL AND referrer != ''
GROUP BY referrer
ORDER BY visits DESC LIMIT 20;

-- 7. HOURLY USAGE PATTERN (CST)
SELECT
  EXTRACT(HOUR FROM created_at AT TIME ZONE 'America/Chicago') as hour_cst,
  COUNT(*) as events,
  COUNT(DISTINCT session_id) as sessions
FROM analytics_events WHERE project = 'drift'
GROUP BY hour_cst
ORDER BY hour_cst;
