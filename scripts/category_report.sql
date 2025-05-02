/*
===============
CATEGORY REPORT
===============
*/

/*
REQUIRED COLUMNS:
-category_id
-category_name
-product_count
-total_sales
-revenue_segmentation (Low-Performers, Mid-Performers, High-Performers)
-avg_sales
-total_orders
-avg_list_price
-total_customers
-avg_order_revenue (total_sales / total_orders)
*/

CREATE VIEW category_report AS
--base query
WITH category_base_query AS(
	SELECT 
		o.order_id,
		c.category_id,
		c.category_name,
		CAST(ROUND(oi.quantity * oi.list_price * (1 - discount), 0) AS FLOAT) AS sales_amount,
		p.product_id,
		p.list_price,
		cus.customer_id
	FROM sales.orders o
	LEFT JOIN sales.customers cus ON cus.customer_id = o.customer_id
	LEFT JOIN sales.order_items oi ON oi.order_id = o.order_id
	LEFT JOIN production.products p ON p.product_id = oi.product_id
	LEFT JOIN production.categories c ON c.category_id = p.category_id
	WHERE o.order_date IS NOT NULL
)
--aggregation query
, category_aggregation_query AS(
	SELECT 
		category_id,
		category_name,
		COUNT(DISTINCT product_id) AS product_count,
		SUM(sales_amount) AS total_sales,
		ROUND(AVG(sales_amount), 0) AS avg_sales,
		COUNT(DISTINCT order_id) AS total_orders,
		CAST(ROUND(AVG(list_price), 2) AS FLOAT) AS avg_list_price,
		COUNT(DISTINCT customer_id) AS total_customers
	FROM category_base_query
	GROUP BY category_id, category_name
)
--result query
SELECT 
	category_id,
	category_name,
	product_count,
	total_sales,
	CASE 
		WHEN total_sales < 150000 THEN 'Low-Performers'
		WHEN total_sales BETWEEN 150000 AND 500000 THEN 'Mid-Performers'
		ELSE 'High-Performers'
	END AS revenue_segmentation,
	avg_sales,
	total_orders,
	avg_list_price,
	total_customers,
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(total_sales / total_orders, 0)
	END AS avg_order_revenue
FROM category_aggregation_query