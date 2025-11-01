-- CREDIT RISK ANALYSIS - EXPLORATORY QUERIES
-- Author: Huỳnh Minh Luận
-- Date: November 2, 2025
-- Database: CreditRisk
-- Table: [dbo].[UCI_Credit_Card]


-- QUERY 1: OVERALL DEFAULT STATISTICS
-- Purpose: Calculate total customers and overall default rate
SELECT 
    COUNT(*) as total_customers,
    SUM(CAST([default payment next month] AS INT)) as total_defaults,
    CAST(SUM(CAST([default payment next month] AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card];

-- Expected: ~30000 customers, ~6636 defaults, 22.12% default rate


-- QUERY 2: DEFAULT RATE BY GENDER
-- Purpose: Identify if gender is a risk factor
SELECT 
    CASE WHEN SEX = 1 THEN 'Male' WHEN SEX = 2 THEN 'Female' ELSE 'Unknown' END as gender,
    COUNT(*) as total_customers,
    SUM(CAST([default payment next month] AS INT)) as defaults,
    CAST(SUM(CAST([default payment next month] AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card]
GROUP BY SEX
ORDER BY default_rate_pct DESC;

-- Expected: Female has higher default rate than Male


-- QUERY 3: DEFAULT RATE BY EDUCATION LEVEL
-- Purpose: Identify if education level affects default risk
SELECT 
    CASE WHEN EDUCATION = 1 THEN 'Graduate' WHEN EDUCATION = 2 THEN 'University'
         WHEN EDUCATION = 3 THEN 'High School' ELSE 'Others' END as education,
    COUNT(*) as total,
    CAST(AVG(CAST([default payment next month] AS INT)) * 100.0 AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card]
GROUP BY EDUCATION
ORDER BY default_rate_pct DESC;

-- Expected: Lower education = Higher default risk


-- QUERY 4: DEFAULT RATE BY AGE GROUP
-- Purpose: Identify age group risk segmentation
SELECT 
    CASE WHEN AGE < 25 THEN '<25' WHEN AGE BETWEEN 25 AND 35 THEN '25-35'
         WHEN AGE BETWEEN 36 AND 45 THEN '36-45' WHEN AGE BETWEEN 46 AND 55 THEN '46-55' ELSE '>55' END as age_group,
    COUNT(*) as total,
    CAST(AVG(CAST([default payment next month] AS INT)) * 100.0 AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card]
GROUP BY CASE WHEN AGE < 25 THEN '<25' WHEN AGE BETWEEN 25 AND 35 THEN '25-35'
             WHEN AGE BETWEEN 36 AND 45 THEN '36-45' WHEN AGE BETWEEN 46 AND 55 THEN '46-55' ELSE '>55' END
ORDER BY age_group;

-- Expected: Younger age groups (especially <25) have much higher default rate


-- QUERY 5: PAYMENT DELAY FREQUENCY & DEFAULT RISK
-- Purpose: Identify payment delay as strongest predictor of default
SELECT 
    (CASE WHEN PAY_0 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_2 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_3 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_4 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_5 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_6 > 0 THEN 1 ELSE 0 END) as payment_delay_months,
    COUNT(*) as total,
    CAST(AVG(CAST([default payment next month] AS INT)) * 100.0 AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card]
GROUP BY (CASE WHEN PAY_0 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_2 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_3 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_4 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_5 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_6 > 0 THEN 1 ELSE 0 END)
ORDER BY payment_delay_months;

-- Expected: 2+ payment delays = EXTREME RISK (>85% default rate)
