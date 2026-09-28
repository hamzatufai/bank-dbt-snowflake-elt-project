-- ============================================================
-- 01_create_raw_tables.sql
-- Layer: BRONZE / RAW
-- Purpose: create the database, warehouse-facing schema, and
--          the raw landing tables. Then seed them with a few
--          rows so you have something to query immediately.
-- ============================================================

-- 1. Database + warehouse (skip if you already have one)
CREATE DATABASE IF NOT EXISTS ELT_LEARNING_DB;
CREATE WAREHOUSE IF NOT EXISTS ELT_LEARNING_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

USE WAREHOUSE ELT_LEARNING_WH;
USE DATABASE ELT_LEARNING_DB;

-- 2. RAW schema — this is the "Bronze" layer: untouched, as-landed data
CREATE SCHEMA IF NOT EXISTS RAW;
USE SCHEMA RAW;

-- 3. Raw tables -------------------------------------------------

CREATE OR REPLACE TABLE RAW_CUSTOMERS (
    customer_id     INT,
    first_name      STRING,
    last_name       STRING,
    email           STRING,
    created_at      STRING          -- left as STRING on purpose: raw data is messy
);

CREATE OR REPLACE TABLE RAW_ORDERS (
    order_id        INT,
    customer_id     INT,
    order_date      STRING,
    status          STRING
);

CREATE OR REPLACE TABLE RAW_PAYMENTS (
    payment_id      INT,
    order_id        INT,
    payment_method  STRING,
    amount          STRING          -- stored as text on purpose, e.g. "42.50"
);

-- 4. Sample data --------------------------------------------------

INSERT INTO RAW_CUSTOMERS (customer_id, first_name, last_name, email, created_at) VALUES
    (1, 'Ayesha',  'Khan',    'ayesha.khan@example.com',   '2024-01-05'),
    (2, 'Bilal',   'Ahmed',   'bilal.ahmed@example.com',   '2024-01-09'),
    (3, 'Sara',    'Malik',   'sara.malik@example.com',    '2024-02-14'),
    (4, 'Usman',   'Raza',    'usman.raza@example.com',    '2024-03-01'),
    (5, 'Hina',    'Farooq',  'hina.farooq@example.com',   '2024-03-20');

INSERT INTO RAW_ORDERS (order_id, customer_id, order_date, status) VALUES
    (101, 1, '2024-02-01', 'completed'),
    (102, 1, '2024-03-15', 'completed'),
    (103, 2, '2024-02-20', 'cancelled'),
    (104, 3, '2024-03-02', 'completed'),
    (105, 4, '2024-03-10', 'pending'),
    (106, 5, '2024-04-01', 'completed'),
    (107, 5, '2024-04-18', 'completed');

INSERT INTO RAW_PAYMENTS (payment_id, order_id, payment_method, amount) VALUES
    (1, 101, 'credit_card', '45.00'),
    (2, 102, 'credit_card', '120.50'),
    (3, 103, 'debit_card',  '0.00'),
    (4, 104, 'cash',        '75.25'),
    (5, 105, 'credit_card', '30.00'),
    (6, 106, 'debit_card',  '89.99'),
    (7, 107, 'credit_card', '15.00');

-- sanity check
SELECT * FROM RAW_CUSTOMERS;
SELECT * FROM RAW_ORDERS;
SELECT * FROM RAW_PAYMENTS;

-- ============================================================
-- Additional dataset: bank marketing campaign data (bank.csv)
-- Source: https://raw.githubusercontent.com/MainakRepositor/Datasets/refs/heads/master/bank.csv
-- ============================================================

CREATE OR REPLACE TABLE RAW_BANK_MARKETING (
    age         INT,
    job         STRING,
    marital     STRING,
    education   STRING,
    "default"   STRING,   -- quoted: DEFAULT is a reserved word in Snowflake
    balance     INT,
    housing     STRING,
    loan        STRING,
    contact     STRING,
    day         INT,
    month       STRING,
    duration    INT,
    campaign    INT,
    pdays       INT,
    previous    INT,
    poutcome    STRING,
    deposit     STRING
);

-- Option A: load via internal stage + COPY INTO (after downloading bank.csv locally)
CREATE OR REPLACE FILE FORMAT CSV_STANDARD
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL');

CREATE OR REPLACE STAGE BANK_CSV_STAGE
    FILE_FORMAT = CSV_STANDARD;

-- from SnowSQL CLI (not a Snowsight worksheet):
-- PUT file://bank.csv @BANK_CSV_STAGE;

COPY INTO RAW_BANK_MARKETING
    FROM (SELECT $1::INT, $2::STRING, $3::STRING, $4::STRING, $5::STRING,
                 $6::INT, $7::STRING, $8::STRING, $9::STRING, $10::INT,
                 $11::STRING, $12::INT, $13::INT, $14::INT, $15::INT,
                 $16::STRING, $17::STRING
          FROM @BANK_CSV_STAGE/bank.csv)
    FILE_FORMAT = CSV_STANDARD
    ON_ERROR = 'CONTINUE';

-- NOTE: do not use the (FROM (SELECT $1, $2 ... )) shorthand without explicit
-- casts: COPY INTO would then generate positional column aliases like
-- "DEFAULT", producing "invalid identifier 'DEFAULT'" unless the target
-- table is (re)created with quoted identifiers as well.

-- Option B: skip the stage entirely and use ../any_script.py instead,
-- which downloads the CSV from GitHub and loads it with write_pandas().

-- sanity check
SELECT * FROM RAW_BANK_MARKETING LIMIT 10;
