-- data
SELECT *
FROM LosAngeles_Crime.dbo.LA_CrimeData

--																			 Cleaning Process

/*
time is supposed to be in military time
after looking through the source data it is 
missing leading zeros for example 
(1 needs 3 leading zeros '0001') a midnight after midnight
*/
-- change time_occ to a varchar to be able to CONCAT Leading Zero's
ALTER TABLE LosAngeles_Crime.dbo.LA_CrimeData
ALTER COLUMN time_occ VARCHAR(5);

-- use UPDATE AND CASE to clean time_occ column.
UPDATE LosAngeles_Crime.dbo.LA_CrimeData
SET time_occ = CASE
					WHEN LEN(time_occ) = 1 THEN CONCAT('000',time_occ)
					WHEN LEN(time_occ) = 2 THEN CONCAT('00',time_occ)
					WHEN LEN(time_occ) = 3 THEN CONCAT('0',time_occ)
				END
WHERE LEN(time_occ) < 4;
/*
if it was a bigger data set I would just use CASE in the front end
or the output  instead of updating the entire DB
*/

-- check if code above cleaned the time 
SELECT *
FROM LosAngeles_Crime.dbo.LA_CrimeData
WHERE LEN(time_occ) < 4;
-- there are no times with less than 4 characters in it.


-- vict_decent uses code for descent I want the actual word
-- check for NA
SELECT vict_descent, COUNT(*)
FROM LosAngeles_Crime..LA_CrimeData
WHERE vict_descent = 'NA'
GROUP BY vict_descent;

-- update vict_descent columns
UPDATE LosAngeles_Crime.dbo.LA_CrimeData
SET vict_descent = CASE
					WHEN vict_descent = 'A' THEN 'Asian'
					WHEN vict_descent = 'B' THEN 'Black'
					WHEN vict_descent = 'C' THEN 'Chineese'
					WHEN vict_descent = 'D' THEN 'Cambodian'
					WHEN vict_descent = 'F' THEN 'Filipino'
					WHEN vict_descent = 'G' THEN 'Guamaniam'
					WHEN vict_descent = 'H' THEN 'Hispanic/Latin'
					WHEN vict_descent = 'I' THEN 'American Indian'
					WHEN vict_descent = 'J' THEN 'Japanese'
					WHEN vict_descent = 'K' THEN 'Korean'
					WHEN vict_descent = 'L' THEN 'Laotian'
					WHEN vict_descent = 'O' THEN 'Other'
					WHEN vict_descent = 'P' THEN 'Pacific Islander'
					WHEN vict_descent = 'S' THEN 'Samoan'
					WHEN vict_descent = 'U' THEN 'Hawaiian'
					WHEN vict_descent = 'V' THEN 'Vietnamese'
					WHEN vict_descent = 'W' THEN 'White'
					WHEN vict_descent = 'X' THEN 'Unknown'
					WHEN vict_descent = 'Z' THEN 'Asian Indian'
				END
WHERE vict_descent != 'NA';

-- create an age group column
ALTER TABLE LosAngeles_Crime.dbo.LA_CrimeData
ADD age_group VARCHAR(5)

--insert int age_group
UPDATE LosAngeles_Crime.dbo.LA_CrimeData
SET age_group = CASE
					WHEN vict_age >= 1 AND vict_age <= 14 THEN '00-14' 
					WHEN vict_age >= 15 AND vict_age <= 24 THEN '15-24' 
					WHEN vict_age >= 25 AND vict_age <= 64 THEN '25-65' 
					WHEN vict_age > 65 THEN '65+' 
				
				END
WHERE vict_sex IN ('F','M');


-- ALTER time column do give space for colon
ALTER TABLE LosAngeles_Crime.dbo.LA_CrimeData
ALTER COLUMN time_occ VARCHAR(5);
-- add colons to time
UPDATE LosAngeles_Crime.dbo.LA_CrimeData
SET time_occ = CONCAT(LEFT(time_occ,2),':',RIGHT(time_occ,2))

-- Create date and time column 
ALTER TABLE LosAngeles_Crime.dbo.LA_CrimeData
ADD datetime_occ varchar(20);

