
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
