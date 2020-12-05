/* 	Sessions which hit the /products page and see where they went next
	Pull clickthrough rates from /products since the new product launch on January 6th 2013 by product
    Compare to 3 months leading up to launch as a baseline
    Pre product launch from '2012-10-06' to '2013-01-06'
    Post product launcg from '2013-01-06' to '2013-04-06' */
    
-- STEP 1: find the relevant /products pageviews with website_session_id
-- STEP 2: find the NEXT pageview_id that occers AFTER the product pageview
-- STEP 3: find the pageview_url associated with any applicable next pageview_id
-- STEP 4: summarize the data and analyze the pre vs post periods

-- STEP 1: find the relevant /products pageviews with website_session_id

CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
    CASE
		WHEN created_at < '2013-01-06' THEN 'A. Pre_Product_2'
        WHEN created_at >= '2013-01-06' THEN 'B. Post_Product_2'
        ELSE 'uh oh...check logic'
	END AS time_period
FROM website_pageviews
WHERE created_at < '2013-04-06' -- Date of request
	AND created_at > '2012-10-06' -- 3 months before product 2 launch
    AND pageview_url = '/products';
    
SELECT * FROM products_pageviews;

-- STEP 2: find the NEXT pageview_id that occers AFTER the product pageview

CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT 
	pp.time_period,
    pp.website_session_id,
    MIN(wp.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews pp
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id = pp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
GROUP BY 1,2;

SELECT * FROM sessions_w_next_pageview_id;

-- STEP 3: find the pageview_url associated with any applicable next pageview_id

CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT
	sid.time_period,
    sid.website_session_id,
    wp.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id sid
	LEFT JOIN website_pageviews wp
		ON wp.website_pageview_id = sid.min_next_pageview_id;

SELECT * FROM sessions_w_next_pageview_url;

-- STEP 4: summarize the data and analyze the pre vs post periods

SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM sessions_w_next_pageview_url
GROUP BY 1;


	