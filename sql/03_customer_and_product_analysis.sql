-- JOINs
-- Find join orders to customers and return order_id, customer_name and revenue.
SELECT order_id, customer_name, revenue
FROM orders AS o JOIN customers AS c
ON o.customer_id = c.customer_id;
 

-- Find join orders to products and return order_id, product_name and revenue.
SELECT order_id, product_name, revenue
FROM orders AS o JOIN products AS p
ON o.product_id = p.product_id;
 

-- Find completed orders with order_id, customer_name, region and revenue.
SELECT o.order_id, c.customer_name, c.region, o.revenue FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE status = 'Completed'; 
  

-- Find the top 10 Completed orders by revenue and show order_id, customer_name and revenue.
SELECT order_id, customer_name, revenue
FROM orders AS o JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE status = 'Completed' 
ORDER BY revenue DESC LIMIT 10; 
 

-- Find lEFT JOIN orders to sales_reps and show orders where the sales representative name is missing after the join.
SELECT * FROM orders AS o LEFT JOIN sales_reps AS s
ON o.rep_id = s.rep_id
WHERE rep_name IS NULL;
 

-- Find join orders, customers and products. Return order_id, customer_name, region, product_name, category and revenue.
SELECT order_id, customer_name, region, product_name, category, revenue
FROM orders AS o JOIN customers AS c
ON o.customer_id = c.customer_id
JOIN products AS p 
ON o.product_id = p.product_id;
 

-- Find completed orders for Ontario customers where the product category is Technology.
SELECT *
FROM orders AS o JOIN customers AS c
ON o.customer_id = c.customer_id
JOIN products AS p 
ON o.product_id = p.product_id
WHERE category = 'Technology' AND region = 'Ontario' AND status = 'Completed'; 
 

-- JOIN + Aggregation
-- Find completed revenue and order count by customer region.
SELECT region, SUM(revenue) AS total_revenue, COUNT(order_id) AS number_orders
FROM orders AS o JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE status = 'Completed'
GROUP BY region;
 

-- Find completed revenue and order count by product category.
SELECT category, SUM(revenue) AS total_revenue, COUNT(order_id) AS number_orders
FROM orders AS o JOIN products AS p
ON o.product_id = p.product_id
WHERE status = 'Completed'
GROUP BY category
ORDER BY total_revenue DESC; 
 

-- Find the 5 customers with the highest total Completed revenue.
SELECT customer_name, SUM(revenue) as total_revenue
FROM orders AS o JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE status = 'Completed' 
GROUP BY customer_name
ORDER BY total_revenue DESC LIMIT 5;
