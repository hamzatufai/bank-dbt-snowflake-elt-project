"""
any_script.py

----------------

The "Extract" step from the architecture diagram.

Downloads bank.csv directly from GitHub and loads it into:

    ELT_LEARNING_DB.RAW.RAW_BANK_MARKETING

using write_pandas.

Install:

    pip install pandas "snowflake-connector-python[pandas]" python-dotenv

Run:

    python any_script.py
"""

import os

import pandas as pd
import snowflake.connector
from dotenv import load_dotenv
from snowflake.connector.pandas_tools import write_pandas

# Load variables from .env
load_dotenv()


CSV_URL = "https://raw.githubusercontent.com/MainakRepositor/Datasets/refs/heads/master/bank.csv"


def main():

    # ---------------------------------------------------------
    # Read CSV
    # ---------------------------------------------------------

    

    df = pd.read_csv(CSV_URL)


    # Match Snowflake's default uppercase column names
    df.columns = [c.upper() for c in df.columns]

    # ---------------------------------------------------------
    # Snowflake connection
    # ---------------------------------------------------------

    conn = snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
        database=os.environ["SNOWFLAKE_DATABASE"],
        schema=os.environ["SNOWFLAKE_SCHEMA"],
        role=os.environ.get("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
    )

    # ---------------------------------------------------------
    # Cursor
    # ---------------------------------------------------------

    cur = conn.cursor()

    # ---------------------------------------------------------
    # Set database and schema explicitly
    # ---------------------------------------------------------

    cur.execute(f"USE DATABASE {os.environ['SNOWFLAKE_DATABASE']}")

    cur.execute(f"USE SCHEMA {os.environ['SNOWFLAKE_SCHEMA']}")

    # ---------------------------------------------------------
    # Create RAW table
    # ---------------------------------------------------------

    table_name = os.environ["SNOWFLAKE_RAW_TABLE"]

    cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {table_name} (

            AGE INT,
            JOB STRING,
            MARITAL STRING,
            EDUCATION STRING,
            "DEFAULT" STRING,
            BALANCE INT,
            HOUSING STRING,
            LOAN STRING,
            CONTACT STRING,
            DAY INT,
            MONTH STRING,
            DURATION INT,
            CAMPAIGN INT,
            PDAYS INT,
            PREVIOUS INT,
            POUTCOME STRING,
            DEPOSIT STRING

        )
    """)

    # ---------------------------------------------------------
    # Load DataFrame into Snowflake
    # ---------------------------------------------------------

    success, nchunks, nrows, _ = write_pandas(conn, df, table_name)

    # ---------------------------------------------------------
    # Result
    # ---------------------------------------------------------

    print(
        f"Loaded {nrows} rows into "
        f"{os.environ['SNOWFLAKE_DATABASE']}."
        f"{os.environ['SNOWFLAKE_SCHEMA']}."
        f"{table_name} "
        f"(success={success})"
    )

    # ---------------------------------------------------------
    # Close connection
    # ---------------------------------------------------------

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
