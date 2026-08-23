--Deep Analysis

/*Before I start, I would like to note that i would be using 'TB91' or 'policy' where applicable, just swap it 
with your preference if need arises.*/

--Checking for zeros and negatives (theoretically its possible)
SELECT 
	rate
	--,MIN(rate) OVER()
FROM gold.fact_interest_rates   --*NOTE: just erase the hyphens were needed to get the desired query.
--WHERE rate = 0;

--NO zeros or negatives which is a relief.
-----------------------------------------------------------------------------------------------------------

--The anomalous period of Kenyan Economy
SELECT 
	date_key,
	rate
FROM
(SELECT 
	date_key,
	rate,
	STDEV(rate) OVER() AS stdv_rate,
	AVG(rate) OVER() AS avg_rate
FROM gold.fact_interest_rates
WHERE rate_type_code = 'TB91'
) AS t
WHERE rate > (avg_rate + stdv_rate*2)
ORDER BY rate DESC;
/* This period of time (FROM APR 1993 TO DEC 1993) the TB91(91-day_tbill) which was basically the standard policy rate
was flagged as a statistical outlier (>2 standard deviations above the30-year mean) — corresponds to Kenya's real 1993 financial crisis,
confirmed against external sources. */
----------------------------------------------------------------------------------------------------------------------------------------------------


--Month over Month change
--this is for a specific rate type
SELECT 
	d.date_key,
	d.month_number,
	i.rate_type_code,
	i.rate AS this_,
    LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key)AS last_,
    ROUND(((i.rate - LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))
      / LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))*100,2) AS [%change],
    ABS(ROUND(((i.rate - LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))
    / LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))*100,2)) AS [%changeABS]
FROM gold.fact_interest_rates AS i
LEFT JOIN gold.dim_dates AS d
ON d.date_key = i.date_key
WHERE rate_type_code = 'TB91'
ORDER BY [%changeABS] DESC;

--And this is for a specific rate category
SELECT 
	d.date_key,
	d.month_number,
	i.rate_type_code,
	i.rate AS this_,
    LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key)AS last_,
    ROUND(((i.rate - LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))
      / LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))*100,2) AS [%change],
    ABS(ROUND(((i.rate - LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))
    / LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))*100,2)) AS [%changeABS]
FROM gold.fact_interest_rates AS i
LEFT JOIN gold.dim_dates AS d
ON d.date_key = i.date_key
LEFT JOIN gold.dim_rates AS r
ON r.rate_type_code = i.rate_type_code
WHERE r.rate_category = 'policy'
ORDER BY [%changeABS] DESC;
--------------------------------------------------------------------------------------------

--Seasonality by month
SELECT 
    month_number,
    AVG(t.[%changeABS]) AS avg_change_abs
FROM
(
SELECT 
	d.date_key,
	d.month_number,
	i.rate_type_code,
	i.rate AS this_,
    LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key)AS last_,
    ROUND(((i.rate - LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))
      / LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))*100,2) AS [%change],
    ABS(ROUND(((i.rate - LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))
    / LAG(i.rate) OVER(PARTITION BY  i.rate_type_code ORDER BY i.date_key))*100,2)) AS [%changeABS]
FROM gold.fact_interest_rates AS i
LEFT JOIN gold.dim_dates AS d
ON d.date_key = i.date_key
WHERE rate_type_code = 'TB91'
)t
GROUP BY month_number
ORDER BY avg_change_abs DESC
/* It seems like JUNE has the highest avg MOM% change and january has the lowest.*/
--------------------------------------------------------------------------------------------------------------------------

--Decade drift
SELECT
    decade,
    this_,
    last_,
    ((this_-last_)/last_)*100 AS [%change]
FROM
(
SELECT
	d.decade,
	AVG(i.rate) AS this_,
	LAG(AVG(i.rate)) OVER(ORDER BY d.decade) AS last_
FROM gold.fact_interest_rates AS i
LEFT JOIN gold.dim_dates AS d
ON d.date_key = i.date_key
WHERE rate_type_code = 'TB91'
GROUP BY d.decade
)t;
/* We infer that the 1990-2000 decade had the highest avg rate following a steep 68.4% drop, from
24.56% to 7.76% rate then a steady climb from then and now the average for the TB91 sits at 9.89%*/

--Within decade volatitlity
SELECT 
    d.decade,
    AVG(i.rate) AS avg_rate,
    STDEV(i.rate) AS stdv_rate,
    (STDEV(i.rate)/AVG(i.rate))*100 AS rate_cv
FROM gold.fact_interest_rates AS i
LEFT JOIN gold.dim_dates AS d
ON d.date_key = i.date_key
WHERE i.rate_type_code = 'TB91' 
GROUP BY d.decade
ORDER BY rate_cv DESC;
/*Seems like the decade drift theory holds up here too with the 1990 decade
experiencing higher within decade movements hence higher volatility*/

--Highest and lowest month peaks
SELECT
    year,
    month_number,
    i.rate
FROM gold.fact_interest_rates AS i
LEFT JOIN gold.dim_dates AS d
ON d.date_key = i.date_key
WHERE rate_type_code = 'TB91'
ORDER BY i.rate --DESC;  
--Highest peak for TB91 is July 1993
--Lowest peak for TB91 is September 2003

