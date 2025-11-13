import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

POSTGRES_URL = os.getenv("POSTGRES_URL")
if not POSTGRES_URL:
    raise RuntimeError("POSTGRES_URL not set in .env")

engine = create_engine(POSTGRES_URL)

def load_table(df, table_name):
    """Load a dataframe into PostgreSQL, replacing if exists"""
    print(f"Loading {len(df)} rows into {table_name}...")
    with engine.begin() as conn:
        conn.execute(text(f"DROP TABLE IF EXISTS {table_name};"))
        df.to_sql(table_name, conn, index=False)
    print(f"✅ {table_name} loaded successfully")

if __name__ == "__main__":
    # Load crashes
    print("=== Loading Crash Data ===")
    df_crashes = pd.read_csv("data/raw/data_raw_collisions.csv")
    load_table(df_crashes, "raw_collisions")

    # Load vehicles
    print("\n=== Loading Vehicle Data ===")
    df_vehicles = pd.read_csv("data/raw/data_raw_vehicles.csv")
    load_table(df_vehicles, "raw_collision_vehicles")

    # Load persons
    print("\n=== Loading Person Data ===")
    df_persons = pd.read_csv("data/raw/data_raw_persons.csv")
    load_table(df_persons, "raw_collision_persons")

    print("\n=== Summary ===")
    print(f"Total crashes loaded: {len(df_crashes)}")
    print(f"Total vehicles loaded: {len(df_vehicles)}")
    print(f"Total persons loaded: {len(df_persons)}")
    print(f"Avg vehicles per crash: {len(df_vehicles) / len(df_crashes):.2f}")
    print(f"Avg persons per crash: {len(df_persons) / len(df_crashes):.2f}")