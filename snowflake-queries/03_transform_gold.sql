-- ============================================================
-- 03_transform_gold.sql
-- Layer: GOLD
-- Purpose: join + aggregate SILVER into business-ready tables.
--          This is the manual version of what dbt's "marts"
--          models will do for you automatically later.
-- ============================================================

USE DATABASE ELT_LEARNING_DB;

CREATE SCHEMA IF NOT EXISTS GOLD;
USE SCHEMA GOLD;

-- One row per order, with its total paid amount
CREATE OR REPLACE TABLE GOLD_FCT_ORDERS AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    COALESCE(SUM(p.amount), 0)             AS amount_paid,
    COUNT(p.payment_id)                    AS payment_count
FROM ELT_LEARNING_DB.SILVER.SILVER_ORDERS o
LEFT JOIN ELT_LEARNING_DB.SILVER.SILVER_PAYMENTS p
    ON o.order_id = p.order_id
GROUP BY o.order_id, o.customer_id, o.order_date, o.status;

-- One row per customer, with lifetime totals
CREATE OR REPLACE TABLE GOLD_DIM_CUSTOMERS AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.created_at,
    COUNT(o.order_id)                      AS total_orders,
    COALESCE(SUM(o.amount_paid), 0)        AS lifetime_value
FROM ELT_LEARNING_DB.SILVER.SILVER_CUSTOMERS c
LEFT JOIN GOLD_FCT_ORDERS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.created_at;

-- sanity check
SELECT * FROM GOLD_FCT_ORDERS;
SELECT * FROM GOLD_DIM_CUSTOMERS ORDER BY lifetime_value DESC;

-- ============================================================
-- Additional dataset: bank marketing campaign summary
-- ============================================================

CREATE OR REPLACE TABLE GOLD_BANK_CAMPAIGN_SUMMARY AS
SELECT
    job,
    marital,
    education,
    COUNT(*)                                                   AS total_contacted,
    SUM(IFF(subscribed_deposit, 1, 0))                         AS total_subscribed,
    ROUND(SUM(IFF(subscribed_deposit, 1, 0)) / COUNT(*), 4)    AS subscription_rate,
    ROUND(AVG(balance), 2)                                     AS avg_balance,
    ROUND(AVG(call_duration_sec), 1)                           AS avg_call_duration_sec
FROM ELT_LEARNING_DB.SILVER.SILVER_BANK_MARKETING
GROUP BY job, marital, education
ORDER BY subscription_rate DESC;

-- sanity check
SELECT * FROM GOLD_BANK_CAMPAIGN_SUMMARY;
