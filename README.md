# MySQL-Layoffs-Data

A SQL project that cleans and explores a real-world dataset of company layoffs using MySQL. The project is split into two stages: data cleaning (turning a messy raw CSV into a reliable table) and exploratory data analysis (querying that clean table to surface trends).

Dataset

The raw data (layoffs.csv) contains one row per reported layoff event, with the following fields:

ColumnDescriptioncompanyName of the companylocationCity/HQ location of the companyindustryIndustry the company operates intotal_laid_offNumber of employees laid offpercentage_laid_offPercentage of the company's workforce laid offdateDate of the layoff eventstageCompany funding stage (e.g. Post-IPO, Series C)countryCountry of the companyfunds_raised_millionsTotal funds raised by the company, in millions USD

Project Structure

MySQL-Layoffs-Data/
├── layoffs.csv                    # Raw dataset
├── Layoffs_Data_Cleaning.sql      # Data cleaning script
├── Layoffs_Data_Exploration.sql   # Exploratory data analysis (EDA) script
└── README.md

1. Data Cleaning (Layoffs_Data_Cleaning.sql)

Working directly on the raw layoffs table risks losing data if a mistake is made, so all cleaning happens on staging copies. The script proceeds in four stages:

Remove duplicates


Copies the raw table into layoffs_staging, then into layoffs_staging2 with an added ROW_NUMBER() column partitioned across every column (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions).
Rows with row_num > 1 are true duplicates and are deleted, leaving one copy of each event.


Standardize the data


Trims stray whitespace from company names.
Consolidates inconsistent industry labels (e.g. Crypto, Crypto Currency, CryptoCurrency → Crypto).
Strips a trailing period from country values (e.g. United States. → United States).
Converts the date column from text (%m/%d/%Y) into a proper SQL DATE type using STR_TO_DATE, then alters the column type.


Handle NULL and blank values


Blank industry strings are set to NULL for consistency.
Missing industry values are backfilled using a self-join: if another row for the same company/location has a known industry, that value is copied over.


Remove unnecessary rows and columns


Deletes rows where both total_laid_off and percentage_laid_off are NULL, since they carry no usable layoff figures.
Drops the helper row_num column now that de-duplication is complete.


The result is a clean, de-duplicated, standardized table: layoffs_staging2, used as the source for all analysis.

2. Exploratory Data Analysis (Layoffs_Data_Exploration.sql)

Queries run against layoffs_staging2 to answer questions such as:


Scale of layoffs – largest single layoff event and highest percentage of a workforce cut (MAX(total_laid_off), MAX(percentage_laid_off)).
Companies that shut down entirely – companies with percentage_laid_off = 1, ranked by funds raised.
Totals by dimension – total employees laid off grouped by company, industry, country, stage, year, and month.
Date range – earliest and latest dates covered by the dataset.
Rolling monthly total – a CTE (Rolling_Total) paired with a window function (SUM() OVER (ORDER BY Month)) to track cumulative layoffs over time.
Top companies per year – a two-step CTE that sums layoffs by company/year, then applies DENSE_RANK() (partitioned by year) to find the top 5 companies with the most layoffs each year.


Requirements


MySQL 8.0+ (or a compatible engine that supports window functions and CTEs)
A MySQL client such as MySQL Workbench or the mysql CLI


How to Use


Create a database and import layoffs.csv into a table named layoffs.
Run Layoffs_Data_Cleaning.sql from top to bottom to produce the cleaned layoffs_staging2 table.
Run Layoffs_Data_Exploration.sql against layoffs_staging2 to reproduce the analysis, or adapt the queries for your own questions.


Key SQL Techniques Used


Window functions: ROW_NUMBER(), DENSE_RANK(), SUM() OVER (...)
Common Table Expressions (CTEs), including chained/nested CTEs
Self-joins for filling in missing data
String functions: TRIM(), STR_TO_DATE(), SUBSTRING()
Aggregate functions with GROUP BY and ORDER BY


Acknowledgments

Dataset based on publicly available tech industry layoffs data.
