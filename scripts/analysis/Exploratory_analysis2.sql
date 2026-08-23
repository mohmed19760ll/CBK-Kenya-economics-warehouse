--Exploratory Analysis

--Average Interest rate per rate-type
SELECT 
	rate_type_code,
	AVG(rate) AS avg_rate
FROM gold.fact_interest_rates
GROUP BY rate_type_code
ORDER BY AVG(rate) DESC;

--Maximum Interest rate per rate-type
SELECT 
	rate_type_code,
	MAX(rate) AS max_rate
FROM gold.fact_interest_rates
GROUP BY rate_type_code
ORDER BY MAX(rate) DESC;

--Minimum Interest rate per rate-type
SELECT 
	rate_type_code,
	MIN(rate) AS min_rate
FROM gold.fact_interest_rates
GROUP BY rate_type_code
ORDER BY MIN(rate) DESC;

-- A General view of the aggregations
SELECT 
	rate_type_code,
	AVG(rate) AS avg_rate,
	MAX(rate) AS max_rate,
	MIN(rate) AS min_rate,
	MAX(rate) - MIN(rate) AS range_ --The range indicates how much each rate-type has moved
FROM gold.fact_interest_rates
GROUP BY rate_type_code
ORDER BY range_ DESC