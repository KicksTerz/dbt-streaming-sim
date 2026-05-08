select
    event_id,
    user_id,
    stream_id,
    event_type,
    event_timestamp::timestamp      as event_timestamp

from {{ source('raw', 'events') }}

where event_id is not null