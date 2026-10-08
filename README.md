# Streamify: dbt + Snowflake analytics project

An analytics engineering project for a simulated live-streaming platform. Raw data on users, streams, viewer events and subscriptions is transformed with **dbt Core** on **Snowflake** into a tested, documented star schema.

## Architecture

```
STREAMIFY_RAW.PUBLIC                STREAMIFY_DEV.<dev schema>
────────────────────                ─────────────────────────────────────────────────────────
users          ─► stg_users          ─┐
streams        ─► stg_streams        ─┼─► int_stream_engagement ─► fct_streams
events         ─► stg_events         ─┤                            fct_events (incremental)
subscriptions  ─► stg_subscriptions  ─┘                            dim_users
      │                                                            mart_daily_active_viewers
      └──────────► subscriptions_snapshot (SCD2)                   mart_revenue
```

| Layer | Materialization | Purpose |
|---|---|---|
| **Staging** (`stg_`) | View | One model per source table: renaming, type casting, light cleaning |
| **Intermediate** (`int_`) | View | Reusable logic shared by several marts |
| **Marts** (`dim_`, `fct_`, `mart_`) | Table / incremental | Business-facing star schema and aggregates |
| **Snapshots** | SCD2 table | Change history of subscriptions |

## Models

| Model | Grain | Notes |
|---|---|---|
| `dim_users` | One row per user | User attributes and lifetime streaming activity |
| `fct_streams` | One row per stream | Duration, category and engagement counts; joins to `dim_users` on `streamer_id` |
| `fct_events` | One row per viewer event | **Incremental**, merged on `event_id` |
| `mart_daily_active_viewers` | One row per day | Daily active viewers, streams watched, views and likes |
| `mart_revenue` | One row per month and paid plan | Paid subscription starts, active and churned counts |
| `subscriptions_snapshot` | One row per version of a subscription | Tracks plan and status changes over time |

Every model and column is documented. Run `dbt docs generate && dbt docs serve` to browse the docs and lineage graph.

## Testing

25 data tests:

- **Grain:** `unique` and `not_null` on every model's key, plus `dbt_utils.unique_combination_of_columns` on `mart_revenue` (`month` + `plan_type`).
- **Referential integrity:** `relationships` tests from streams to users, in both staging and marts.
- **Domain:** `accepted_values` on `plan_type`.
- **Completeness:** a singular test (`tests/assert_marts_not_empty.sql`) that fails if the marts are built from empty input. Key-based tests pass on an empty table, so this catches a class of failure they can't.

## Design decisions

**Incremental events with a lookback window.** `fct_events` processes only events newer than the latest one already loaded, minus a 3-hour lookback. Filtering strictly on the latest timestamp silently drops late-arriving events. The lookback re-reads recent rows, and merging on `unique_key='event_id'` keeps that overlap from creating duplicates. `--full-refresh` rebuilds the table for anything later than the window, or after logic changes.

**Snapshot with the `check` strategy.** The source has no reliable `updated_at` column, so `subscriptions_snapshot` detects changes by comparing `plan_type`, `status` and `ended_at` between runs. It snapshots the raw source rather than staging, so changes to staging logic can't alter recorded history. `dbt_valid_from` reflects when the snapshot ran, so history is as precise as the snapshot schedule.

**Seeds as a stand-in for ingestion.** The CSVs in `seeds/` play the role of an ingestion tool landing data in `STREAMIFY_RAW`. Models read them through `source()`, as they would real raw data. A custom `generate_schema_name` macro puts seeds in `STREAMIFY_RAW.PUBLIC` instead of dbt's default `<target>_public`. Because dbt doesn't link seeds to the sources they populate, seeds are loaded as a separate step before the build.

**Credentials stay out of the repo.** `profiles.yml` reads everything from environment variables, and dbt authenticates to Snowflake with a key pair rather than a password.

## Running it

**Prerequisites:** Python with `dbt-core` and `dbt-snowflake` (developed on dbt 1.11), and a Snowflake account.

1. Run `setup_snowflake.sql` once in Snowflake to create the warehouse and databases.
2. Set up key-pair authentication for your Snowflake user.
3. Copy `.env.example` to `.env` and fill in your account, user and private key path. With [direnv](https://direnv.net/), run `direnv allow` once and `.env` loads automatically; otherwise run `set -a; source .env; set +a`.
4. Install packages, load the raw data, then build:
   ```
   dbt deps
   dbt seed
   dbt build --exclude resource_type:seed
   ```

## Possible next steps

- Report `mart_revenue` subscription status as of each month-end, using the snapshot, rather than by current status.
- Source freshness checks once data arrives continuously.
- Separate `dev` and `prod` targets with a least-privilege dbt role.
- CI that runs `dbt build` on pull requests.
