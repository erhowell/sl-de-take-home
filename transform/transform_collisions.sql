-- ============================================================================
-- NYC COLLISION DATA TRANSFORMATIONS
-- Creates analytical tables from raw collision, vehicle, and person data
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. COLLISION SUMMARY - Basic daily aggregations by borough
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS collision_summary;

CREATE TABLE collision_summary AS
SELECT
    borough,
    DATE(crash_date) AS crash_day,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN CAST(number_of_persons_injured AS INTEGER) > 0 THEN 1 ELSE 0 END) AS injury_incidents,
    SUM(CASE WHEN CAST(number_of_persons_killed AS INTEGER) > 0 THEN 1 ELSE 0 END) AS fatal_incidents,
    SUM(CAST(number_of_persons_injured AS INTEGER)) AS total_persons_injured,
    SUM(CAST(number_of_persons_killed AS INTEGER)) AS total_persons_killed,
    SUM(CAST(number_of_pedestrians_injured AS INTEGER)) AS pedestrians_injured,
    SUM(CAST(number_of_pedestrians_killed AS INTEGER)) AS pedestrians_killed,
    SUM(CAST(number_of_cyclist_injured AS INTEGER)) AS cyclists_injured,
    SUM(CAST(number_of_cyclist_killed AS INTEGER)) AS cyclists_killed,
    SUM(CAST(number_of_motorist_injured AS INTEGER)) AS motorists_injured,
    SUM(CAST(number_of_motorist_killed AS INTEGER)) AS motorists_killed
FROM raw_collisions
WHERE borough IS NOT NULL
GROUP BY borough, crash_day
ORDER BY crash_day DESC, total_collisions DESC;

-- ----------------------------------------------------------------------------
-- 2. HOURLY PATTERNS - When do collisions happen?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS collision_by_hour;

CREATE TABLE collision_by_hour AS
SELECT
    EXTRACT(HOUR FROM crash_time::time) AS hour_of_day,
    borough,
    COUNT(*) AS total_collisions,
    SUM(CAST(number_of_persons_injured AS INTEGER)) AS total_injured,
    SUM(CAST(number_of_persons_killed AS INTEGER)) AS total_killed,
    ROUND(AVG(CAST(number_of_persons_injured AS INTEGER)), 2) AS avg_injured_per_collision
FROM raw_collisions
WHERE crash_time IS NOT NULL AND borough IS NOT NULL
GROUP BY hour_of_day, borough
ORDER BY hour_of_day, total_collisions DESC;

-- ----------------------------------------------------------------------------
-- 3. DAY OF WEEK PATTERNS - Weekday vs weekend patterns
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS collision_by_weekday;

CREATE TABLE collision_by_weekday AS
SELECT
    TO_CHAR(DATE(crash_date), 'Day') AS day_of_week,
    EXTRACT(DOW FROM DATE(crash_date)) AS day_num,
    borough,
    COUNT(*) AS total_collisions,
    SUM(CAST(number_of_persons_injured AS INTEGER)) AS total_injured,
    ROUND(AVG(CAST(number_of_persons_injured AS INTEGER)), 2) AS avg_injured_per_collision,
    SUM(CASE WHEN CAST(number_of_persons_killed AS INTEGER) > 0 THEN 1 ELSE 0 END) AS fatal_crashes
FROM raw_collisions
WHERE borough IS NOT NULL
GROUP BY day_of_week, day_num, borough
ORDER BY day_num, borough;

-- ----------------------------------------------------------------------------
-- 4. CONTRIBUTING FACTORS - What causes collisions?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS contributing_factors_summary;

CREATE TABLE contributing_factors_summary AS
SELECT
    contributing_factor_vehicle_1 AS factor,
    COUNT(*) AS collision_count,
    SUM(CAST(number_of_persons_injured AS INTEGER)) AS total_injured,
    SUM(CAST(number_of_persons_killed AS INTEGER)) AS total_killed,
    ROUND(100.0 * SUM(CASE WHEN CAST(number_of_persons_injured AS INTEGER) > 0 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN CAST(number_of_persons_killed AS INTEGER) > 0 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS fatality_rate_pct
FROM raw_collisions
WHERE contributing_factor_vehicle_1 IS NOT NULL
    AND contributing_factor_vehicle_1 != 'Unspecified'
GROUP BY contributing_factor_vehicle_1
HAVING COUNT(*) > 10
ORDER BY collision_count DESC;

-- ----------------------------------------------------------------------------
-- 5. GEOGRAPHIC HOTSPOTS - Dangerous zip codes
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS collision_hotspots_zip;

CREATE TABLE collision_hotspots_zip AS
SELECT
    zip_code,
    borough,
    COUNT(*) AS collision_count,
    SUM(CAST(number_of_persons_injured AS INTEGER)) AS total_injured,
    SUM(CAST(number_of_persons_killed AS INTEGER)) AS total_killed,
    ROUND(100.0 * SUM(CAST(number_of_persons_injured AS INTEGER)) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct
FROM raw_collisions
WHERE zip_code IS NOT NULL
GROUP BY zip_code, borough
HAVING COUNT(*) >= 10
ORDER BY collision_count DESC;

-- ----------------------------------------------------------------------------
-- 6. DANGEROUS STREETS - Top collision locations
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dangerous_streets;

CREATE TABLE dangerous_streets AS
SELECT
    on_street_name,
    borough,
    COUNT(*) AS collision_count,
    SUM(CAST(number_of_persons_injured AS INTEGER)) AS total_injured,
    SUM(CAST(number_of_persons_killed AS INTEGER)) AS total_killed
FROM raw_collisions
WHERE on_street_name IS NOT NULL AND borough IS NOT NULL
GROUP BY on_street_name, borough
HAVING COUNT(*) >= 5
ORDER BY collision_count DESC
LIMIT 100;

-- ----------------------------------------------------------------------------
-- 7. RUSH HOUR ANALYSIS - Peak travel time safety
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS rush_hour_analysis;

CREATE TABLE rush_hour_analysis AS
SELECT
    borough,
    CASE
        WHEN EXTRACT(HOUR FROM crash_time::time) BETWEEN 7 AND 9 THEN 'Morning Rush (7-9 AM)'
        WHEN EXTRACT(HOUR FROM crash_time::time) BETWEEN 16 AND 19 THEN 'Evening Rush (4-7 PM)'
        WHEN EXTRACT(HOUR FROM crash_time::time) BETWEEN 22 AND 23
             OR EXTRACT(HOUR FROM crash_time::time) BETWEEN 0 AND 5 THEN 'Night (10 PM-5 AM)'
        ELSE 'Off-Peak'
    END AS time_period,
    COUNT(*) AS collision_count,
    SUM(CAST(number_of_persons_injured AS INTEGER)) AS total_injured,
    ROUND(AVG(CAST(number_of_persons_injured AS INTEGER)), 2) AS avg_injuries_per_collision
FROM raw_collisions
WHERE crash_time IS NOT NULL AND borough IS NOT NULL
GROUP BY borough, time_period
ORDER BY collision_count DESC;
