# dbt + PySpark + Delta Lake — Databricks Full Course

A hands-on data engineering repository covering modern analytics engineering with **dbt**, distributed processing with **PySpark**, and lakehouse storage with **Delta Lake**, all running on **Databricks**.

This repo contains three components:

| Folder | What it is |
|---|---|
| [`Abhay_dbt_tutorial/`](#1-abhay_dbt_tutorial) | A complete medallion-architecture dbt pipeline (bronze → silver → gold) built from scratch, with tests, snapshots, and documentation |
| [`dbt_masterclass/`](#2-dbt_masterclass) | A second dbt project using seeds, staging models, and marts, following a classic dbt-learn style structure |
| [`Pyspark-DeltaLake DATA and NOTEBOOK/`](#3-pyspark-deltalake-data-and-notebook) | Databricks notebooks covering PySpark fundamentals, Delta Lake, Spark Streaming, and Spark optimization |

---

## Architecture Overview

> 📌 *Diagram placeholder — add an exported image (e.g. `docs/architecture.png`) and reference it here:*
> `![Architecture](docs/architecture.png)`

```
                ┌─────────────┐
                │   Sources   │
                │ (raw data)  │
                └──────┬──────┘
                       │
                ┌──────▼──────┐
                │   BRONZE    │  Raw ingestion, no transformations
                │ (6 models)  │
                └──────┬──────┘
                       │
          ┌────────────┼────────────┐
          │                         │
   ┌──────▼──────┐          ┌───────▼───────┐
   │   SILVER    │          │   SNAPSHOTS   │
   │ (joined &   │          │ (SCD history  │
   │ aggregated) │          │   tracking)   │
   └──────┬──────┘          └───────────────┘
          │
   ┌──────▼──────┐
   │    GOLD     │  Business-ready / reporting layer
   └─────────────┘

   26 automated data tests run across the pipeline
```

---

## 1. `Abhay_dbt_tutorial/`

A dbt project built around the **Medallion Architecture** (Bronze → Silver → Gold), running on **Databricks** via the `dbt-databricks` adapter.

### What it does

- Ingests raw source tables (customers, products, stores, dates, sales, returns) into a **bronze** layer with zero transformations
- Builds **silver** models that join and aggregate sales and returns data (revenue by category/gender, refunds by category/return reason)
- Tracks historical changes to customer records using a **snapshot** with the `check` strategy
- Tracks a `gold` source table snapshot using the newer YAML-based snapshot syntax (dbt 1.9+)
- Documents every bronze column and enforces **26 data quality tests** (`unique`, `not_null`, `relationships`, and a custom `non_negative_test`)

### Project structure

```
Abhay_dbt_tutorial/
├── dbt_project.yml
├── models/
│   ├── source/            # source.yml — declares raw source tables
│   ├── bronze/            # raw passthrough models + properties.yml (docs + tests)
│   ├── silver/            # silver_salesinfo.sql, silver_returnsinfo.sql
│   └── gold/              # source_gold_items.sql
├── snapshots/
│   ├── customer_snapshot.sql   # SCD Type 2 tracking (check strategy)
│   └── gold_items.yml          # SCD Type 2 tracking (YAML snapshot config, dbt 1.9+ syntax)
├── macros/
│   ├── generate_schema.sql     # custom schema-naming macro
│   └── multiply.sql            # reusable calculation macro
├── tests/
│   └── non_negative_test.sql   # singular test guarding against negative values
└── analyses/
```

### Data model

| Layer | Models | Purpose |
|---|---|---|
| Bronze | `bronze_customer`, `bronze_date`, `bronze_product`, `bronze_returns`, `bronze_sales`, `bronze_store` | 1:1 raw copies of source tables |
| Silver | `silver_salesinfo` | Gross revenue grouped by product category and customer gender |
| Silver | `silver_returnsinfo` | Returned quantity and refund amount grouped by category and return reason |
| Gold | `source_gold_items` | Business-ready item-level table |
| Snapshot | `customer_snapshot` | Historical record of customer attribute changes (loyalty tier, contact info, name) |
| Snapshot | `gold_items` | Historical record of gold item changes |

### Running it

```bash
cd Abhay_dbt_tutorial

# Run everything: models → snapshots → tests, in dependency order
dbt build

# Or run steps individually
dbt run
dbt snapshot
dbt test

# Generate and view interactive docs
dbt docs generate
dbt docs serve
```

### Setup

This project connects to **Databricks SQL** via the `dbt-databricks` adapter. You'll need your own `profiles.yml` (intentionally **not included** in this repo — see [Credentials](#credentials--security) below).

```yaml
# ~/.dbt/profiles.yml  (create this yourself — not checked into git)
Abhay_dbt_tutorial:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: <your_catalog>
      schema: dev
      host: <your_databricks_host>
      http_path: <your_sql_warehouse_http_path>
      token: <your_databricks_token>
```

---

## 2. `dbt_masterclass/`

A second, independent dbt project demonstrating the classic **staging → marts** pattern using CSV **seeds** as the data source (no external warehouse data needed to get started).

### Structure

```
dbt_masterclass/
├── seeds/              # dim_customer.csv, dim_date.csv, dim_product.csv,
│                       # dim_store.csv, fact_returns.csv, fact_sales.csv
├── models/
│   ├── staging/        # stg_customers, stg_dates, stg_products, stg_returns, stg_sales, stg_stores
│   └── marts/
│       ├── core/       # dim_customers, dim_dates, dim_products, dim_stores, fct_sales
│       └── finance/    # fin_daily_sales_summary
├── snapshots/
│   └── customers_snapshot.sql
├── macros/
│   ├── discount_percentage.sql
│   └── test_non_negative.sql
└── tests/
    ├── assert_net_amount_reconciles.sql
    └── assert_refund_not_greater_than_sale.sql
```

### Running it

```bash
cd dbt_masterclass
dbt seed     # load CSVs into the warehouse
dbt build    # run models, snapshots, and tests
```

---

## 3. `Pyspark-DeltaLake DATA and NOTEBOOK/`

Databricks notebooks for learning distributed data processing and lakehouse storage, plus the sample datasets used in them.

| Notebook | Topic |
|---|---|
| `1_Tutoral.ipynb` | PySpark fundamentals |
| `DeltaLake4.0_Combined.ipynb` | Delta Lake: ACID transactions, time travel, MERGE/upserts |
| `ApacheSparkStreaming_Combined.ipynb` | Structured Streaming with Spark |
| `SparkOptimization.ipynb` / `.dbc` | Spark performance tuning (partitioning, caching, joins) |

**Sample data included:** `BigMart Sales.csv`, `drivers.json`, `day1.json`, `day2.json`, `day3.json`

> 💡 These notebooks are designed to be imported directly into a Databricks workspace.

---

## Tech Stack

- **dbt-core** (1.11) + **dbt-databricks** adapter
- **Databricks** (SQL Warehouse + Lakehouse)
- **Delta Lake**
- **PySpark**
- **Docker** / **Docker Compose** (local environment, including an Apache Airflow setup for orchestration)
- **Git / GitHub**

---

## Credentials & Security

This repo does **not** include any `profiles.yml`, tokens, or connection secrets — they are explicitly excluded via `.gitignore`. To run any of the dbt projects yourself, create your own `~/.dbt/profiles.yml` (or a project-local one, kept out of version control) with your own Databricks host, HTTP path, and personal access token.

If you're cloning this repo to learn from it, never commit real credentials — use environment variables or a local, gitignored profile instead.

---

## Author

**Abhay Pandey**
Built while learning end-to-end data engineering: dbt, PySpark, Delta Lake, Docker, and Airflow on Databricks.