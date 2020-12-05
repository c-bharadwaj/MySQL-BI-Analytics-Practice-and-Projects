SELECT 
	website_sessions.utm_source,	 
	website_sessions.utm_campaign,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.website_session_id) AS orders,
    (COUNT(DISTINCT orders.website_session_id)/COUNT(DISTINCT website_sessions.website_session_id))*100 AS session_to_order_cvr_rate
FROM website_sessions
	LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-15' -- Date when I received Tom's email.
GROUP BY 
	website_sessions.utm_source,	 
	website_sessions.utm_campaign,
    website_sessions.http_referer
ORDER BY sessions DESC;

SELECT
	MIN(DATE(created_at)) AS week_started_at,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
    WEEK(created_at);
		
	
