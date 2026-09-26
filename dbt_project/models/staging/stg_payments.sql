-- Staging model: thin cleanup of raw_payments.
-- Materialized as a VIEW -> lands in the SILVER schema.

with source as (

    select * from {{ source('raw', 'raw_payments') }}

),

cleaned as (

    select
        payment_id,
        order_id,
        lower(trim(payment_method))            as payment_method,
        try_cast(amount as number(10,2))       as amount

    from source
    where payment_id is not null

)

select * from cleaned
