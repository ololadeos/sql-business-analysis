# SQL Business Analysis | Sales Performance

## Project overview
A SQLite business analysis project using a practice retail sales dataset covering April–June 2026. The scenario is to support sales management in understanding completed sales, channel and customer performance, high-value orders and changes in revenue over time.

## Business objectives
- Measure completed revenue, order volume and average order value.
- Identify the strongest channels, customers, product categories and regions.
- Compare individual completed orders against overall and channel averages.
- Rank orders and customers using window functions.
- Track cumulative revenue and changes between consecutive completed orders.

## Dataset

| Table | Records | Purpose |
|---|---:|---|
| orders | 260 | Order transactions, revenue, status and channel |
| customers | 40 | Customer names, segments and regions |
| products | 12 | Product categories and standard prices |
| sales_reps | 8 | Sales representative information |
| region_targets | 6 | Quarterly regional revenue targets |
| returns | 12 | Return transactions and refund amounts |

Orders can be joined to customers, products and sales representatives using their respective IDs. Returns can be associated with orders using order_id; regional targets are linked logically by region and quarter. The dataset is synthetic and these are logical relationships rather than enforced foreign keys.

## Repository guide

| Script | Purpose |
|---|---|
| [01 — Data exploration](sql/01_data_exploration.sql) | Filtering, sorting, distinct values and null checks |
| [02 — Sales performance](sql/02_sales_performance.sql) | Aggregations, GROUP BY, HAVING and CASE expressions |
| [03 — Customer and product analysis](sql/03_customer_and_product_analysis.sql) | Joins and grouped business metrics |
| [04 — Advanced SQL](sql/04_advanced_sql_analysis.sql) | Subqueries, CTEs, rankings and window aggregates |
| [05 — Sales performance capstone](sql/05_sales_performance_capstone.sql) | Integrated management analysis using CTEs and window functions |

The [source data](data/) and [SQLite database](database/sales_analysis.sqlite) are included for reproduction.

## Sales performance results

Completed orders are the basis for revenue performance unless explicitly stated otherwise.

| KPI | Result |
|---|---:|
| Total orders | 260 |
| Completed orders | 169 |
| Completion rate | 65.0% |
| Completed revenue | $170,911.65 |
| Average completed order value | $1,011.31 |
| Completed orders above average revenue | 46 |

## Selected SQL analyses

### 1. Sales channel performance
**Business question:** Which sales channels generate the most completed revenue?

```sql
SELECT channel, SUM(revenue) AS total_revenue
FROM orders
WHERE status = 'Completed'
GROUP BY channel;
```

| Channel | Completed orders | Completed revenue |
|---|---:|---:|
| Partner | 58 | $70,796.15 |
| Store | 53 | $51,520.03 |
| Online | 58 | $48,595.47 |

Partner accounts for 41.4% of completed revenue. Partner and Online have equal completed order counts, but Partner generates substantially more revenue. The order counts above were calculated separately using COUNT(*) grouped by channel.

### 2. Customer revenue ranking
**Business question:** Who are the top five customers based on completed sales?

```sql
WITH customer_revenue AS (
    SELECT c.customer_name,
           SUM(revenue) AS completed_revenue
    FROM orders AS o
    JOIN customers AS c ON o.customer_id = c.customer_id
    WHERE status = 'Completed'
    GROUP BY customer_name
),
customer_completed_rank AS (
    SELECT cr.customer_name, cr.completed_revenue,
           DENSE_RANK() OVER (
               ORDER BY cr.completed_revenue DESC
           ) AS customer_rank
    FROM customer_revenue AS cr
)
SELECT * FROM customer_completed_rank AS ccr
WHERE ccr.customer_rank <= 5;
```

| Rank | Customer | Completed revenue |
|---:|---|---:|
| 1 | Customer 13 | $14,789.70 |
| 2 | Customer 27 | $12,525.09 |
| 3 | Customer 12 | $11,070.00 |
| 4 | Customer 09 | $10,225.88 |
| 5 | Customer 40 | $9,487.00 |

