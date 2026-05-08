select
    date_trunc('month', s.started_at)       as month,
    s.plan_type,
    count(distinct s.user_id)               as paying_subscribers,
    count(distinct case when s.status = 'active' then s.user_id end)   as active_subscribers,
    count(distinct case when s.status = 'churned' then s.user_id end)  as churned_subscribers

from {{ ref('stg_subscriptions') }}     s

where s.plan_type != 'free'

group by 1,2
order by 1,2