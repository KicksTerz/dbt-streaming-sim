-- STREAMS FACT. Grain: ONE ROW PER STREAM (the atomic event we measure).
-- Narrow star-schema fact: foreign key to dim_users (streamer_id) + measures.
-- Descriptive attributes (plan_type, country) are NOT duplicated here — you get
-- them by joining dim_users. That's the dimensional-modelling discipline.
with streams as (
    select * from {{ ref('stg_streams') }}
),
engagement as (
    select * from {{ ref('int_stream_engagement') }}
)
select
    s.stream_id,                      -- primary key (grain)
    s.streamer_id,                    -- FK -> dim_users.user_id
    s.started_at,
    s.ended_at,
    s.duration_minutes,
    s.category,
    e.total_events,
    e.unique_viewers,
    e.unique_likes
from streams s
left join engagement e on s.stream_id = e.stream_id
