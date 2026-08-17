IF OBJECT_ID('gold.fact_interest_rates','u') IS NOT NULL
    DROP TABLE gold.fact_interest_rates;

SELECT date_key,rate_type_code,rate
INTO gold.fact_interest_rates
FROM
(SELECT 
	d.date_key,
    r.repo AS REPO,
    r.reverse_repo AS REV_REPO,
    r.interbank_rate AS INTBK,
    r.[91-day_tbill] AS TB91,
    r.[182-day_tbill] AS TB182,
    r.[364-day_tbill] AS TB364,
    r.cash_reserve_requirement AS CRR,
    r.central_bank_rate AS CBR
FROM silver.interest_rates AS r
LEFT JOIN gold.dim_dates AS d
ON d.date = r.date) as WIDE
UNPIVOT(
		rate FOR rate_type_code IN 
		(REPO,REV_REPO,INTBK,TB91,TB182,TB364,CRR,CBR)
		) AS unpvt
