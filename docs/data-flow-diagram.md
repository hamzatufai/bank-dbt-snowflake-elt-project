# 🔄 Data Flow / Architecture

Based on the target architecture: a Python script lands data into Snowflake, then dbt takes over the transformation.

```mermaid
flowchart LR
    subgraph Extract["Extract (later step)"]
        A["any_script.py"]
    end

    subgraph Manual["Snowflake — built by hand (snowflake-queries/)"]
        direction TB
        B1["RAW / Bronze\n01_create_raw_tables.sql"]
        B2["SILVER\n02_transform_silver.sql"]
        B3["GOLD\n03_transform_gold.sql"]
        B1 --> B2 --> B3
    end

    subgraph DBT["dbt (dbt_project/)"]
        direction TB
        C1["Sources\n(point at RAW tables)"]
        C2["Staging models\nVIEWS — silver schema"]
        C3["Marts models\nTABLES — gold schema"]
        C1 --> C2 --> C3
    end

    A --> B1
    B1 --> C1
```

## Reading the diagram

1. **Extract** — `any_script.py` (built in a later round) will pull data from a source system and load it into Snowflake `RAW` tables. For now, `snowflake-queries/01_create_raw_tables.sql` seeds this data manually with `INSERT` statements, so you can start learning dbt today without waiting on the Python step.
2. **Manual pipeline** — `02_transform_silver.sql` and `03_transform_gold.sql` show the *traditional*, hand-written way of moving data through Bronze → Silver → Gold. Nothing here is automated, tracked, or tested — that's the pain dbt solves.
3. **dbt pipeline** — dbt declares the same `RAW` tables as **sources**, then rebuilds Silver as **staging views** and Gold as **marts tables**, all version-controlled, documented, and re-runnable with one command (`dbt run`).

Once you compare steps 2 and 3, the value of dbt (repeatability, dependency graph, docs, tests) becomes concrete instead of theoretical.
