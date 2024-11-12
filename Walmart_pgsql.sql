select * from walmart;

------------------------------------------------------------------------------------
-- WALMART PROJECT QUERIES

SELECT COUNT(*) FROM walmart;

 -- 9969

SELECT payment_method , 
       COUNT(*)
FROM walmart
GROUP BY payment_method ;

-- "Credit card" 4256
-- "Ewallet"	 3881
-- "Cash"	     1832


SELECT COUNT(DISTINCT branch)
FROM walmart ;

-- 100

-- Q.1 Find different payment method and number of transactions, number of qty sold ?

select * from walmart ;

SELECT payment_method, 
	   COUNT(*) AS number_of_payment,
	   SUM(quantity) AS number_of_qty_sold
FROM walmart
GROUP BY payment_method ;


-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category & avg rating

SELECT * FROM walmart;

SELECT *
FROM
(	
	SELECT category
	        branch,
		    AVG(rating) AS avg_rating,
			RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS Rank
	FROM walmart
	GROUP BY category, branch 
)
WHERE Rank = 1;


-- Q.3 Identify the busiest day for each branch based on the number of transactions ?

SELECT * FROM walmart;

SELECT * FROM
(
SELECT branch,
	   TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY') AS day_name,
	   COUNT(*) AS no_transaction,
	   RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC ) AS Rank
FROM walmart 
GROUP BY branch, TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY')
)
WHERE Rank = 1 ;


-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT * FROM walmart ;

SELECT payment_method,
	   SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method ;


-- Q.5 Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT * FROM walmart ;

SELECT city, category,
       AVG(rating) AS average_rating,
       MIN(rating) AS min_rating,
	   MAX(rating) AS max_rating
FROM walmart
GROUP BY 1, 2 ;


-- Q.6 Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT * FROM walmart ; 

SELECT	category, 
		SUM(total) AS total_revenu,
		SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY category ;



-- Q.7 Determine the most common payment method for each Branch.Display Branch and the preferred_payment_method.

SELECT * FROM walmart;

WITH CTE
AS
(
	SELECT 
		branch,
		payment_method,
		COUNT(*) as total_transaction,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as Rank
	FROM walmart
	GROUP BY 1, 2
)
SELECT *
FROM CTE
WHERE Rank = 1 ;



-- Q.8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING.Find out each of the shift and number of invoices 

SELECT * FROM walmart ;

SELECT
		CASE
			WHEN EXTRACT (HOUR FROM (time::time)) < 12 THEN 'MORNING'
			WHEN EXTRACT (HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			ELSE 'EVENING'
		END shift_time,
		COUNT(*) AS number_of_invoice
FROM walmart
GROUP BY 1 
ORDER BY 2 DESC;


-- Q.9 Identify 5 branch with highest decrese ratio in revevenue compare to last year.
-- (current year 2023 and last year 2022)

SELECT * FROM walmart ;

-- [ revenu_decrese_ratio (rdr) = last_yr_revenue - current_yr_revenue / last_yr_revenue * 100  ]

WITH 
revenue_2022
AS
(
SELECT 
	branch,
	SUM(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 
GROUP BY 1
),
revenue_2023
AS
(
SELECT 
	branch,
	SUM(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND((ls.revenue - cs.revenue)::numeric/ls.revenue::numeric * 100, 2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5


