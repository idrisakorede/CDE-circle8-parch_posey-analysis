--- /* (a) Identify top-performing sales reps by total revenue (Top performers by total revenue: Sum of total_amt_usd from orders by sales rep). */ ---
SELECT sr.name AS sales_rep_name, sum(total_amt_usd) as total_revenue
FROM orders AS o
INNER JOIN accounts a ON a.id = o.account_id
INNER JOIN sales_reps sr ON sr.id = a.sales_rep_id
GROUP BY sales_rep_name
ORDER BY total_revenue DESC;

--- /* (b) Analyze sales rep performance by number of orders (Top performers by order volume: Count of orders per sales rep). */ ---
SELECT sr.name AS sales_rep_name, total AS total_orders_per_sales_rep
FROM orders AS o
INNER JOIN accounts a ON a.id = o.account_id
INNER JOIN sales_reps sr ON sr.id = a.sales_rep_id
GROUP BY sales_rep_name, total_orders_per_sales_rep
ORDER BY total_orders_per_sales_rep DESC;

--- /* (c) Calculate average order value per sales rep (Average order value per rep: total_amt_usd ÷ number of orders per rep(total)). */ ---
SELECT sr.name AS sales_rep_name,
       COALESCE(SUM(o.total_amt_usd) / NULLIF(COUNT(*), 0), 0) AS average_order_per_sales_rep
FROM orders AS o
INNER JOIN accounts a ON a.id = o.account_id
INNER JOIN sales_reps sr ON sr.id = a.sales_rep_id
GROUP BY sr.name
ORDER BY average_order_per_sales_rep DESC;

--- /* (d) Product mix performance: Analysis of standard_amt_usd, gloss_amt_usd, poster_amt_usd per rep (Revenue breakdown by paper type for each sales representative). */ ---
SELECT sr.name AS sales_rep_name,
		SUM(o.standard_amt_usd) AS standard_revenue,
		SUM(o.gloss_amt_usd) AS gloss_revenue,
		SUM(o.poster_amt_usd) AS poster_renue,
		SUM(o.total_amt_usd) AS total_revenue,
		--- Calculate the percentage (each revenue/total revenue) ---
		ROUND(SUM(o.standard_amt_usd) / SUM(o.total_amt_usd) * 100, 2) AS standard_percentage,
		ROUND(SUM(o.gloss_amt_usd) / SUM(o.total_amt_usd) * 100, 2) AS gloss_percentage,
		ROUND(SUM(o.poster_amt_usd) / SUM(o.total_amt_usd) * 100, 2) AS poster_percentage
FROM orders AS o
INNER JOIN accounts a ON a.id = o.account_id
INNER JOIN sales_reps sr ON sr.id = a.sales_rep_id
GROUP BY sr.name
ORDER BY SUM(o.gloss_amt_usd) + SUM(o.poster_amt_usd) DESC; -- Premium product focus (shows which reps are "premium product specialists" vs "volume sellers")



--- 2. ### Sales Rep Efficiency Metrics ### ---

--- /* (a) Revenue per account managed (Revenue efficiency: Total revenue ÷ number of accounts per rep to measure account management effectiveness). */ ---
SELECT sr.name AS sales_rep_name,
	   COUNT(DISTINCT a.id) AS number_of_accounts,
	   SUM(o.total_amt_usd) AS total_revenue,
	   ROUND(SUM(o.total_amt_usd) / COUNT(DISTINCT a.id), 2) AS revenue_per_account
FROM sales_reps AS sr
INNER JOIN accounts a ON a.sales_rep_id = sr.id
INNER JOIN orders o ON o.account_id = a.id
GROUP BY sr.id, sr.name
ORDER BY revenue_per_account DESC;

--- /* (b) Account portfolio size (Portfolio management: Number of accounts assigned to each sales rep to assess workload distribution). */ ---
SELECT sr.name AS sales_rep_name,
	   COUNT(DISTINCT a.id) AS number_of_accounts
FROM sales_reps AS sr
LEFT JOIN accounts a ON a.sales_rep_id = sr.id
GROUP BY sr.id, sr.name
ORDER BY number_of_accounts DESC;

