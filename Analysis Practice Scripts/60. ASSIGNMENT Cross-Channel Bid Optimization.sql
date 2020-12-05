SELECT
	ws.device_type,
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
FROM
	website_sessions ws
		LEFT JOIN orders o
			ON o.website_session_id = ws.website_session_id
WHERE
	ws.utm_campaign = 'nonbrand'
    AND ws.created_at >= '2012-08-22'
    AND ws.created_at <= '2012-09-19'
GROUP BY 1,2;