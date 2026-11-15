-- Fundamentals
-- Find all columns and all rows from the orders table.
SELECT * FROM orders; 

-- Find only order_id, order_date and revenue from orders.
SELECT order_id, 
	order_date, 
	revenue 
FROM orders;
 

-- Find order_id and revenue for Completed orders.
SELECT order_id, 
	revenue 
FROM orders 
WHERE status = 'Completed';
 

-- Find all orders with revenue greater than 1,000.
SELECT * FROM orders 
WHERE revenue > 1000;
  

-- Find all Online orders.
SELECT * FROM orders 
WHERE channel = 'Online';
 

-- Find all orders where quantity is at least 5.
SELECT * FROM orders 
WHERE quantity >=5;  
 

-- Find all orders where discount_pct is exactly 0.
SELECT * FROM orders 
WHERE discount_pct = 0;
 

-- Find all Cancelled orders.
SELECT * FROM orders 
WHERE status = 'Cancelled';  
 

-- Find order_id, channel and status for Partner orders.
SELECT order_id, 
	channel, 
	status 
FROM orders 
WHERE channel = 'Partner'; 
 

-- Find order_id, revenue and discount_pct for orders with revenue at most 250.
SELECT order_id, 
	revenue, 
	discount_pct 
FROM orders 
WHERE revenue <= 250; 
  
 

-- AND / OR / Parentheses
-- Find completed orders with revenue greater than 1,000.
SELECT * FROM orders
WHERE status = 'Completed' 
AND revenue > 1000;
  
 
-- Find online orders with quantity at least 4.
SELECT * FROM orders
WHERE channel = 'Online' 
AND quantity >= 4;
  

-- Find orders whose status is Pending OR Cancelled. Use OR.
SELECT * FROM orders
WHERE status = 'Pending' OR status = 'Cancelled';
 

-- Find completed orders from either the Online or Store channel. Use parentheses with OR.
SELECT * FROM orders
WHERE status = 'Completed' AND
(channel = 'Online' OR channel = 'Store'); 
 

-- Find partner orders that have a discount greater than 0 AND revenue greater than 500.
SELECT * FROM orders
WHERE discount_pct > 0 AND
channel = 'Partner' AND
revenue > 500; 
 
 
-- Find completed orders where either quantity is at least 5 OR revenue is greater than 1,500. Use parentheses.
SELECT * FROM orders 
WHERE status = 'Completed' AND
(quantity >= 5 OR revenue > 1500); 
  

-- Find online orders whose status is Pending OR Returned. Use parentheses.
SELECT * FROM orders
WHERE channel = 'Online' AND 
(status = 'Pending' OR status = 'Returned'); 
  

-- Find completed orders with quantity between 2 and 5 inclusive. Use comparison operators rather than BETWEEN.
SELECT * FROM orders
WHERE status = 'Completed' AND
(quantity >= 2 AND quantity <= 5); 
 

-- Find orders that are NOT Completed and have revenue greater than 1,000.
SELECT * FROM orders 
WHERE status != 'Completed' AND
revenue > 1000; 


-- IN / BETWEEN / LIKE
-- Find orders whose status is Completed or Pending. Use IN.
SELECT * FROM orders
WHERE status in ('Completed', 'Pending'); 
 
 
-- Find orders from the Online or Partner channel. Use IN.
SELECT * FROM orders 
WHERE channel IN ('Online', 'Partner');
  

-- Find orders with revenue between 500 and 1,500 inclusive.
SELECT * FROM orders
WHERE revenue BETWEEN 500 AND 1500;  
 

-- Find orders placed during April 2026.
SELECT * FROM orders 
WHERE order_date BETWEEN '2026-04-01' AND '2026-04-30';  
 

-- Find orders where order_id begins with O00.
SELECT * FROM orders 
WHERE order_id LIKE 'O00%'; 


-- Find orders where channel contains the letter n.
SELECT * FROM orders
WHERE channel LIKE '%n%'; 

 
-- Find completed orders placed in June 2026 with revenue between 100 and 1,000.
SELECT * FROM orders
WHERE status = 'Completed' AND
order_date BETWEEN '2026-06-01' AND '2026-06-30' AND
revenue BETWEEN 100 AND 1000; 
 

-- Find orders whose status is NOT Pending or Cancelled.
SELECT * FROM orders
WHERE status NOT IN ('Pending', 'Cancelled');
 

-- NULL / DISTINCT / ORDER BY / LIMIT
-- Find all distinct order statuses.
SELECT DISTINCT status FROM orders;


-- Find all distinct channels in alphabetical order.
SELECT DISTINCT channel FROM orders
ORDER BY channel ASC; 


-- Find orders where rep_id is NULL.
SELECT * FROM orders 
WHERE rep_id IS NULL; 
 

-- Find the 10 highest-revenue orders.
SELECT * FROM orders
ORDER BY revenue DESC LIMIT 10; 
  

-- Find the 5 oldest orders.
SELECT * FROM orders 
ORDER BY order_date ASC LIMIT 5;


-- Find the 8 highest-revenue Completed orders, returning only order_id, order_date and revenue.
SELECT order_id, order_date, revenue FROM orders
WHERE status = 'Completed' 
ORDER BY revenue DESC LIMIT 8;
