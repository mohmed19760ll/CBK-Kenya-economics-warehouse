--DATA CLEANSING bronze.exchange_rates


--FIXING DATETIME -merging the year and month into one date.
SELECT 
CASE WHEN Month != '10' and Month !=  '11' and Month !=  '12'  THEN Year + '-' + '0' + Month + '-' + '0' + '1'
	 ELSE Year + '-' + Month + '-' + '0' + '1'
END AS Date
FROM bronze.exchange_rates 

--CASTING DATA -from Nvarchar to correct data-type
SELECT Euro
FROM bronze.exchange_rates
WHERE Euro = ''

SELECT 
TRY_CAST (Euro AS FLOAT)
FROM bronze.exchange_rates

select *
from bronze.exchange_rates
