# 📁 Folder Structure

```
dbt-snowflake-elt-project/
│
├── README.md
├── .gitignore
├── any_script.py                   # Extract step: pulls bank.csv from GitHub into RAW
│
├── docs/
│   ├── folder-structure.md        # this file
│   └── data-flow-diagram.md       # architecture + data flow (Mermaid diagram)
│
├── snowflake-queries/              # manual SQL — run these FIRST, before dbt
│   ├── 01_create_raw_tables.sql    # Bronze layer: raw tables + sample data (+ raw_bank_marketing)
│   ├── 02_transform_silver.sql     # Silver layer: cleaned / typed tables (+ silver_bank_marketing)
│   └── 03_transform_gold.sql       # Gold layer: business-ready tables (+ gold_bank_campaign_summary)
│
└── dbt_project/                    # the actual dbt project
    ├── dbt_project.yml             # project config (name, paths, materializations)
    ├── profiles_example.yml        # template for ~/.dbt/profiles.yml (Snowflake creds)
    │
    ├── macros/
    │   └── generate_schema_name.sql  # makes custom schemas clean (silver/gold, no prefix)
    │
    └── models/
        ├── staging/                 # Bronze → Silver, materialized as VIEWS
        │   ├── _staging__sources.yml   # declares the RAW tables as dbt "sources"
        │   ├── stg_customers.sql
        │   ├── stg_orders.sql
        │   ├── stg_payments.sql
        │   └── stg_bank_marketing.sql   # from bank.csv
        │
        └── marts/                   # Silver → Gold, materialized as TABLES
            ├── _marts__models.yml      # descriptions of the final models
            ├── dim_customers.sql
            ├── fct_orders.sql
            └── bank_campaign_summary.sql   # subscription rate by job/marital/education
```

## Why it's organized this way

| Folder | Purpose | dbt concept practiced |
|---|---|---|
| `snowflake-queries/` | Hand-written SQL that builds the same medallion layers dbt will build. Doing it manually once makes the value of dbt obvious. | none — plain SQL |
| `dbt_project/models/staging/` | One model per source table, minimal cleanup, always a **view**. | sources, views, naming (`stg_`) |
| `dbt_project/models/marts/` | Joined / aggregated, consumption-ready, always a **table**. | tables, naming (`dim_`, `fct_`) |
| `dbt_project/macros/` | Reusable Jinja logic — here, controlling how schema names are generated. | macros |
