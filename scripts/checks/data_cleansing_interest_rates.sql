--DATA CLEANSING bronze.interest_rates

--Cleaning and standardizing nulls
SELECT 
       [YEAR],
      [MONTH],
      CASE WHEN Repo LIKE '%-%' THEN NULL
           ELSE Repo
      END AS repo,
      CASE WHEN [Reverse Repo] LIKE '%-%' THEN NULL
           ELSE [Reverse Repo] 
      END AS reverse_repo,
      CASE WHEN [Interbank Rate] LIKE '%-%' THEN NULL
           ELSE [Interbank Rate] 
      END AS interbank_rate,
      CASE WHEN [91-Day Tbill] LIKE '%-%' THEN NULL
           ELSE [91-Day Tbill] 
      END AS '91-day_tbill',
      CASE WHEN [182-days Tbill] LIKE '%-%' THEN NULL
           ELSE [182-days Tbill] 
      END AS '182-day_tbill',
      CASE WHEN [364-days Tbill] LIKE '%-%' THEN NULL
           ELSE [364-days Tbill] 
      END AS '364-day_tbill',
      CASE WHEN [Cash Reserve Requirement] LIKE '%-%' THEN NULL
           ELSE [Cash Reserve Requirement] 
      END AS Cash_reserve_requirement,
      CASE WHEN [Central Bank Rate] LIKE '%-%' THEN NULL
           ELSE [Central Bank Rate] 
      END AS central_bank_rate
FROM bronze.interest_rates

--merging Year and Month columns into one date
SELECT
Year,
Month,
CAST(
        (CONVERT(NVARCHAR,(CONVERT(FLOAT,(MAX(Year) OVER(ORDER BY id_)))))
        +'-'
        + RIGHT('0' + CAST(MONTH(TRY_CAST(Month + ' 1 2000' AS DATE)) AS NVARCHAR),2))
        +'-01'
        AS DATE)
        AS date
FROM
(
SELECT
ROW_NUMBER() OVER(ORDER BY (SELECT(NULL))) as id_,
YEAR AS Year,
CASE MONTH
    WHEN 'Sept' THEN 'Sep'
    ELSE MONTH
END AS Month
FROM bronze.interest_rates)t






