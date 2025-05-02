/*
============
STORE REPORT
============
*/

/*
REQUIRED COLUMNS:
-store_id
-store_name
-state
-city
-street
-total_customers
-total_staff
-total_orders
-total_sales
-total_products_sold
*/

--base query
CREATE VIEW store_report AS
WITH store_base_query AS (
	SELECT 
		o.order_id,
		strs.store_id,
		strs.store_name,
		strs.state,
		strs.city,
		strs.street,
		o.customer_id,
		CAST(oi.quantity * oi.list_price * (1 - oi.discount) AS FLOAT) AS sales_amount,
		oi.quantity
	FROM sales.stores strs
	JOIN sales.orders o ON o.store_id = strs.store_id
	JOIN sales.order_items oi ON oi.order_id = o.order_id
	WHERE o.order_date IS NOT NULL
)

-- Final aggregation
SELECT 
	store_id,
	store_name,
	state,
	city,
	street,
	COUNT(DISTINCT customer_id) AS total_customers,
	COUNT(DISTINCT order_id) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_products_sold
FROM store_base_query 
GROUP BY
	store_id,
	store_name,
	state,
	city,
	street
;
