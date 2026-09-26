-- Mart model: order-level fact table, joined against payments.
-- Materialized as a TABLE (set in dbt_project.yml) -> lands in the GOLD schema.

with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

order_payments as (

    select
        order_id,
        sum(amount)     as amount_paid,
        count(*)        as payment_count

    from payments
    group by order_id

)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    coalesce(op.amount_paid, 0)    as amount_paid,
    coalesce(op.payment_count, 0)  as payment_count

from orders o
left join order_payments op
    on o.order_id = op.order_id
