import requests
import pandas as pd

API_URL = (
    "https://data.cityofnewyork.us/resource/h9gi-nx95.json"
    "?$limit=10000&$where=crash_date>'2024-10-01T00:00:00'"
)

def fetch_collisions():
    print("Fetching collisions from NYC Open Data...")
    resp = requests.get(API_URL)
    resp.raise_for_status()
    df = pd.DataFrame(resp.json())
    print(f"Fetched {len(df)} rows")
    return df

if __name__ == "__main__":
    df = fetch_collisions()
    df.to_csv("data_raw_collisions.csv", index=False)  # optional local backup
