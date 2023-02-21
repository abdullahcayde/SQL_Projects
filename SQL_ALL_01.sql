-- LIKE 
Select name
From accounts
Where name LIKE 'S%' OR name LIKE '%s';
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- IN , NOT IN
SELECT *
FROM web_events
WHERE channel NOT IN ('organic', 'adwords');
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- IS NULL, IS NOT NULL
Select *
From orders
Where total is NULL

or

SELECT orders.*, accounts.*
FROM accounts
LEFT JOIN orders
ON accounts.id = orders.account_id
Where orders.id is Null
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- AND , BETWEEN
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- COUNT, DISTINCT, SUM, MIN, MAX, AVG,
Select account_id, Count(total_amt_usd) cnt, Max(total_amt_usd) mx, AVG(total_amt_usd) avg_tt
From orders
Group By account_id
Order By account_id
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DATE_TRUNC, DATE_PART
Select Date_Part('year', occurred_at) as year, Date_Trunc('year', occurred_at)
From orders
------ In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT Date_Part('month', o.occurred_at) o_month, a.name, SUM(o.gloss_amt_usd) tt_gloss
FROM accounts a
JOIN orders o 
ON a.id = o.account_id
group by o_month, a.name
Having a.name = 'Walmart'
Order by 3 DESC Limit 1;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- JOIN (INNER JOIN)
SELECT orders.*, accounts.*
FROM accounts
JOIN orders
ON accounts.id = orders.account_id;

-- LEFT JOIN, FULL OUTER JOIN, RIGHT JOIN
SELECT orders.*, accounts.*
FROM accounts
LEFT JOIN orders
ON accounts.id = orders.account_id
Where accounts.id not in (Select account_id from orders);

or 

SELECT orders.*, accounts.*
FROM accounts
LEFT JOIN orders
ON accounts.id = orders.account_id
Where orders.id is Null



-- SQL Aggregations
-- COUNT, DISTINCT, SUM, MIN, MAX, AVG
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- HAVING (Group By dan sonra gelir)
-- How many of the sales reps have more than 5 accounts that they manage?
-- Having
Select s.name, Count(a.name) cnt_acc
From accounts a
Join sales_reps s
On s.id =a.sales_rep_id
Group By s.name
Having Count(a.name) > 5
Order BY 2;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- How many of the sales reps have more than 5 accounts that they manage?
-- SubQuery
SELECT COUNT(*) num_reps_above5
FROM(SELECT s.id, s.name, COUNT(*) num_accounts
	FROM accounts a
	JOIN sales_reps s
	ON s.id = a.sales_rep_id
	GROUP BY s.id, s.name
	HAVING COUNT(*) > 5
	ORDER BY num_accounts) AS Table1;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

--SUB QUERY
--Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
Select o.occurred_at, a.name
From orders o
Join accounts a
On a.id = o.account_id
Where o.occurred_at = (Select Min(occurred_at) From orders);

or

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CASE
Select CASE WHEN total_amt_usd < 3000 THEN 'Small'
			When total_amt_usd Between 3000 and 7000 Then 'large'
			ELSE 'XXL' END AS category_total,
			total_amt_usd, account_id
From orders
order by 2 DESC
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SQL Subqueries & Temporary Tables
--   • What is the top channel used by each account to market products? 
-- 	 • How often was that same channel used? 

SELECT t3.id, t3.name, t3.channel, t3.ct
FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
     FROM accounts a
     JOIN web_events we
     On a.id = we.account_id
     GROUP BY a.id, a.name, we.channel) T3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_chan
      FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events we
            ON a.id = we.account_id
            GROUP BY a.id, a.name, we.channel) t1
      GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_chan = t3.ct
ORDER BY t3.id ;

or

-- WITH 

