-- One row per stream, including streams with no events (counts are 0).
with streams as (
    select * from {{ ref('stg_streams') }}
),
events as (
    select * from {{ ref('stg_events') }}
)
select
    s.stream_id,
    count(e.event_id)                                                   as total_events,
    count(distinct case when e.event_type = 'view' then e.user_id end)  as unique_viewers,
    count(distinct case when e.event_type = 'like' then e.user_id end)  as unique_likes
from streams s
left join events e on s.stream_id = e.stream_id
group by 1
