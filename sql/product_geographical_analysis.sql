/* top 10 total orders by region*/
SELECT rgn.name AS name_of_region, srs.name AS name_of_sales_rep, SUM(ors.total) AS total_sales FROM region AS rgn 
	INNER JOIN sales_reps AS srs ON rgn.id = srs.region_id
	INNER JOIN accounts AS act ON act.sales_rep_id = srs.id
	INNER JOIN orders AS ors ON ors.account_id = act.id
	GROUP BY name_of_region, name_of_sales_rep
	ORDER BY total_sales DESC LIMIT 10;
	
/* average orders by region*/
SELECT rgn.name AS name_of_region, AVG(ors.total) AS average_sales FROM region AS rgn 
	INNER JOIN sales_reps AS srs ON rgn.id = srs.region_id
	INNER JOIN accounts AS act ON act.sales_rep_id = srs.id
	INNER JOIN orders AS ors ON ors.account_id = act.id
	GROUP BY name_of_region
	ORDER BY average_sales DESC;

/* total revenue by region*/
SELECT rgn.name AS name_of_region, SUM(ors.total_amt_usd) AS total_revenue FROM region AS rgn 
	INNER JOIN sales_reps AS srs ON rgn.id = srs.region_id
	INNER JOIN accounts AS act ON act.sales_rep_id = srs.id
	INNER JOIN orders AS ors ON ors.account_id = act.id
	GROUP BY name_of_region
	ORDER BY total_revenue DESC;

/*average revenue by region*/
SELECT rgn.name AS name_of_region, AVG(ors.total_amt_usd) AS average_revenue FROM region AS rgn 
	INNER JOIN sales_reps AS srs ON rgn.id = srs.region_id
	INNER JOIN accounts AS act ON act.sales_rep_id = srs.id
	INNER JOIN orders AS ors ON ors.account_id = act.id
	GROUP BY name_of_region
	ORDER BY average_revenue DESC;

/* total gloss and poster quantity by region*/
SELECT rgn.name AS name_of_region, SUM(ors.gloss_qty) AS total_gloss_qty, SUM(ors.poster_qty) AS total_poster_qty FROM region AS rgn 
	INNER JOIN sales_reps AS srs ON rgn.id = srs.region_id
	INNER JOIN accounts AS act ON act.sales_rep_id = srs.id
	INNER JOIN orders AS ors ON ors.account_id = act.id
	GROUP BY name_of_region
	ORDER BY total_gloss_qty DESC;