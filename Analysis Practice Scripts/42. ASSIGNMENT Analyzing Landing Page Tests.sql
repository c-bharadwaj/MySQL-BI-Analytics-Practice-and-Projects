-- STEP 0 : Find out when the new page / lander launched
-- STEP 1 : finding the first_website_pageview_id for relevant sessions
-- STEP 2 : identifying the landing page of each session
-- STEP 3 : counting pageviews for each session, to identify "bounces"
-- STEP 4 : summarizing total sessions and bounced sessionsby LP

-- STEP 0 : Find out when the new page / lander launched

SELECT 
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL;

-- first_created_at = '2012-06-18 22:35:54'
-- first_pageview_id = 23504

-- STEP 1 : finding the first_website_pageview_id for relevant sessions

CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
		AND website_sessions.created_at < '2012-07-28'
		AND website_pageviews.website_pageview_id > 23504
		AND website_sessions.utm_source = 'gsearch'
		AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id;

SELECT * FROM first_test_pageviews;

-- STEP 2 : identifying the landing page of each session

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT 
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.first_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

SELECT * FROM nonbrand_test_sessions_w_landing_page;

-- STEP 3 : counting pageviews for each session, to identify "bounces"

CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
GROUP BY
	nonbrand_test_sessions_w_landing_page.website_session_id,
	nonbrand_test_sessions_w_landing_page.landing_page
HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;
    
SELECT * FROM nonbrand_test_bounced_sessions; -- Do this first to show, and count them after.

-- STEP 4 : summarizing total sessions and bounced sessions

SELECT
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
	(COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id))*100 AS bounce_rate
    FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY
	nonbrand_test_sessions_w_landing_page.landing_page;
