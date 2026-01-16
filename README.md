# Data-cleaning-in-SQL
Data is almost never clean. I took a messy dataset of global layoffs and spent time in SQL fixing the stuff that breaks analysis: duplicate rows, dates stored as text, and missing industry labels. This project is the 'behind-the-scenes' work that makes real data science possible.
# World Layoffs: Data Cleaning & Transformation (SQL)

## 📌 The Problem
Data in the real world is almost always messy. I took a raw dataset of global layoffs (2020-2023) that was riddled with issues: duplicate entries, dates stored as plain text, missing categories, and inconsistent naming conventions. These issues make it impossible to create accurate charts or draw reliable conclusions without a major cleanup first.

## 🚀 The Solution
I built a multi-step SQL pipeline to transform this "swamp" of data into a clean, query-ready database. My focus was on data integrity, ensuring every row was unique and every column was correctly typed for future analysis.

### 🛠️ Tech Stack
* **Language:** SQL (MySQL)
* **Key Concepts:** CTEs, Window Functions, Schema Migrations, Data Imputation.

---

## 🛠️ Cleaning Roadmap

### 1. The Staging Strategy
Before touching the data, I created a **Staging Table**. 
> **Why?** In a professional environment, you never edit your "Source of Truth." This ensures that if a cleaning script goes wrong, you can reset without re-importing the whole dataset.

### 2. Hunting for "Ghost" Duplicates
Since the raw data lacked unique IDs, I used a **CTE** and the `ROW_NUMBER()` window function to partition the data across every single column. This allowed me to find and remove rows that were 100% identical.

### 3. Fixing the "Date Crisis"
The dates were imported as strings (e.g., `03/25/2022`). This meant SQL couldn't sort them chronologically or calculate time intervals.
* **Step A:** Used `STR_TO_DATE` to reformat the strings into the SQL-standard `YYYY-MM-DD`.
* **Step B:** Used `ALTER TABLE` to permanently change the column type to `DATE`.

### 4. Categorical Integrity & Imputation
I audited the `Industry` and `Country` columns to fix inconsistencies that would break grouping:
* **Manual Research:** Found missing industries for companies like **Appsmith** and updated them manually.
* **Standardization:** Unified naming (e.g., converted 'UAE' to 'United Arab Emirates' and trimmed trailing periods from 'United States').

### 5. Stripping the Junk
I identified and deleted records where both the `total_laid_off` and `percentage_laid_off` were blank. Since these provided no analytical value for a layoff study, removing them kept the dataset lean and focused.

---

## 📈 The Result
The final output is a high-performance, structured table. 
* **Reliable:** No duplicate counts.
* **Optimized:** Date columns allow for instant time-series analysis.
* **Accurate:** Categorical data is uniform and complete.

---

## 💡 What I Learned
The trickiest part was the date conversion. It taught me that data types are the foundation of any database—if your types are wrong, your insights will be wrong. Manual imputation also reminded me that sometimes you have to look outside the database to get the full story.
