-- Aggregate raw data per month and country
with users_country as (
  select to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') as period,
    country, sum(users) as users
  from google_analytics.sessions
  -- Take only the last 13 months (not the current one)
  where to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') < to_char(current_date, 'YYYY-MM')
    and to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') >= to_char(current_date - interval'13 months', 'YYYY-MM')
  group by 1, 2
),
-- Order the countries by number of users in the previous month
top_countries as (
  select country, row_number() over (order by users desc) as rk
  from users_country
  where period = to_char(current_date - interval'1 month', 'YYYY-MM')
),
-- Select the best performing countries
top_countries_select as (
  select *
  from top_countries
  where rk <= 5
),
-- keep only the best 5 country and affect the rest to Other
reduce_countries as (
  select period,
    coalesce(top_countries_select.country, 'Other') as country, 
    sum(users) as users
  from users_country
  left join top_countries_select using (country) 
  group by 1, 2
)
-- Finish with some ordering
select *
from reduce_countries
order by 1 desc, 3 desc