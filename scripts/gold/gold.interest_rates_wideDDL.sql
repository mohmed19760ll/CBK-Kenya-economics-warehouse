IF OBJECT_ID('gold.interest_rates_wide','u') IS NOT NULL
	DROP VIEW gold.interest_rates_wide;
GO

CREATE VIEW gold.interest_rates_wide AS 
SELECT *
FROM 
(SELECT 
	d.date_key,
	d.date,
	d.year,
	d.month_name AS month,
	i.rate_type_code,
	i.rate
FROM gold.fact_interest_rates i
LEFT JOIN gold.dim_dates d
ON d.date_key = i.date_key) as unpvt
PIVOT(
		MAX(rate) FOR rate_type_code IN (REPO, REV_REPO, INTBK, TB91, TB182, TB364, CRR, CBR)
	) AS pvt