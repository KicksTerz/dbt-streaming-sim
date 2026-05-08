select
    date_trunc('day', event_timestamp)      as event_date,
    count(distinct user_id)                 as daily_active_viewers,
    count(distinct stream_id)               as streams_watched,
    count(case when event_type = 'view' then event_id end)  as total_views,
    count(case when event_type = 'like' then event_id end)  as total_likes

from {{ ref('stg_events') }}

group by 1
order by 1