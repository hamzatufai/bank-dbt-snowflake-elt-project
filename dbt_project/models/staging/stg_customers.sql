-- Staging model: thin cleanup of raw_customers, 1:1 grain with the source.
-- Materialized as a VIEW (set in dbt_project.yml) -> lands in the SILVER schema.

with source as (

    select * from {{ source('raw', 'raw_customers') }}

),

cleaned as (

    select
        customer_id,
        initcap(trim(first_name))          as first_name,
        initcap(trim(last_name))           as last_name,
        lower(trim(email))                 as email,
        to_date(created_at, 'YYYY-MM-DD')  as created_at

    from source
    where customer_id is not null

)

select * from cleaned
