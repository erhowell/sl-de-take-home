import requests
import pandas as pd
import os

# API endpoints for NYC Motor Vehicle Collisions
CRASH_COLLISION_ID = 'h9gi-nx95'
CRASH_VEHICLE_ID = 'bm4k-52h4'
CRASH_PERSONS_ID = 'f55k-p6yu'


def fetch_data(id, name, limit=100000):
    print(f"Fetching {name} from NYC Open Data...")
    url = (
        f"https://data.cityofnewyork.us/resource/{id}.json"
        f"?$limit={limit}&$where=crash_date>='2024-01-01T00:00:00' AND crash_date<'2025-01-01T00:00:00'"
    )
    resp = requests.get(url)
    resp.raise_for_status()
    df = pd.DataFrame(resp.json())
    return df

if __name__ == "__main__":
    # Create data/raw directory if it doesn't exist
    os.makedirs("data/raw", exist_ok=True)

    # Fetch all three datasets
    df_crashes = fetch_data(CRASH_COLLISION_ID, "crashes")
    df_crashes.to_csv("data/raw/data_raw_collisions.csv", index=False)

    df_vehicles = fetch_data(CRASH_VEHICLE_ID, "vehicles", 200000)
    df_vehicles.to_csv("data/raw/data_raw_vehicles.csv", index=False)

    df_persons = fetch_data(CRASH_PERSONS_ID, "persons", 500000)
    df_persons.to_csv("data/raw/data_raw_persons.csv", index=False)

    print(f"\n=== Summary ===")
    print(f"Total crashes: {len(df_crashes)}")
    print(f"Total vehicles: {len(df_vehicles)}")
    print(f"Total persons: {len(df_persons)}")
