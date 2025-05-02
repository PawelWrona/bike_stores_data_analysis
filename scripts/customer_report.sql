/*
===============
CUSTOMER REPORT
===============
*/

/*
REQUIRED COLUMNS:
-customer_id
-first_name
-last_name
-state
-city
-lifespan (latest order_date - first order_date)
-customer_status (New/Regular based on lifespan)
-last_order_date
-recency (current date - last_order_date)
-total_orders
-total_sales
-total_products
-avg_order_value (total_sales / total_orders)
-favorite_category
*/

CREATE VIEW customer_report AS
--base query
WITH customer_base_query AS(
	SELECT 
		o.order_id,
		cus.customer_id,
		o.order_date,
		CAST(ROUND(oi.quantity * oi.list_price * (1 - discount), 0) AS FLOAT) AS sales_amount,
		oi.quantity,
		cat.category_name
	FROM sales.orders o
	LEFT JOIN sales.customers cus ON cus.customer_id = o.customer_id
	LEFT JOIN sales.order_items oi ON oi.order_id = o.order_id
	LEFT JOIN production.products p ON p.product_id = oi.product_id
	LEFT JOIN production.categories cat ON cat.category_id = p.category_id
	WHERE o.order_date IS NOT NULL
)
--customer aggregation query
,customer_aggregation_query AS (
	SELECT 
		customer_id,
        MAX(order_date) AS last_order_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) as lifespan,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_products
	FROM customer_base_query
	GROUP BY customer_id
)
--favorite category aggregation query
,favorite_category_aggregation_query AS (
	SELECT 
		customer_id,
        category_name,
        SUM(sales_amount) AS category_sales,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY SUM(sales_amount) DESC) AS category_rank
	FROM customer_base_query
	GROUP BY customer_id, category_name
)

SELECT 
	c.customer_id,
	c.first_name,
	c.last_name,
	c.state,
	c.city,
	ca.lifespan,
	CASE 
        WHEN lifespan <= 6 THEN 'New'
        ELSE 'Regular'
    END AS customer_status, 
	ca.last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) as recency,
	ca.total_orders,
	ca.total_sales,
	ca.total_products,
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(total_sales / total_orders, 0)
	END AS avg_order_revenue,
	fca.category_name AS favorite_category
FROM customer_aggregation_query ca
JOIN sales.customers c ON c.customer_id = ca.customer_id
LEFT JOIN favorite_category_aggregation_query fca ON fca.customer_id = c.customer_id AND fca.category_rank = 1