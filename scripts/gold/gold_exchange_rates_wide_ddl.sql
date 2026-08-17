IF OBJECT_ID('gold.exchange_rates_wide','u') IS NOT NULL
	DROP VIEW gold.exchange_rates_wide;
GO

CREATE VIEW gold.exchange_rates_wide AS 
SELECT *
FROM 
(SELECT 
	d.date_key,
	d.date,
	d.year,
	d.month_name AS month,
	e.currency_code,
	e.rate
FROM gold.fact_exchange_rates e
LEFT JOIN gold.dim_dates d
ON d.date_key = e.date_key) as unpvt
PIVOT(
		MAX(rate) FOR currency_code IN ([USD], [GBP], [EUR], [ZAR], [UGX], [TZS], [RWF], [BIF],
                                     [AED], [DEM], [CAD], [FRF], [CHF], [NLG], [ITL], [BEF],
                                     [JPY], [SEK], [NOK], [DKK], [ATS], [FIM], [ESP], [INR],
                                     [HKD], [SGD], [SAR], [CNY], [AUD])
	) AS pvt
