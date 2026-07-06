-- Exploratory Data Analysis

SELECT * 
FROM Layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM Layoffs_staging2;

# companies that laid off their entire staff
SELECT * 
FROM Layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


# total laid off by company
SELECT company, SUM(total_laid_off)
FROM Layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

# date range of data set
SELECT MIN(`date`), MAX(`date`)
FROM Layoffs_staging2;

# total laid off by industry
SELECT industry, SUM(total_laid_off)
FROM Layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

# total laid off by country 
SELECT country, SUM(total_laid_off)
FROM Layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

# total laid off by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM Layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

# total laid off by stage
SELECT stage, SUM(total_laid_off)
FROM Layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

# total laid off by month
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off)
FROM Layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;

# total laid off by month with rolling total
WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
FROM Layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`, total_off, SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_Total; 

# total laid off by company by year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

# ranking of which companies had the top five highest total laid off for each month
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS `Ranking`
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;

