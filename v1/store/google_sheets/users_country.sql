with users_country as (
  select to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') as period,
    country, sum(users) as users
  from google_analytics.sessions
  where to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') < to_char(current_date, 'YYYY-MM')
    and to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') >= to_char(current_date - interval'13 months', 'YYYY-MM')
  group by 1, 2
),
top_countries as (
  select country, row_number() over (order by users desc) as rk
  from users_country
  where period = to_char(current_date - interval'1 month', 'YYYY-MM')
),
top_countries_select as (
  select *
  from top_countries
  where rk <= 5
),
reduce_countries as (
  select period,
    coalesce(top_countries_select.country, 'Other') as country, 
    sum(users) as users
  from users_country
  left join top_countries_select using (country) 
  group by 1, 2
)
select *
from reduce_countries
order by 1 desc, 3 desc