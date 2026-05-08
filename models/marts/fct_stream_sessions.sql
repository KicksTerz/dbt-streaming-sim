select
    s.stream_id,
    s.streamer_id,
    u.plan_type,
    u.country_code,
    s.started_at,
    s.ended_at,
    s.duration_minutes,
    s.category,
    s.title,
    count(distinct case when e.event_type = 'view' then e.user_id end)  as unique_viewers,
    count(distinct case when e.event_type = 'like' then e.user_id end)  as unique_likes,
    count(e.event_id)                                                    as total_events

from {{ ref('stg_streams') }}           s
left join {{ ref('stg_users') }}        u  on s.streamer_id = u.user_id
left join {{ ref('stg_events') }}       e  on s.stream_id = e.stream_id

group by 1,2,3,4,5,6,7,8,9