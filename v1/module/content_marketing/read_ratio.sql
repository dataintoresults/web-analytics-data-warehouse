-- Cleaning the pages in events to avoid duplicates
with clean_events as (
  select
    regexp_replace(page, '[?&].*$', '') as clean_page, *
  from google_analytics.events 
),
-- Cleaning the pages in sessions to avoid duplicates
clean_sessions as (
  select regexp_replace(page, '[?&].*$', '') as clean_page, *
  from google_analytics.sessions 
),
-- For each page, how many people read more than 75% ?
-- The Scroll event was implemented on 2020-01-15 so skip 
-- everything before, it is not relevant
end_of_page_events as (
  select clean_page as page, sum(unique_events) as finish_count
  from clean_events
  where label = '75%'
    and category = 'Scroll'
    and date > '20200115'
  group by 1
),
-- For each page track the number of unique pageviews
-- We also just keep view after the implementation date of 
-- scroll tracking.
start_of_page_events as (
  select clean_page as page, sum(unique_pageviews) as start_count
  from clean_sessions
  where date > '20200115'
  group by 1
)
-- Blend those
select page, start_count, finish_count, 
  coalesce(finish_count, 0)*1.0/start_count as read_ratio
from start_of_page_events 
-- It's a left join because some articles are started
-- but were never read up to the 75% mark.
left join end_of_page_events using (page)
-- Avoid division by 0
where start_count <> 0