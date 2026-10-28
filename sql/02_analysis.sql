USE upi_project;
-- 1. Sanity check: should be 90
SELECT COUNT(*) FROM monthly_upi;

-- 2. Financial-year summary (April-March)
SELECT
    CASE WHEN MONTH(month) >= 4 THEN YEAR(month) ELSE YEAR(month) - 1 END AS fy_start,
    COUNT(*) AS months_in_data,
    ROUND(SUM(volume_mn), 0) AS total_volume_mn,
    ROUND(SUM(value_cr), 0) AS total_value_cr,
    ROUND(SUM(value_cr) / SUM(volume_mn) * 10, 2) AS avg_ticket_rs
FROM monthly_upi
GROUP BY fy_start
ORDER BY fy_start;

-- 3. Seasonality: how much busier or quieter is each calendar month than its surrounding trend?
WITH ma AS (
    SELECT month, avg_daily_volume_mn,
           AVG(avg_daily_volume_mn) OVER (
               ORDER BY month ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
           ) AS trend
    FROM monthly_upi
)
SELECT MONTH(month) AS m,
       MONTHNAME(month) AS month_name,
       ROUND(AVG(avg_daily_volume_mn / trend), 3) AS seasonal_index
FROM ma
WHERE month BETWEEN '2019-07-01' AND '2026-03-01'
GROUP BY m, month_name
ORDER BY m;

-- 4. A reusable view with growth columns (this is what Power BI will read)
CREATE OR REPLACE VIEW monthly_analysis AS
SELECT
    month, banks_live, volume_mn, value_cr, avg_daily_volume_mn, avg_ticket_rs,
    ROUND((volume_mn / LAG(volume_mn) OVER (ORDER BY month) - 1) * 100, 2) AS mom_growth_pct,
    ROUND((volume_mn / LAG(volume_mn, 12) OVER (ORDER BY month) - 1) * 100, 2) AS yoy_growth_pct,
    ROUND((avg_daily_volume_mn / LAG(avg_daily_volume_mn) OVER (ORDER BY month) - 1) * 100, 2) AS mom_daily_growth_pct
FROM monthly_upi;

SELECT * FROM monthly_analysis ORDER BY month;

-- 5. COVID window
SELECT month, volume_mn, value_cr, avg_ticket_rs, mom_growth_pct
FROM monthly_analysis
WHERE month BETWEEN '2020-01-01' AND '2020-12-01'
ORDER BY month;
-- 6. MoM Growth Query
SELECT
    month,
    volume_mn,
    LAG(volume_mn) OVER (ORDER BY month) AS prev_month_volume,
    ROUND(
        (volume_mn - LAG(volume_mn) OVER (ORDER BY month))
        / LAG(volume_mn) OVER (ORDER BY month) * 100, 2
    ) AS mom_growth_pct
FROM monthly_upi
ORDER BY month;