--- /* (c) Order frequency (Account engagement: Average orders per account [Total number of orders ÷ Number of accounts] for each rep to measure customer relationship strength). */ ---
SELECT sr.name AS sales_rep_name,
	   COUNT(DISTINCT a.id) AS number_of_accounts,
	   COUNT(o.id) AS total_number_of_orders,
	   ROUND(COUNT(o.id) / COUNT(DISTINCT a.id), 2) AS avg_orders_per_account
FROM sales_reps AS sr
INNER JOIN accounts a ON a.sales_rep_id = sr.id
INNER JOIN orders o ON o.account_id = a.id
GROUP BY sr.id, sr.name
ORDER BY avg_orders_per_account DESC;

--- /* (d) Product specialization (Expertise analysis: Identify which reps excel at selling specific paper types - standard/gloss/poster - to determine specialization areas). */ ---
SELECT sr.name AS sales_rep_name,
    SUM(o.standard_qty) AS standard_qty_sold,
    SUM(o.gloss_qty) AS gloss_qty_sold,
    SUM(o.poster_qty) AS poster_qty_sold,
    SUM(o.total) AS total_qty_sold,
    -- Add specialization column
    CASE
        WHEN SUM(o.gloss_qty) > SUM(o.standard_qty) AND SUM(o.gloss_qty) > SUM(o.poster_qty) THEN 'Gloss Specialist'
        WHEN SUM(o.poster_qty) > SUM(o.standard_qty) AND SUM(o.poster_qty) > SUM(o.gloss_qty) THEN 'Poster Specialist'
        ELSE 'Standard Specialist'
    END AS primary_specialization
FROM orders AS o
INNER JOIN accounts a ON a.id = o.account_id
INNER JOIN sales_reps sr ON sr.id = a.sales_rep_id
GROUP BY sr.name
ORDER BY
    CASE
        WHEN SUM(o.gloss_qty) > SUM(o.standard_qty) AND SUM(o.gloss_qty) > SUM(o.poster_qty) THEN 1 -- Gloss specialist
        WHEN SUM(o.poster_qty) > SUM(o.standard_qty) AND SUM(o.poster_qty) > SUM(o.gloss_qty) THEN 2 -- Poster specialist
        ELSE 3 -- Standard specialist
    END,
    total_qty_sold DESC;



--- 3. ### Regional Sales Performance ### ---

--- /* (a) Sales rep performance by region (Regional breakdown: Analyze individual sales rep performance within each region using region → sales_reps relationship). */ ---
SELECT sr.name AS sales_rep_name,
	   r.name AS region,
	   SUM(o.total_amt_usd) AS total_revenue,
	   -- Rank within each region
       RANK() OVER (PARTITION BY r.name ORDER BY SUM(o.total_amt_usd) DESC) AS regional_rank,
       -- Rank across entire company
       RANK() OVER (ORDER BY SUM(o.total_amt_usd) DESC) AS overall_rank
FROM region AS r
INNER JOIN sales_reps sr ON r.id = sr.region_id
INNER JOIN accounts a ON sr.id = a.sales_rep_id
INNER JOIN orders o ON a.id = o.account_id
GROUP BY sr.name, r.name
ORDER BY
		r.name,
        regional_rank,
		overall_rank
		DESC;  -- Groups by region, ranks within region and across the entire company

--- /* (b) Regional revenue contribution (Regional totals: Calculate total revenue (total_amt_usd) by region through sales reps to measure regional market impact). */ ---
SELECT r.name AS region,
	   SUM(o.total_amt_usd) AS regional_revenue,
	   COUNT(o.id) AS total_orders,
	   COUNT(DISTINCT a.id) AS total_accounts,
	   -- Calculate percentage using window function
       ROUND(SUM(o.total_amt_usd) * 100.0 / SUM(SUM(o.total_amt_usd)) OVER(), 2) AS revenue_percentage
FROM region AS r
INNER JOIN sales_reps sr ON r.id = sr.region_id
INNER JOIN accounts a ON sr.id = a.sales_rep_id
INNER JOIN orders o ON a.id = o.account_id
GROUP BY r.name
ORDER BY regional_revenue DESC;

