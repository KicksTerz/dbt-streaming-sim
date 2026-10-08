-- ============================================================
-- ONE-TIME SETUP on the new test Snowflake account.
-- Run this once (VS Code Snowflake extension, Snowsight worksheet,
-- or snowsql) BEFORE dbt seed/run. Requires ACCOUNTADMIN (trial default).
-- dbt creates SCHEMAS but not DATABASES or WAREHOUSES, so we make them here.
-- ============================================================
use role accountadmin;

create warehouse if not exists compute_wh
  warehouse_size = 'xsmall' auto_suspend = 60 auto_resume = true initially_suspended = true;

create database if not exists streamify_raw;   -- raw source layer (seeds load here)
create database if not exists streamify_dev;   -- dbt model output

use warehouse compute_wh;
