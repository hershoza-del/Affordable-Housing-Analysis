-- 1. Create the database and start fresh
CREATE DATABASE IF NOT EXISTS affordable_housing;
USE affordable_housing;
DROP TABLE IF EXISTS buildings, projects;
SET GLOBAL local_infile = 1;
 
-- 2. Create the tables
CREATE TABLE projects (
    project_id                  VARCHAR(100),
    project_name                VARCHAR(100),
    program_group               VARCHAR(100),
    project_start_date          VARCHAR(100),
    project_completion_date     VARCHAR(100),
    extended_affordability_only VARCHAR(100),
    prevailing_wage_status      VARCHAR(100),
    planned_tax_benefit         VARCHAR(100),
    extremely_low_income_units  VARCHAR(100),
    very_low_income_units       VARCHAR(100),
    low_income_units            VARCHAR(100),
    moderate_income_units       VARCHAR(100),
    middle_income_units         VARCHAR(100),
    other_income_units          VARCHAR(100),
    counted_rental_units        VARCHAR(100),
    counted_homeownership_units VARCHAR(100),
    all_counted_units           VARCHAR(100),
    total_units                 VARCHAR(100),
    senior_units                VARCHAR(100)
);
 
CREATE TABLE buildings (
    project_id                  VARCHAR(100),
    project_name                VARCHAR(100),
    project_start_date          VARCHAR(100),
    project_completion_date     VARCHAR(100),
    building_id                 VARCHAR(100),
    house_number                VARCHAR(100),
    street                      VARCHAR(100),
    borough                     VARCHAR(100),
    postcode                    VARCHAR(100),
    bbl                         VARCHAR(100),
    bin                         VARCHAR(100),
    community_board             VARCHAR(100),
    council_district            VARCHAR(100),
    census_tract                VARCHAR(100),
    nta                         VARCHAR(100),
    latitude                    VARCHAR(100),
    longitude                   VARCHAR(100),
    latitude_internal           VARCHAR(100),
    longitude_internal          VARCHAR(100),
    building_completion_date    VARCHAR(100),
    reporting_construction_type VARCHAR(100),
    extended_affordability_only VARCHAR(100),
    prevailing_wage_status      VARCHAR(100),
    extremely_low_income_units  VARCHAR(100),
    very_low_income_units       VARCHAR(100),
    low_income_units            VARCHAR(100),
    moderate_income_units       VARCHAR(100),
    middle_income_units         VARCHAR(100),
    other_income_units          VARCHAR(100),
    studio_units                VARCHAR(100),
    br1_units                   VARCHAR(100),
    br2_units                   VARCHAR(100),
    br3_units                   VARCHAR(100),
    br4_units                   VARCHAR(100),
    br5_units                   VARCHAR(100),
    br6plus_units               VARCHAR(100),
    unknown_br_units            VARCHAR(100),
    counted_rental_units        VARCHAR(100),
    counted_homeownership_units VARCHAR(100),
    all_counted_units           VARCHAR(100),
    total_units                 VARCHAR(100)
);

-- 3. Load the original files
LOAD DATA LOCAL INFILE '/Users/hershoza/Downloads/Affordable_Housing_Production_by_Project_20261107.csv'
INTO TABLE projects
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE '/Users/hershoza/Downloads/Affordable_Housing_Production_by_Building_20261108.csv'
INTO TABLE buildings
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
IGNORE 1 LINES;

-- 4. Showing the files
SELECT COUNT(*) AS total_projects FROM projects;
SELECT COUNT(*) AS total_buildings FROM buildings;
SELECT * FROM projects;
SELECT * FROM buildings;

-- 5. Overall Join
SELECT * FROM projects p
JOIN buildings b 
ON p.project_id = b.project_id;

-- 6. Inner Join
SELECT p.project_id, p.project_name, p.program_group, p.project_start_date,
b.house_number, b.street, b.building_completion_date, b.extremely_low_income_units
FROM projects p
INNER JOIN buildings b ON p.project_id = b.project_id AND b.building_completion_date != '';

-- 7. Left Join
SELECT p.project_id, p.project_name, p.program_group, p.project_start_date,
b.house_number, b.street, b.building_completion_date, b.extremely_low_income_units
FROM projects p
LEFT JOIN buildings b ON p.project_id = b.project_id AND b.building_completion_date != '';

-- 8. Right Join
SELECT p.project_id, p.project_name, p.program_group, p.project_start_date,
b.house_number, b.street, b.building_completion_date, b.extremely_low_income_units
FROM projects p
RIGHT JOIN buildings b ON p.project_id = b.project_id AND b.building_completion_date != '';

-- 9. Another Inner Join
SELECT p.program_group AS program, COUNT(*) AS completed_buildings
FROM projects p
INNER JOIN buildings b ON p.project_id = b.project_id AND b.building_completion_date != ''
GROUP BY p.program_group
ORDER BY completed_buildings DESC;