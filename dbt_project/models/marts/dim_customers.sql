-- Mart model: one row per customer with lifetime totals.
-- Materialized as a TABLE -> lands in the GOLD schema.
-- Depends on fct_orders, which is why we ref() it below --
-- dbt uses this to build the dependency graph automatically.

with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('fct_orders') }}

),

customer_orders as (

    select
        customer_id,
        count(order_id)             as total_orders,
        sum(amount_paid)            as lifetime_value

    from orders
    group by customer_id

)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.created_at,
    coalesce(co.total_orders, 0)        as total_orders,
    coalesce(co.lifetime_value, 0)      as lifetime_value

from customers c
left join customer_orders co
    on c.customer_id = co.customer_id
