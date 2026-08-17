IF OBJECT_ID('gold.fact_exchange_rates','u') IS NOT NULL
	DROP TABLE gold.fact_exchange_rates;

SELECT date_key,currency_code,rate
INTO gold.fact_exchange_rates
FROM
	(SELECT 
	d.date_key,e.USD,e.GBP,e.EUR,e.ZAR,e.UGX,e.TZS,e.RWF,
	e.BIF,e.AED,e.DEM,e.CAD,e.FRF,e.CHF,e.NLG,
	e.ITL,e.BEF,e.JPY,e.SEK,e.NOK,e.DKK,e.ATS,
	e.FIM,e.ESP,e.INR,e.HKD,e.SGD,e.SAR,e.CNY,e.AUD

	FROM silver.exchange_rates as e
	LEFT JOIN gold.dim_dates as d
	ON d.date = e.date) AS Wide
UNPIVOT
(		rate FOR currency_code IN 
    (USD, GBP, EUR, ZAR, UGX, TZS, RWF, BIF, AED, DEM, CAD, FRF, CHF, NLG, ITL,
     BEF, JPY, SEK, NOK, DKK, ATS, FIM, ESP, INR, HKD, SGD, SAR, CNY, AUD)
) AS unpvt
