import requests
import pandas as pd
import os

# API endpoints for NYC Motor Vehicle Collisions
CRASH_API_URL = (
    "https://data.cityofnewyork.us/resource/h9gi-nx95.json"
    "?$limit=50000&$where=crash_date>'2024-11-01T00:00:00'"
)
CRASH_VEHICLE_API_URL = (
    "https://data.cityofnewyork.us/resource/bm4k-52h4.json"
    "?$limit=50000&$where=crash_date>'2024-11-01T00:00:00'"
)
CRASH_PERSONS_API_URL = (
    "https://data.cityofnewyork.us/resource/f55k-p6yu.json"
    "?$limit=50000&$where=crash_date>'2024-11-01T00:00:00'"
)

def fetch_data(url, name):
    print(f"Fetching {name} from NYC Open Data...")
    resp = requests.get(url)
    resp.raise_for_status()
    df = pd.DataFrame(resp.json())
    print(f"✅ Fetched {len(df)} rows for {name}")
    return df

if __name__ == "__main__":
    # Create data/raw directory if it doesn't exist
    os.makedirs("data/raw", exist_ok=True)

    # Fetch all three datasets
    df_crashes = fetch_data(CRASH_API_URL, "crashes")
    df_crashes.to_csv("data/raw/data_raw_collisions.csv", index=False)

    df_vehicles = fetch_data(CRASH_VEHICLE_API_URL, "vehicles")
    df_vehicles.to_csv("data/raw/data_raw_vehicles.csv", index=False)

    df_persons = fetch_data(CRASH_PERSONS_API_URL, "persons")
    df_persons.to_csv("data/raw/data_raw_persons.csv", index=False)

    print(f"\n=== Summary ===")
    print(f"Total crashes: {len(df_crashes)}")
    print(f"Total vehicles: {len(df_vehicles)}")
    print(f"Total persons: {len(df_persons)}")
