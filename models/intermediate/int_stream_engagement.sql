-- INTERMEDIATE layer (view): business logic lives here, keeping marts clean.
-- Materialized as a view (set for the whole folder in dbt_project.yml), so it
-- can be queried directly in Snowflake when debugging, at no storage cost.
--
-- Here: per-stream engagement counts, derived once and reused by the fact table.
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
