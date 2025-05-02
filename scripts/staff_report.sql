/*
============
STAFF REPORT
============
*/

/*
REQUIRED COLUMNS:
-staff_id
-first_name
-last_name
-store_name
-state
-city
-street
-total_orders
-total_customers
-total_sales
-avg_sales
-total_products_sold
-lifespan
-staff_status (New, Regular, Senior)
*/

CREATE VIEW staff_report AS
--base query
WITH staff_base_query AS(
	SELECT 
		o.order_id,
		s.staff_id,
		s.first_name,
		s.last_name,
		strs.store_name,
		strs.state,
		strs.city,
		strs.street,
		CAST(ROUND(oi.quantity * oi.list_price * (1 - discount), 0) AS FLOAT) AS sales_amount,
		oi.quantity,
		o.order_date,
		o.customer_id
	FROM sales.orders o
	LEFT JOIN sales.staffs s ON s.staff_id = o.staff_id
	LEFT JOIN sales.order_items oi ON oi.order_id = o.order_id
	LEFT JOIN sales.stores strs ON strs.store_id = s.store_id
	WHERE o.order_date IS NOT NULL
)
--aggregation query
, staff_aggregation_query AS(
	SELECT 
		staff_id,
		first_name,
		last_name,
		store_name,
		state,
		city,
		street,
		COUNT(DISTINCT order_id) AS total_orders,
		COUNT(DISTINCT customer_id) AS total_customers,
		SUM(sales_amount) AS total_sales,
		ROUND(AVG(sales_amount), 0) AS avg_sales,
		SUM(quantity) AS total_products_sold,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) as lifespan
	FROM staff_base_query
	GROUP BY
		staff_id,
		first_name,
		last_name,
		store_name,
		state,
		city,
		street
)

--result query
SELECT 
	staff_id,
	first_name,
	last_name,
	store_name,
	state,
	city,
	street,
	total_orders,
	total_customers,
	total_sales,
	avg_sales,
	total_products_sold,
	lifespan,
	CASE 
        WHEN lifespan < 12 THEN 'New'
		WHEN lifespan BETWEEN 12 AND 36 THEN 'Regular'
        ELSE 'Senior'
    END AS staff_status
FROM staff_aggregation_query