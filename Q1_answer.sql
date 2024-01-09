-- CODE CHALLENGE V2.11

-- QUESTION 1

/*
1. Data Integrity Checking & Cleanup

Alphabetically list all of the country codes in the continent_map table that appear more than once. Display any values where country_code 
is null as country_code = "FOO" and make this row appear first in the list, even though it should alphabetically sort to the middle. 
Provide the results of this query as your answer.
*/

-- remove empty values, change to NULL
UPDATE continent_map
	SET country_code = CASE WHEN country_code = '' THEN NULL ELSE country_code END,
		continent_code = CASE WHEN continent_code = '' THEN NULL ELSE continent_code END;

SELECT CASE WHEN ISNULL(country_code) THEN 'FOO' -- query all null value as 'FOO' 
	ELSE country_code
    END AS cc
FROM continent_map
GROUP BY cc
HAVING count(*) > 1 -- make sure duplicate
ORDER BY (cc = 'FOO') DESC, 1;

SELECT * FROM continent_map
WHERE country_code = 'RUS'
ORDER BY country_code;

/*
1.

- For all countries that have multiple rows in the continent_map table, delete all multiple records leaving only the 1 record per country.
  The record that you keep should be the first one when sorted by the continent_code alphabetically ascending. Provide the query/ies and 
  explanation of step(s) that you follow to delete these records.
*/

drop table IF EXISTS t1; -- drop table if exists
CREATE TABLE t1 ( 
	SELECT row_number() over (PARTITION BY country_code ORDER BY continent_code ASC) as id, 
    -- number each row with same country_code, ordered by continent_code alphabetically
	-- so the countries with multiple continents have id:1 for the first continent that appears alphabetically
    country_code, continent_code
	FROM continent_map
    ORDER BY country_code, id, continent_code); 
    
SELECT * FROM t1; -- inspecting table



-- create a second temp table which only keeps the rows which appear first when sorted alphabetically by their continent_code, for each
-- distinct country_code
DROP TABLE t2; -- drop table if exists
CREATE TABLE t2 (SELECT country_code, continent_code FROM t1 WHERE id = 1); -- keep first row of each distinct country_code, leave the rest.

SELECT * FROM t2; -- inspect table

DELETE FROM continent_map; -- remove old values from continent_map tables

INSERT INTO continent_map -- insert the new values with no duplicate country_codes
	(SELECT country_code, continent_code FROM t2);

SELECT * FROM continent_map; -- inspect table

/*
# country_code, continent_code
NULL, 'AS\r'
'ABW', 'NA\r'
'AFG', 'AS\r'
'AGO', 'AF\r'
'AIA', 'NA\r'
'ALA', 'EU\r'
'ALB', 'EU\r'
'AND', 'EU\r'
'ANT', 'NA\r'
'ARE', 'AS\r'
'ARG', 'SA\r'
'ARM', 'AF\r'
'ASM', 'OC\r'
'ATA', 'AN\r'
'ATF', 'AN\r'
*/

-- DROP TEMP TABLEs
DROP TABLE t1;
DROP TABLE t2;