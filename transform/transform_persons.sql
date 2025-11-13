-- ============================================================================
-- PERSON & SAFETY ANALYSIS TRANSFORMATIONS
-- Analyzes person-level injury and safety equipment data
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. PERSON TYPE ANALYSIS - Occupants vs Pedestrians vs Cyclists
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS person_type_analysis;

CREATE TABLE person_type_analysis AS
SELECT
    p.person_type,
    c.borough,
    COUNT(*) AS person_count,
    SUM(CASE WHEN p.person_injury IN ('Injured', 'Killed') THEN 1 ELSE 0 END) AS injured_count,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS killed_count,
    ROUND(100.0 * SUM(CASE WHEN p.person_injury IN ('Injured', 'Killed') THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct
FROM raw_collision_persons p
LEFT JOIN raw_collisions c ON p.collision_id = c.collision_id
WHERE p.person_type IS NOT NULL AND c.borough IS NOT NULL
GROUP BY p.person_type, c.borough
ORDER BY person_count DESC;

-- ----------------------------------------------------------------------------
-- 2. SAFETY EQUIPMENT EFFECTIVENESS - Does it save lives?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS safety_equipment_analysis;

CREATE TABLE safety_equipment_analysis AS
SELECT
    p.safety_equipment,
    p.person_type,
    COUNT(*) AS person_count,
    SUM(CASE WHEN p.person_injury = 'Injured' THEN 1 ELSE 0 END) AS injured_count,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS killed_count,
    ROUND(100.0 * SUM(CASE WHEN p.person_injury IN ('Injured', 'Killed') THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 4) AS fatality_rate_pct
FROM raw_collision_persons p
WHERE p.safety_equipment IS NOT NULL
    AND p.safety_equipment != 'None'
    AND p.safety_equipment != 'Unknown'
GROUP BY p.safety_equipment, p.person_type
HAVING COUNT(*) >= 50
ORDER BY person_count DESC;

-- ----------------------------------------------------------------------------
-- 3. AGE GROUP VULNERABILITY - Who is most at risk?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS age_group_analysis;

CREATE TABLE age_group_analysis AS
SELECT
    CASE
        WHEN p.person_age::text ~ '^[0-9]+$' AND p.person_age::int < 18 THEN 'Under 18'
        WHEN p.person_age::text ~ '^[0-9]+$' AND p.person_age::int BETWEEN 18 AND 30 THEN '18-30'
        WHEN p.person_age::text ~ '^[0-9]+$' AND p.person_age::int BETWEEN 31 AND 50 THEN '31-50'
        WHEN p.person_age::text ~ '^[0-9]+$' AND p.person_age::int BETWEEN 51 AND 70 THEN '51-70'
        WHEN p.person_age::text ~ '^[0-9]+$' AND p.person_age::int > 70 THEN '70+'
        ELSE 'Unknown'
    END AS age_group,
    p.person_type,
    p.person_sex,
    COUNT(*) AS person_count,
    SUM(CASE WHEN p.person_injury = 'Injured' THEN 1 ELSE 0 END) AS injured,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS killed,
    ROUND(100.0 * SUM(CASE WHEN p.person_injury IN ('Injured', 'Killed') THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct
FROM raw_collision_persons p
WHERE p.person_age IS NOT NULL
GROUP BY age_group, p.person_type, p.person_sex
HAVING COUNT(*) >= 20
ORDER BY age_group, person_count DESC;

-- ----------------------------------------------------------------------------
-- 4. PEDESTRIAN SAFETY ANALYSIS - Pedestrian-specific details
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS pedestrian_safety_analysis;

CREATE TABLE pedestrian_safety_analysis AS
SELECT
    p.ped_role,
    p.ped_action,
    p.ped_location,
    COUNT(*) AS pedestrian_count,
    SUM(CASE WHEN p.person_injury = 'Injured' THEN 1 ELSE 0 END) AS injured,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS killed,
    ROUND(100.0 * SUM(CASE WHEN p.person_injury IN ('Injured', 'Killed') THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct
FROM raw_collision_persons p
WHERE p.person_type = 'Pedestrian'
    AND (p.ped_role IS NOT NULL OR p.ped_action IS NOT NULL)
GROUP BY p.ped_role, p.ped_action, p.ped_location
HAVING COUNT(*) >= 10
ORDER BY pedestrian_count DESC;

-- ----------------------------------------------------------------------------
-- 5. BODILY INJURY TYPE ANALYSIS - What injuries occur?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS bodily_injury_analysis;

CREATE TABLE bodily_injury_analysis AS
SELECT
    p.bodily_injury,
    p.person_type,
    COUNT(*) AS occurrence_count,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS fatalities
FROM raw_collision_persons p
WHERE p.bodily_injury IS NOT NULL
    AND p.bodily_injury != 'Does Not Apply'
GROUP BY p.bodily_injury, p.person_type
HAVING COUNT(*) >= 20
ORDER BY occurrence_count DESC;

-- ----------------------------------------------------------------------------
-- 6. POSITION IN VEHICLE ANALYSIS - Which seats are safest?
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS position_safety_analysis;

CREATE TABLE position_safety_analysis AS
SELECT
    p.position_in_vehicle,
    COUNT(*) AS person_count,
    SUM(CASE WHEN p.person_injury = 'Injured' THEN 1 ELSE 0 END) AS injured,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS killed,
    ROUND(100.0 * SUM(CASE WHEN p.person_injury IN ('Injured', 'Killed') THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS injury_rate_pct
FROM raw_collision_persons p
WHERE p.position_in_vehicle IS NOT NULL
    AND p.person_type = 'Occupant'
GROUP BY p.position_in_vehicle
HAVING COUNT(*) >= 50
ORDER BY person_count DESC;

-- ----------------------------------------------------------------------------
-- 7. EJECTION ANALYSIS - Impact of being ejected from vehicle
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS ejection_analysis;

CREATE TABLE ejection_analysis AS
SELECT
    p.ejection,
    COUNT(*) AS person_count,
    SUM(CASE WHEN p.person_injury = 'Injured' THEN 1 ELSE 0 END) AS injured,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS killed,
    ROUND(100.0 * SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) /
          NULLIF(COUNT(*), 0), 2) AS fatality_rate_pct
FROM raw_collision_persons p
WHERE p.ejection IS NOT NULL
    AND p.ejection != 'Not Ejected'
GROUP BY p.ejection
ORDER BY person_count DESC;

-- ----------------------------------------------------------------------------
-- 8. PERSON-LEVEL CONTRIBUTING FACTORS
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS person_contributing_factors;

CREATE TABLE person_contributing_factors AS
SELECT
    p.contributing_factor_1 AS factor,
    p.person_type,
    COUNT(*) AS occurrence_count,
    SUM(CASE WHEN p.person_injury = 'Injured' THEN 1 ELSE 0 END) AS injuries,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS fatalities
FROM raw_collision_persons p
WHERE p.contributing_factor_1 IS NOT NULL
    AND p.contributing_factor_1 != 'Unspecified'
GROUP BY p.contributing_factor_1, p.person_type
HAVING COUNT(*) >= 20
ORDER BY occurrence_count DESC;

-- ----------------------------------------------------------------------------
-- 9. COMPREHENSIVE INJURY SEVERITY SUMMARY
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS injury_severity_summary;

CREATE TABLE injury_severity_summary AS
SELECT
    c.borough,
    DATE(c.crash_date) AS crash_day,
    COUNT(DISTINCT p.collision_id) AS total_crashes,
    COUNT(*) AS total_persons_involved,
    SUM(CASE WHEN p.person_type = 'Pedestrian' THEN 1 ELSE 0 END) AS pedestrians,
    SUM(CASE WHEN p.person_type = 'Cyclist' THEN 1 ELSE 0 END) AS cyclists,
    SUM(CASE WHEN p.person_type = 'Occupant' THEN 1 ELSE 0 END) AS occupants,
    SUM(CASE WHEN p.person_injury = 'Injured' THEN 1 ELSE 0 END) AS total_injured,
    SUM(CASE WHEN p.person_injury = 'Killed' THEN 1 ELSE 0 END) AS total_killed,
    SUM(CASE WHEN p.person_type = 'Pedestrian' AND p.person_injury IN ('Injured', 'Killed') THEN 1 ELSE 0 END) AS pedestrian_casualties,
    SUM(CASE WHEN p.person_type = 'Cyclist' AND p.person_injury IN ('Injured', 'Killed') THEN 1 ELSE 0 END) AS cyclist_casualties
FROM raw_collision_persons p
LEFT JOIN raw_collisions c ON p.collision_id = c.collision_id
WHERE c.borough IS NOT NULL
GROUP BY c.borough, crash_day
ORDER BY crash_day DESC, total_persons_involved DESC;
