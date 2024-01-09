-- CODE CHALLENGE V2.11

-- QUESTION 4

/*
4a. What is the count of countries and sum of their related gdp_per_capita values for the year 2007 where the string 
'an' (case insensitive) appears anywhere in the country name?
*/

-- This query below if for interest only. showing the names and checking they all include 'an' of some sort 
SELECT  country_name, count(c.country_name) AS num_country_incl_an_case_insensitive, CONCAT('$',ROUND(sum(pc.gdp_per_capita),2)) AS sum_of_gdp_per_capita
FROM per_capita pc
	INNER JOIN countries c 
		USING (country_code)
WHERE YEAR = 2007 AND gdp_per_capita IS NOT NULL AND country_name LIKE '%an%'
GROUP BY COUNTRY_NAME; 



-- results table for 4.a
SELECT  count(c.country_name) AS num_country_incl_an_case_insensitive, CONCAT('$',ROUND(sum(pc.gdp_per_capita),2)) AS sum_of_gdp_per_capita
FROM per_capita pc
	INNER JOIN countries c 
		USING (country_code)
WHERE YEAR = 2007 AND gdp_per_capita IS NOT NULL AND country_name LIKE '%an%'; 


/*
 RESULTS 4(A):
 
 num_country_incl_an_case_insensitive	sum_of_gdp_per_capita
									66			  $1022936.33
 */


/*
4b. Repeat question 4a, but this time make the query case sensitive.
 */


-- results table 4.b
SELECT  count(c.country_name) AS num_country_incl_an_case_sensitive, CONCAT('$',ROUND(sum(pc.gdp_per_capita),2)) AS sum_of_gdp_per_capita
FROM per_capita pc
	INNER JOIN countries c 
		USING (country_code)
WHERE YEAR = 2007 AND gdp_per_capita IS NOT NULL AND country_name LIKE BINARY '%an%'; -- KEYWORD BINARY: changes the LIKE operator TO CASE SENSITIVE.


/*
 RESULTS 4(B):
 
 num_country_incl_an_case_sensitive	sum_of_gdp_per_capita
								 64			   $979600.72
 */

