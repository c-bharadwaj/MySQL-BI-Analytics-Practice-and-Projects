/* bearch nonbrand campaign - percentage of traffic coming on mobile compared to gsearch
Aggregate data since 2012-08-22*/

SELECT
	utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_sessions.website_session_id) AS pct_mobile
FROM website_sessions
WHERE
    utm_source IN ('bsearch' , 'gsearch')
    AND utm_campaign = 'nonbrand'
    AND created_at BETWEEN '2012-08-22' AND '2012-11-30'
GROUP BY 1
ORDER BY sessions DESC;