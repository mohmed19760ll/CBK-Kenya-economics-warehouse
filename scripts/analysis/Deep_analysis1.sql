--Deep Analysis

--Finding the most stable currency
SELECT 
	currency_code,
	COUNT(*) AS n,
	STDEV(rate) AS stdv_rate,
	AVG(rate) AS avg_rate,
	(STDEV(rate) / AVG(rate))*100 AS rate_cv
FROM gold.fact_exchange_rates
GROUP BY currency_code
HAVING COUNT(*) = 376
ORDER BY rate_cv;
/* According to the output INR is the most stable currency over the 4 decades.*/

-- using the most stable currency to point out KES anomalous activities
SELECT 
    date_key,
    rate
FROM (
    SELECT 
        date_key,
        rate,
        STDEV(rate) OVER() AS stdv_rate,
        AVG(rate) OVER() AS avg_rate
    FROM gold.fact_exchange_rates
    WHERE currency_code = 'INR'
) AS t
WHERE rate > (avg_rate + stdv_rate * 2)
ORDER BY rate DESC;
/* INR was chosen as a stable control currency,
but research revealed India also floated its own currency in March 1993 — 
meaning this result can't cleanly isolate KES-specific causes.
It may instead reflect a broader wave of developing-economy 
currency liberalization in the early 1990s */

/*Multiple independent signals (TB91, INR) point to 1993 being an 
unusual year for the Kenyan economy — though the INR signal is confounded 
by India's own currency float that same year, so treat it as suggestive, not conclusive.*/

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--Month over Month %change
SELECT
    e.date_key,
    d.date,
    e.currency_code,
    e.rate AS this_,
    LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key)AS last_,
    ROUND(((e.rate - LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key))
      / LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key))*100,2) AS [%change],
    ABS(ROUND(((e.rate - LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key))
    / LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key))*100,2)) AS [%changeABS]
FROM gold.fact_exchange_rates AS e
LEFT JOIN gold.dim_dates AS d
ON d.date_key = e.date_key
ORDER BY [%changeABS] DESC;

--Seasonality by month
SELECT 
    month_number,
    AVG(t.[%changeABS]) AS avg_change_abs
FROM
(SELECT
    e.date_key,
    d.date,
    month_number,
    e.currency_code,
    e.rate AS this_,
    LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key)AS last_,
    ROUND(((e.rate - LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key))
      / LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key))*100,2) AS [%change],
    ABS(ROUND(((e.rate - LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key))
    / LAG(e.rate) OVER(PARTITION BY  e.currency_code ORDER BY e.date_key))*100,2)) AS [%changeABS]
FROM gold.fact_exchange_rates AS e
LEFT JOIN gold.dim_dates AS d
ON d.date_key = e.date_key
WHERE currency_code = 'USD'
)t
GROUP BY month_number
ORDER BY avg_change_abs DESC
/* seems like May contains the most monthly volatility across the data period
while february has the least*/

--decade over decade drift
SELECT
    decade,
    this_,
    last_,
    ((this_-last_)/last_)*100 AS [%change]
FROM
(SELECT
    d.decade,
    AVG(e.rate) AS this_,
    LAG(AVG(e.rate)) OVER(ORDER BY d.decade ) AS last_
FROM gold.fact_exchange_rates e
LEFT JOIN gold.dim_dates d
ON d.date_key = e.date_key
WHERE currency_code = 'USD' --you can adjust for whichever currency here.
GROUP BY d.decade)t;

/*It seems like out of the two documented decades (the first decade has no documented decade prior
and the last decade is currently not completed) the 2000-2010 decade held the highest drift,
findings might change over time*/

--Highest and lowest month peaks
SELECT
    year,
    month_number,
    e.rate
FROM gold.fact_exchange_rates AS e
LEFT JOIN gold.dim_dates AS d
ON d.date_key = e.date_key
WHERE currency_code = 'USD'
ORDER BY e.rate;
-- 2024-JAN has the highest recorded rate for USD/KES at 159.69
-- 1993-JAN has the lowest recorded rate for USD/KES at 36.22

-- Within decade volatility
SELECT 
    d.decade,
    e.currency_code,
    STDEV(e.rate) AS stdv_rate,
    (STDEV(e.rate)/AVG(e.rate))*100 AS rate_cv
FROM gold.fact_exchange_rates AS e
LEFT JOIN gold.dim_dates AS d
ON d.date_key = e.date_key
WHERE e.currency_code = 'USD' --this currency is the one I'm using as a reference,feel free to replace it.
GROUP BY d.decade,e.currency_code
ORDER BY rate_cv;
/* Assuming the USD was fairly stable which it wasn't to be honest,
the decade with most volatility within was 1990-2000*/
--------------------------------------------------------------------------------------------------------------

--Depreciation rate of KES over the data period
WITH CAGR_query AS 
(
SELECT TOP 1
    MIN(d.date) OVER() AS start_date,
    MAX(d.date) OVER() AS end_date,
    FIRST_VALUE(e.rate) OVER(ORDER BY d.date_key) AS start_rate,
    LAST_VALUE(e.rate) OVER(ORDER BY d.date_key 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS end_rate
FROM gold.fact_exchange_rates AS e
LEFT JOIN gold.dim_dates AS d 
ON d.date_key = e.date_key
WHERE e.currency_code = 'USD'
)
SELECT 
    (end_rate/start_rate)*100 AS dep_rate,
    (POWER((end_rate/start_rate),(1.0/(DATEDIFF(YEAR,start_date,end_date)))) - 1) AS Raw_CAGR,
    CAST(((POWER((end_rate/start_rate),(1.0/(DATEDIFF(YEAR,start_date,end_date)))) - 1)*100)
    AS NVARCHAR) + '%' AS clean_CAGR
FROM CAGR_query;

/*KES depreciated by a compound annual rate of 4.25%,
which compounds to roughly a 263% total increase over the period 
(rate is now ~3.63x what it was at the start)." */