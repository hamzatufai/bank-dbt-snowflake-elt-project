-- Mart model: subscription rate by job / marital status / education.
-- Materialized as a TABLE -> lands in the GOLD schema.

with bank as (

    select * from {{ ref('stg_bank_marketing') }}

)

select
    job,
    marital,
    education,
    count(*)                                                   as total_contacted,
    sum(iff(subscribed_deposit, 1, 0))                         as total_subscribed,
    round(sum(iff(subscribed_deposit, 1, 0)) / count(*), 4)    as subscription_rate,
    round(avg(balance), 2)                                     as avg_balance,
    round(avg(call_duration_sec), 1)                           as avg_call_duration_sec

from bank
group by job, marital, education
order by subscription_rate desc
