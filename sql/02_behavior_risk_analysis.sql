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
