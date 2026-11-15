-- Scenario
-- You're a Data Analyst supporting the Sales team. Management wants an analysis of sales performance. They're interested in:
--- Completed sales performance
--- Customer and channel performance
--- High-value orders
--- How individual orders compare with their groups
--- Changes over time
--- Running revenue
--- Top performers

-- Part 1 — Build your analysis base
-- 1: Create a CTE called completed_orders containing only Completed orders.

WITH completed_orders AS
(SELECT
	order_id, 
	order_date, 
	customer_id, 
	product_id, 
	channel,
	revenue
FROM orders
WHERE status = 'Completed')

SELECT * FROM completed_orders;

-- 2 Using a CTE, calculate the average revenue of Completed orders.
WITH average_revenue AS
(SELECT AVG(revenue) AS avg_rev
FROM orders
WHERE status = 'Completed')

SELECT 
	o.order_id,
	o.order_date,
	o.channel,
	o.revenue
FROM orders AS o
JOIN average_revenue as a
WHERE o.status = 'Completed' AND o.revenue > a.avg_rev;


-- Part 2 — Ranking
-- 3 Rank all Completed orders from highest to lowest revenue (Business requirement: Orders with equal revenue should receive the same rank and the next ranking number should not be skipped.)

SELECT
	order_id,
	channel,
	revenue, 
	DENSE_RANK() OVER(ORDER BY revenue DESC) AS revenue_rank
FROM orders
WHERE status = 'Completed';


-- 4 Find the top 3 highest-revenue Completed orders within each channel.

WITH channel_ranking AS
(SELECT 
	order_id, 
	channel, 
	revenue,
	ROW_NUMBER() OVER(PARTITION BY channel ORDER BY revenue DESC) AS channel_position
FROM orders
WHERE status = 'Completed')

SELECT * FROM channel_ranking AS c
WHERE c.channel_position <=3;


-- Part 3 — Customer analysis
-- 5 Calculate each customer's total Completed revenue. Then rank customers from highest to lowest Completed revenue. Again, customers with equal Completed revenue should receive the same rank with continuous ranking numbers.

WITH customer_revenue AS
(SELECT
	customer_name, 
	SUM(revenue) AS completed_revenue
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE status = 'Completed'
GROUP BY customer_name)

SELECT
	cr.customer_name, 
	cr.completed_revenue,
	DENSE_RANK() OVER(ORDER BY cr.completed_revenue DESC) AS customer_rank
FROM customer_revenue AS cr;


-- 6 Return only customers ranked in the top 5. 

WITH customer_revenue AS
(SELECT
	c.customer_name, 
	SUM(revenue) AS completed_revenue
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE status = 'Completed'
GROUP BY customer_name),

customer_completed_rank AS(
SELECT
	cr.customer_name,
	cr.completed_revenue,
	DENSE_RANK() OVER(ORDER BY cr.completed_revenue DESC) AS customer_rank
FROM customer_revenue AS cr)

SELECT * FROM customer_completed_rank AS ccr
WHERE ccr.customer_rank <= 5;

-- Part 4 — Window analysis
-- 7 For every Completed order, show:

WITH completed_average AS(
SELECT 
	order_id, 
	channel, 
	revenue, 
	ROUND(AVG(revenue) OVER(PARTITION BY channel),2) AS channel_avg_revenue 
FROM orders
WHERE status = 'Completed')

SELECT 
	*,
	ROUND((c.revenue - c.channel_avg_revenue),2) AS difference_from_channel_avg
FROM completed_average AS c;


-- 8 Calculate the running Completed revenue within each channel.

SELECT 
	order_id,
	order_date,	
	channel, 
	revenue, 
	ROUND(SUM(revenue) OVER(PARTITION BY channel ORDER BY order_date, order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS running_completed_revenue 
FROM orders
WHERE status = 'Completed';



-- Part 5 — Previous-order analysis
-- 9 For every Completed order, show the revenue of the previous Completed order within the same channel.

SELECT 
	order_id,
	order_date,
	channel,
	revenue,
	LAG(revenue) OVER(PARTITION BY channel ORDER BY order_date, order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS previous_order_revenue
FROM orders
WHERE status = 'Completed'; 

-- 10 Extend #9 by calculating: revenue_change

SELECT 
	order_id,
	order_date,
	channel,
	revenue,
	LAG(revenue) OVER(PARTITION BY channel ORDER BY order_date, order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS previous_order_revenue,
	(revenue - LAG(revenue) OVER(PARTITION BY channel ORDER BY order_date, order_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS revenue_change
FROM orders
WHERE status = 'Completed';


-- Part 6 — Put the week together
-- 11 Management asks: Within each channel, which 3 customers generated the most Completed revenue?

WITH customer_completed_revenue AS
(SELECT 
	channel, 
	customer_name,
	SUM(revenue) AS customer_revenue
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE status = 'Completed'
GROUP BY o.channel, c.customer_name, o.customer_id)
,

customer_rank AS 
(SELECT 
	*,
	DENSE_RANK() OVER(PARTITION BY channel ORDER BY cr.customer_revenue DESC) AS customer_rank
FROM customer_completed_revenue AS cr)

SELECT 
	*
FROM customer_rank AS ccr
WHERE ccr.customer_rank <=3;