--- /* (c) Cross-regional performance comparison (Regional benchmarking: Compare regions to identify which have the strongest sales teams and highest performance metrics). */ ---
SELECT
    r.name AS region_name,

    -- Basic Regional Totals
    COUNT(DISTINCT sr.id) AS number_of_sales_reps,
    SUM(o.total_amt_usd) AS total_regional_revenue,
    COUNT(o.id) AS total_regional_orders,
    COUNT(DISTINCT a.id) AS total_regional_accounts,

    -- Average Performance Per Rep (Key Metrics)
    ROUND(SUM(o.total_amt_usd) / COUNT(DISTINCT sr.id), 2) AS avg_revenue_per_rep,
    ROUND(COUNT(o.id) * 1.0 / COUNT(DISTINCT sr.id), 2) AS avg_orders_per_rep,
    ROUND(COUNT(DISTINCT a.id) * 1.0 / COUNT(DISTINCT sr.id), 2) AS avg_accounts_per_rep,
    ROUND(SUM(o.total_amt_usd) / COUNT(o.id), 2) AS avg_order_value_regional,

    -- Regional Efficiency Metrics
    ROUND(SUM(o.total_amt_usd) / COUNT(DISTINCT a.id), 2) AS revenue_per_account_regional,
    ROUND(COUNT(o.id) * 1.0 / COUNT(DISTINCT a.id), 2) AS orders_per_account_regional,

    -- Regional Performance Rankings
    RANK() OVER (ORDER BY SUM(o.total_amt_usd) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY SUM(o.total_amt_usd) / COUNT(DISTINCT sr.id) DESC) AS avg_revenue_per_rep_rank,
    RANK() OVER (ORDER BY COUNT(o.id) * 1.0 / COUNT(DISTINCT sr.id) DESC) AS avg_orders_per_rep_rank,
    RANK() OVER (ORDER BY SUM(o.total_amt_usd) / COUNT(o.id) DESC) AS avg_order_value_rank,

    -- Market Share
    ROUND(SUM(o.total_amt_usd) * 100.0 / SUM(SUM(o.total_amt_usd)) OVER(), 2) AS regional_market_share_percent

FROM region r
INNER JOIN sales_reps sr ON r.id = sr.region_id
INNER JOIN accounts a ON sr.id = a.sales_rep_id
INNER JOIN orders o ON a.id = o.account_id
GROUP BY r.name
ORDER BY avg_revenue_per_rep DESC;

-- Additional : Overall Regional Performance Score
WITH regional_performance AS (
    SELECT
        r.name AS region_name,
        ROUND(SUM(o.total_amt_usd) / COUNT(DISTINCT sr.id), 2) AS avg_revenue_per_rep,
        ROUND(COUNT(o.id) * 1.0 / COUNT(DISTINCT sr.id), 2) AS avg_orders_per_rep,
        ROUND(SUM(o.total_amt_usd) / COUNT(o.id), 2) AS avg_order_value,

        -- Standardized performance scores (0-100 scale)
        ROUND(
            (RANK() OVER (ORDER BY SUM(o.total_amt_usd) / COUNT(DISTINCT sr.id) DESC) * 100.0 /
             COUNT(*) OVER()), 2) AS revenue_per_rep_score,
        ROUND(
            (RANK() OVER (ORDER BY COUNT(o.id) * 1.0 / COUNT(DISTINCT sr.id) DESC) * 100.0 /
             COUNT(*) OVER()), 2) AS orders_per_rep_score,
        ROUND(
            (RANK() OVER (ORDER BY SUM(o.total_amt_usd) / COUNT(o.id) DESC) * 100.0 /
             COUNT(*) OVER()), 2) AS avg_order_value_score

    FROM region r
    INNER JOIN sales_reps sr ON r.id = sr.region_id
    INNER JOIN accounts a ON sr.id = a.sales_rep_id
    INNER JOIN orders o ON a.id = o.account_id
    GROUP BY r.name
)
SELECT
    region_name,
    avg_revenue_per_rep,
    avg_orders_per_rep,
    avg_order_value,
    -- Overall Performance Score (weighted average)
    (revenue_per_rep_score * 0.5 + orders_per_rep_score * 0.3 + avg_order_value_score * 0.2) AS overall_performance_score,
    RANK() OVER (ORDER BY (revenue_per_rep_score * 0.5 + orders_per_rep_score * 0.3 + avg_order_value_score * 0.2) DESC) AS overall_rank
FROM regional_performance
ORDER BY overall_performance_score DESC;
