# Layoffs Data Cleaning & Exploratory Analysis

This project focuses on **cleaning, transforming, and analyzing global layoffs data**. Using SQL scripts and a CSV dataset, the workflow ensures data integrity and extracts insights about layoffs across companies, industries, countries, and years.  


## Project Files

- **`layoffs.csv`** – Raw dataset of global layoffs.  
- **`Data_cleaning.sql`** – SQL script for cleaning and standardizing the dataset.  
- **`Exploratory_Analysis.sql`** – SQL script for analyzing the cleaned data.  


## Data Cleaning Workflow (`Data_cleaning.sql`)

The cleaning process involves four steps:

1. **Duplicate Removal**
   - Created staging tables (`layoff_staging`, `layoffs_staging2`).
   - Used `ROW_NUMBER()` to detect and delete duplicates.

2. **Standardization**
   - Trimmed whitespace from company names.
   - Unified industry names (e.g., standardizing all variations of *Crypto*).
   - Corrected country names (e.g., *United States* vs *United States.*).
   - Converted `date` column from text to SQL `DATE`.

3. **Handling Nulls**
   - Converted blank fields to `NULL`.
   - Filled missing industries where company data existed.

4. **Column Refinement**
   - Removed rows missing both `total_laid_off` and `percentage_laid_off`.
   - Dropped helper columns (`row_num`).


## Exploratory Analysis (`Exploratory_Analysis.sql`)

Analyses performed on the cleaned dataset:

- **Largest layoffs** – companies with highest total laid-off employees.  
- **Industries most impacted** – layoffs aggregated by industry.  
- **Yearly trends** – layoffs aggregated by year.  
- **Rolling totals** – cumulative layoffs over time.  
- **Company-year rankings** – top 5 companies per year by layoffs.  


## 🚀 How to Run

1. **Load the dataset**
   ```sql
   LOAD DATA INFILE 'layoffs.csv'
   INTO TABLE layoffs
   FIELDS TERMINATED BY ','
   IGNORE 1 LINES;
