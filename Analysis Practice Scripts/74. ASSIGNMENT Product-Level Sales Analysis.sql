
/* current flagship product ? Pull monthly trends to date 
for - number of sales , total revenue and total margin generated.
to date as on - 2013-01-04 */

SELECT
	YEAR(o.created_at) AS yr,
    MONTH(o.created_at) AS mo,
    COUNT(DISTINCT o.order_id) AS number_of_sales,
    SUM(o.price_usd) AS total_revenue,
    SUM(o.price_usd - o.cogs_usd) AS total_margin
FROM orders o
WHERE
	created_at <= '2013-01-04'
    AND o.items_purchased IS NOT NULL
GROUP BY 1,2;