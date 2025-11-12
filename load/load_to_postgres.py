import os
import pandas as pd
from sqlalchemy import create_engine,text
from dotenv import load_dotenv

load_dotenv()

POSTGRES_URL = os.getenv("POSTGRES_URL")
if not POSTGRES_URL:
    raise RuntimeError("POSTGRES_URL not set in .env")

engine = create_engine(POSTGRES_URL)

def load_collisions(df):
    print("Loading raw data into PostgreSQL...")
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS raw_collisions;"))
        df.to_sql("raw_collisions", conn, index=False)
    print("✅ Data loaded into PostgreSQL")

if __name__ == "__main__":
    df = pd.read_csv("data_raw_collisions.csv")  # or fetch directly
    load_collisions(df)
