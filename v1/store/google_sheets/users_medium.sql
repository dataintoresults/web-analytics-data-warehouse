with users_medium as (
  select to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') as period,
    case when medium = '(none)' then 'Other' else medium end as medium, 
    sum(users) as users
  from google_analytics.sessions
  where to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') < to_char(current_date, 'YYYY-MM')
    and to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') >= to_char(current_date - interval'13 months', 'YYYY-MM')
  group by 1, 2
),
top_medium as (
  select medium, row_number() over (order by users desc) as rk
  from users_medium
  where period = to_char(current_date - interval'1 month', 'YYYY-MM')
),
top_medium_select as (
  select *
  from top_medium
  where rk <= 10
),
reduce_medium as (
  select period,
    coalesce(top_medium_select.medium, 'Other') as medium, 
    sum(users) as users
  from users_medium
  left join top_medium_select using (medium) 
  group by 1, 2
)
select *
from reduce_medium
order by 1 desc, 3 desc