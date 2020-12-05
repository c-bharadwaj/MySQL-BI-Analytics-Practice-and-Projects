SELECT 
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.website_session_id) AS orders,
    (COUNT(DISTINCT orders.website_session_id)/COUNT(DISTINCT website_sessions.website_session_id))*100 AS session_to_order_cvr_rate
FROM website_sessions
	LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11' -- Date when I received Tom's email.
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
	website_sessions.device_type
ORDER BY sessions DESC;
