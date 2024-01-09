-- CODE CHALLENGE V2.11

-- QUESTION 2


/*
2.

List the countries ranked 10-12 in each continent by the percent of year-over-year growth descending from 2011 to 2012.

The percent of growth should be calculated as: ((2012 gdp - 2011 gdp) / 2011 gdp)

The list should include the columns:

- rank
- continent_name
- country_code
- country_name
- growth_percent
*/

SELECT * FROM per_capita
WHERE YEAR IN(2011,2012);

-- create temp tables for gdp, different years.
CREATE TABLE t2012 (SELECT country_code, gdp_per_capita FROM per_capita WHERE year = 2012); 
CREATE TABLE t2011 (SELECT country_code, gdp_per_capita FROM per_capita WHERE year = 2011);


-- CALCULATE PERCENT GROWTH 2011-2012
DROP TABLE pc; -- pc: per capita
CREATE TABLE pc (
	SELECT t2012.country_code, t2011.gdp_per_capita as '2011', t2012.gdp_per_capita as '2012', 
		((t2012.gdp_per_capita - t2011.gdp_per_capita) / t2011.gdp_per_capita * 100) as percent_change -- =  ((2012 gdp - 2011 gdp) / 2011 gdp) * 100 for percent
	FROM t2012 
		INNER JOIN t2011 USING (country_code)
		-- do not calculate the percentage change for countires with null gdp_per_capita values in either 2011 or 2012
	WHERE t2011.gdp_per_capita IS NOT NULL and t2012.gdp_per_capita IS NOT NULL 
	ORDER BY percent_change DESC
);

SELECT * FROM pc;

-- below are some problem that occured when trying to join the continents and continents_map tables
-- and the solution i found.

/*
SELECT c.country_code, c.country_name, pc.percent_change, cm.continent_code , con.continent_name
FROM countries as c
	LEFT JOIN pc as pc
		USING (country_code)
    INNER JOIN continent_map as cm 
		ON c.country_code = cm.country_code
    LEFT JOIN continents as con 	-- not joining because the continent_code 's in continent_map have length() = 3 instead of 2.
		ON TRIM(cm.continent_code) = con.continent_code;
        
        
SELECT length(continent_code) FROM continents;
SELECT length(country_code), length(continent_code) FROM continent_map;
SELECT * FROM continent_map;
*/
/*
--tring to find what was wrong with the joins between continents.continent_code and continent_map.continent_code.


UPDATE continent_map SET continent_code = REPLACE(continent_code, ' ', '');
UPDATE continent_map SET continent_code = REPLACE(continent_code, '\n', '');
UPDATE continent_map SET continent_code = REPLACE(continent_code, '\t', '');
UPDATE continent_map SET continent_code = TRIM(continent_code);


SELECT continent_code
FROM continent_map
WHERE LENGTH(continent_code) > 2 AND continent_code REGEXP '[^ -~]' ;

UPDATE continent_map SET continent_code = REPLACE(continent_code, '^', '');
UPDATE continent_map SET continent_code = REPLACE(continent_code, '-', '');
UPDATE continent_map SET continent_code = REPLACE(continent_code, '~', '');
*/

-- solution:
-- what worked
SELECT continent_code, HEX(continent_code) -- this shows the code 0D which referes to '\r' character at the end of each continent_code value
											-- in continent_map 
FROM continent_map
WHERE LENGTH(continent_code) > 2 AND continent_code REGEXP '[^ -~]';

UPDATE continent_map SET continent_code = REPLACE(continent_code, '\r', ''); -- so we need to remove this values to allow the joins to work correctly on the continent_code column
UPDATE continents SET continent_name = REPLACE(continent_name, '\r', ''); -- also found some \r expression in continents.continent_name

-- now we see the lenght of the continent_code column is 2 for all rows
SELECT length(country_code), length(continent_code) FROM continent_map;




-- now repeating the previous join it should work
DROP TABLE IF EXISTS growth_rank_in_cont;
CREATE TABLE growth_rank_in_cont (	
    SELECT (row_number() over (PARTITION BY con.continent_name ORDER BY pc.percent_change DESC)) as rank_cont,
    c.country_code, c.country_name, pc.percent_change, con.continent_name
	FROM countries as c
		LEFT JOIN pc as pc
			USING (country_code)
		INNER JOIN continent_map as cm 
			ON c.country_code = cm.country_code
		LEFT JOIN continents as con 	
			ON cm.continent_code = con.continent_code);
            
SELECT * FROM growth_rank_in_cont;
            

-- finding the countries names and other columns for countries ranked 10-12 in their continent by the percentage change of gdp per capita 2012-2011 
SELECT rank_cont, continent_name, country_code, country_name, CONCAT(ROUND(percent_change,2), '%') as percent_growth
FROM growth_rank_in_cont
WHERE rank_cont IN(10,11,12);
            
/*
RESULTS:
# rank_cont, continent_name, country_code, country_name, percent_growth
'10', 'Africa', 'RWA', 'Rwanda', '8.73%'
'11', 'Africa', 'GIN', 'Guinea', '8.32%'
'12', 'Africa', 'NGA', 'Nigeria', '8.09%'
'10', 'Asia', 'UZB', 'Uzbekistan', '11.12%'
'11', 'Asia', 'IRQ', 'Iraq', '10.06%'
'12', 'Asia', 'PHL', 'Philippines', '9.73%'
'10', 'Europe', 'MNE', 'Montenegro', '-2.93%'
'11', 'Europe', 'SWE', 'Sweden', '-3.02%'
'12', 'Europe', 'ISL', 'Iceland', '-3.84%'
'10', 'North America', 'GTM', 'Guatemala', '2.71%'
'11', 'North America', 'HND', 'Honduras', '2.71%'
'12', 'North America', 'ATG', 'Antigua and Barbuda', '2.52%'
'10', 'Oceania', 'FJI', 'Fiji', '3.29%'
'11', 'Oceania', 'TUV', 'Tuvalu', '1.27%'
'12', 'Oceania', 'KIR', 'Kiribati', '0.04%'
'10', 'South America', 'ARG', 'Argentina', '5.67%'
'11', 'South America', 'PRY', 'Paraguay', '-3.62%'
'12', 'South America', 'BRA', 'Brazil', '-9.83%'


DROP ALL TEMP TABLES
*/
DROP TABLE IF EXISTS t2012;
DROP TABLE IF EXISTS t2011;
DROP TABLE IF EXISTS pc;
DROP TABLE IF EXISTS growth_rank_in_cont;

