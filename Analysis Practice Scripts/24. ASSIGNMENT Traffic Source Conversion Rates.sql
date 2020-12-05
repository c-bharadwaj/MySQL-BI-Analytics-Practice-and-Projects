SELECT 
	website_sessions.utm_source,	 
	website_sessions.utm_campaign,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.website_session_id) AS orders,
    (COUNT(DISTINCT orders.website_session_id)/COUNT(DISTINCT website_sessions.website_session_id))*100 AS session_to_order_cvr_rate
FROM website_sessions
	LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14' -- Date when I received Tom's email.
GROUP BY 
	website_sessions.utm_source,	 
	website_sessions.utm_campaign,
    website_sessions.http_referer
ORDER BY sessions DESC;

-- CVR rate is less than 4% so we have to reduce the bids.
-- Monitor the impact of bid reductions
-- Analyze performance trending by device type in order to refine bidding strategy.

SELECT 
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.website_session_id) AS orders,
    (COUNT(DISTINCT orders.website_session_id)/COUNT(DISTINCT website_sessions.website_session_id))*100 AS session_to_order_cvr_rate
FROM website_sessions
	LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14' -- Date when I received Tom's email.
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
	website_sessions.utm_source,	 
	website_sessions.utm_campaign,
    website_sessions.http_referer
ORDER BY sessions DESC;
