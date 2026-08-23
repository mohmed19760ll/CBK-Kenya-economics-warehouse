--Exploratory Analysis

--Average rate against KES per currency over the time period of the dataset
SELECT 
	currency_code,
	AVG(rate) AS avg_rate
FROM gold.fact_exchange_rates
GROUP BY currency_code
ORDER BY AVG(rate) DESC;

--Maximum rate against KES per currency over the time period of the dataset
SELECT 
	currency_code,
	MAX(rate) AS max_rate
FROM gold.fact_exchange_rates
GROUP BY currency_code
ORDER BY MAX(rate) DESC;

--Minimum rate against KES per currency over the time period of the dataset
SELECT 
	currency_code,
	MIN(rate) AS min_rate
FROM gold.fact_exchange_rates
GROUP BY currency_code
ORDER BY MIN(rate) DESC;

-- A General view of the aggregations
SELECT 
	currency_code,
	AVG(rate) AS avg_rate,
	MAX(rate) AS max_rate,
	MIN(rate) AS min_rate,
	((MAX(rate) - MIN(rate))/ AVG(rate))*100 AS range_ --The range indicates how much each currency has moved against KES
FROM gold.fact_exchange_rates
GROUP BY currency_code
ORDER BY range_ DESC

--comments;
/*This mannner of range comparison is misleading 
because it conflates currency-specific volatility with KES's overall depreciation trend*/