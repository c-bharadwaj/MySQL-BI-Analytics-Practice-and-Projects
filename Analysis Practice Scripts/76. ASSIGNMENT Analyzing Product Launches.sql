
/* 	New product launched on '2013-01-06'
	Find - 	MONTHLY ORDER VOLUME
			OVERALL CONVERSION RATES 
            REVENUE PER SESSION 
            BREAKDOWN OF SALES BY PRODUCT
	Since '2012-04-01' */
    
    SELECT DISTINCT primary_product_id
    FROM orders
    WHERE created_at BETWEEN '2012-04-01' AND '2013-04-05'; -- only 2 products have been ordered - 1 and 2
    
    SELECT
		YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate,
        SUM(o.price_usd)/COUNT(DISTINCT ws.website_session_id) AS reveue_per_session,
        COUNT(DISTINCT CASE WHEN o.primary_product_id = 1 THEN o.order_id ELSE NULL END) AS product_one_orders,
        COUNT(DISTINCT CASE WHEN o.primary_product_id = 2 THEN o.order_id ELSE NULL END) AS product_two_orders
	FROM website_sessions ws 
		LEFT JOIN orders o
			ON ws.website_session_id = o.website_session_id
    WHERE ws.created_at BETWEEN '2012-04-01' AND '2013-04-05' -- only 2 products have been ordered - 1 and 2
    GROUP BY 1,2;
    
    

    
    