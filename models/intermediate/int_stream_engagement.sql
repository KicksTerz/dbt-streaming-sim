-- INTERMEDIATE layer (ephemeral): business logic lives here, keeping marts clean.
-- Ephemeral models are not built as objects in the warehouse — dbt inlines them
-- as a CTE wherever they're ref()'d. Use them for reusable logic you don't need
-- to query directly.
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
