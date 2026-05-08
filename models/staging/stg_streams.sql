select
    stream_id,
    user_id                                             as streamer_id,
    started_at::timestamp                               as started_at,
    ended_at::timestamp                                 as ended_at,
    datediff('minute', started_at, ended_at)            as duration_minutes,
    category,
    title

from {{ source('raw', 'streams') }}

where stream_id is not null