-- Staging model: thin cleanup of raw_orders.
-- Materialized as a VIEW -> lands in the SILVER schema.

with source as (

    select * from {{ source('raw', 'raw_orders') }}

),

cleaned as (

    select
        order_id,
        customer_id,
        to_date(order_date, 'YYYY-MM-DD')  as order_date,
        lower(trim(status))                as status

    from source
    where order_id is not null

)

select * from cleaned
