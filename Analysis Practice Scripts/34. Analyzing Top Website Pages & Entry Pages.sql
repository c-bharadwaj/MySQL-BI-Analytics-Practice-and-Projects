USE mavenfuzzyfactory;

SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE website_pageview_id < 1000 -- Arbitrary
GROUP BY pageview_url
ORDER BY pvs DESC;

SELECT *
FROM website_pageviews
WHERE website_pageview_id < 1000; -- Arbitrary

-- The concept of doing entry page analysisis that we just want to look at the pageview_url's 
-- that are the first pageview of a given website session. This is the place where the customer landed on your website,
-- a lot of times, your top entry pages is where mangers look to optimize.

-- In terms of the business problem, we will be looking for the website_session_id and try to find the first pageview that
-- that website_session_id sees.

SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
    FROM website_pageviews
    WHERE website_pageview_id < 1000 -- arbitrary
    GROUP BY website_session_id;

CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000 -- arbitrary
GROUP BY website_session_id;

SELECT
	website_pageviews.pageview_url AS landing_page,-- a.k.a "entry page"
    COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
    ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY 1;


