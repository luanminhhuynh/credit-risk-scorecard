-- CREDIT RISK ANALYSIS - EXPLORATORY QUERIES
-- Date: November 2, 2025
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


-- QUERY 6: EAD-WEIGHTED DEFAULT RATE (OVERALL & BY GENDER)
-- Purpose: Đo tỷ lệ vỡ nợ có trọng số theo hạn mức tín dụng (EAD) để phản ánh rủi ro danh mục
WITH s AS (
  SELECT
      CASE WHEN SEX = '1' THEN 'Male'
           WHEN SEX = '2' THEN 'Female'
           ELSE 'Unknown' END                                   AS gender,
      TRY_CONVERT(DECIMAL(38,6), [default payment next month])  AS def_next,
      TRY_CONVERT(DECIMAL(38,6), TRY_CONVERT(FLOAT, REPLACE(LIMIT_BAL, ',', ''))) AS limit_bal
  FROM dbo.UCI_Credit_Card
)
-- Overall view
SELECT 
    CAST(SUM(def_next * limit_bal) / NULLIF(SUM(limit_bal), 0) AS DECIMAL(18,6)) AS ead_weighted_dr_overall
FROM s
WHERE def_next IS NOT NULL AND limit_bal IS NOT NULL;

-- By gender view
SELECT 
    gender,
    CAST(SUM(def_next * limit_bal) / NULLIF(SUM(limit_bal), 0) AS DECIMAL(18,6)) AS ead_weighted_dr
FROM s
WHERE def_next IS NOT NULL AND limit_bal IS NOT NULL
GROUP BY gender
ORDER BY ead_weighted_dr DESC;


-- QUERY 7: DEFAULT RATE BY CREDIT LIMIT BANDS
-- Purpose: Phân khúc rủi ro theo hạn mức tín dụng (LIMIT_BAL) – phục vụ cut/price/limit strategy
WITH b AS (
  SELECT 
      TRY_CONVERT(DECIMAL(38,6), TRY_CONVERT(FLOAT, REPLACE(LIMIT_BAL, ',', ''))) AS limit_bal_num,
      TRY_CONVERT(INT, [default payment next month]) AS def_next
  FROM dbo.UCI_Credit_Card
),
banded AS (
  SELECT 
      CASE 
        WHEN limit_bal_num <  50000   THEN '<50k'
        WHEN limit_bal_num <  100000  THEN '50k-100k'
        WHEN limit_bal_num <  200000  THEN '100k-200k'
        WHEN limit_bal_num <  500000  THEN '200k-500k'
        ELSE '>=500k'
      END AS limit_band,
      def_next
  FROM b
  WHERE limit_bal_num IS NOT NULL AND def_next IS NOT NULL
)
SELECT 
  limit_band,
  COUNT(*) AS n,
  SUM(def_next) AS defaults,
  CAST(100.0 * SUM(def_next) / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS dr_pct
FROM banded
GROUP BY limit_band
ORDER BY CASE limit_band
  WHEN '<50k' THEN 1 WHEN '50k-100k' THEN 2 WHEN '100k-200k' THEN 3
  WHEN '200k-500k' THEN 4 ELSE 5 END;


-- QUERY 8: DEFAULT RATE BY DELINQUENCY SEVERITY (MAX DPD)
-- Purpose: Đo ảnh hưởng mức độ trễ hạn nặng nhất trong 6 kỳ gần nhất lên rủi ro vỡ nợ
WITH x AS (
  SELECT
      TRY_CONVERT(INT, [default payment next month]) AS def_next,
      (SELECT MAX(v)
       FROM (VALUES (
                TRY_CONVERT(INT, PAY_0)), (TRY_CONVERT(INT, PAY_2)),
                (TRY_CONVERT(INT, PAY_3)), (TRY_CONVERT(INT, PAY_4)),
                (TRY_CONVERT(INT, PAY_5)), (TRY_CONVERT(INT, PAY_6))
            ) AS t(v)
      ) AS max_dpd
  FROM dbo.UCI_Credit_Card
)
SELECT
    max_dpd,
    COUNT(*) AS total,
    SUM(def_next) AS defaults,
    CAST(100.0 * SUM(def_next) / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS default_rate_pct
FROM x
WHERE max_dpd IS NOT NULL AND def_next IS NOT NULL
GROUP BY max_dpd
ORDER BY max_dpd DESC;


-- QUERY 9: DEFAULT RATE BY DPD RECENCY TREND (PAY_0 VS PAY_6)
-- Purpose: Phân loại xu hướng gần đây của trễ hạn (xấu đi/cải thiện/đều trễ/ổn định) và đo rủi ro vỡ nợ
SELECT 
  CASE 
    WHEN TRY_CONVERT(INT, PAY_0) > 0 AND TRY_CONVERT(INT, PAY_6) <= 0 THEN 'Worsening'
    WHEN TRY_CONVERT(INT, PAY_0) <= 0 AND TRY_CONVERT(INT, PAY_6) > 0 THEN 'Improving'
    WHEN TRY_CONVERT(INT, PAY_0) > 0 AND TRY_CONVERT(INT, PAY_6) > 0  THEN 'Persistent DPD'
    ELSE 'Clean/Stable' 
  END AS dpd_trend,
  COUNT(*) AS n,
  CAST(100.0 * SUM(TRY_CONVERT(INT, [default payment next month])) / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS dr_pct
FROM dbo.UCI_Credit_Card
GROUP BY CASE 
    WHEN TRY_CONVERT(INT, PAY_0) > 0 AND TRY_CONVERT(INT, PAY_6) <= 0 THEN 'Worsening'
    WHEN TRY_CONVERT(INT, PAY_0) <= 0 AND TRY_CONVERT(INT, PAY_6) > 0 THEN 'Improving'
    WHEN TRY_CONVERT(INT, PAY_0) > 0 AND TRY_CONVERT(INT, PAY_6) > 0  THEN 'Persistent DPD'
    ELSE 'Clean/Stable' 
  END
ORDER BY dr_pct DESC;


-- QUERY 10: ROLL-TO-DEFAULT BY CURRENT DELINQUENCY (PAY_0)
-- Purpose: Ước lượng xác suất “chuyển sang vỡ nợ tháng tới” theo trạng thái DPD hiện tại
WITH cur AS (
  SELECT 
    CASE 
      WHEN TRY_CONVERT(INT, PAY_0) <= 0 THEN 'Current/No DPD'
      WHEN TRY_CONVERT(INT, PAY_0) = 1  THEN 'DPD1'
      WHEN TRY_CONVERT(INT, PAY_0) = 2  THEN 'DPD2'
      WHEN TRY_CONVERT(INT, PAY_0) BETWEEN 3 AND 6 THEN 'DPD3-6'
      ELSE 'DPD>6' 
    END AS cur_bucket,
    TRY_CONVERT(INT, [default payment next month]) AS def_next
  FROM dbo.UCI_Credit_Card
)
SELECT 
  cur_bucket,
  COUNT(*) AS n,
  SUM(def_next) AS defaults,
  CAST(100.0 * SUM(def_next) / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS roll_to_default_pct
FROM cur
WHERE def_next IS NOT NULL
GROUP BY cur_bucket
ORDER BY CASE cur_bucket
  WHEN 'Current/No DPD' THEN 1 WHEN 'DPD1' THEN 2 WHEN 'DPD2' THEN 3
  WHEN 'DPD3-6' THEN 4 ELSE 5 END;

-- Author: Huỳnh Minh Luận
