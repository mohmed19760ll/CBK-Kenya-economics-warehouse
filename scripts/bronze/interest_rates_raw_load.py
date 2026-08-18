import pandas as pd
from sqlalchemy import create_engine, text, types
from sqlalchemy.engine import URL

# 1. Define SQL Server Connection
connection_url = URL.create(
    "mssql+pyodbc",
    host=r"localhost\SQLEXPRESS",
    database="KenyaEconomicData",
    query={
        "driver": "ODBC Driver 18 for SQL Server",
        "trusted_connection": "yes",
        "TrustServerCertificate": "yes",
    },
)

engine = create_engine(connection_url)

# 2. Read the Interest Rates CSV
# Adjust filename or skiprows if your CSV structure requires it
df_interest = pd.read_csv("CBK_INTEREST_RATES.csv", skiprows=1, skipfooter=1)

# 3. Dynamic NVARCHAR(100) Data Type Mapping for Bronze Layer
dtype_mapping = {col: types.NVARCHAR(length=100) for col in df_interest.columns}

# 4. Ensure Bronze Schema Exists & Load Data
with engine.connect() as conn:
    conn.execute(
        text("IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze') EXEC('CREATE SCHEMA bronze')")
    )
    conn.commit()

df_interest.to_sql(
    "interest_rates",
    engine,
    schema="bronze",
    if_exists="replace",
    index=False,
    dtype=dtype_mapping,
)

print("Successfully loaded interest_rates into bronze.interest_rates!")
