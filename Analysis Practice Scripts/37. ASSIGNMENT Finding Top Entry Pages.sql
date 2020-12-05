-- Question : Pull all entry pages and rank them on entry volume as on 2012-06-12

SELECT * 
FROM website_pageviews
WHERE created_at < '2012-06-12';

-- STEP 1 : Find the first pageview for each website session
-- STEP 2 : Find the url that the customer saw on the first pageview

CREATE TEMPORARY TABLE first_pageview_table
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS first_pageview
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT * FROM first_pageview_table;

SELECT
	website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pageview_table.website_session_id) AS sessions_hitting_page
FROM first_pageview_table
	LEFT JOIN website_pageviews
	ON first_pageview_table.first_pageview = website_pageviews.website_pageview_id
WHERE created_at < '2012-06-12'
GROUP BY 1;

    


