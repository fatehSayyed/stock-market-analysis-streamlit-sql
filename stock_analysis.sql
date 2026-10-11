-- ===========================================================================
-- Stock Market Analysis - SQL script (DuckDB dialect)
-- Table: stock_data(trade_date DATE, company, open_price, high_price, low_price,
--        close_price, wap, no_of_shares, no_of_trades, total_turnover,
--        deliverable_quantity, pct_deliverable, spread_high_low,
--        spread_close_open, daily_return_pct)
-- Parameters used: company = 'TCS', range = 2015-01-01 .. 2018-07-31
-- Notes: data is historical (not live); prices may be unadjusted for corporate
--        actions; missing values are left as NULL.
-- ===========================================================================

-- ############ BEGINNER ############

-- Q1. First 10 records: Display the first 10 records of the dataset.
-- Concept: SELECT, ORDER BY, LIMIT
SELECT *
FROM stock_data
ORDER BY company, trade_date
LIMIT 10;

-- Q2. Count total records: Count how many rows the table holds.
-- Concept: COUNT(*)
SELECT COUNT(*) AS total_records
FROM stock_data;

-- Q3. Distinct companies: List every company in the dataset.
-- Concept: DISTINCT
SELECT DISTINCT company
FROM stock_data
ORDER BY company;

-- Q4. Minimum and maximum dates: Find the earliest and latest trading date.
-- Concept: MIN, MAX on dates
SELECT MIN(trade_date) AS first_date,
       MAX(trade_date) AS last_date
FROM stock_data;

-- Q5. Highest closing price per company: Highest close recorded for each company.
-- Concept: GROUP BY, MAX
SELECT company,
       MAX(close_price) AS highest_close
FROM stock_data
GROUP BY company
ORDER BY highest_close DESC;

-- Q6. Average closing price by company: Average close for each company.
-- Concept: GROUP BY, AVG, ROUND
SELECT company,
       ROUND(AVG(close_price), 2) AS avg_close
FROM stock_data
GROUP BY company
ORDER BY avg_close DESC;

-- Q7. Total turnover by company: Total traded value (Rs.) per company.
-- Concept: GROUP BY, SUM
SELECT company,
       SUM(total_turnover) AS total_turnover_rs
FROM stock_data
GROUP BY company
ORDER BY total_turnover_rs DESC;

-- Q8. Missing delivery quantities: Rows where deliverable quantity is missing.
-- Concept: IS NULL
SELECT company, trade_date, no_of_shares, deliverable_quantity, pct_deliverable
FROM stock_data
WHERE deliverable_quantity IS NULL
ORDER BY company, trade_date;

-- ############ INTERMEDIATE ############

-- Q9. Top 5 turnover dates (selected company): Five dates with the highest turnover for the selected company.
-- Concept: WHERE, ORDER BY DESC, LIMIT
SELECT trade_date, company, total_turnover, no_of_shares, close_price
FROM stock_data
WHERE company = 'TCS'
ORDER BY total_turnover DESC
LIMIT 5;

-- Q10. Rank companies by average close: Rank companies by their average closing price.
-- Concept: Aggregate + window RANK()
SELECT company,
       ROUND(AVG(close_price), 2) AS avg_close,
       RANK() OVER (ORDER BY AVG(close_price) DESC) AS price_rank
FROM stock_data
GROUP BY company
ORDER BY price_rank;

-- Q11. Monthly average close per company: Average closing price per company and month.
-- Concept: DATE_TRUNC, GROUP BY
SELECT company,
       DATE_TRUNC('month', trade_date)::DATE AS month,
       ROUND(AVG(close_price), 2) AS avg_close
FROM stock_data
GROUP BY company, month
ORDER BY company, month;

-- Q12. Monthly total turnover per company: Total turnover per company and month.
-- Concept: DATE_TRUNC, SUM
SELECT company,
       DATE_TRUNC('month', trade_date)::DATE AS month,
       SUM(total_turnover) AS monthly_turnover_rs
FROM stock_data
GROUP BY company, month
ORDER BY company, month;

-- Q13. Top 10 highest-volume days: The ten trading days with the most shares traded (any company).
-- Concept: ORDER BY, LIMIT
SELECT company, trade_date, no_of_shares, total_turnover, close_price
FROM stock_data
ORDER BY no_of_shares DESC
LIMIT 10;

