/* 
													MID AND FINAL COURSE PROJECT
														
SITUATION: 
I have just been hired as an eCommerce Database Analyst for Maven Fuzzy Factory an online retailer startup selling teddy bears and as a member 
of the startup team, I will be helping the CEO, Marketing Director and Website Manager to help steer the business.

PROJECT OVERVIEW:
In the mid and final course project, I will be helping the hypothetical CEO of Maven Fuzzy Factory prepare for a Board Meeting by analyizing 
relevant business metrics. This project's tasks have been structured into a list of questions/queries from the CEO, followed by the SQL code 
used to retrieve the information asked.

DATABASE: 
mavenfuzzyfactory 

*/

------------------------------------------------------------------------------------

/* Q1. 
As on '2012-11-27' 
Gsearch seems to be the biggest driver of our business. 
Could you pull "monthly trends" for "gsearch sessions and orders" so that we can showcase the growth there? */

SELECT
	YEAR(website_sessions.created_at) AS Yr,
    MONTH(website_sessions.created_at) AS Mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS order_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE
	website_sessions.created_at < '2012-11-27'
    AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

/* Q2. 
As on '2012-11-27' 
Next it would be great to see a similar "monthly trend" for "Gsearch"  but this time splitting out "nonbrand and brand" campaigns separately.
Check if "brand" is picking up at all.
*/

SELECT
	YEAR(website_sessions.created_at) AS year,
    MONTH(website_sessions.created_at) AS month,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
    -- ROUND(COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END)*100,2) AS brand_rate,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders
    -- ROUND(COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END)*100,2) AS nonbrand_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE 
	website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign IN ('brand','nonbrand')
    AND website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

/* Q3. 
As on '2012-11-27' 
While we’re on "Gsearch", could you dive into "nonbrand", and pull "monthly sessions" and orders "split by device type"? 
I want to flex our analytical muscles a little and show the board we really know our traffic sources.
*/

SELECT DISTINCT device_type FROM website_sessions; -- There are only two device types - mobile and desktop

SELECT 	
	YEAR(website_sessions.created_at) AS Yr,
    MONTH(website_sessions.created_at) AS Mo,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN orders.order_id END) AS desktop_orders,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN orders.order_id END) AS mobile_orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE
	website_sessions.utm_source = 'gsearch' and 
    website_sessions.utm_campaign = 'nonbrand' and 
    website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

/* Q4. 
As on '2012-11-27' 
I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
Can you pull "monthly trends" for "Gsearch", alongside "monthly trends" for each of our "other channels"?
*/

SELECT
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-11-27'; -- 51154 Total Sessions

SELECT
	DISTINCT website_sessions.utm_source,
	website_sessions.http_referer
FROM website_sessions
WHERE created_at < '2012-11-27'; -- gsearch, bsearch, organic, direct type-in

SELECT
	YEAR(website_sessions.created_at) AS Year,
    MONTH(website_sessions.created_at) AS Month,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS typed_in_sessions
FROM website_sessions
WHERE created_at < '2012-11-27'
GROUP BY 1,2;

/* Q5. 
As on '2012-11-27' 
I’d like to tell the story of our website performance improvements over the course of the first 8 months. 
Could you pull session to order conversion rates, by month?
*/

SELECT 
	YEAR(website_sessions.created_at) AS Year,
    MONTH(website_sessions.created_at) AS Month,
    COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
    COUNT(DISTINCT orders.order_id) AS Orders,
    ROUND((COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id))*100,2) AS Conversion_Rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE 
	website_sessions.created_at < '2012-11-27'
GROUP BY
	1,2;

/* Q6. 
As on '2012-11-27' 
For the gsearch lander test, please estimate the revenue that test earned us. (Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), 
and use nonbrand sessions and revenue since then to calculate incremental value)
*/

-- 1. Find the minimum pageview_id when the test started.
-- 2. Find the session level first pageviews and create temporary table
-- 3. We will bring in the landing page for each session, limiting to /home and /lander-1 and make temporary table
-- 4. Then we will make a temporary table to bring in orders
-- 5. Find difference between conversion rates
-- 6. Finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home.
-- 7. See how many sessions we have since that test.


-- 1. Find the minimum pageview_id when the test started.
SELECT
	MIN(website_pageview_id) as first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1'; 
-- 23504

-- 2. Find the session level first pageviews and create temporary table

CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id 
WHERE
	website_pageviews.website_pageview_id >= 23504
    AND website_sessions.created_at < '2012-07-28'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1;

