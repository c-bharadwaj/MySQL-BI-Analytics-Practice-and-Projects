-- As on '2013-11-22' - Date of Request
-- From '2013-09-25' - Cross sell products made available to customers
-- Month before and month after change - '2013-08-25' to '2013-10-25'
-- 1. CTR from /cart_page,
-- 2. Average Products per Order
-- 3. AOV
-- 4. Overall revenue per /cart_page view.

-- STEP 1: Identify the relevant /cart page views and their sessions
-- STEP 2: See which of those /cart sessions clicked through to the shipping page
-- STEP 3: Find the orders associated with the cart sessions. Analyze products purchased and AOV
-- STEP 4: Aggregate and analyze a summary of our findings.

-- STEP 1:

CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT
	CASE 
		WHEN created_at < '2013-09-25' THEN 'A. Pre_Cross_Sell'
        WHEN created_at >= '2013-09-25' THEN 'B. Post_Cross_Sell'
        ELSE 'uh oh...check logic'
	END AS time_period,
    website_session_id AS cart_session_id,
    website_pageview_id AS cart_pageview_id
FROM website_pageviews
WHERE 
	created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url = '/cart';
    
SELECT * FROM sessions_seeing_cart;

-- STEP 2:

CREATE TEMPORARY TABLE cart_sessions_seeing_another_page
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    MIN(website_pageviews.website_pageview_id) AS pv_id_after_cart
FROM sessions_seeing_cart
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_cart.cart_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id
GROUP BY 
	1,2
HAVING 
	MIN(website_pageviews.website_pageview_id) IS NOT NULL;

SELECT * FROM cart_sessions_seeing_another_page;

-- STEP 3:

CREATE TEMPORARY TABLE pre_post_session_orders
SELECT
	ssc.time_period,
    ssc.cart_session_id,
    o.order_id,
    o.items_purchased,
    o.price_usd
FROM
	sessions_seeing_cart ssc
		INNER JOIN orders o	
			ON ssc.cart_session_id = o.website_session_id;

SELECT * FROM pre_post_session_orders;

-- STEP 4.1: Sub Query

SELECT 
	sessions_seeing_cart.time_period,
	sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_session_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_session_orders.items_purchased,
    pre_post_session_orders.price_usd
FROM sessions_seeing_cart
	LEFT JOIN cart_sessions_seeing_another_page
		ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
	LEFT JOIN pre_post_session_orders
		ON sessions_seeing_cart.cart_session_id = pre_post_session_orders.cart_session_id
ORDER BY
	sessions_seeing_cart.cart_session_id; 

-- STEP 4.2: 

SELECT
	time_period,
	COUNT(DISTINCT cart_session_id) AS cart_sessions,
	SUM(clicked_to_another_page) AS clickthroughs,
	SUM(clicked_to_another_page)/COUNT(DISTINCT cart_session_id) AS cart_ctr,
	SUM(placed_order) AS orders_placed,
	SUM(items_purchased) AS products_purchased,
	SUM(items_purchased)/SUM(placed_order) AS products_per_order,
	SUM(price_usd) AS revenue,
	SUM(price_usd)/SUM(placed_order) AS AOV,
	SUM(price_usd)/COUNT(DISTINCT cart_session_id) AS rev_per_cart_session
FROM (
	SELECT 
		sessions_seeing_cart.time_period,
		sessions_seeing_cart.cart_session_id,
	    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
	    CASE WHEN pre_post_session_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
	    pre_post_session_orders.items_purchased,
	    pre_post_session_orders.price_usd
	FROM sessions_seeing_cart
		LEFT JOIN cart_sessions_seeing_another_page
			ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
		LEFT JOIN pre_post_session_orders
			ON sessions_seeing_cart.cart_session_id = pre_post_session_orders.cart_session_id
	ORDER BY
		sessions_seeing_cart.cart_session_id
) AS full_data
GROUP BY 1;

    

