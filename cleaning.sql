/*
================================================================================
World Layoffs Data Cleaning Project
================================================================================
Goal: Transform raw, messy layoff data into a standardized format ready for analysis.
Key Techniques: CTEs, Window Functions, Type Casting, Data Imputation.
*/

-- 1. STAGING: How do we protect the raw data?
-- Question: Why not work on the raw table? 
-- Answer: To ensure we have a fallback "Source of Truth" if a query goes wrong.

CREATE DATABASE IF NOT EXISTS layoff;
USE layoff;

CREATE TABLE layoffs_staging LIKE layoffs;
INSERT layoffs_staging SELECT * FROM layoffs;

-- Add Unique ID for granular control during the update process
ALTER TABLE layoffs_staging ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;


-- 2. DEDUPLICATION: Are there identical entries?
-- Question: How do we identify rows that are 100% identical without a primary key?
-- Answer: Use ROW_NUMBER() over a PARTITION of all columns.

WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, funds_raised
    ) AS row_num
    FROM layoffs_staging
)
DELETE FROM layoffs_staging
WHERE row_id IN (
    SELECT row_id FROM duplicate_cte WHERE row_num > 1
);


-- 3. CATEGORICAL STANDARDIZATION: Is the naming consistent?
-- Question: Do we have "hidden" blanks or variations in industry/country names?

-- Standardizing Industry (Manual Imputation based on research)
UPDATE layoffs_staging
SET industry = 'Technology'
WHERE company = 'Appsmith' AND (industry IS NULL OR industry = '');

-- Standardizing Countries (Fixing inconsistencies)
UPDATE layoffs_staging SET country = 'United Arab Emirates' WHERE country = 'UAE';
UPDATE layoffs_staging SET country = 'Canada' WHERE row_id = 1149;


-- 4. TYPE CASTING (DATES): Can we perform time-series analysis?
-- Question: Why can't we sort or group by the 'date' column?
-- Answer: It is stored as TEXT. We must convert it to a DATE data type.

SET SQL_SAFE_UPDATES = 0;

-- Convert 'date' column
UPDATE layoffs_staging SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging MODIFY COLUMN `date` DATE;

-- Convert 'date_added' column
UPDATE layoffs_staging SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y');
ALTER TABLE layoffs_staging MODIFY COLUMN date_added DATE;


-- 5. HANDLING NULLS & BLANKS: Is the data analytically useful?
-- Question: Should we keep rows that have no layoff numbers?
-- Answer: No. If total_laid_off and percentage_laid_off are both missing, the row adds no value.

DELETE FROM layoffs_staging
WHERE (total_laid_off = '' OR total_laid_off IS NULL)
AND (percentage_laid_off = '' OR percentage_laid_off IS NULL);

-- Final Polish: Convert remaining empty strings to NULL for better SQL compatibility
UPDATE layoffs_staging SET percentage_laid_off = NULL WHERE percentage_laid_off = '';
UPDATE layoffs_staging SET total_laid_off = NULL WHERE total_laid_off = '';


-- 6. FINAL REVIEW
SELECT * FROM layoffs_staging;
