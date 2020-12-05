-- STEP 1 : Find first pageview id and url for each session

CREATE TEMPORARY TABLE first_website_pageview_table
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_website_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

SELECT * FROM first_website_pageview_table;

-- STEP 2 : Find the url with the maximum number of landing hits

SELECT 
	website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_website_pageview_table.website_session_id) AS sessions_hitting_page
FROM first_website_pageview_table
	LEFT JOIN website_pageviews
	ON  first_website_pageview_table.first_website_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.created_at < '2012-06-14'
GROUP BY 1;

-- STEP 3: Identifying the landing page for each session

CREATE TABLE session_w_landing_page
SELECT 
	first_website_pageview_table.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_website_pageview_table
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_website_pageview_table.first_website_pageview_id
WHERE website_pageviews.pageview_url = '/home';

SELECT * FROM session_w_landing_page;

-- STEP 4: Table to have count of pageviews per session then limit it to just bounced_sessions

CREATE TEMPORARY TABLE bounced_sessions
SELECT
	session_w_landing_page.website_session_id,
    session_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM session_w_landing_page
	LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = session_w_landing_page.website_session_id
GROUP BY
	session_w_landing_page.website_session_id,
    session_w_landing_page.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;
    
    SELECT * FROM bounced_sessions;
    
-- STEP 5 :

SELECT
	COUNT(DISTINCT session_w_landing_page.website_session_id) AS sessions,
	COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_website_session_id,
    COUNT(DISTINCT bounced_sessions.website_session_id) / COUNT(DISTINCT session_w_landing_page.website_session_id) AS bounce_rate
FROM session_w_landing_page
	LEFT JOIN bounced_sessions
	ON session_w_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY
	session_w_landing_page.website_session_id;

