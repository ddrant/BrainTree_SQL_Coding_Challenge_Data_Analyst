-- CODE CHALLENGE V2.11

-- QUESTION 3


/*
3. For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions:

(i) Asia, (ii) Europe, (iii) the Rest of the World. Your result should look something like

Asia	Europe	Rest of World
25.0%	25.0%	50.0%
*/


-- inspecting the data 
SELECT * FROM per_capita 
WHERE year = 2012;

SELECT * FROM per_capita
	INNER JOIN continent_map USING (country_code)
    INNER JOIN continents USING (continent_code)
WHERE year = 2012;



-- create a table to show the sum of gdp_per_capita grouped by continent
DROP TABLE IF EXISTS pc_sum_per_continent;
CREATE TABLE pc_sum_per_continent (
	SELECT continent_code, year, continent_name, sum(pc.gdp_per_capita) as total_pc_cont
	FROM per_capita pc -- for gdp_per_capita data
		INNER JOIN continent_map cm -- for country_code -> continent_code
			USING (country_code)
		INNER JOIN continents c -- for continent names
			USING (continent_code)
	WHERE year = 2012
	GROUP BY continent_code, year, continent_name);
    
    
-- create another table grouping the continents NOT IN ('Europe', 'Asia') together as 'Rest of world'
DROP TABLE IF EXISTS gdp_pc_grouped;
CREATE TABLE gdp_pc_grouped (
	SELECT CASE WHEN continent_name IN('Europe', 'Asia') THEN continent_name -- separating europe and asia
		ELSE 'Rest of World'
		END AS continent_name,
			sum(total_pc_cont) as total_pc, -- sum for all continents in group 
			(sum(total_pc_cont)/(SELECT sum(total_pc_cont) FROM pc_sum_per_continent /*sum of all pc gdp all continents*/)) * 100 AS percent_share 
	FROM pc_sum_per_continent
	GROUP BY 1 -- grouping by the 'NEW' continent names ie asia, europe and rest of world
    );
    
   
  
   
-- Flipping the columns and rows from the gdp_pc_grouped table
DROP TABLE IF EXISTS results_table;
CREATE TABLE results_table (
	SELECT
		MAX(CASE WHEN continent_name = 'Asia' THEN CONCAT(ROUND(percent_share,2), '%') END) AS Asia,
		MAX(CASE WHEN continent_name = 'Europe' THEN CONCAT(ROUND(percent_share,2), '%') END) AS Europe,
		MAX(CASE WHEN continent_name = 'Rest of World' THEN CONCAT(ROUND(percent_share,2), '%') END) AS 'Rest of World'
	FROM gdp_pc_grouped
);

	
SELECT * FROM results_table;

/*
RESULTS:

Asia	Europe	Rest of World
28.33%	42.24%	29.43%
 */

-- DROP all temp tables

DROP TABLE IF EXISTS results_table;
DROP TABLE IF EXISTS gdp_pc_grouped;
DROP TABLE IF EXISTS pc_sum_per_continent;

  
    

    
    
    
