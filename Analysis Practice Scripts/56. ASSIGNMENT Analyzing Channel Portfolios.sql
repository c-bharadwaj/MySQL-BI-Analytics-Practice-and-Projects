-- bsearch 2012-08-22
-- weekly trended session volume compared to gsearch nonbrand

SELECT
	-- YEARWEEK(website_sessions.created_at) AS yrwk,
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gserach_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_to_bsearch_rate
FROM website_sessions
WHERE
	website_sessions.created_at > '2012-08-22'
    AND website_sessions.created_at < '2012-11-29'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);

