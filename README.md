# Credit Risk Scorecard - SQL Analysis

SQL-based credit risk analysis on 30,000 customer records.

## Key Findings

| Metric | Value |
|--------|-------|
| Default Rate | 22.12% |
| Total Customers | 30,000 |
| Total Defaults | 6,636 |
| Main Predictor | Payment Behavior |

## Files

- `sql/01_default_analysis.sql` - 5 SQL queries
- `reports/screenshots/` - Query results
- `data/raw/UCI_Credit_Card.csv` - Raw data

## Query Summary

1. Overall default rate calculation
2. Gender-based risk analysis
3. Education impact on default
4. Age group segmentation
5. Payment delay analysis (strongest predictor)

## How to Use

1. Open SSMS
2. Import CSV to database
3. Run queries in `sql/01_default_analysis.sql`
4. View results in `reports/screenshots/`

## Results

- Payment delays show 70%+ default rate
- Clear age and education correlations
- Gender shows minimal impact


**Author:** Luan Minh Huynh  
**Date:** November 2, 2025
