/*
===================
CUMULATIVE ANALYSIS 
===================
*/


--Cumulative analysis of sales by month, grouped by year
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(PARTITION BY year(order_date)  ORDER BY order_date) AS running_total_sales
FROM (
	SELECT	
		DATETRUNC(month, o.order_date) AS order_date,
		CAST(ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)), 0) AS FLOAT) AS total_sales
	FROM sales.orders o
	LEFT JOIN sales.order_items oi ON oi.order_id = o.order_id
	GROUP BY DATETRUNC(month, o.order_date)
) subq



--Cumulative Analysis of sales by year 
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales
FROM (
	SELECT	
		DATETRUNC(year, o.order_date) AS order_date,
		CAST(ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)), 0) AS FLOAT) AS total_sales
	FROM sales.orders o
	LEFT JOIN sales.order_items oi ON oi.order_id = o.order_id
	GROUP BY DATETRUNC(year, o.order_date)
) subq