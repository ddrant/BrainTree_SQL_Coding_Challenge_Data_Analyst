-- CODE CHALLENGE V2.11

-- QUESTION 5

/*
5. Find the sum of gpd_per_capita by year and the count of countries for each year that have non-null gdp_per_capita where:

(i) the year is before 2012 
and 
(ii) the country has a null gdp_per_capita in 2012. 

Your result should have the columns:

year
country_count
total
*/




SELECT country_code FROM per_capita -- country_code of all countries which satify conditions (i),(ii)
WHERE year = 2012 AND GDP_PER_CAPITA IS NULL; -- 15 IN TOTAL


-- calculate the sum  of gdp_per_capita for valid countries, rounding the figure to 2d.p and adding the dollar sign
-- count how many countries per year pass the conditions (i) and (ii)
SELECT year, CONCAT('$',ROUND(sum(GDP_PER_CAPITA),2)) AS sum_gdp_pc, count(DISTINCT(country_code)) country_count 
FROM per_capita pc
WHERE year < 2012 AND
	gdp_per_capita IS NOT NULL AND
	country_code IN (
		SELECT country_code FROM per_capita
		WHERE year = 2012 AND GDP_PER_CAPITA IS NULL)
GROUP BY year;




/*
RESULTS:

year	sum_gdp_pc	country_count
2,004	$491203.19	15
2,005	$510734.98	15
2,006	$553689.64	14
2,007	$654508.77	14
2,008	$574016.21	10
2,009	$473103.33	9
2,010	$179750.83	4
2,011	$199152.68	4

*/