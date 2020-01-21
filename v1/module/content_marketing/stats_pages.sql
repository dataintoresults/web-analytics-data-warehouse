-- We avoid page duplication because of page parameters
with clean_sessions as (
  select regexp_replace(page, '[?&].*$', '') as clean_page, *
  from google_analytics.sessions 
),
-- Creating a reference table with the last 13 months and their ordering
weeks_ref as (
  select to_char(ts, 'YYYY-MM') as year_week, 
    row_number() over (order by ts) as rk
  from generate_series(current_date - interval'13 months', 
    current_date - interval'1 months', '1 month') ts
),
-- Unique page view over the last 13 month (up to end of last month)
pages_stats_row as (
  select to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') as year_week,    
    clean_page as page, sum(unique_pageviews) as pageviews
  from clean_sessions
  where unique_pageviews > 0
    and to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') 
      < to_char(current_date, 'IYYY-MM')
    and to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM') 
      >= to_char(current_date - interval'13 months', 'IYYY-MM')
  group by 1, 2  
),
-- SEO Data
clean_seo as (
  select to_char(to_date(date, 'YYYY-MM-DD'), 'YYYY-MM') as year_week,
    regexp_replace(page, '^https?://[a-z\.]+', '') as page, 
    sum(impressions) as impressions, sum(clicks) as clicks, 
    sum(impressions*position)/sum(impressions) as position,
    coalesce(sum(clicks),0)*1.0/sum(impressions) as ctr
  from google_search.seo_pages
  where to_char(to_date(date, 'YYYY-MM-DD'), 'YYYY-MM') 
      < to_char(current_date, 'YYYY-MM')
    and to_char(to_date(date, 'YYYY-MM-DD'), 'YYYY-MM') 
      >= to_char(current_date - interval'13 months', 'YYYY-MM')
  group by 1, 2
),
-- Pivot the data
pages_stats as (
  select page,
    coalesce(sum(case when rk = 1 then pageviews end),0) as pageviews_month_1,
    coalesce(sum(case when rk = 2 then pageviews end),0) as pageviews_month_2,
    coalesce(sum(case when rk = 3 then pageviews end),0) as pageviews_month_3,
    coalesce(sum(case when rk = 4 then pageviews end),0) as pageviews_month_4,
    coalesce(sum(case when rk = 5 then pageviews end),0) as pageviews_month_5,
    coalesce(sum(case when rk = 6 then pageviews end),0) as pageviews_month_6,
    coalesce(sum(case when rk = 7 then pageviews end),0) as pageviews_month_7,
    coalesce(sum(case when rk = 8 then pageviews end),0) as pageviews_month_8,
    coalesce(sum(case when rk = 9 then pageviews end),0) as pageviews_month_9,
    coalesce(sum(case when rk = 10 then pageviews end),0) as pageviews_month_10,
    coalesce(sum(case when rk = 11 then pageviews end),0) as pageviews_month_11,
    coalesce(sum(case when rk = 12 then pageviews end),0) as pageviews_month_12,
    coalesce(sum(case when rk = 13 then pageviews end),0) as pageviews_month_13,
    coalesce(sum(case when rk = 1 then impressions end),0) as impressions_month_1,
    coalesce(sum(case when rk = 2 then impressions end),0) as impressions_month_2,
    coalesce(sum(case when rk = 3 then impressions end),0) as impressions_month_3,
    coalesce(sum(case when rk = 4 then impressions end),0) as impressions_month_4,
    coalesce(sum(case when rk = 5 then impressions end),0) as impressions_month_5,
    coalesce(sum(case when rk = 6 then impressions end),0) as impressions_month_6,
    coalesce(sum(case when rk = 7 then impressions end),0) as impressions_month_7,
    coalesce(sum(case when rk = 8 then impressions end),0) as impressions_month_8,
    coalesce(sum(case when rk = 9 then impressions end),0) as impressions_month_9,
    coalesce(sum(case when rk = 10 then impressions end),0) as impressions_month_10,
    coalesce(sum(case when rk = 11 then impressions end),0) as impressions_month_11,
    coalesce(sum(case when rk = 12 then impressions end),0) as impressions_month_12,
    coalesce(sum(case when rk = 13 then impressions end),0) as impressions_month_13,
    coalesce(sum(case when rk = 1 then clicks end),0) as clicks_month_1,
    coalesce(sum(case when rk = 2 then clicks end),0) as clicks_month_2,
    coalesce(sum(case when rk = 3 then clicks end),0) as clicks_month_3,
    coalesce(sum(case when rk = 4 then clicks end),0) as clicks_month_4,
    coalesce(sum(case when rk = 5 then clicks end),0) as clicks_month_5,
    coalesce(sum(case when rk = 6 then clicks end),0) as clicks_month_6,
    coalesce(sum(case when rk = 7 then clicks end),0) as clicks_month_7,
    coalesce(sum(case when rk = 8 then clicks end),0) as clicks_month_8,
    coalesce(sum(case when rk = 9 then clicks end),0) as clicks_month_9,
    coalesce(sum(case when rk = 10 then clicks end),0) as clicks_month_10,
    coalesce(sum(case when rk = 11 then clicks end),0) as clicks_month_11,
    coalesce(sum(case when rk = 12 then clicks end),0) as clicks_month_12,
    coalesce(sum(case when rk = 13 then clicks end),0) as clicks_month_13,
    coalesce(sum(case when rk = 1 then position end),100) as position_month_1,
    coalesce(sum(case when rk = 2 then position end),100) as position_month_2,
    coalesce(sum(case when rk = 3 then position end),100) as position_month_3,
    coalesce(sum(case when rk = 4 then position end),100) as position_month_4,
    coalesce(sum(case when rk = 5 then position end),100) as position_month_5,
    coalesce(sum(case when rk = 6 then position end),100) as position_month_6,
    coalesce(sum(case when rk = 7 then position end),100) as position_month_7,
    coalesce(sum(case when rk = 8 then position end),100) as position_month_8,
    coalesce(sum(case when rk = 9 then position end),100) as position_month_9,
    coalesce(sum(case when rk = 10 then position end),100) as position_month_10,
    coalesce(sum(case when rk = 11 then position end),100) as position_month_11,
    coalesce(sum(case when rk = 12 then position end),100) as position_month_12,
    coalesce(sum(case when rk = 13 then position end),100) as position_month_13
  from pages_stats_row
  left join clean_seo using (year_week, page)
  inner join weeks_ref using (year_week)
  group by 1
)
select pages_stats.*, read_ratio
from pages_stats 
left join content_marketing.read_ratio using (page)