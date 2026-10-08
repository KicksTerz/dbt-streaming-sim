{{
    config(
        materialized='incremental',
        unique_key='event_id'
    )
}}

select
    event_id,
    user_id                         as viewer_id,
    stream_id,
    event_type,
    event_timestamp,
    event_timestamp::date           as event_date

from {{ ref('stg_events') }}

{% if is_incremental() %}
-- Reprocess the last 3 hours to catch late-arriving events; the unique_key
-- merge keeps the overlap from creating duplicates.
where event_timestamp > (select dateadd('hour', -3, max(event_timestamp)) from {{ this }})
{% endif %}