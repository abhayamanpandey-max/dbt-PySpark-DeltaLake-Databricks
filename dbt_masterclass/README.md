# dbt_masterclass

A dbt Core project (targeting **Databricks**) built around a retail star-schema dataset:
sales transactions, returns, and customer/product/store/date dimensions.

> **Note:** This project was built from scratch using the sample data files
> (`fact_sales`, `fact_returns`, `dim_customer`, `dim_product`, `dim_store`,
> `dim_date`). It is original work demonstrating standard dbt patterns
> (staging → marts, snapshots, tests, macros) — it is **not** a transcript or
> reproduction of any specific video tutorial's code.

## Project layout

```
dbt_masterclass/
├── dbt_project.yml          # project config
├── seeds/                   # raw CSVs, loaded via `dbt seed`
│   ├── dim_customer.csv
│   ├── dim_date.csv
│   ├── dim_product.csv
│   ├── dim_store.csv
│   ├── fact_returns.csv
│   └── fact_sales.csv
├── models/
│   ├── staging/             # 1:1 cleaned views over each seed
│   │   ├── stg_customers.sql
│   │   ├── stg_dates.sql
│   │   ├── stg_products.sql
│   │   ├── stg_stores.sql
│   │   ├── stg_sales.sql
│   │   ├── stg_returns.sql
│   │   └── staging.yml      # docs + tests for staging models
│   └── marts/
│       ├── core/             # dimensional model (tables)
│       │   ├── dim_customers.sql
│       │   ├── dim_products.sql
│       │   ├── dim_stores.sql
│       │   ├── dim_dates.sql
│       │   ├── fct_sales.sql # central fact table (sales joined with returns)
│       │   └── core.yml
│       └── finance/
│           ├── fin_daily_sales_summary.sql  # daily revenue rollup by store
│           └── finance.yml
├── snapshots/
│   └── customers_snapshot.sql   # SCD Type 2 history of loyalty_tier/email/phone changes
├── macros/
│   ├── discount_percentage.sql  # reusable SQL macro
│   └── test_non_negative.sql    # custom generic (reusable) test
└── tests/
    ├── assert_refund_not_greater_than_sale.sql   # singular test
    └── assert_net_amount_reconciles.sql          # singular test
```

## Data model

- **Facts:** `fct_sales` — one row per sales line, left-joined to aggregated
  returns for that `sales_id`. Includes `net_amount_after_returns` and
  `discount_pct` (via the `discount_percentage()` macro).
- **Dimensions:** `dim_customers`, `dim_products`, `dim_stores`, `dim_dates`.
- **Mart:** `fin_daily_sales_summary` — daily revenue/refunds rolled up by
  store and date, joined to dimension attributes for reporting.

## Setup

1. **Create a Unity Catalog catalog** in Databricks for this project (the
   `profiles.yml` template assumes a catalog named `dbt_masterclass` —
   change it if you use a different name).

2. **Set environment variables** (don't hardcode credentials in `profiles.yml`):
   ```bash
   export DATABRICKS_HOST="dbc-xxxxxxx-yyyy.cloud.databricks.com"
   export DATABRICKS_HTTP_PATH="/sql/1.0/warehouses/xxxxxxxxxxxxxxxx"
   export DATABRICKS_TOKEN="dapiXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
   ```

3. **Point dbt at the profiles file** (it lives one level above the project
   folder in this bundle — normally you'd put it at `~/.dbt/profiles.yml`):
   ```bash
   export DBT_PROFILES_DIR=/path/to/dbt_project
   ```

4. **Install packages / check connection:**
   ```bash
   cd dbt_masterclass
   dbt debug
   ```

## Running the project

```bash
# 1. Load the seed CSVs into Databricks
dbt seed

# 2. Build staging views + mart tables
dbt run

# 3. Run all tests (schema tests + singular tests)
dbt test

# 4. Take a snapshot of customer dimension changes (run this on a schedule
#    in production to build SCD Type 2 history over time)
dbt snapshot

# 5. Generate and view documentation
dbt docs generate
dbt docs serve
```

Or all at once for a fresh build:
```bash
dbt seed && dbt run && dbt test && dbt snapshot
```

## Things to try next (good practice exercises)

- Add a `dim_promotions` and `dim_suppliers` seed/model — `fct_sales`
  references `promotion_sk` and `dim_products` references `supplier_sk`,
  but no source data exists for either yet.
- Add an incremental model for `fct_sales` (`materialized='incremental'`)
  instead of full-refresh `table`, using `sales_id` as the unique key.
- Swap the `customers_snapshot` strategy from `check` to `timestamp` if an
  `updated_at` column is added to the source data.
- Add a `dbt_utils` package dependency (`packages.yml`) and replace the
  custom `non_negative` test with `dbt_utils.expression_is_true`.