SELECT * FROM first_test_pageviews;

-- 3. We will bring in the landing page for each session, limiting to /home and /lander-1 and make temporary table

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages2
SELECT
	first_test_pageviews.website_session_id,
    first_test_pageviews.min_pageview_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
    ON first_test_pageviews.min_pageview_id = website_pageviews.website_pageview_id
WHERE 
	website_pageviews.pageview_url IN ('/home', '/lander-1');

SELECT * FROM nonbrand_test_sessions_w_landing_pages2;
    
-- 4. Then we will make a temporary table to bring in orders

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
	nonbrand_test_sessions_w_landing_pages2.website_session_id,
    nonbrand_test_sessions_w_landing_pages2.landing_page,
    orders.order_id AS order_id
FROM nonbrand_test_sessions_w_landing_pages2
	LEFT JOIN orders
		ON orders.website_session_id = nonbrand_test_sessions_w_landing_pages2.website_session_id;
        
SELECT * FROM nonbrand_test_sessions_w_orders;

-- 5. Find difference between conversion rates

SELECT
	nonbrand_test_sessions_w_orders.landing_page,
	COUNT(DISTINCT nonbrand_test_sessions_w_orders.website_session_id) AS sessions,
    COUNT(DISTINCT nonbrand_test_sessions_w_orders.order_id) AS orders,
    COUNT(DISTINCT nonbrand_test_sessions_w_orders.order_id)/COUNT(DISTINCT nonbrand_test_sessions_w_orders.website_session_id) AS Conv_Rate
FROM nonbrand_test_sessions_w_orders
GROUP BY 1;

-- 6. Finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home.

SELECT
	MAX(ws.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id = ws.website_session_id
WHERE ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
AND wp.pageview_url = '/home'
AND ws.created_at < '2012-11-27';

-- MAX ws.website_session_id = 17145 that went to /home. Since then, all traffic has been rerouted elsewhere.

-- 7. See how many sessions we have since that test.

SELECT
	COUNT(ws.website_session_id) AS sessions_since_test
FROM website_sessions ws
WHERE ws.created_at < '2012-11-27'
AND ws.website_session_id > 17145
AND ws.utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'; 

-- 22980 website sessions since test so 22,972 * 0.0087 incremental conversion is 200 incremental orders since 7/29
-- Roughly 4 months, so 200/4 = 50 orders per month increment which is not bad.

/*Q7. 
First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter for the life of the business? 
Since the most recent quarter is incomplete, you can decide how to handle it.
*/ 

SELECT
	YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
GROUP BY 1,2;

/*Q8.
Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures 
since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. 
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr, 
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate, 
    SUM(price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order, 
    SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions 
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2
;

/*Q9.
I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders 
from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_orders, 
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_orders, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in_orders
    
FROM website_sessions 
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2
;

/*Q10.
Next, let’s show the overall session-to-order conversion rate trends for those same channels, 
by quarter. Please also make a note of any periods where we made major improvements or optimizations.
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt, 
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions 
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2
;

/*Q11.
We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
*/

SELECT
	YEAR(created_at) AS yr, 
    MONTH(created_at) AS mo, 
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,  
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items 
GROUP BY 1,2
ORDER BY 1,2
;

/*Q12.
Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to 
the /products page, and show how the % of those sessions clicking through another page has changed 
over time, along with a view of how conversion from /products to placing an order has improved.
*/

-- 1. Identifying all the views of the /products page
CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id, 
    website_pageview_id, 
    created_at AS saw_product_page_at

FROM website_pageviews 
WHERE pageview_url = '/products'
;


SELECT 
	YEAR(saw_product_page_at) AS yr, 
    MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page, 
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page, 
    COUNT(DISTINCT website_pageviews.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM products_pageviews
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = products_pageviews.website_session_id -- same session
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id -- they had another page AFTER
	LEFT JOIN orders 
		ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2
;

/*Q13.
We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). 
Could you please pull sales data since then, and show how well each product cross-sells from one another?
*/

CREATE TEMPORARY TABLE primary_products
SELECT 
	order_id, 
    primary_product_id, 
    created_at AS ordered_at
FROM orders 
WHERE created_at > '2014-12-05' -- when the 4th product was added (says so in question)
;

SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0; -- only bringing in cross-sells;

SELECT 
	primary_product_id, 
    COUNT(DISTINCT order_id) AS total_orders, 
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM
(
SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0 -- only bringing in cross-sells
) AS primary_w_cross_sell
GROUP BY 1;

    






