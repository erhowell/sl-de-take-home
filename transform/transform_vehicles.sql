-- ============================================================================
-- VEHICLE ANALYSIS TRANSFORMATIONS
-- Analyzes vehicle-specific data from collisions
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. VEHICLE TYPE ANALYSIS - Which vehicles are involved most?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS vehicle_type_analysis;

CREATE TABLE vehicle_type_analysis AS
SELECT
    v.vehicle_type,
    COUNT(*) AS collision_count,
    COUNT(DISTINCT v.collision_id) AS unique_crashes,
    SUM(CASE WHEN c.number_of_persons_injured::int > 0 THEN 1 ELSE 0 END) AS crashes_with_injuries,
    SUM(c.number_of_persons_injured::int) AS total_injuries,
    ROUND(100.0 * SUM(CASE WHEN c.number_of_persons_injured::int > 0 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(DISTINCT v.collision_id), 0), 2) AS injury_rate_pct
FROM raw_collision_vehicles v
LEFT JOIN raw_collisions c ON v.collision_id = c.collision_id
WHERE v.vehicle_type IS NOT NULL
GROUP BY v.vehicle_type
HAVING COUNT(*) >= 50
ORDER BY collision_count DESC;

-- ----------------------------------------------------------------------------
-- 2. VEHICLE MAKE ANALYSIS - Safety by manufacturer
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS vehicle_make_analysis;

CREATE TABLE vehicle_make_analysis AS
SELECT
    v.vehicle_make,
    COUNT(*) AS vehicle_count,
    COUNT(DISTINCT v.collision_id) AS unique_crashes,
    SUM(c.number_of_persons_injured::int) AS total_injuries,
    SUM(c.number_of_persons_killed::int) AS total_fatalities,
    ROUND(AVG(c.number_of_persons_injured::int), 2) AS avg_injuries_per_crash
FROM raw_collision_vehicles v
LEFT JOIN raw_collisions c ON v.collision_id = c.collision_id
WHERE v.vehicle_make IS NOT NULL
GROUP BY v.vehicle_make
HAVING COUNT(*) >= 100
ORDER BY vehicle_count DESC;

-- ----------------------------------------------------------------------------
-- 3. DRIVER LICENSE STATUS - Impact on safety
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS driver_license_analysis;

CREATE TABLE driver_license_analysis AS
SELECT
    v.driver_license_status,
    COUNT(*) AS crash_count,
    SUM(c.number_of_persons_injured::int) AS total_injured,
    SUM(c.number_of_persons_killed::int) AS total_killed,
    ROUND(100.0 * SUM(CASE WHEN c.number_of_persons_injured::int > 0 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct
FROM raw_collision_vehicles v
LEFT JOIN raw_collisions c ON v.collision_id = c.collision_id
WHERE v.driver_license_status IS NOT NULL
GROUP BY v.driver_license_status
ORDER BY crash_count DESC;

-- ----------------------------------------------------------------------------
-- 4. DRIVER DEMOGRAPHICS - Gender analysis
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS driver_gender_analysis;

CREATE TABLE driver_gender_analysis AS
SELECT
    v.driver_sex,
    c.borough,
    COUNT(*) AS crash_count,
    SUM(c.number_of_persons_injured::int) AS total_injured,
    ROUND(AVG(c.number_of_persons_injured::int), 2) AS avg_injured_per_crash
FROM raw_collision_vehicles v
LEFT JOIN raw_collisions c ON v.collision_id = c.collision_id
WHERE v.driver_sex IS NOT NULL AND c.borough IS NOT NULL
GROUP BY v.driver_sex, c.borough
ORDER BY c.borough, crash_count DESC;

-- ----------------------------------------------------------------------------
-- 5. VEHICLE DAMAGE ANALYSIS - Crash severity indicators
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS vehicle_damage_analysis;

CREATE TABLE vehicle_damage_analysis AS
SELECT
    v.vehicle_damage,
    COUNT(*) AS vehicle_count,
    SUM(c.number_of_persons_injured::int) AS total_injured,
    SUM(c.number_of_persons_killed::int) AS total_killed,
    ROUND(AVG(c.number_of_persons_injured::int), 2) AS avg_injuries_per_crash
FROM raw_collision_vehicles v
LEFT JOIN raw_collisions c ON v.collision_id = c.collision_id
WHERE v.vehicle_damage IS NOT NULL
GROUP BY v.vehicle_damage
ORDER BY vehicle_count DESC;

-- ----------------------------------------------------------------------------
-- 6. VEHICLE CONTRIBUTING FACTORS - From vehicle perspective
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS vehicle_contributing_factors;

CREATE TABLE vehicle_contributing_factors AS
SELECT
    v.contributing_factor_1 AS factor,
    v.vehicle_type,
    COUNT(*) AS occurrence_count,
    SUM(c.number_of_persons_injured::int) AS total_injured,
    SUM(c.number_of_persons_killed::int) AS total_killed
FROM raw_collision_vehicles v
LEFT JOIN raw_collisions c ON v.collision_id = c.collision_id
WHERE v.contributing_factor_1 IS NOT NULL
    AND v.contributing_factor_1 != 'Unspecified'
GROUP BY v.contributing_factor_1, v.vehicle_type
HAVING COUNT(*) >= 20
ORDER BY occurrence_count DESC;

-- ----------------------------------------------------------------------------
-- 7. VEHICLE OCCUPANCY ANALYSIS - How many people per vehicle?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS vehicle_occupancy_analysis;

CREATE TABLE vehicle_occupancy_analysis AS
SELECT
    v.vehicle_occupants::int AS occupants,
    COUNT(*) AS vehicle_count,
    SUM(c.number_of_persons_injured::int) AS total_injured,
    ROUND(100.0 * SUM(CASE WHEN c.number_of_persons_injured::int > 0 THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct
FROM raw_collision_vehicles v
LEFT JOIN raw_collisions c ON v.collision_id = c.collision_id
WHERE v.vehicle_occupants IS NOT NULL
    AND v.vehicle_occupants::text ~ '^[0-9]+$'
    AND v.vehicle_occupants::int <= 20
GROUP BY v.vehicle_occupants::int
ORDER BY v.vehicle_occupants::int;

-- ----------------------------------------------------------------------------
-- 8. TRAVEL DIRECTION ANALYSIS - Which directions are most dangerous?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS travel_direction_analysis;

CREATE TABLE travel_direction_analysis AS
SELECT
    v.travel_direction,
    c.borough,
    COUNT(*) AS collision_count,
    SUM(c.number_of_persons_injured::int) AS total_injured,
    SUM(c.number_of_persons_killed::int) AS total_killed
FROM raw_collision_vehicles v
LEFT JOIN raw_collisions c ON v.collision_id = c.collision_id
WHERE v.travel_direction IS NOT NULL AND c.borough IS NOT NULL
GROUP BY v.travel_direction, c.borough
ORDER BY collision_count DESC;
