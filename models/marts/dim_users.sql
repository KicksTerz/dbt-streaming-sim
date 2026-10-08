-- One row per user. Holds user attributes so the fact tables only need user_id.
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
