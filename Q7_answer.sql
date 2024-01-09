-- CODE CHALLENGE V2.11

-- QUESTION 7

/*
7. Find the country with the highest average gdp_per_capita for each continent for all years. 
   
   Now compare your list to the following data set. 
   
   Please describe any and all mistakes that you can find with the data set below.
   
   Include any code that you use to help detect these mistakes.
   
   
    nk	continent_name	country_code	country_name	avg_gdp_per_capita
	1	Africa			SYC				Seychelles		$11,348.66
	1	Asia			KWT				Kuwait			$43,192.49
	1	Europe			MCO				Monaco			$152,936.10
	1	North America	BMU				Bermuda			$83,788.48
	1	Oceania			AUS				Australia		$47,070.39
	1	South America	CHL				Chile			$10,781.71
*/



-- INORING NULLS  (avg() ignores null values by default) 
DROP TABLE IF EXISTS ranked_avg_gdp_per_cont;
-- first column orders rows in each continent by avg_gdp over all years
-- fourth column is the average gdp per capita for each country over the years
CREATE TABLE ranked_avg_gdp_per_cont (SELECT row_number() over(PARTITION BY cm.continent_code ORDER BY AVG(pc.gdp_per_capita) DESC) as rank_cont, 
		pc.COUNTRY_CODE, 
		cm.continent_code,
		AVG(pc.gdp_per_capita) avg_gdp  
	FROM per_capita pc
	INNER JOIN continent_map cm
		USING (country_code)
	GROUP BY pc.country_code, cm.continent_code
);


-- formatting the table and joining necessary tables/rows 
SELECT ragpc.rank_cont, cont.continent_name, ragpc.country_code, c.COUNTRY_NAME, 
	CONCAT('$', ROUND(ragpc.avg_gdp, 2)) AS avg_gdp 
FROM ranked_avg_gdp_per_cont ragpc
INNER JOIN continents cont
	USING (continent_code)
INNER JOIN countries c
	USING (country_code)
WHERE ragpc.rank_cont = 1
ORDER BY CONTINENT_NAME; 




/*
RESULTS:

rank_cont	continent_name	country_code	COUNTRY_NAME		avg_gdp
1			Africa			GNQ				Equatorial Guinea	$17955.72
1			Asia			QAT				Qatar				$70567.96
1			Europe			MCO				Monaco				$151421.89
1			North America	BMU				Bermuda				$84634.83
1			Oceania			AUS				Australia			$46147.45
1			South America	CHL				Chile				$10781.71

COMPARED TO (FROM QUESTION):

    nk	continent_name	country_code	country_name	avg_gdp_per_capita
	1	Africa			SYC				Seychelles		$11,348.66
	1	Asia			KWT				Kuwait			$43,192.49
	1	Europe			MCO				Monaco			$152,936.10
	1	North America	BMU				Bermuda			$83,788.48
	1	Oceania			AUS				Australia		$47,070.39
	1	South America	CHL				Chile			$10,781.71
	
	- For Africa the country with highest avg gdp_per_capita is Equatorial Guinea not Seychelles,
		 although the values for the Seychelles matches my data, as seen in the query below
	
	- For Asia it is Qatar not Kuwait, although the values are correct for Kuwait
	
	- Avg gdp per capita values for Bermuda, Australia, and Monoco were all wrong, correct values are shown in my results table
	
	- The only correct row was Chile's row.
*/

-- QUERY TO EXAMINE MISTAKES IN ORIGINAL DATA SET
SELECT  pc.COUNTRY_CODE, cm.continent_code, AVG(pc.gdp_per_capita) avg_gdp  
	FROM per_capita pc
	INNER JOIN continent_map cm
		USING (country_code)
	GROUP BY pc.country_code, continent_code
	HAVING country_code IN ('KWT', 'SYC', 'MCO','BMU','AUS')
	ORDER BY CONTINENT_CODE;