import pandas as pd
from sqlalchemy import create_engine, types
from sqlalchemy.engine import URL
from sqlalchemy import text

# 1. Define SQL Server Connection
connection_url = URL.create(
    "mssql+pyodbc",
    host=r"LAPTOP-CAU4GESA\SQLEXPRESS",
    database="KenyaEconomicData",
    query={
        "driver": "ODBC Driver 18 for SQL Server",
        "trusted_connection": "yes",
        "TrustServerCertificate": "yes",
    },
)

engine = create_engine(connection_url)
# 2. Ensure Bronze Schema Exists & Load Data
with engine.connect() as conn:
    conn.execute(
        text("IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze') EXEC('CREATE SCHEMA bronze')")
    )
    conn.commit()

# 3. Read the Interest Rates CSV
# Adjust filename or skiprows if your CSV structure requires it
df = pd.read_csv("CBK_EXCHANGE_RATES.csv", skiprows=1)

# 4. Build a dict mapping every column name to NVARCHAR
dtype_mapping = {col: types.NVARCHAR(length=100) for col in df.columns}

df.to_sql(
    "exchange_rates",
    engine,
    schema="bronze",
    if_exists="replace",
    index=False,
    dtype=dtype_mapping
)

print("Successfully loaded Exchange_rates into bronze.exchange_rates!")
