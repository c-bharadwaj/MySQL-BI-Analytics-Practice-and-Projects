/* As on 2013-01-02
2012's monthly and weekly volume patterns
Find session volume and order volume */

SELECT
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
WHERE
	ws.created_at BETWEEN '2012-01-01' AND '2012-12-31'
GROUP BY
	1,2;
    
SELECT
	MIN(DATE(ws.created_at)) AS week_start_date,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
WHERE
	ws.created_at BETWEEN '2012-01-01' AND '2012-12-31'
GROUP BY YEARWEEK(ws.created_at);



