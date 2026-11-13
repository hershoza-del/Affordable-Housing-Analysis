-- 1. previewing the whole csv

SELECT * FROM data.affordable_housing_analysis;

-- 2. running sample queries

SELECT `Program Group`, `Extended Affordability Only`, `Prevailing Wage Status`
FROM data.affordable_housing_analysis
WHERE `Extended Affordability Only` = "True";

SELECT `Program Group`, COUNT(*) AS number_of_projects_in_group 
FROM data.affordable_housing_analysis
GROUP BY `Program Group`
HAVING COUNT(*) > 1500;

-- 3. running queries based on the three questions I have for this week's project

SELECT SUM(`All Counted Units`) FROM data.affordable_housing_analysis;
SELECT SUM(`Total Units`) FROM data.affordable_housing_analysis;
SELECT `Total Units` - `All Counted Units` AS unknown_units FROM data.affordable_housing_analysis;

WITH income_groupings AS (
SELECT `Extremely Low Income Units`, `Very Low Income Units`, `Low Income Units`,
`Moderate Income Units`, `Middle Income Units`
FROM data.affordable_housing_analysis
)
SELECT * 
FROM income_groupings;

SELECT `Program Group` AS program_group, SUM(`All Counted Units`) AS all_counted_units,
CASE
WHEN SUM(`All Counted Units`) > 100000 THEN "Lot of units for a program"
WHEN SUM(`All Counted Units`) BETWEEN 50000 AND 100000 THEN "Decent amount of units for a program"
ELSE "Relatively normal amount of units for a program"
END AS program_group_units
FROM data.affordable_housing_analysis
GROUP BY program_group;