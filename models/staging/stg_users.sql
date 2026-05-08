select
    user_id,
    lower(trim(email))        as email,
    created_at::timestamp     as created_at,
    plan_type,
    country_code

from {{ source('raw', 'users') }}

where user_id is not null