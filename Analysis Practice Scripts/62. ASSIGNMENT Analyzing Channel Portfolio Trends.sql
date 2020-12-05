-- Weekly session volume for gsearch and bsearch nonbrand broken down by device
-- Since 2012-11-04
-- Comparison Metric to show bsearch as a percentage of gsearch for each device

SELECT
	utm_source,
    device_type
FROM website_sessions
WHERE utm_source IN ('bsearch','gsearch')
GROUP BY 1,2;

-- Both gsearch and bsearch have mobile and desktop

SELECT
	-- YEARWEEK(ws.created_at) AS year_week,
    MIN(DATE(ws.created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN ws.utm_source ='gsearch' AND ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN ws.utm_source ='bsearch' AND ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS b_dtop_sessions,
	COUNT(DISTINCT CASE WHEN ws.utm_source ='bsearch' AND ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN ws.utm_source ='gsearch' AND ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
    COUNT(DISTINCT CASE WHEN ws.utm_source ='gsearch' AND ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS g_mob_sessions,
	COUNT(DISTINCT CASE WHEN ws.utm_source ='bsearch' AND ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS b_mob_sessions,
    COUNT(DISTINCT CASE WHEN ws.utm_source ='bsearch' AND ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN ws.utm_source ='gsearch' AND ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS b_pct_of_g_mob
FROM website_sessions ws
WHERE
	ws.utm_campaign = 'nonbrand'
    AND ws.created_at BETWEEN '2012-11-04' AND '2012-12-22'
GROUP BY YEARWEEK(ws.created_at);
    
   