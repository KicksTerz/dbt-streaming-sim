select
    subscription_id,
    user_id,
    plan_type,
    started_at::timestamp           as started_at,
    ended_at::timestamp             as ended_at,
    status

from {{ source('raw', 'subscriptions') }}

where subscription_id is not null