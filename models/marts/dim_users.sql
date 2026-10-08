-- USER DIMENSION. Grain: one row per user.
-- Kimball note: the starter fct_stream_sessions folded user attributes
-- (plan_type, country_code) INTO the fact. That's a denormalised "wide table"
-- style — fine for some BI, but the textbook star schema pulls descriptive
-- attributes into a dimension and keeps the fact narrow (keys + measures).
-- This dim is the "clean" version; fct_streams below references it by key.
with users as (
    select * from {{ ref('stg_users') }}
),
streams as (
    select streamer_id, count(*) as lifetime_streams,
           min(started_at) as first_stream_at,
           max(started_at) as most_recent_stream_at
    from {{ ref('stg_streams') }}
    group by 1
)
select
    u.user_id,
    u.email,
    u.plan_type,
    u.country_code,
    u.created_at,
    coalesce(s.lifetime_streams, 0)        as lifetime_streams,
    s.first_stream_at,
    s.most_recent_stream_at,
    case when u.plan_type = 'free' then false else true end as is_paying
from users u
left join streams s on u.user_id = s.streamer_id
