/* 
====================================================================
DDL Script: Create silver Tables
====================================================================
Script Purpose:
This script creates tables in the 'silver' schema. Dropping existing 
tables if they alredy exist.
Run this script to Re-define the DDL structure of 'silver' tables
=====================================================================
*/
CREATE OR ALTER PROCEDURE silver.silver_load AS 
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
        BEGIN TRY
            SET @batch_start_time = GETDATE();

            PRINT '========================================';
            PRINT 'Loading silver Layer';
            PRINT '========================================';


                ---- silver.exchange_rates ddl -----
                SET @start_time = GETDATE();

                PRINT '----------------------------------------';
                PRINT 'Loading exchange_rates Table';
                PRINT '----------------------------------------';

                IF OBJECT_ID ( 'silver.exchange_rates', 'u') IS NOT NULL
                    DROP TABLE silver.exchange_rates;
                SELECT  
                    CAST((  CASE WHEN Month != '10' and Month !=  '11' and Month !=  '12'  THEN Year + '-' + '0' + Month + '-' + '0' + '1'
	                                ELSE Year + '-' + Month + '-' + '0' + '1'
                            END ) AS DATE) AS date,
                        TRY_CAST([United States dollar] AS FLOAT) USD,
                        TRY_CAST([Sterling pound] AS FLOAT) GBP,
                        TRY_CAST([Euro] AS FLOAT) EUR,
                        TRY_CAST([South Africa Rand] AS FLOAT) ZAR,
                        TRY_CAST([Uganda shilling\2] AS FLOAT) UGX,
                        TRY_CAST([Tanzania shilling\2] AS FLOAT) TZS,
                        TRY_CAST([Rwanda Franc] AS FLOAT) RWF,
                        TRY_CAST([Burundi Franc] AS FLOAT) BIF,
                        TRY_CAST([AE Dirham] AS FLOAT) AED,
                        TRY_CAST([Deutch Mark] AS FLOAT) DEM,
                        TRY_CAST([Canadian dollar] AS FLOAT) CAD,
                        TRY_CAST([French franc] AS FLOAT) FRF,
                        TRY_CAST([Swiss franc] AS FLOAT) CHF,
                        TRY_CAST([Dutch guilder] AS FLOAT) NLG,
                        TRY_CAST([Italian lira] AS FLOAT) ITL,
                        TRY_CAST([Belgium franc] AS FLOAT) BEF,
                        (TRY_CAST([Japanese yen (100)] AS FLOAT)/100) JPY,
                        TRY_CAST([Swdish kroner] AS FLOAT) SEK,
                        TRY_CAST([Norwegian kroner] AS FLOAT) NOK,
                        TRY_CAST([Danish kroner] AS FLOAT) DKK,
                        TRY_CAST([Austrian schilling] AS FLOAT) ATS,
                        TRY_CAST([Finn marka] AS FLOAT) FIM,
                        TRY_CAST([Spanish peseta] AS FLOAT) ESP,
                        TRY_CAST([Indian rupee] AS FLOAT) INR,
                        TRY_CAST([Hong  kong dollar] AS FLOAT) HKD,
                        TRY_CAST([Singapore dollar] AS FLOAT) SGD,
                        TRY_CAST([Saudi riyal] AS FLOAT) SAR,
                        TRY_CAST([Chinese Yuan] AS FLOAT) CNY,
                        TRY_CAST([Australian dollar] AS FLOAT) AUD
                    INTO silver.exchange_rates
                    FROM [bronze].[exchange_rates];

                SET @end_time = GETDATE();
                PRINT '----------------------------------------------'
                PRINT '>>Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds'
                PRINT '----------------------------------------------'


                ---- silver.interest_rates ddl -----
                SET @start_time = GETDATE();

                PRINT '----------------------------------------';
                PRINT 'Loading interest_rates Table';
                PRINT '----------------------------------------';

                    IF OBJECT_ID ( 'silver.interest_rates', 'u') IS NOT NULL
                    DROP TABLE silver.interest_rates;
                WITH ranked AS (
                    SELECT
                        ROW_NUMBER() OVER(ORDER BY (SELECT(NULL))) as id_,
                        YEAR AS Year,
                        CASE MONTH
                            WHEN 'Sept' THEN 'Sep'
                            ELSE MONTH
                        END AS Month,
                        Repo, [Reverse Repo], [Interbank Rate], [91-Day Tbill],
                        [182-days Tbill], [364-days Tbill], [Cash Reserve Requirement],
                        [Central Bank Rate]
                    FROM bronze.interest_rates
                ),
                dated AS (
                    SELECT
                        CAST(
                            CONVERT(NVARCHAR, CONVERT(FLOAT, (MAX(Year) OVER(ORDER BY id_))))
                            + '-' 
                            + RIGHT('0' + CAST(MONTH(TRY_CAST(Month + ' 1 2000' AS DATE)) AS VARCHAR), 2)
                            + '-01'
                            AS DATE
                        ) AS date,
                        Repo, [Reverse Repo], [Interbank Rate], [91-Day Tbill],
                        [182-days Tbill], [364-days Tbill], [Cash Reserve Requirement],
                        [Central Bank Rate]
                    FROM ranked
                )

                SELECT 
                        date,
                        TRY_CAST(Repo AS FLOAT) AS repo,
                        TRY_CAST([Reverse Repo] AS FLOAT) AS reverse_repo,
                        TRY_CAST([Interbank Rate] AS FLOAT) AS interbank_rate,
                        TRY_CAST([91-Day Tbill] AS FLOAT) AS [91-day_tbill],
                        TRY_CAST([182-days Tbill] AS FLOAT) AS [182-day_tbill],
                        TRY_CAST([364-days Tbill] AS FLOAT) AS [364-day_tbill],
                        TRY_CAST([Cash Reserve Requirement] AS FLOAT) AS cash_reserve_requirement,
                        TRY_CAST([Central Bank Rate] AS FLOAT) AS central_bank_rate
                INTO silver.interest_rates
                FROM dated
                WHERE date IS NOT NULL;

                SET @end_time = GETDATE();
                PRINT '----------------------------------------------'
                PRINT '>>Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds'
                PRINT '----------------------------------------------'


            SET @batch_end_time = GETDATE();
            PRINT'======================================================'
            PRINT'Loading Silver Layer Completed!'
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