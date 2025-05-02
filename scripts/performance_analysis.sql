/*
====================
PERFORMANCE ANALYSIS
====================
*/



--Total sales compared to average total sales for each product category every year
WITH yearly_sales_per_category AS( 
	SELECT
		YEAR(o.order_date) AS order_year,
		c.category_name,
		SUM(CAST(ROUND(oi.quantity * oi.list_price * (1 - discount), 0) AS FLOAT)) AS total_sales
	FROM sales.order_items oi
	LEFT JOIN sales.orders o ON o.order_id = oi.order_id
	LEFT JOIN production.products p ON p.product_id = oi.product_id
	LEFT JOIN production.categories c ON c.category_id = p.category_id
	GROUP BY YEAR(o.order_date), c.category_name
)

SELECT 
	category_name,
	order_year,
	total_sales,
	ROUND(AVG(total_sales) OVER(PARTITION BY category_name), 0) AS avg_total_sales,
	CASE
		WHEN total_sales > ROUND(AVG(total_sales) OVER(PARTITION BY category_name), 0) THEN 'Above average'
		WHEN total_sales < ROUND(AVG(total_sales) OVER(PARTITION BY category_name), 0) THEN 'Below average'
		ELSE 'Same as average'
	END AS sales_vs_average
FROM yearly_sales_per_category
ORDER BY category_name, order_year



--Total sales compared to last month total sales for each product category
WITH monthly_sales_per_category AS( 
	SELECT
		DATETRUNC(month, o.order_date) AS order_date,
		c.category_name,
		SUM(CAST(ROUND(oi.quantity * oi.list_price * (1 - discount), 0) AS FLOAT)) AS total_sales
	FROM sales.order_items oi
	LEFT JOIN sales.orders o ON o.order_id = oi.order_id
	LEFT JOIN production.products p ON p.product_id = oi.product_id
	LEFT JOIN production.categories c ON c.category_id = p.category_id
	GROUP BY DATETRUNC(month, o.order_date), c.category_name
)

SELECT 
	category_name,
	FORMAT(order_date, 'yyyy-MMM'),
	total_sales,
	LAG(total_sales) OVER(PARTITION BY category_name ORDER BY order_date) AS prev_total_sales,
	(total_sales - LAG(total_sales) OVER(PARTITION BY category_name ORDER BY order_date)) AS diff_total_sales,
	CASE
		WHEN total_sales - LAG(total_sales) OVER(PARTITION BY category_name ORDER BY order_date) > 0 THEN 'Increase'
		WHEN total_sales - LAG(total_sales) OVER(PARTITION BY category_name ORDER BY order_date) < 0 THEN 'Decrease'
		ELSE 'No change'
	END AS prev_month_change
FROM monthly_sales_per_category



--Total sales compared to average total sales for each product every year
WITH yearly_sales_per_product AS(
	SELECT
		YEAR(o.order_date) AS order_year,
		p.product_name,
		SUM(CAST(ROUND(oi.quantity * oi.list_price * (1 - discount), 0) AS FLOAT)) AS total_sales
	FROM sales.order_items oi
	LEFT JOIN sales.orders o ON o.order_id = oi.order_id
	LEFT JOIN production.products p ON p.product_id = oi.product_id
	GROUP BY YEAR(o.order_date), p.product_name
)

SELECT 
	product_name,
	order_year,
	total_sales,
	ROUND(AVG(total_sales) OVER(PARTITION BY product_name), 0) AS avg_total_sales,
	CASE
		WHEN total_sales > ROUND(AVG(total_sales) OVER(PARTITION BY product_name), 0) THEN 'Above average'
		WHEN total_sales < ROUND(AVG(total_sales) OVER(PARTITION BY product_name), 0) THEN 'Below average'
		ELSE 'Same as average'
	END AS sales_vs_average
FROM yearly_sales_per_product



--Total sales compared to last month total sales for each product
WITH monthly_sales_per_product AS( 
	SELECT
		DATETRUNC(month, o.order_date) AS order_date,
		p.product_name,
		SUM(CAST(ROUND(oi.quantity * oi.list_price * (1 - discount), 0) AS FLOAT)) AS total_sales
	FROM sales.order_items oi
	LEFT JOIN sales.orders o ON o.order_id = oi.order_id
	LEFT JOIN production.products p ON p.product_id = oi.product_id
	GROUP BY DATETRUNC(month, o.order_date), p.product_name
)

SELECT 
	product_name,
	FORMAT(order_date, 'yyyy-MMM'),
	total_sales,
	LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_date) AS prev_total_sales,
	(total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_date)) AS diff_total_sales,
	CASE
		WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_date) > 0 THEN 'Increase'
		WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_date) < 0 THEN 'Decrease'
		ELSE 'No change'
	END AS prev_month_change
FROM monthly_sales_per_product