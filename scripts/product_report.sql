/*
==============
PRODUCT REPORT
==============
*/

/*
REQUIRED COLUMNS:
-product_id
-product_name
-category_name
-brand_name
-total_sales
-revenue_segmentation (Low-Performers, Mid-Performers, High-Performers)
-avg_sales
-total_orders
-avg_list_price
-total_quantity
-total_customers
-avg_order_revenue (total_sales / total_orders)
*/

CREATE VIEW product_report AS
--base query
WITH product_base_query AS(
	SELECT 
		o.order_id,
		p.product_id,
		p.product_name,
		cat.category_name,
		b.brand_name,
		CAST(ROUND(oi.quantity * oi.list_price * (1 - discount), 0) AS FLOAT) AS sales_amount,
		p.list_price,
		s.quantity,
		cus.customer_id
	FROM sales.orders o
	LEFT JOIN sales.customers cus ON cus.customer_id = o.customer_id
	LEFT JOIN sales.order_items oi ON oi.order_id = o.order_id
	LEFT JOIN production.products p ON p.product_id = oi.product_id
	LEFT JOIN production.categories cat ON cat.category_id = p.category_id
	LEFT JOIN production.stocks s ON s.product_id = p.product_id
	LEFT JOIN production.brands b ON b.brand_id = p.brand_id
	WHERE o.order_date IS NOT NULL
)
--aggregation query
, product_aggregation_query AS(
	SELECT 
		product_id,
		product_name,
		category_name,
		brand_name,
		SUM(sales_amount) AS total_sales,
		ROUND(AVG(sales_amount), 0) AS avg_sales,
		COUNT(DISTINCT order_id) AS total_orders,
		CAST(ROUND(AVG(list_price), 2) AS FLOAT) AS avg_list_price,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT customer_id) AS total_customers
	FROM product_base_query
	GROUP BY product_id, product_name, category_name, brand_name
)
--result query
SELECT 
	product_id,
	product_name,
	category_name,
	brand_name,
	total_sales,
	CASE 
		WHEN total_sales < 20000 THEN 'Low-Performers'
		WHEN total_sales BETWEEN 20000 AND 50000 THEN 'Mid-Performers'
		ELSE 'High-Performers'
	END AS revenue_segmentation,
	avg_sales,
	total_orders,
	avg_list_price,
	total_quantity,
	total_customers,
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(total_sales / total_orders, 0)
	END AS avg_order_revenue
FROM product_aggregation_query