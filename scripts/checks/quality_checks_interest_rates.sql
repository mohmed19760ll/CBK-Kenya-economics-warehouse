/*
====================================================================
Quality Checks: silver.interest_rates
====================================================================
Purpose:
Non-destructive validation queries to sanity-check the Silver layer
after loading. Each query should return ZERO rows if the data is clean.
A query returning rows flags something worth investigating.
====================================================================
*/

-- 1. Check for NULL dates (would mean the year forward-fill or date logic failed)
SELECT *
FROM silver.interest_rates
WHERE date IS NULL;

-- 2. Check for duplicate dates (should be exactly one row per month)
SELECT date, COUNT(*) AS row_count
FROM silver.interest_rates
GROUP BY date
HAVING COUNT(*) > 1;

-- 3. Check row count against Bronze minus the known junk footer row
SELECT
    (SELECT COUNT(*) FROM bronze.interest_rates) AS bronze_count,
    (SELECT COUNT(*) FROM silver.interest_rates) AS silver_count;


-- 4. Sanity check central_bank_rate is in a plausible range for Kenya
-- (a rate of 0 or an extreme outlier likely means a conversion error)
SELECT date, central_bank_rate
FROM silver.interest_rates
WHERE central_bank_rate IS NOT NULL
  AND (central_bank_rate <= 0 OR central_bank_rate > 50);

-- 5. Confirm date range covers what we expect (earliest/latest month loaded)
SELECT MIN(date) AS earliest_month, MAX(date) AS latest_month
FROM silver.interest_rates;