/*
====================================================================
Quality Checks: silver.exchange_rates
====================================================================
Purpose:
Non-destructive validation queries to sanity-check the Silver layer
after loading. Each query should return ZERO rows if the data is clean.
A query returning rows flags something worth investigating.
====================================================================
*/

-- 1. Check for NULL dates (would mean the date-building logic failed silently)
SELECT *
FROM silver.exchange_rates
WHERE date IS NULL;

-- 2. Check for duplicate dates (should be exactly one row per month)
SELECT date, COUNT(*) AS row_count
FROM silver.exchange_rates
GROUP BY date
HAVING COUNT(*) > 1;

-- 3. Check row count matches Bronze (confirms nothing was silently dropped)
SELECT
    (SELECT COUNT(*) FROM bronze.exchange_rates) AS bronze_count,
    (SELECT COUNT(*) FROM silver.exchange_rates) AS silver_count;

-- 4. Sanity check currency values are in a plausible range
-- (a rate of 0 or a huge outlier likely means a conversion error, not real data)
SELECT date, USD
FROM silver.exchange_rates
WHERE USD IS NOT NULL AND (USD <= 0 OR USD > 1000);

-- 5. Confirm date range covers what we expect (earliest/latest month loaded)
SELECT MIN(date) AS earliest_month, MAX(date) AS latest_month
FROM silver.exchange_rates;