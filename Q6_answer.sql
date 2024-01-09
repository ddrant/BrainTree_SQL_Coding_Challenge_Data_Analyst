-- CODE CHALLENGE V2.11

-- QUESTION 6

/*
6. All in a single query, execute all of the steps below and provide the results as your final answer:

a. create a single list of all per_capita records for year 2009 that includes columns:

	continent_name
	country_code
	country_name
	gdp_per_capita

b. order this list by:

	continent_name ascending
	characters 2 through 4 (inclusive) of the country_name descending
	

c. create a running total of gdp_per_capita by continent_name


d. return only the first record from the ordered list for which each continent's running total of gdp_per_capita meets or
   exceeds $70,000.00 with the following columns:

	continent_name
	country_code
	country_name
	gdp_per_capita
	running_total
*/

SELECT t1.continent_name, t1.country_code, t1.country_name, -- (a)
	CONCAT('$', ROUND(t1.GDP_PC,2)) as gdp_per_capita, 
	CONCAT('$', ROUND(t1.gdp_pc_run_total,2)) as running_total
FROM (
	SELECT cont.continent_name as continent_name, pc.COUNTRY_CODE as country_code, c.country_name, 
		pc.GDP_PER_CAPITA as gdp_pc,   
		sum(gdp_per_capita) OVER(PARTITION BY continent_name -- the over function allows us to sum all the rows in the given criteria that come before itself in the order and itself.
				ORDER BY continent_name ASC, SUBSTRING(country_name, 2, 3) DESC) as gdp_pc_run_total -- (c) running total by continent
	FROM PER_CAPITA PC 
	INNER JOIN countries C
		USING (country_code)
	INNER JOIN CONTINENT_MAP CM 
		USING (country_code)
	INNER JOIN continents cont
		USING (continent_code)
	WHERE year = 2009 
	ORDER BY continent_name ASC, SUBSTRING(country_name, 2, 3) DESC -- (b) order by substring starting from index 2 for 3 characters
) as t1
WHERE gdp_pc_run_total >= 70000 AND gdp_pc_run_total - gdp_pc < 70000; -- (d) select only the country from each continent that pushed the running total over $70,000
-- the second equality condition calculates the run toal - the chosen country gdp_per_capita, and ensures the value is below $70,000
-- i.e it's the country that hits the $70000 marker 


/*
RESULTS:

continent_name	country_code	country_name	gdp_per_capita	running_total
Africa			LBY				Libya			$10455.57		$70227.16
Asia			KWT				Kuwait			$37160.54		$73591.81
Europe			CHE				Switzerland		$65790.07		$84673.58
North America	ABW				Aruba			$24639.94		$84504.67
Oceania			NZL				New Zealand		$27474.33		$84623.92
South America	ECU				Ecuador			$4236.78 		$72315.82


*/
