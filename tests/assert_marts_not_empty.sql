-- Fails (returns a row) if either mart was built from empty input
select 'mart_daily_active_viewers is empty' as problem
where (select count(*) from {{ ref('mart_daily_active_viewers') }}) = 0
union all
select 'fct_streams has no engagement' as problem
where (select coalesce(sum(total_events), 0) from {{ ref('fct_streams') }}) = 0