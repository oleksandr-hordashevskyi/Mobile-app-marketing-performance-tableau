WITH 
-- 1. Агрегація витрат
cost_agg AS (
  SELECT
    SAFE_CAST(date AS DATE) AS event_date,
    media_source,
    campaign_id,
    ANY_VALUE(campaign) AS campaign_name,
    country_code AS country,
    SUM(cost_usd) AS cost,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks
  FROM `mornhouse-test-environment.test_app_dataset.cost_table`
  GROUP BY 1, 2, 3, 5
),

-- 2. Агрегація неорганічних установок
installs_agg AS (
  SELECT
    DATE(install_date) AS event_date,
    media_source,
    campaign_id,
    ANY_VALUE(campaign_name) AS campaign_name,
    country,
    COUNT(DISTINCT COALESCE(advertising_id, analytics_installation_id, appsflyer_id)) AS installs
  FROM `mornhouse-test-environment.test_app_dataset.non_org_installs_report`
  GROUP BY 1, 2, 3, 5
),

-- 3. Агрегація доходу від реклами (Ad Revenue)
ad_rev_agg AS (
  SELECT
    DATE(event_date) AS event_date,
    media_source,
    campaign_id,
    country,
    SUM(event_revenue_usd) AS ad_revenue
  FROM `mornhouse-test-environment.test_app_dataset.ad_revenue_raw`
  GROUP BY 1, 2, 3, 4
),

-- 4. Агрегація доходу від покупок та підписок (In-App Purchases)
iap_rev_agg AS (
  SELECT
    DATE(event_date) AS event_date,
    media_source,
    campaign_id,
    country,
    SUM(event_revenue_usd) AS iap_revenue
  FROM `mornhouse-test-environment.test_app_dataset.in_app_events_report`
  GROUP BY 1, 2, 3, 4
),

-- 5. Об'єднання всіх джерел у єдину матрицю
unified AS (
  SELECT
    COALESCE(c.event_date, i.event_date, a.event_date, p.event_date) AS date,
    COALESCE(c.media_source, i.media_source, a.media_source, p.media_source) AS media_source,
    COALESCE(c.campaign_id, i.campaign_id, a.campaign_id, p.campaign_id) AS campaign_id,
    COALESCE(c.campaign_name, i.campaign_name) AS campaign_name,
    UPPER(COALESCE(c.country, i.country, a.country, p.country)) AS country,
    
    COALESCE(c.cost, 0) AS cost,
    COALESCE(c.impressions, 0) AS impressions,
    COALESCE(c.clicks, 0) AS clicks,
    COALESCE(i.installs, 0) AS installs,
    COALESCE(a.ad_revenue, 0) AS ad_revenue,
    COALESCE(p.iap_revenue, 0) AS iap_revenue
  FROM cost_agg c
  FULL OUTER JOIN installs_agg i
    ON c.event_date = i.event_date
   AND c.campaign_id = i.campaign_id
   AND c.media_source = i.media_source
   AND UPPER(c.country) = UPPER(i.country)
  FULL OUTER JOIN ad_rev_agg a
    ON COALESCE(c.event_date, i.event_date) = a.event_date
   AND COALESCE(c.campaign_id, i.campaign_id) = a.campaign_id
   AND COALESCE(c.media_source, i.media_source) = a.media_source
   AND UPPER(COALESCE(c.country, i.country)) = UPPER(a.country)
  FULL OUTER JOIN iap_rev_agg p
    ON COALESCE(c.event_date, i.event_date, a.event_date) = p.event_date
   AND COALESCE(c.campaign_id, i.campaign_id, a.campaign_id) = p.campaign_id
   AND COALESCE(c.media_source, i.media_source, a.media_source) = p.media_source
   AND UPPER(COALESCE(c.country, i.country, a.country)) = UPPER(p.country)
)

-- 6. Фінальний розрахунок бізнес-метрик
SELECT
  date,
  media_source,
  campaign_id,
  campaign_name,
  country,
  impressions,
  clicks,
  installs,
  ROUND(cost, 2) AS cost,
  ROUND(ad_revenue, 2) AS ad_revenue,
  ROUND(iap_revenue, 2) AS iap_revenue,
  ROUND(ad_revenue + iap_revenue, 2) AS total_revenue,
  ROUND((ad_revenue + iap_revenue) - cost, 2) AS net_profit,
  
  -- Розрахункові показники
  ROUND(SAFE_DIVIDE(ad_revenue + iap_revenue, cost) * 100, 2) AS roas_percent,
  ROUND(SAFE_DIVIDE(cost, installs), 2) AS cpi,
  ROUND(SAFE_DIVIDE(ad_revenue + iap_revenue, installs), 2) AS arpu,
  ROUND(SAFE_DIVIDE(clicks, impressions) * 100, 2) AS ctr_percent
FROM unified
ORDER BY date DESC, cost DESC;