-- Q14. Opening vs closing prices: Compare each company's average open and close and how often it closed above the open.
-- Concept: Conditional aggregation (CASE)
SELECT company,
       ROUND(AVG(open_price), 2)  AS avg_open,
       ROUND(AVG(close_price), 2) AS avg_close,
       ROUND(AVG(close_price - open_price), 2) AS avg_close_minus_open,
       ROUND(100.0 * SUM(CASE WHEN close_price > open_price THEN 1 ELSE 0 END) / COUNT(*), 1)
           AS pct_days_close_above_open
FROM stock_data
GROUP BY company
ORDER BY pct_days_close_above_open DESC;

-- Q15. Close above 30-day moving average: Days when the close was above its 30-day moving average (full 30-day windows only).
-- Concept: CTE + window AVG, filter on window result
WITH ma AS (
    SELECT company, trade_date, close_price,
           AVG(close_price) OVER w AS ma30,
           COUNT(*) OVER w AS window_size
    FROM stock_data
    WINDOW w AS (PARTITION BY company ORDER BY trade_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
)
SELECT company, trade_date, close_price, ROUND(ma30, 2) AS ma30
FROM ma
WHERE window_size = 30 AND close_price > ma30
ORDER BY company, trade_date;

-- Q16. Daily returns with window functions: Daily % return per company using LAG().
-- Concept: LAG(), PARTITION BY, ORDER BY
SELECT company, trade_date, close_price,
       ROUND((close_price / LAG(close_price) OVER (PARTITION BY company ORDER BY trade_date) - 1) * 100, 4)
           AS daily_return_pct
FROM stock_data
ORDER BY company, trade_date;

-- Q17. Identify duplicate records: Find company/date combinations that appear more than once.
-- Concept: GROUP BY ... HAVING
SELECT company, trade_date, COUNT(*) AS occurrences
FROM stock_data
GROUP BY company, trade_date
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, company, trade_date;

-- Q18. Average trading volume by company: Compare average daily shares traded and trades per company.
-- Concept: AVG on several columns
SELECT company,
       ROUND(AVG(no_of_shares), 0) AS avg_daily_shares,
       ROUND(AVG(no_of_trades), 0) AS avg_daily_trades
FROM stock_data
GROUP BY company
ORDER BY avg_daily_shares DESC;

-- ############ ADVANCED ############

-- Q19. 30-day moving average: 30-day moving average of the close (reported only for full windows).
-- Concept: Window frame ROWS BETWEEN, named WINDOW
SELECT company, trade_date, close_price,
       CASE WHEN COUNT(*) OVER w = 30 THEN ROUND(AVG(close_price) OVER w, 2) END AS ma30
FROM stock_data
WINDOW w AS (PARTITION BY company ORDER BY trade_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
ORDER BY company, trade_date;

-- Q20. 90-day moving average: 90-day moving average of the close (reported only for full windows).
-- Concept: Window frame with a longer window
SELECT company, trade_date, close_price,
       CASE WHEN COUNT(*) OVER w = 90 THEN ROUND(AVG(close_price) OVER w, 2) END AS ma90
FROM stock_data
WINDOW w AS (PARTITION BY company ORDER BY trade_date ROWS BETWEEN 89 PRECEDING AND CURRENT ROW)
ORDER BY company, trade_date;

-- Q21. RANK vs DENSE_RANK of daily returns: On each date, rank the companies by their daily return.
-- Concept: RANK(), DENSE_RANK(), PARTITION BY date
SELECT trade_date, company,
       ROUND(daily_return_pct, 4) AS daily_return_pct,
       RANK()       OVER (PARTITION BY trade_date ORDER BY daily_return_pct DESC) AS rnk,
       DENSE_RANK() OVER (PARTITION BY trade_date ORDER BY daily_return_pct DESC) AS dense_rnk
FROM stock_data
WHERE daily_return_pct IS NOT NULL
ORDER BY trade_date, rnk;

-- Q22. Highest and lowest close dates: Date and value of each company's highest and lowest close.
-- Concept: ROW_NUMBER + conditional aggregation
WITH ranked AS (
    SELECT company, trade_date, close_price,
           ROW_NUMBER() OVER (PARTITION BY company ORDER BY close_price DESC, trade_date) AS hi_rank,
           ROW_NUMBER() OVER (PARTITION BY company ORDER BY close_price ASC,  trade_date) AS lo_rank
    FROM stock_data
)
SELECT company,
       MAX(CASE WHEN hi_rank = 1 THEN trade_date  END) AS highest_close_date,
       MAX(CASE WHEN hi_rank = 1 THEN close_price END) AS highest_close,
       MAX(CASE WHEN lo_rank = 1 THEN trade_date  END) AS lowest_close_date,
       MAX(CASE WHEN lo_rank = 1 THEN close_price END) AS lowest_close
FROM ranked
GROUP BY company
ORDER BY company;

-- Q23. Cumulative turnover: Running total of turnover per company.
-- Concept: SUM() OVER with UNBOUNDED PRECEDING
SELECT company, trade_date, total_turnover,
       SUM(total_turnover) OVER (
           PARTITION BY company ORDER BY trade_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_turnover
FROM stock_data
ORDER BY company, trade_date;

-- Q24. Running maximum close: Highest close seen so far (all-time high to date) per company.
-- Concept: MAX() OVER running frame
SELECT company, trade_date, close_price,
       MAX(close_price) OVER (
           PARTITION BY company ORDER BY trade_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_max_close
FROM stock_data
ORDER BY company, trade_date;

-- Q25. Consecutive positive / negative streaks: Runs of at least 3 consecutive trading days with the same return direction.
-- Concept: Gaps-and-islands with two ROW_NUMBERs
WITH r AS (
    SELECT company, trade_date, daily_return_pct,
           CASE WHEN daily_return_pct > 0 THEN 'Positive'
                WHEN daily_return_pct < 0 THEN 'Negative'
                ELSE 'Flat' END AS direction
    FROM stock_data
    WHERE daily_return_pct IS NOT NULL
),
g AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY company ORDER BY trade_date)
         - ROW_NUMBER() OVER (PARTITION BY company, direction ORDER BY trade_date) AS grp
    FROM r
)
SELECT company, direction,
       MIN(trade_date) AS streak_start,
       MAX(trade_date) AS streak_end,
       COUNT(*)        AS trading_days
FROM g
WHERE direction <> 'Flat'
GROUP BY company, direction, grp
HAVING COUNT(*) >= 3
ORDER BY trading_days DESC, company, streak_start
LIMIT 100;

-- Q26. Monthly returns (first vs last observation): Return from the first to the last valid close of each month.
-- Concept: arg_min / arg_max (DuckDB)
SELECT company,
       DATE_TRUNC('month', trade_date)::DATE AS month,
       arg_min(close_price, trade_date) AS first_close,
       arg_max(close_price, trade_date) AS last_close,
       ROUND((arg_max(close_price, trade_date) / arg_min(close_price, trade_date) - 1) * 100, 2)
           AS monthly_return_pct
FROM stock_data
WHERE close_price IS NOT NULL
GROUP BY company, month
ORDER BY company, month;

-- Q27. Volatility of daily returns: Standard deviation of daily returns per company (also annualised).
-- Concept: STDDEV_SAMP, SQRT
SELECT company,
       COUNT(daily_return_pct) AS observations,
       ROUND(AVG(daily_return_pct), 4) AS avg_daily_return_pct,
       ROUND(STDDEV_SAMP(daily_return_pct), 4) AS daily_volatility_pct,
       ROUND(STDDEV_SAMP(daily_return_pct) * SQRT(252), 2) AS annualised_volatility_pct
FROM stock_data
GROUP BY company
ORDER BY daily_volatility_pct DESC;

-- Q28. Top performers over a date range: Rank companies by return between two dates (first to last close in range).
-- Concept: CTE + arg_min/arg_max + RANK()
WITH r AS (
    SELECT company,
           MIN(trade_date) AS first_date,
           MAX(trade_date) AS last_date,
           arg_min(close_price, trade_date) AS start_close,
           arg_max(close_price, trade_date) AS end_close
    FROM stock_data
    WHERE trade_date BETWEEN DATE '2015-01-01' AND DATE '2018-07-31'
    GROUP BY company
)
SELECT company, first_date, last_date, start_close, end_close,
       ROUND((end_close / start_close - 1) * 100, 2) AS period_return_pct,
       RANK() OVER (ORDER BY end_close / start_close DESC) AS performance_rank
FROM r
ORDER BY performance_rank;