With t1 as	(SELECT a.id, a.name, we.channel, COUNT(*) ct
        		FROM accounts a
         		JOIN web_events we
          		ON a.id = we.account_id
            	GROUP BY a.id, a.name, we.channel) ,
	t2 AS (Select t1.id, t1.name, MAX(ct) max_chan
		   From t1
		   Group By 1,2),
	t3 AS (SELECT a.id, a.name, we.channel, COUNT(*) ct
     		FROM accounts a
     		JOIN web_events we
     		On a.id = we.account_id
     		GROUP BY a.id, a.name, we.channel),
	t4 AS (Select t3.id, t3.name, t3.channel, t2.max_chan
		   From t3
		   Join t2
		   On t3.id = t2.id AND t2.max_chan = t3.ct)
Select *
From t4
Order By 1
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- LEFT, RIGHT
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 1 ELSE 0 END AS num, 
            CASE WHEN LEFT(UPPER(name), 1) NOT IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 1 ELSE 0 END AS letter
         FROM accounts) t1;

SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                           THEN 1 ELSE 0 END AS vowels, 
             CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                          THEN 0 ELSE 1 END AS other
            FROM accounts) t1;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- STRING_SPLIT
-- CONCAT, LEFT, RIGHT, and SUBSTR
SELECT CONCAT(SALES_REPS.ID, '_', REGION.NAME) EMP_ID_REGION, SALES_REPS.NAME
FROM SALES_REPS
JOIN REGION
ON SALES_REPS.REGION_ID = REGION.ID;

-- CAST
CAST ( expression AS target_type );
SELECT
	CAST ('100' AS INTEGER),
   CAST ('01-OCT-2015' AS DATE),
   CAST('true' AS BOOLEAN)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------  

-- POSITION, STRPOS, LENGTH, SUBSTR
-- Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc. 
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, primary_poc
FROM accounts;

SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, 
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, primary_poc
FROM accounts;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- COALESCE (Left joinde Diger taraftaki ID bos olmasin diye kullanilir)
SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL; 

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id,
COALESCE(o.account_id, a.id) account_id, o.occurred_at, o.standard_qty, o.gloss_qty, o.poster_qty, o.total, o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, 
COALESCE(o.account_id, a.id) account_id, o.occurred_at, 
COALESCE(o.standard_qty, 0) standard_qty, 
COALESCE(o.gloss_qty,0) gloss_qty, 
COALESCE(o.poster_qty,0) poster_qty, 
COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- WINDOW FUNCTION, OVER (PARTITION BY)
SELECT id,
       account_id,
       total_amt_usd,
       RANK() OVER (ORDER BY total_amt_usd DESC) AS total_rank
FROM orders

SELECT id,
       account_id,
       total_amt_usd,
       RANK() OVER (PARTITION BY account_id ORDER BY total_amt_usd DESC) AS total_rank
FROM orders

Select account_id, channel, occurred_at,
		Count(channel) OVER (PARTITION BY account_id Order by account_id) as cnt_cha,
		MAX(channel) OVER (PARTITION BY account_id Order by account_id) as max_cha
From web_events

SELECT standard_amt_usd,
       DATE_TRUNC('year', occurred_at) as year,
       SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS sum_standard_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS count_standard_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS avg_standard_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS min_standard_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS max_standard_qty
FROM orders

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- RANK()
-- Ranking Total Paper Ordered by Account
SELECT id,
       account_id,
       total_amt_usd,
       RANK() OVER (ORDER BY total_amt_usd DESC) AS total_rank
FROM orders

SELECT id,
       account_id,
       total,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders

-- Multiple WINDOW FUNCTIONS
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders 
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Percentiles with Partitions
SELECT
       account_id,
       occurred_at,
       total_amt_usd,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_quartile
FROM orders 
ORDER BY account_id 

SELECT
       account_id,
       occurred_at,
       total_amt_usd,
       NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders 
ORDER BY account_id DESC
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Inequality JOINs
SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Self JOINs (INTERVALS)
SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1 
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- EXtras
--3. Determine the number of times a particular channel was used in the web_events table for each sales rep.
-- Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
SELECT s.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY num_events DESC;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Find all the orders that occurred in 2015.
-- Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.

Select o.occurred_at, a.name, o.total, o.total_amt_usd
From orders o
Join accounts a
On a.id = o.account_id
Where Date_Part('year', occurred_at) = 2015

