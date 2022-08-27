-- Data was cleaned in R before imported into database

-- Looking through data table
 
SELECT *
FROM LosAngeles_Crime.dbo.location;

SELECT * 
FROM LosAngeles_Crime.dbo.time;

SELECT * 
FROM LosAngeles_Crime.dbo.victim;

SELECT * 
FROM LosAngeles_Crime.dbo.weapons;

SELECT * 
FROM LosAngeles_Crime.dbo.crime;

-- EDA

-- Crime data by victim Sex
-- male vs female victims
SELECT vict_sex, COUNT(*) AS Cases,
	COUNT(*) * 100.0 / SUM(COUNT(*)) over() as perc
FROM LosAngeles_Crime.dbo.victim
GROUP BY vict_sex;

-- victim sex included
-- H <- Unknown
-- X <- Unknown
-- NA <- Unknown
-- F <- Female
-- M <- Male

-- Glance through data with H & X as vict_sex
SELECT *
FROM LosAngeles_Crime.dbo.victim AS victim
JOIN LosAngeles_Crime.dbo.crime AS crime
ON victim.dr_no = crime.dr_no
WHERE victim.vict_sex IN ('H','X')
ORDER BY vict_sex;

-- How many victims with unknown sex have unknown age
SELECT age_group,COUNT(*) AS cases,
	COUNT(*) * 100.0 /SUM(COUNT(*)) over() AS perc
FROM LosAngeles_Crime.dbo.victim AS victim
WHERE victim.vict_sex = 'X'
GROUP BY age_group;
-- 90 percent of unkown sex also have unknown age

-- Age group is dirty 
----------------------------------Clean Age_Group
--Distinct age groups
SELECT DISTINCT age_group, dev_stage
FROM LosAngeles_Crime.dbo.victim;
-- 4-Feb
-- 12-May
-- it is not supposed to be a date but an age range for grouping.

-- 4-Feb will be replaced by 1-3
UPDATE LosAngeles_Crime.dbo.victim
SET age_group = '1-3'
WHERE age_group = '4-Feb';

-- 12-May will be replaced by 4-12
UPDATE LosAngeles_Crime.dbo.victim
SET age_group = '4-12'
WHERE age_group = '12-May';
-- Run Distinct age group query above to recheck// Age_group is now cleaned.
----------------------------------- END OF Cleaning Age_group -----------------------------------------------



-- How many victims with unknown sex have unknown descent
SELECT vict_descent,COUNT(*) AS cases,
	COUNT(*) * 100.0 /SUM(COUNT(*)) over() AS perc
FROM LosAngeles_Crime.dbo.victim AS victim
WHERE vict_sex = 'X'
GROUP BY vict_descent;
-- 99 percent of the cases with unknown sex also have unkown descent

-- this is an analysis on crime and the victims, without victim information I cannot do much in a victim crime analysis.
-- I will not use X and H for analysis of crime but I can analyze the unknown observation and figure out why they are not being reported.

-- male vs female victims by year of 2020 & 2021
SELECT 
	year(t.date_occ) AS year_occ,vict_sex, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.victim AS v
	JOIN
		LosAngeles_Crime.dbo.time AS t
			ON v.dr_no = t.dr_no
WHERE vict_sex IN ('F','M')
GROUP BY vict_sex, year(t.date_occ)

-- male vs female victims by descent and year of 2020 & 2021
SELECT 
	year(t.date_occ) AS year_occ,vict_sex, v.vict_descent, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.victim AS v
	JOIN
		LosAngeles_Crime.dbo.time AS t
			ON v.dr_no = t.dr_no
WHERE vict_sex IN ('F','M')
GROUP BY vict_sex, year(t.date_occ), v.vict_descent
ORDER BY year(t.date_occ);
	
--female vs male victims by age_group and year of 2020 & 2021
SELECT year(t.date_occ) AS year_occ, v.age_group, v.vict_sex, COUNT(*) AS cases
FROM 
	LosAngeles_Crime.dbo.victim AS v
		JOIN
			LosAngeles_Crime.dbo.time AS t
				ON v.dr_no = t.dr_no
WHERE vict_sex IN ('F','M')
GROUP BY year(t.date_occ),v.age_group,v.vict_sex
ORDER BY year(t.date_occ),v.age_group

-- victim Age group and victim descent by year of 2020 & 2021
SELECT year(t.date_occ) AS year_occ, v.age_group, v.vict_descent, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.victim AS v
		JOIN
			LosAngeles_Crime.dbo.time AS t
				ON v.dr_no = t.dr_no
GROUP BY year(t.date_occ) ,v.age_group, v.vict_descent
ORDER BY year(t.date_occ), v.age_group, cases DESC

-- All categories of crime in the database and their case count. Ranked by case count.
SELECT crm_cd_desc as crime_description, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.crime
GROUP BY 
	crm_cd_desc
ORDER BY cases DESC

-- crime cases and age groups
SELECT 
	v.age_group, c.crm_cd_desc, COUNT(*) AS cases
FROM
	LosAngeles_Crime.dbo.victim AS v
	JOIN
		LosAngeles_Crime.dbo.crime AS c
			ON v.dr_no = c.dr_no
GROUP BY 
	v.age_group, c.crm_cd_desc
ORDER BY 
	v.age_group, cases DESC


