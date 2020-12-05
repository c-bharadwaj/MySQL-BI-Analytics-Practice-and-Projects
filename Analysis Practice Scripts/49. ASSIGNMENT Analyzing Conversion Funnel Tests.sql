-- 1. See whether /billing-2 is doing any better than /billing
-- 2. What % of sessions on those pages end up placing an order - (all traffic)
-- 3. Date request received - '2012-11-10'

-- first, find the starting point to frame the analysis:

SELECT
	MIN(website_pageviews.website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2';

-- first pv id is 53550

-- first we will look at this without orders and then add orders

SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id > 53550 -- first pageview id where test was live
	AND website_pageviews.created_at < '2012-11-10' -- time of assignment
    AND website_pageviews.pageview_url IN ('/billing', '/billing-2');
    
-- now we will take the above query and make it a subquery for the final output and summarize.

SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS billing_to_order_rt
FROM (
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id > 53550 -- first pageview id where test was live
	AND website_pageviews.created_at < '2012-11-10' -- time of assignment
    AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
    ) AS billing_sessions_with_orders
GROUP BY billing_version_seen;


