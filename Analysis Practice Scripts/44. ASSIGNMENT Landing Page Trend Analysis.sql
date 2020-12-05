-- STEP 1 : finding the first website_pageview_id for relevant sessions
-- STEP 2 : identifying the landing page for each sesion
-- STEP 3 : counting pageviews for each session to identify "bounces"
-- STEP 4 : Summarizing by week (bounce rate, sessions to each lander)

CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count2
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
	website_sessions.created_at > '2012-06-01' -- asked by requestor
    AND website_sessions.created_at < '2012-08-31' -- date query / mail received from Morgan
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_pageviews.website_session_id;
  
SELECT * FROM sessions_w_min_pv_id_and_view_count2; -- Q A Check 

CREATE TEMPORARY TABLE session_w_counts_lander_and_created_at
SELECT
	sessions_w_min_pv_id_and_view_count2.website_session_id,
    sessions_w_min_pv_id_and_view_count2.first_pageview_id,
    sessions_w_min_pv_id_and_view_count2.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count2
	LEFT JOIN website_pageviews
		ON sessions_w_min_pv_id_and_view_count2.first_pageview_id = website_pageviews.website_pageview_id;

SELECT * FROM session_w_counts_lander_and_created_at; -- Q A Check

SELECT 
	-- YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
    -- COUNT(DISTINCT website_session_id) AS total_sessions, 
    -- COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM
	session_w_counts_lander_and_created_at
GROUP BY
	YEARWEEK(session_created_at);



