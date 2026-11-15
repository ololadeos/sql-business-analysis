SELECT * FROM orders;

SELECT order_id, revenue
FROM orders
WHERE revenue > (
SELECT AVG(revenue) FROM orders WHERE status = 'Completed') AND status = 'Completed';

WITH channel_revenue AS
(SELECT channel, SUM(revenue) AS total_revenue
FROM orders
GROUP BY channel)

SELECT * FROM channel_revenue;

WITH region_revenue AS
(SELECT region, SUM(revenue) AS total_revenue
FROM customers AS c
JOIN orders AS o
ON c.customer_id = o.customer_id
WHERE status = 'Completed'
GROUP BY region)

SELECT region, total_revenue
FROM region_revenue
WHERE total_revenue > 30000;

WITH customer_revenue AS
(SELECT customer_name, SUM(revenue) AS completed_revenue
FROM customers AS c
JOIN orders AS o 
ON c.customer_id = o.customer_id
WHERE status = 'Completed'
GROUP BY customer_name)

SELECT * FROM customer_revenue
ORDER BY completed_revenue DESC LIMIT 5;

SELECT order_id, 
revenue, 
ROW_NUMBER() OVER (ORDER BY revenue DESC) AS revenue_position
FROM orders;

SELECT order_id, 
revenue, 
RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM orders;

SELECT order_id, 
revenue, 
ROW_NUMBER() OVER (ORDER BY revenue DESC) AS revenue_position, 
RANK() OVER (ORDER BY revenue DESC) AS revenue_rank, 
DENSE_RANK() OVER (ORDER BY revenue DESC) AS dense_ranking
FROM orders;

SELECT order_id, 
channel, 
revenue,
ROW_NUMBER () OVER(PARTITION BY channel ORDER BY revenue DESC) AS channel_position
FROM orders;

WITH channel_position AS
(SELECT order_id, 
channel, 
revenue,
ROW_NUMBER () OVER(PARTITION BY channel ORDER BY revenue DESC) AS channel_ranking
FROM orders)

SELECT order_id, channel, revenue, channel_ranking
FROM channel_position
WHERE channel_ranking <=3;


SELECT order_id, order_date, revenue, 
SUM(revenue) OVER (ORDER BY order_date 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders;

SELECT order_id, order_date, channel, revenue, 
SUM(revenue) OVER (PARTITION BY channel ORDER BY order_date 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_channel_revenue
FROM orders;

SELECT
    order_id,
    channel,
    revenue,
    SUM(revenue) OVER (
        PARTITION BY channel
    ) AS channel_total_revenue
FROM orders;
