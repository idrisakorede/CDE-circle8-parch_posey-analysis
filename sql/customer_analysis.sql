-- 1. What companies are the top ten customers
SELECT a.name, SUM(cast(o.total_amt_usd AS FLOAT)) AS total_sales
FROM public.accounts AS a
JOIN public.orders AS o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
