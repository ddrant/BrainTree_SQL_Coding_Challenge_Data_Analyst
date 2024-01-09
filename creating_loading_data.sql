CREATE DATABASE braintree_challenge;

USE braintree_challenge;


-- CREATING THE TABLES
DROP TABLE IF EXISTS continent_map;
CREATE TABLE continent_map (country_code VARCHAR(10), continent_code VARCHAR(10));

DROP TABLE IF EXISTS continents;
CREATE TABLE continents (continent_code VARCHAR(10) PRIMARY KEY, continent_name VARCHAR(20));

CREATE TABLE IF EXISTS countries (country_code VARCHAR(10), country_name VARCHAR(100));

CREATE TABLE IF EXISTS per_capita (country_code VARCHAR(10), year int, gdp_per_capita double);
DROP TABLE per_capita;



-- INSERTING THE DATA FROM CSV FILES
/*
first i copied the .csv files into "C:\ProgramData\MySQL\MySQL Server 8.0\Data\braintree_challenge" to 
be able to use LOAD DATA INFILE
*/
LOAD DATA INFILE "continent_map.csv" INTO TABLE continent_map
FIELDS terminated by ','
IGNORE 1 LINES;

LOAD DATA INFILE "continents.csv" INTO TABLE continents
FIELDS terminated by ','
IGNORE 1 LINES;


/*
Before this i was trying to load the data the same way as for continents table, but because of the empty values in the gdp_per_capita 
column, there were some issues. To resolve this i added the ENCLOSED BY, LINES TERMINATED BY and a set clause with a temporary variable to 
handle the empty values and convert them into null values. 
*/
LOAD DATA INFILE "per_capita.csv" INTO TABLE per_capita
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' -- each value in the csv is enclosed by ""
LINES TERMINATED BY '\r\n' -- 
IGNORE 1 LINES
(country_code, year, @vgdp_per_capita)
SET gdp_per_capita = NULLIF(@vgdp_per_capita, ''); -- changing empty string into NULL values in the gdp_per_capita column


/*
Similarly to the per_capita table there were problems insterting the data from the csv for the contries table also. The reason for this being
that some values in the country_names column contained commas themselves so the LOAD DATA INFILE function assumed these values were two 
seperate values and returned the error.
 Error Code: 1262. Row 22 was truncated; it contained more data than there were input columns
To fix this added ENCLOSED BY '"' and LINES TERMINATED BY....
*/
LOAD DATA INFILE "countries.csv" INTO TABLE countries  
FIELDS terminated by ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