### 3. Product category performance
**Business question:** Which product categories contribute the most completed revenue?

```sql
SELECT category, SUM(revenue) AS total_revenue,
       COUNT(order_id) AS number_orders
FROM orders AS o
JOIN products AS p ON o.product_id = p.product_id
WHERE status = 'Completed'
GROUP BY category
ORDER BY total_revenue DESC;
```

Selected output (revenue):

| Category | Completed revenue |
|---|---:|
| Furniture | $114,540.28 |
| Technology | $37,646.42 |
| Storage | $10,154.55 |
| Accessories | $6,417.60 |
| Supplies | $1,876.80 |

### 4. Top three completed orders per channel
**Business question:** Which individual orders generated the highest revenue within each channel?

```sql
WITH channel_ranking AS (
    SELECT order_id, channel, revenue,
           ROW_NUMBER() OVER (
               PARTITION BY channel ORDER BY revenue DESC
           ) AS channel_position
    FROM orders
    WHERE status = 'Completed'
)
SELECT * FROM channel_ranking AS c
WHERE c.channel_position <= 3;
```

| Channel | Order ID | Revenue | Position |
|---|---|---:|---:|
| Online | O0111 | $7,794.00 | 1 |
| Online | O0192 | $5,196.00 | 2 |
| Online | O0231 | $2,992.43 | 3 |
| Partner | O0201 | $9,093.00 | 1 |
| Partner | O0258 | $7,404.30 | 2 |
| Partner | O0055 | $7,014.60 | 3 |
| Store | O0112 | $7,794.00 | 1 |
| Store | O0043 | $7,014.60 | 2 |
| Store | O0005 | $2,677.44 | 3 |

### 5. Running revenue and previous-order comparisons
**Business question:** How does completed revenue accumulate within each channel?

```sql
SELECT order_id, order_date, channel, revenue,
       ROUND(SUM(revenue) OVER (
           PARTITION BY channel
           ORDER BY order_date, order_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ), 2) AS running_completed_revenue
FROM orders
WHERE status = 'Completed';
```

This query retains transaction-level detail while calculating cumulative channel revenue. The capstone also uses LAG to compare each order with the preceding completed order in its channel. These comparisons are transaction-level, not month-over-month growth.

## Key findings and recommendations
- **Channel performance:** Partner leads with $70,796.15; investigate its order mix and average order value relative to Online.
- **Customer concentration:** The top five customers account for approximately 34% of completed revenue; monitor retention and concentration exposure.
- **Product mix:** Furniture represents approximately 67% of completed revenue; assess category margins and inventory requirements before expanding investment.
- **Regional performance:** Quebec leads with $45,240.16, while Alberta records $9,817.64; investigate demand, customer mix and regional targets before drawing conclusions.
- **Order completion:** 91 of 260 orders are not completed; investigate pending, cancelled and returned statuses separately to identify actionable causes.

## Limitations
- The dataset is a practice dataset covering one quarter; it does not establish long-term trends or causal relationships.
- Completed revenue is a reporting definition, not audited net revenue. Refunds and costs are not deducted in these metrics; profitability is not evaluated.
- Ranking with ROW_NUMBER returns exactly three orders per channel here; a secondary ordering key would make tie handling deterministic in other datasets.
- Recommendations are hypotheses for further investigation, not proven business outcomes.

## Reproduce the analysis
1. Download or clone this repository.
2. Open database/sales_analysis.sqlite in DB Browser for SQLite or another SQLite client with window function support.
3. Open the scripts under sql/ and execute individual statements to inspect their results.
4. Use the included CSVs to inspect source data or recreate the tables.

## Skills demonstrated
SQLite · Data exploration · Filtering · Conditional logic · Aggregations · INNER and LEFT JOINs · Subqueries · CTEs · ROW_NUMBER · RANK · DENSE_RANK · LAG · Running totals · Business analysis

This portfolio project consolidates SQL practice and a sales analysis capstone into a reproducible business case. Query excerpts have been formatted for readability and selected outputs are presented as tables rather than dashboards.
