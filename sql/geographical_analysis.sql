-- 6 What are the highest and lowest selling areas and what is the quantity sold for each area
SELECT r.name, SUM(cast(o.total_amt_usd AS FLOAT)) AS quantity_products,
       (SUM(cast(standard_amt_usd AS FLOAT)) + SUM(cast(gloss_amt_usd AS FLOAT)) 
	   + SUM(cast(gloss_amt_usd AS FLOAT))) AS total_sales
FROM public.orders AS o
JOIN public.accounts a
ON a.id = o.account_id
JOIN public.sales_reps AS s
ON s.id = a.sales_rep_id
JOIN public.region AS r
ON r.id = s.region_id
GROUP BY 1
ORDER BY 3 DESC;
