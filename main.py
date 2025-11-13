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
print("\n" + "="*70)
print("Step 1: EXTRACT - Fetching data from NYC Open Data API")
print("="*70)
subprocess.run(["python", "extract/fetch_collisions.py"], check=True)

# Step 2: Load
print("\n" + "="*70)
print("Step 2: LOAD - Loading raw data into PostgreSQL")
print("="*70)
subprocess.run(["python", "load/load_to_postgres.py"], check=True)

# Step 3: Transform
print("\n" + "="*70)
print("Step 3: TRANSFORM - Creating analytical tables")
print("="*70)

# Run collision transformations
print("\n[1/3] Running collision transformations...")
with open("transform/transform_collisions.sql") as f:
    sql = f.read()
with engine.begin() as conn:
    conn.execute(text(sql))
print("✅ Collision tables created")

# Run vehicle transformations
print("\n[2/3] Running vehicle transformations...")
with open("transform/transform_vehicles.sql") as f:
    sql = f.read()
with engine.begin() as conn:
    conn.execute(text(sql))
print("✅ Vehicle tables created")

# Run person transformations
print("\n[3/3] Running person/safety transformations...")
with open("transform/transform_persons.sql") as f:
    sql = f.read()
with engine.begin() as conn:
    conn.execute(text(sql))
print("✅ Person/safety tables created")

# Step 4: Summary
print("\n" + "="*70)
print("Step 4: SUMMARY - Counting analytical tables")
print("="*70)

with engine.connect() as conn:
    # Get all tables
    tables_query = text("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
            AND table_name NOT LIKE 'raw_%'
        ORDER BY table_name
    """)
    tables = pd.read_sql(tables_query, conn)

    print(f"\nCreated {len(tables)} analytical tables:")
    for idx, row in tables.iterrows():
        table_name = row['table_name']
        count_query = text(f"SELECT COUNT(*) as count FROM {table_name}")
        result = conn.execute(count_query).fetchone()
        print(f"  • {table_name}: {result[0]:,} rows")

print("\n" + "="*70)
print("✅ ELT PIPELINE COMPLETED SUCCESSFULLY!")
print("="*70)
print("\nNext steps:")
print("  • Run: jupyter notebook analyze_collisions.ipynb")
print("  • Or query tables directly from PostgreSQL")
print("="*70 + "\n")