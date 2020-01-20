select * 
from content_marketing.stats_pages 
where page like '/post%'
  and page not like '/post/tag/%'
  and page not like '/post/category/%'
 order by pageviews_month_13 desc nulls last