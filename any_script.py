"""
any_script.py
-------------
The "Extract" step from the architecture diagram.

Downloads bank.csv straight from GitHub and loads it into
ELT_LEARNING_DB.RAW.RAW_BANK_MARKETING using write_pandas.

Install:
    pip install pandas "snowflake-connector-python[pandas]"

Run:
    export SNOWFLAKE_ACCOUNT=...
    export SNOWFLAKE_USER=...
    export SNOWFLAKE_PASSWORD=...
    python any_script.py
"""

import os
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

CSV_URL = "https://raw.githubusercontent.com/MainakRepositor/Datasets/refs/heads/master/bank.csv"


def main():
    df = pd.read_csv(CSV_URL)
    df.columns = [c.upper() for c in df.columns]  # match Snowflake's default uppercase

    ## Connect to Snowflake
    conn = snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        warehouse="ELT_LEARNING_WH",
        database="ELT_LEARNING_DB",
        schema="RAW",
        role=os.environ.get("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
    )


    cur = (
        conn.cursor()
    )  ## returns a SnowflakeCursor object, which is used to execute SQL statements
    cur.execute("""
        CREATE TABLE IF NOT EXISTS RAW_BANK_MARKETING (
            AGE INT, JOB STRING, MARITAL STRING, EDUCATION STRING,
            "DEFAULT" STRING, BALANCE INT, HOUSING STRING, LOAN STRING,
            CONTACT STRING, DAY INT, MONTH STRING, DURATION INT,
            CAMPAIGN INT, PDAYS INT, PREVIOUS INT, POUTCOME STRING,
            DEPOSIT STRING
        )
    """)

    success, nchunks, nrows, _ = write_pandas(conn, df, "RAW_BANK_MARKETING")
    print(f"Loaded {nrows} rows into RAW_BANK_MARKETING (success={success})")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
