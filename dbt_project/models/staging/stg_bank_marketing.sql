-- Staging model: thin cleanup of raw_bank_marketing.
-- Materialized as a VIEW -> lands in the SILVER schema.

with source as (

    select * from {{ source('raw', 'raw_bank_marketing') }}

),

cleaned as (

    select
        age,
        lower(trim(job))                            as job,
        lower(trim(marital))                        as marital,
        lower(trim(education))                      as education,
        iff(lower("DEFAULT") = 'yes', true, false)  as has_credit_default,
        balance,
        iff(lower(housing) = 'yes', true, false)    as has_housing_loan,
        iff(lower(loan) = 'yes', true, false)       as has_personal_loan,
        lower(trim(contact))                        as contact_method,
        day,
        month,
        duration                                    as call_duration_sec,
        campaign                                    as contacts_this_campaign,
        pdays,
        previous                                    as contacts_before_campaign,
        lower(trim(poutcome))                       as previous_outcome,
        iff(lower(deposit) = 'yes', true, false)    as subscribed_deposit

    from source

)

select * from cleaned
