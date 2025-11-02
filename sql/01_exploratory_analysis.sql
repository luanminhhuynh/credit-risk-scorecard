-- CREDIT RISK ANALYSIS - EXPLORATORY QUERIES
-- Database: CreditRisk
-- Table: [dbo].[UCI_Credit_Card]


-- QUERY 1: OVERALL DEFAULT STATISTICS
-- Purpose: Tính tổng số khách hàng và tỷ lệ vỡ nợ (default) chung toàn bộ danh mục
SELECT 
    COUNT(*) as total_customers,
    SUM(CAST([default payment next month] AS INT)) as total_defaults,
    CAST(SUM(CAST([default payment next month] AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card];


-- QUERY 2: DEFAULT RATE BY GENDER
-- Purpose: Kiểm tra giới tính (SEX) có phải là yếu tố rủi ro ảnh hưởng đến tỷ lệ vỡ nợ hay không
SELECT 
    CASE WHEN SEX = 1 THEN 'Male' WHEN SEX = 2 THEN 'Female' ELSE 'Unknown' END as gender,
    COUNT(*) as total_customers,
    SUM(CAST([default payment next month] AS INT)) as defaults,
    CAST(SUM(CAST([default payment next month] AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card]
GROUP BY SEX
ORDER BY default_rate_pct DESC;


-- QUERY 3: DEFAULT RATE BY EDUCATION LEVEL
-- Purpose: Phân tích xem trình độ học vấn (EDUCATION) có ảnh hưởng đến khả năng vỡ nợ hay không
SELECT 
    CASE WHEN EDUCATION = 1 THEN 'Graduate' WHEN EDUCATION = 2 THEN 'University'
         WHEN EDUCATION = 3 THEN 'High School' ELSE 'Others' END as education,
    COUNT(*) as total,
    SUM(CAST([default payment next month] AS INT)) as defaults,
    CAST(SUM(CAST([default payment next month] AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card]
GROUP BY CASE WHEN EDUCATION = 1 THEN 'Graduate' WHEN EDUCATION = 2 THEN 'University'
             WHEN EDUCATION = 3 THEN 'High School' ELSE 'Others' END
ORDER BY default_rate_pct DESC;


-- QUERY 4: DEFAULT RATE BY AGE GROUP 
-- Purpose: Phân khúc khách hàng theo nhóm tuổi để xác định nhóm có rủi ro vỡ nợ cao
SELECT 
    CASE WHEN AGE < 25 THEN '<25' WHEN AGE BETWEEN 25 AND 35 THEN '25-35'
         WHEN AGE BETWEEN 36 AND 45 THEN '36-45' WHEN AGE BETWEEN 46 AND 55 THEN '46-55' ELSE '>55' END as age_group,
    COUNT(*) as total,
    SUM(CAST([default payment next month] AS INT)) as defaults,
    CAST(SUM(CAST([default payment next month] AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card]
GROUP BY CASE WHEN AGE < 25 THEN '<25' WHEN AGE BETWEEN 25 AND 35 THEN '25-35'
             WHEN AGE BETWEEN 36 AND 45 THEN '36-45' WHEN AGE BETWEEN 46 AND 55 THEN '46-55' ELSE '>55' END
ORDER BY age_group;


-- QUERY 5: PAYMENT DELAY FREQUENCY & DEFAULT RISK
-- Purpose: Phân tích mối quan hệ giữa số tháng bị trễ hạn thanh toán và xác suất vỡ nợ
SELECT 
    (CASE WHEN PAY_0 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_2 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_3 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_4 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_5 > 0 THEN 1 ELSE 0 END +
     CASE WHEN PAY_6 > 0 THEN 1 ELSE 0 END) as payment_delay_months,
    COUNT(*) as total,
    SUM(CAST([default payment next month] AS INT)) as defaults,
    CAST(SUM(CAST([default payment next month] AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as default_rate_pct
FROM [dbo].[UCI_Credit_Card]
GROUP BY (CASE WHEN PAY_0 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_2 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_3 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_4 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_5 > 0 THEN 1 ELSE 0 END +
          CASE WHEN PAY_6 > 0 THEN 1 ELSE 0 END)
ORDER BY payment_delay_months;
