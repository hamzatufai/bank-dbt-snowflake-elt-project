# ❄️ Snowflake + dbt ELT Learning Project

A small, hands-on ELT project built to learn **dbt** concepts step by step, using **Snowflake** as the warehouse.

## 🎯 Goal
Learn dbt fundamentals (sources, models, materializations, staging vs. marts, custom schemas)
by building a tiny **Bronze → Silver → Gold** pipeline — the same medallion pattern shown in the architecture diagram.

## 🏗️ Architecture
Full picture: [`docs/data-flow-diagram.md`](docs/data-flow-diagram.md)

In short:
1. **`any_script.py`** *(a later step — not built yet)* will land raw data into Snowflake.
2. **Manual SQL** (`snowflake-queries/`) builds the first Bronze → Silver → Gold pass by hand — this is exactly what dbt will soon automate for you. Doing it manually first makes it obvious *why* dbt is useful.
3. **dbt** reads the raw (Bronze) tables as **sources** and rebuilds Silver → Gold itself, using models (views + tables).

## 📁 Structure
See [`docs/folder-structure.md`](docs/folder-structure.md) for the full tree with explanations.

## 🚀 Getting started

### 1. Snowflake setup
Run the scripts in `snowflake-queries/` **in order** (in a Snowflake worksheet):
```
01_create_raw_tables.sql     -- Bronze: raw landing tables + sample data
02_transform_silver.sql      -- Silver: cleaned / typed tables (manual)
03_transform_gold.sql        -- Gold: business-ready tables (manual)
```
These three files give you a working warehouse with data in it *before* you even touch dbt.

### 2. dbt setup
```bash
cd dbt_project
pip install dbt-snowflake

# copy the example profile and fill in your own credentials
cp profiles_example.yml ~/.dbt/profiles.yml

dbt debug                    # test the connection
dbt run                      # build every model
dbt run --select staging     # build only the staging (view) models
dbt run --select marts       # build only the marts (table) models
```

## 📚 What this round teaches you
- dbt project structure (`dbt_project.yml`, `models/`)
- **Sources** — pointing dbt at tables that already exist (our RAW/Bronze tables)
- **Staging models**, materialized as **views** — thin, 1:1 cleanup of a source table
- **Marts models**, materialized as **tables** — joined, aggregated, business-ready output
- **Materialization config** — set once for a whole folder in `dbt_project.yml`, or overridden per-model with `{{ config(...) }}`
- **Custom schemas** — routing `staging/` models into a `SILVER` schema and `marts/` models into a `GOLD` schema (see `macros/generate_schema_name.sql`)

## 🔜 Coming next (intentionally left out this round)
- `any_script.py` — Python extraction/load script feeding the RAW tables
- dbt **tests** (`unique`, `not_null`, relationships)
- dbt **docs** (`dbt docs generate` + lineage graph)
- **Seeds** and **snapshots**
- **Incremental** models
- CI/CD

## Sample data
Two datasets, side by side:
1. A tiny, jaffle-shop-style dataset: `customers`, `orders`, `payments` — small enough to read in one glance.
2. A real bank marketing dataset (`bank.csv`, ~11k rows) — `job`, `balance`, `contact`, `poutcome`, `deposit`, etc.
   - Loaded into `RAW_BANK_MARKETING` either by `snowflake-queries/01_create_raw_tables.sql` (via `COPY INTO`)
     or by running `any_script.py`, which downloads the CSV straight from GitHub and loads it with `write_pandas`.
   - Flows through the same Silver (`stg_bank_marketing`) → Gold (`bank_campaign_summary`) path as the other tables,
     ending in a subscription-rate breakdown by job, marital status, and education.
