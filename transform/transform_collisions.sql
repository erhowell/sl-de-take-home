-- Transform raw collisions into analytical summary
-- This file can be run in DuckDB or Postgres

DROP TABLE IF EXISTS collision_summary;

CREATE TABLE collision_summary AS
SELECT
    borough,
    DATE(crash_date) AS crash_day,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN CAST(number_of_persons_injured AS INTEGER) > 0 THEN 1 ELSE 0 END) AS injury_incidents,
    SUM(CASE WHEN CAST(number_of_persons_killed AS INTEGER) > 0 THEN 1 ELSE 0 END) AS fatal_incidents
FROM raw_collisions
WHERE borough IS NOT NULL
GROUP BY borough, crash_day
ORDER BY crash_day DESC, total_collisions DESC;
