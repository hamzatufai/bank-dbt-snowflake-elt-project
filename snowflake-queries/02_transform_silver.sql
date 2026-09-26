-- ============================================================
-- 02_transform_silver.sql
-- Layer: SILVER
-- Purpose: clean + type-cast the raw data by hand. This is the
--          manual version of what dbt's "staging" models will
--          do for you automatically later.
-- ============================================================

USE DATABASE ELT_LEARNING_DB;

CREATE SCHEMA IF NOT EXISTS SILVER;
USE SCHEMA SILVER;

-- Cleaned customers: proper casing, cast created_at to a real DATE
CREATE OR REPLACE TABLE SILVER_CUSTOMERS AS
SELECT
    customer_id,
    INITCAP(TRIM(first_name))              AS first_name,
    INITCAP(TRIM(last_name))               AS last_name,
    LOWER(TRIM(email))                     AS email,
    TO_DATE(created_at, 'YYYY-MM-DD')      AS created_at
FROM ELT_LEARNING_DB.RAW.RAW_CUSTOMERS
WHERE customer_id IS NOT NULL;

-- Cleaned orders: cast order_date, standardize status
CREATE OR REPLACE TABLE SILVER_ORDERS AS
SELECT
    order_id,
    customer_id,
    TO_DATE(order_date, 'YYYY-MM-DD')      AS order_date,
    LOWER(TRIM(status))                    AS status
FROM ELT_LEARNING_DB.RAW.RAW_ORDERS
WHERE order_id IS NOT NULL;

-- Cleaned payments: cast amount to NUMBER, drop $0 non-payments
CREATE OR REPLACE TABLE SILVER_PAYMENTS AS
SELECT
    payment_id,
    order_id,
    LOWER(TRIM(payment_method))            AS payment_method,
    TRY_CAST(amount AS NUMBER(10,2))       AS amount
FROM ELT_LEARNING_DB.RAW.RAW_PAYMENTS
WHERE payment_id IS NOT NULL;

-- sanity check
SELECT * FROM SILVER_CUSTOMERS;
SELECT * FROM SILVER_ORDERS;
SELECT * FROM SILVER_PAYMENTS;

-- ============================================================
-- Additional dataset: bank marketing campaign data
-- ============================================================

CREATE OR REPLACE TABLE SILVER_BANK_MARKETING AS
SELECT
    age,
    LOWER(TRIM(job))                              AS job,
    LOWER(TRIM(marital))                          AS marital,
    LOWER(TRIM(education))                        AS education,
    IFF(LOWER("default") = 'yes', TRUE, FALSE)    AS has_credit_default,
    balance,
    IFF(LOWER(housing) = 'yes', TRUE, FALSE)      AS has_housing_loan,
    IFF(LOWER(loan) = 'yes', TRUE, FALSE)         AS has_personal_loan,
    LOWER(TRIM(contact))                          AS contact_method,
    day,
    month,
    duration                                      AS call_duration_sec,
    campaign                                      AS contacts_this_campaign,
    pdays,
    previous                                      AS contacts_before_campaign,
    LOWER(TRIM(poutcome))                         AS previous_outcome,
    IFF(LOWER(deposit) = 'yes', TRUE, FALSE)      AS subscribed_deposit
FROM ELT_LEARNING_DB.RAW.RAW_BANK_MARKETING;

-- sanity check
SELECT * FROM SILVER_BANK_MARKETING LIMIT 10;
