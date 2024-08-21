-- stagging a db to work on

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT layoffs_staging
SELECT * FROM world_layoffs.layoffs;

-- 1) Remove Duplicates
-- 2) Standardize data
-- 3) Null values
-- 4) Remove any cols or rows not needed

SELECT *
FROM world_layoffs.layoffs_staging
;

with duplicates as
(
Select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, stage,
 country, funds_raised_millions, total_laid_off, `date`) as row_num
from world_layoffs.layoffs_staging
)
select * from duplicates
where row_num> 1;

select * from world_layoffs.layoffs_staging2
where company = 'Oda';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` double DEFAULT NULL,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` bigint DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into world_layoffs.layoffs_staging2
Select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, stage,
 country, funds_raised_millions, total_laid_off, `date`) as row_num
from world_layoffs.layoffs_staging;

SHOW COLUMNS FROM world_layoffs.layoffs_staging2;


SET SQL_SAFE_UPDATES = 0;

delete
from world_layoffs.layoffs_staging2
where (row_num > 1);

SET SQL_SAFE_UPDATES = 1;

select * from world_layoffs.layoffs_staging2;

alter table world_layoffs.layoffs_staging2
drop row_num;

-- next standardization

select distinct(trim(company))
from layoffs_staging2;

-- removing white spaces
update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';
-- nothing wrong here
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- all are null instead of blank and null mixed
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- using other rows to fill in null industry rows if possible via self join
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoffs.layoffs_staging2;


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT * 
FROM world_layoffs.layoffs_staging2;


