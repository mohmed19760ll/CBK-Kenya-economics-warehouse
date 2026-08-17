/* 
====================================================================
DDL Script: Create gold Tables
====================================================================
Script Purpose:
This script creates tables in the 'gold' schema. Dropping existing 
tables if they alredy exist.
Run this script to Re-define the DDL structure of 'gold' tables
=====================================================================
*/

CREATE OR ALTER PROCEDURE gold.gold_load AS 
BEGIN

	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	
		BEGIN TRY

		SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'Loading gold Layer';
		PRINT '========================================';
		----------------------------------------------------
			--gold.dim_dates
			SET @start_time = GETDATE();
			PRINT '----------------------------------------';
			PRINT 'Loading dim_dates Table';
			PRINT '----------------------------------------';

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

			SET @end_time = GETDATE();
			PRINT '----------------------------------------------'
			PRINT '>>Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '----------------------------------------------'

		----------------------------------------------------
			--gold.dim_rates
			SET @start_time = GETDATE();
			PRINT '----------------------------------------';
			PRINT 'Loading dim_rates Table';
			PRINT '----------------------------------------';

			IF OBJECT_ID('gold.dim_rates','u') IS NOT NULL
				DROP TABLE gold.dim_rates;

			SELECT 
				rate_type_code,
				rate_type_name,
				rate_category
			INTO gold.dim_rates
			FROM ( VALUES
			  ('REPO',      'repo',                      'policy'),
			  ('REV_REPO',  'reverse_repo',              'policy'),
			  ('INTBK',     'interbank_rate',            'market'),
			  ('TB91',      '91-day_tbill',              'market'),
			  ('TB182',     '182-day_tbill',             'market'),
			  ('TB364',     '364-day_tbill',             'market'),
			  ('CRR',       'cash_reserve_requirement',  'policy'),
			  ('CBR',       'central_bank_rate',         'policy')
			)
			AS v(rate_type_code,rate_type_name,rate_category)

			SET @end_time = GETDATE();
			PRINT '----------------------------------------------'
			PRINT '>>Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '----------------------------------------------'

		----------------------------------------------------
			--gold.dim_currencies
			SET @start_time = GETDATE();
			PRINT '----------------------------------------';
			PRINT 'Loading dim_currencies Table';
			PRINT '----------------------------------------';

			IF OBJECT_ID ('gold.dim_currencies','u') IS NOT NULL
				DROP TABLE gold.dim_currencies;

			SELECT
				currency_code,
				currency_name,
				is_active,
				retired_year
			INTO gold.dim_currencies
			FROM (VALUES
				('USD', 'United States dollar',   1, NULL),
				('GBP', 'Sterling pound',         1, NULL),
				('EUR', 'Euro',                   1, NULL),
				('ZAR', 'South Africa Rand',      1, NULL),
				('UGX', 'Uganda shilling',        1, NULL),
				('TZS', 'Tanzania shilling',      1, NULL),
				('RWF', 'Rwanda Franc',           1, NULL),
				('BIF', 'Burundi Franc',          1, NULL),
				('AED', 'AE Dirham',              1, NULL),
				('DEM', 'Deutch Mark',            0, 1998),
				('CAD', 'Canadian dollar',        1, NULL),
				('FRF', 'French franc',           0, 1998),
				('CHF', 'Swiss franc',            1, NULL),
				('NLG', 'Dutch guilder',          0, 1998),
				('ITL', 'Italian lira',           0, 1998),
				('BEF', 'Belgium franc',          0, 1998),
				('JPY', 'Japanese yen',           1, NULL),
				('SEK', 'Swedish kroner',         1, NULL),
				('NOK', 'Norwegian kroner',       1, NULL),
				('DKK', 'Danish kroner',          1, NULL),
				('ATS', 'Austrian schilling',     0, 1998),
				('FIM', 'Finn marka',             0, 1998),
				('ESP', 'Spanish peseta',         0, 1998),
				('INR', 'Indian rupee',           1, NULL),
				('HKD', 'Hong kong dollar',       1, NULL),
				('SGD', 'Singapore dollar',       1, NULL),
				('SAR', 'Saudi riyal',            1, NULL),
				('CNY', 'Chinese Yuan',           1, NULL),
				('AUD', 'Australian dollar',      1, NULL)
			) AS v(currency_code, currency_name, is_active, retired_year);

			SET @end_time = GETDATE();
			PRINT '----------------------------------------------'
			PRINT '>>Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '----------------------------------------------'
		----------------------------------------------------
			--gold.fact_exchange_rates
			SET @start_time = GETDATE();
			PRINT '----------------------------------------';
			PRINT 'Loading fact_exchange_rates Table';
			PRINT '----------------------------------------';

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

			SET @end_time = GETDATE();
			PRINT '----------------------------------------------'
			PRINT '>>Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '----------------------------------------------'

		----------------------------------------------------
			--gold.fact_interest_rates
			SET @start_time = GETDATE();
			PRINT '----------------------------------------';
			PRINT 'Loading fact_interest_rates Table';
			PRINT '----------------------------------------';

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

			SET @end_time = GETDATE();
			PRINT '----------------------------------------------'
			PRINT '>>Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds'
			PRINT '----------------------------------------------'


		SET @batch_end_time = GETDATE();
		PRINT'======================================================'
		PRINT'Loading gold Layer Completed!'
		PRINT'>>Load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time)AS NVARCHAR) + ' seconds'
		PRINT'======================================================'

		END TRY
		BEGIN CATCH
			PRINT '=================================================';
			PRINT 'ERROR OCCURED';
			PRINT 'ERROR MESSAGE ' + ERROR_MESSAGE();
			PRINT 'ERROR NUMBER ' + CAST(ERROR_NUMBER() AS NVARCHAR);
			PRINT 'ERROR STATE ' + CAST(ERROR_STATE() AS NVARCHAR);
			PRINT '=================================================';
		END CATCH
END