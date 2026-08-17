IF OBJECT_ID ('gold.dim_dates','u') IS NOT NULL
DROP  TABLE gold.dim_dates;


SELECT 
	CAST(FORMAT(date,'yyyyMM') AS INT) as date_key,
	date,
	YEAR(date) AS year,
	MONTH(date) AS month_number,
	DATENAME(MONTH,date) AS month_name,
	CASE 
		WHEN MONTH(date) IN (1,2,3) THEN 1
		WHEN MONTH(date) IN (4,5,6) THEN 2
		WHEN MONTH(date) IN (7,8,9) THEN 3
	ELSE 4
	END quarter_number,
	CASE 
		WHEN YEAR(date) BETWEEN 1990 AND 1999 THEN '1990-2000'
		WHEN YEAR(date) BETWEEN 2000 AND 2009 THEN '2000-2010'
		WHEN YEAR(date) BETWEEN 2010 AND 2019 THEN '2010-2020'
		ELSE '2020-2030'
	END decade
INTO gold.dim_dates
FROM silver.interest_rates
UNION
SELECT 
	CAST(FORMAT(date,'yyyyMM') AS INT) as date_key,
	date,
	YEAR(date) AS year,
	MONTH(date) AS month_number,
	DATENAME(MONTH,date) AS month_name,
	CASE 
		WHEN MONTH(date) IN (1,2,3) THEN 1
		WHEN MONTH(date) IN (4,5,6) THEN 2
		WHEN MONTH(date) IN (7,8,9) THEN 3
	ELSE 4
	END quarter_number,
	CASE 
		WHEN YEAR(date) BETWEEN 1990 AND 1999 THEN '1990-2000'
		WHEN YEAR(date) BETWEEN 2000 AND 2009 THEN '2000-2010'
		WHEN YEAR(date) BETWEEN 2010 AND 2019 THEN '2010-2020'
		ELSE '2020-2030'
	END decade
FROM silver.exchange_rates

