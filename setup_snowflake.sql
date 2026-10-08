-- One-time account setup, run before the first dbt seed/build.
-- dbt creates schemas but not warehouses or databases.
use role accountadmin;

create warehouse if not exists compute_wh
  warehouse_size = 'xsmall' auto_suspend = 60 auto_resume = true initially_suspended = true;

create database if not exists streamify_raw;   -- raw data (seeds)
create database if not exists streamify_dev;   -- dbt models and snapshots

use warehouse compute_wh;
