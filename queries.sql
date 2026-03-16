-- 1. Q4 Revenue Drop By Category

WITH q3_revenue_table AS
(
SELECT p.category, SUM(o.amount) AS Q3_revenue 
FROM orders o
JOIN products p
	ON p.product_id = o.product_id
WHERE o.order_date BETWEEN '2025-07-01' AND '2025-09-30'
GROUP BY p.category
ORDER BY p.category ASC
),
q4_revenue_table AS
(
SELECT p.category, SUM(o.amount) AS Q4_revenue 
FROM orders o
JOIN products p
	ON p.product_id = o.product_id
WHERE o.order_date BETWEEN '2025-10-01' AND '2025-12-31'
GROUP BY p.category
ORDER BY p.category ASC
)
SELECT q4.category Category, q3.Q3_revenue, q4.Q4_revenue,
ROUND (((q4.Q4_revenue - q3.Q3_revenue)/q3.Q3_revenue)*100,1) AS pct_change,
DENSE_RANK() OVER(ORDER BY ((q4.Q4_revenue - q3.Q3_revenue)/q3.Q3_revenue)*100) AS Priority_Rank
FROM q3_revenue_table q3
JOIN q4_revenue_table q4
	ON q3.category = q4.category
WHERE q3.Q3_revenue > q4.Q4_revenue 
ORDER BY pct_change ASC;

-- 2. Customer Churn Prediction

WITH customer_last_order AS
(
SELECT customer_id,
COUNT(order_id) AS total_orders,
MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id
)
SELECT c.customer_name,c.signup_date, o.total_orders, o.last_order_date,
DATEDIFF(CURDATE(), o.last_order_date) AS days_since_last_order
FROM customer_last_order o
JOIN customers c
	ON o.customer_id = c.customer_id
WHERE DATEDIFF(CURDATE(), o.last_order_date) >= 90 AND o.total_orders >=2
ORDER BY days_since_last_order DESC;

-- 3. Top_10%_Customers

WITH top_10_customers AS
(
SELECT c.customer_id,c.customer_name,
SUM(o.amount) AS Total_Spend,
DENSE_RANK() OVER(ORDER BY SUM(o.amount) DESC) AS Spend_Rank,
NTILE(10) OVER(ORDER BY SUM(o.amount)DESC) AS Percentile
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
)
SELECT * FROM top_10_customers
WHERE Percentile=1;


-- 4. Monthly Average Order Value(AOV)

SELECT 
MONTHNAME(order_date) AS `MONTH`,
COUNT(order_id) AS Total_Orders,
SUM(amount) AS Total_Revenue,
ROUND(SUM(amount)/COUNT(order_id),2) AS AOV
FROM orders
WHERE YEAR(order_date) = '2025'
GROUP BY MONTH(order_date),`MONTH`
ORDER BY MONTH(order_date) ;