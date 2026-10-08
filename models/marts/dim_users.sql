-- USER DIMENSION. Grain: one row per user.
-- Kimball note: descriptive attributes (plan_type, country_code) live here,
-- not in the fact. The textbook star schema keeps the fact narrow (keys +
-- measures); fct_streams references this dim by key (streamer_id -> user_id).
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
