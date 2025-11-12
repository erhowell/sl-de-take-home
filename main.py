import subprocess
import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

POSTGRES_URL = os.getenv("POSTGRES_URL")
if not POSTGRES_URL:
    raise RuntimeError("POSTGRES_URL not set in .env")

engine = create_engine(POSTGRES_URL)

# Step 1: Extract
print("=== Step 1: Extract ===")
subprocess.run(["python", "extract/fetch_collisions.py"], check=True)

# Step 2: Load
print("=== Step 2: Load ===")
subprocess.run(["python", "load/load_to_postgres.py"], check=True)

# Step 3: Transform
print("=== Step 3: Transform ===")
with open("transform/transform_collisions.sql") as f:
    sql = f.read()

with engine.begin() as conn:
    conn.execute(text(sql))

# Step 4: Export results
df_summary = pd.read_sql(text("SELECT * FROM collision_summary"), engine)
df_summary.to_csv("collision_summary.csv", index=False)
print("Pipeline complete ✅ — results saved to collision_summary.csv")
