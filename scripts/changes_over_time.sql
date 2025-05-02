/*
==========================
CHANGES OVER TIME ANALYSIS
==========================
*/


--Changes over months for each store
SELECT
	store_name,
	YEAR(o.order_date) AS order_year,
	MONTH(o.order_date) AS order_month,
	COUNT(DISTINCT o.order_id) AS total_orders,
	COUNT(DISTINCT o.customer_id) AS total_customers,
	CAST(ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)), 0) AS FLOAT) AS total_sales
FROM sales.orders o
LEFT JOIN sales.order_items oi ON oi.order_id = o.order_id
LEFT JOIN sales.stores s ON s.store_id = o.store_id
WHERE o.order_date is not null
GROUP BY store_name, YEAR(o.order_date), MONTH(o.order_date)
ORDER BY store_name, YEAR(o.order_date), MONTH(o.order_date)


--Changes over years for each store
SELECT
	store_name,
	YEAR(o.order_date) AS order_year,
	COUNT(DISTINCT o.order_id) AS total_orders,
	COUNT(DISTINCT o.customer_id) AS total_customers,
	CAST(ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)), 0) AS FLOAT) AS total_sales
FROM sales.orders o
LEFT JOIN sales.order_items oi ON oi.order_id = o.order_id
LEFT JOIN sales.stores s ON s.store_id = o.store_id
WHERE o.order_date is not null
GROUP BY store_name, YEAR(o.order_date)
ORDER BY store_name, YEAR(o.order_date)