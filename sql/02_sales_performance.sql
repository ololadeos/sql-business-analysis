-- Aggregations
-- Find the number of Completed orders.
SELECT COUNT(*) AS number_orders FROM orders 
WHERE status = 'Completed'; 
 
 
-- Find total revenue from Completed orders.
SELECT SUM(revenue) AS total_revenue FROM orders
WHERE status = 'Completed'; 


-- Find average revenue for Completed orders.
SELECT AVG(revenue) AS average_revenue FROM orders
WHERE status = 'Completed';  
 
 
-- Find the lowest revenue among Completed orders.
SELECT MIN(revenue) AS min_revenue FROM orders
WHERE status = 'Completed'; 
 

-- GROUP BY
-- Find orders by status.
SELECT status, COUNT(order_id) AS number_orders
FROM orders
GROUP BY status;


-- Find for each channel, return order count and average revenue.
SELECT channel, COUNT(order_id) AS number_orders, AVG(revenue) AS average_revenue
FROM orders
GROUP BY channel; 
  

-- Find completed revenue by channel.
SELECT channel, SUM(revenue) AS total_revenue
FROM orders
WHERE status = 'Completed'
GROUP BY channel;
  

-- Find for each channel and status combination, return order count and total revenue.
SELECT status, channel, COUNT(order_id) AS number_orders, SUM(revenue) AS total_revenue
FROM orders
GROUP BY status, channel; 
  

-- Find for each channel and status combination, calculate average revenue and sort from highest to lowest average revenue.
SELECT channel, status, ROUND(AVG(revenue),2) AS average_revenue
FROM orders
GROUP BY status, channel
ORDER BY average_revenue DESC;
 
 
-- HAVING
-- Find channels with more than 80 orders.
SELECT channel, COUNT(order_id) AS number_orders
FROM orders
GROUP BY channel
HAVING number_orders > 80;
 

-- Find channel and status combinations with at least 10 orders.
SELECT status, channel, COUNT(order_id) AS number_orders
FROM orders
GROUP BY channel, status
HAVING number_orders >= 10;
 

-- CASE WHEN
-- Find each order as High, Medium or Low revenue. High = revenue at least 1,500; Medium = revenue from 500 up to below 1,500; Low = below 500. Return order_id and the category.
SELECT order_id, revenue, 
	CASE
		WHEN revenue >= 1500 THEN 'High'
		WHEN revenue >= 500 AND revenue < 1500 THEN 'Medium'
		ELSE 'Low'
	END AS order_category
FROM orders;
  

-- Find each order as Discounted if discount_pct > 0, otherwise Full Price.
SELECT order_id, discount_pct, 
	CASE
		WHEN discount_pct > 0 THEN 'Discounted'
		ELSE 'Full Price'
	END AS discount_category
FROM orders;
  

-- Find completed order count and Pending order count as two separate columns using SUM(CASE WHEN...).
SELECT 
	SUM (CASE
		WHEN status = 'Completed' THEN 1
		ELSE 0
		END) AS completed_orders, 
	SUM (CASE
		WHEN status = 'Pending' THEN 1
		ELSE 0
		END) AS pending_orders
FROM orders; 
 

-- Find completed revenue and Cancelled revenue as two separate columns using SUM(CASE WHEN...).
SELECT
	SUM(CASE
		WHEN status = 'Completed' THEN revenue
		ELSE 0
		END) AS completed_revenue,
	SUM(CASE
		WHEN status = 'Cancelled' THEN revenue
		ELSE 0
		END) AS cancelled_revenue
FROM orders;
 
 
-- Find for each channel, return the number of Discounted orders and Full Price orders in separate columns.
SELECT channel,
	SUM (CASE
		WHEN discount_pct > 0 THEN 1
		ELSE 0
		END) AS 'discounted',
	SUM(CASE
		WHEN discount_pct = 0 THEN 1
		ELSE 0
		END) AS 'full price'
FROM orders
GROUP BY channel;