-- insert date time by concatenating  date and time into column and converting it into datetime format
UPDATE LosAngeles_Crime.dbo.LA_CrimeData
SET datetime_occ =  CONVERT(datetime,CONCAT(LEFT(CONVERT(varchar(MAX),date_occ,120),10), ' ', time_occ),121)

-- alter column into datetime datatype
ALTER TABLE LosAngeles_Crime.dbo.LA_CrimeData
ALTER COLUMN  datetime_occ datetime not null;

-- END  of cleaning process



-- Scan through data 
SELECT * FROM LosAngeles_Crime.dbo.LA_CrimeData;

-- what are all the crimes committed and how many cases of that crime were reported by year
SELECT
	year(datetime_occ) AS 'year', crm_cd_desc AS 'crimes_committed', COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData
GROUP BY 
	year(datetime_occ), crm_cd_desc
ORDER BY 
	year(datetime_occ), cases DESC;

-- How many female victims vs male victims by year
SELECT
	year(date_occ) AS 'year', vict_sex, COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData
WHERE
	vict_sex IN ('F','M')
GROUP BY
	year(date_occ), vict_sex
ORDER BY year(date_occ), cases DESC;


-- how are the age groups affected by crime 
SELECT
	year(date_occ) AS 'year', age_group, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.LA_CrimeData
WHERE age_group != 'Unknown'
GROUP BY 
	year(date_occ), age_group
ORDER BY year(date_occ), cases DESC;

-- how are victims by descent affected (total between two years.)
SELECT
	vict_descent, COUNT(*) as cases,
	COUNT(*) * 100.0/ SUM(COUNT(*)) OVER() AS perc
FROM	LosAngeles_Crime.dbo.LA_CrimeData
WHERE
	vict_descent NOT IN ('NA','Other','Unkown')
GROUP BY 
	vict_descent
ORDER BY cases DESC;	
-- Hispanics/ Latins made up the largest percentage of victims
-- at 43.79% in 2020 - 2021
-- how are victims by descent affected yearly
SELECT
	year(date_occ), vict_descent, COUNT(*) as cases
FROM	LosAngeles_Crime.dbo.LA_CrimeData
WHERE
	vict_descent NOT IN ('NA','Other','Unkown')
GROUP BY 
	year(date_occ), vict_descent
ORDER BY 
	year(date_occ), cases DESC;	



SELECT
	DISTINCT vict_descent
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData


-- how are victims by descent, sex, age affected
-- Hispanics/latin made up the top 5 victims in LA excluding 
-- white males in the age group of 20-39 which came in 4th
SELECT
	vict_descent, vict_sex, age_group, COUNT(*) as cases,
	COUNT(*) * 100.0/ SUM(COUNT(*)) OVER() AS Perc
FROM
	LosAngeles_Crime.dbo.LA_CrimeData
WHERE
	vict_descent NOT IN ('NA','Unkown') AND vict_sex IN ('F','M')
GROUP BY
	vict_descent, vict_sex, age_group
ORDER BY
	cases DESC;

-- what crimes effect victims by descent.
SELECT
	vict_descent, crm_cd_desc, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.LA_CrimeData
WHERE 
	vict_descent NOT IN ('NA','Unkown')
GROUP BY 
	vict_descent, crm_cd_desc
ORDER BY 
	cases DESC;









-- time and cases.
SELECT 
	CAST(time_occ AS time)[time], COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData
GROUP BY 
	CAST(time_occ AS time)
ORDER BY 
	CAST(time_occ AS time);

-- cases by the hour. Looking at what time does the most crime happen.
SELECT 
	DATEPART(HOUR, time_occ)[time_hourly], COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData
GROUP BY 
	DATEPART(HOUR, time_occ)
ORDER BY 
	DATEPART(HOUR, time_occ);

-- how are areas affected by crime
SELECT
	year(date_occ) AS 'year', area_name, crm_cd_desc, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.LA_CrimeData
WHERE
	lat != 0 AND lon != 0
GROUP BY year(date_occ), area_name, crm_cd_desc, lat, lon
ORDER BY year(date_occ), cases DESC;

-- What type of premises is crime mostly committed
SELECT 
	year(date_occ) AS 'year', premis_desc, COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData
GROUP BY
	year(date_occ), premis_desc
ORDER BY 
	year(date_occ), cases DESC;