-- One row per stream. Streamer attributes come from dim_users via streamer_id.
with streams as (
    select * from {{ ref('stg_streams') }}
),
engagement as (
    select * from {{ ref('int_stream_engagement') }}
)
select
    s.stream_id,
    s.streamer_id,
    s.started_at,
    s.ended_at,
    s.duration_minutes,
    s.category,
    e.total_events,
    e.unique_viewers,
    e.unique_likes
from streams s
left join engagement e on s.stream_id = e.stream_id
