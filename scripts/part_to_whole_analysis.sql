/*
===================================
PART-TO-WHOLE PROPORTIONAL ANALYSIS
===================================
*/

--List shops by their contribution to overall sales
WITH total_sales_per_store AS(
	SELECT
		DISTINCT store_name,
		CAST(ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)), 0) AS FLOAT) AS total_sales
	FROM sales.stores s
	JOIN sales.orders o ON o.store_id = s.store_id
	JOIN sales.order_items oi ON oi.order_id = o.order_id
	GROUP BY store_name
)

SELECT 
	store_name,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100, 2), '%') AS percentage_of_overall_sales
FROM total_sales_per_store
ORDER BY total_sales DESC



--List products by their contribution to overall sales
WITH total_sales_per_product AS(
	SELECT 
		DISTINCT product_name,
		CAST(ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)), 0) AS FLOAT) AS total_sales
	FROM sales.order_items oi
	JOIN sales.orders o ON o.order_id = oi.order_id
	JOIN production.products p ON p.product_id = oi.product_id
	GROUP BY product_name
)

SELECT 
	product_name,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100, 2), '%') AS percentage_of_overall_sales
FROM total_sales_per_product
ORDER BY total_sales DESC



--List categories by their contribution to overall sales
WITH total_sales_per_product AS(
	SELECT 
		DISTINCT category_name,
		CAST(ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)), 0) AS FLOAT) AS total_sales
	FROM sales.order_items oi
	JOIN sales.orders o ON o.order_id = oi.order_id
	JOIN production.products p ON p.product_id = oi.product_id
	JOIN production.categories c ON c.category_id = p.category_id
	GROUP BY category_name
)

SELECT 
	category_name,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100, 2), '%') AS percentage_of_overall_sales
FROM total_sales_per_product
ORDER BY total_sales DESC



--List brands by their contribution to overall sales
WITH total_sales_per_product AS(
	SELECT 
		DISTINCT brand_name,
		CAST(ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)), 0) AS FLOAT) AS total_sales
	FROM sales.order_items oi
	JOIN sales.orders o ON o.order_id = oi.order_id
	JOIN production.products p ON p.product_id = oi.product_id
	JOIN production.brands b ON b.brand_id = p.brand_id
	GROUP BY brand_name
)

SELECT 
	brand_name,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100, 2), '%') AS percentage_of_overall_sales
FROM total_sales_per_product
ORDER BY total_sales DESC