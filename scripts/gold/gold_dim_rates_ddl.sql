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
