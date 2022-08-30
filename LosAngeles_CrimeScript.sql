
-- Scan through data 
SELECT * FROM LosAngeles_Crime.dbo.LA_CrimeData;

-- what are all the crimes committed and how many cases of that crime were reported by year
SELECT
	year(time_occ) AS 'year', crm_cd_desc AS 'crimes_committed', COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData
GROUP BY 
	year(time_occ), crm_cd_desc
ORDER BY 
	year(time_occ), cases DESC;

-- How many female victims vs male victims by year
SELECT
	year(time_occ) AS 'year', vict_sex, COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData
WHERE
	vict_sex IN ('F','M')
GROUP BY
	year(time_occ), vict_sex
ORDER BY year(time_occ), cases DESC;


-- how are the age groups affected by crime 
SELECT
	year(time_occ) AS 'year', age_group, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.LA_CrimeData
WHERE age_group != 'Unkown'
GROUP BY 
	year(time_occ), age_group
ORDER BY year(time_occ), cases DESC;

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
-- Hispanics/ Latins made up 43.79 percent of the victims in 2020 - 2021


-- how are victims by descent affected by year
SELECT
	year(time_occ) AS 'year', vict_descent, COUNT(*) as cases
FROM	LosAngeles_Crime.dbo.LA_CrimeData
WHERE
	vict_descent NOT IN ('NA','Other','Unkown')
GROUP BY 
	year(time_occ), vict_descent
ORDER BY year(time_occ), cases DESC;

-- how are victims by descent, sex, age affected
-- Hispanics made up the top 4 victims in LA excluding 
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
	year(time_occ) AS 'year', area_name, crm_cd_desc, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.LA_CrimeData
WHERE
	lat != 0 AND lon != 0
GROUP BY year(time_occ), area_name, crm_cd_desc, lat, lon
ORDER BY year(time_occ), cases DESC;

-- What type of premises is crime mostly committed
SELECT 
	year(time_occ) AS 'year', premis_desc, COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.LA_CrimeData
GROUP BY
	year(time_occ), premis_desc
ORDER BY 
	year(time_occ), cases DESC;