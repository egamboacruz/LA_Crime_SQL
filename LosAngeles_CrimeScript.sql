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
SELECT vict_sex, COUNT(*) AS Cases
FROM LosAngeles_Crime.dbo.victim
GROUP BY vict_sex;

-- victim sex included
-- H <- Unknown
-- X <- Unknown
-- NA <- Unknown
-- F <- Female
-- M <- Male

-- Glance through data
SELECT *
FROM LosAngeles_Crime.dbo.victim AS victim
JOIN LosAngeles_Crime.dbo.crime AS crime
ON victim.dr_no = crime.dr_no
WHERE victim.vict_sex IN ('H','X')
ORDER BY vict_sex;

-- How many victims with unknown sex have unknown age
SELECT age_group,COUNT(*)
FROM LosAngeles_Crime.dbo.victim AS victim
JOIN LosAngeles_Crime.dbo.crime AS crime
ON victim.dr_no = crime.dr_no
WHERE victim.vict_sex = 'X'
GROUP BY age_group;
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
----------------------------------- END OF -----------------------------------------------




