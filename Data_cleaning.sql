SELECT *
FROM layoffs;
# creating a duplicate of our database to work off of
CREATE TABLE layoff_staging
LIKE layoffs;

INSERT layoff_staging
SELECT * 
FROM layoffs
;

-- 1. remove duplicates
WITH duplicate_CTE AS (
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company,location, industry,total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoff_staging
)
SELECT *
FROM duplicate_CTE
WHERE row_num>1;
;

# Created a copy of the table and added a column to track row numbers
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company,location, industry,total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoff_staging;

# Delete the duplicates
DELETE
FROM layoffs_staging2
WHERE row_num >1;

SELECT *
FROM layoffs_staging2
;

-- 2. standarized the data

# there are white spaces before and after some company names
SELECT company, TRIM(company)
FROM layoffs_staging2
;
# standardize by trimming
UPDATE layoffs_staging2
SET company = TRIM(company);

# some of the same industries has different names (specifically crypto)
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;
# fix naming
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# some of the same countries has different names (specifically United States)
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

#change date format from string to date
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. null values or blank values
#set all blanks to null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL or industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. remove any columns
# Deleting data with missing total laid off and percentage bc it is not usable 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

#remove the row_num col bc it is no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
    
    