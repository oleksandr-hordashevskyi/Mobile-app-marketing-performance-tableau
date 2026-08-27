# 🎮 Mobile App Marketing Performance & ROAS Analytics Dashboard

[![Tableau Public](https://img.shields.io/badge/Tableau_Public-Interactive_Dashboard-E97627?logo=tableau&logoColor=white)](https://public.tableau.com/views/MarketingPerformanceRevenueOverview/MarketingPerformanceRevenueOverview?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link)
[![Google BigQuery](https://img.shields.io/badge/Google_BigQuery-SQL_Data_Mart-669DF6?logo=googlecloud&logoColor=white)](sql/company_marketing_mart.sql)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📌 Executive Summary
An end-to-end User Acquisition and Unit Economics business intelligence solution analyzing multi-channel marketing campaigns for a mobile gaming application. The project features an enterprise-grade **SQL ETL data pipeline in Google BigQuery** and an interactive **Tableau Public** dashboard designed to evaluate marketing profitability, cross-channel blended ROAS, monetization stream breakdown (IAP vs. Ad Revenue), and campaign efficiency against a break-even threshold.

* **Live Interactive Dashboard:** [Tableau Public Report](https://public.tableau.com/views/MarketingPerformanceRevenueOverview/MarketingPerformanceRevenueOverview?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link)
* **Dataset Scope:** 40,199 consolidated records, 482,269 installs across 40+ campaigns and 230+ geographic regions (June – July 2026).

---

## 📊 Visualizations & Dashboard Overview

![Marketing Performance & Revenue Overview](images/Marketing%20Performance%20%26%20Revenue%20Overview.png)

---

## 🛠 Technical Architecture & Pipeline

* **Data Engineering & Harmonization Layer (Google BigQuery):**
  * Consolidated and aligned 4 disparate raw tables (`cost_table`, `non_org_installs_report`, `ad_revenue_raw`, `in_app_events_report`).
  * Harmonized varying granularities into a unified dimensional key composite: `[date + media_source + campaign_id + country]`.
  * Built multi-stage Common Table Expressions (CTEs) united via sequential `FULL OUTER JOIN` operations with resilient `COALESCE` logic to retain unspend organic traffic and unattributed revenues without row multiplication.
  * Extracted unique non-organic installations via `COUNT(DISTINCT user_id)` leveraging composite user attribution tokens `COALESCE(advertising_id, analytics_installation_id, appsflyer_id)`.
* **BI & Semantic Modeling Layer (Tableau):**
  * Engineered non-additive aggregated calculated fields (`[ROAS]`, `[CPI]`, `[ARPU]`, `[CTR]`) to ensure accurate ratio calculations across dynamically filtered subsets.
  * Configured synchronized dual-axis time-series visualizations (`Daily Ad Spend vs. Total Revenue`), grouped stacked bars for revenue monetization composition, and sorted campaign performance charts.
  * Implemented an analytical Reference Line (100% Constant) to isolate profitable user acquisition cohorts from sub-break-even segments.
  * Applied global cross-filtering across core business dimensions (`date`, `media_source`, `country`) utilizing relevant value filtering.

---

## 📈 Key Business Findings

* **Strong Return on Ad Spend (Blended ROAS):** Total marketing spend of **$20,575.41** generated **$71,254.26** in gross revenue (**$50,678.85 Net Profit**), yielding an overall blended ROAS of **346.31%**, significantly exceeding the 100% break-even mark.
* **Monetization Engine (IAP vs. Ad Revenue):** In-App Purchases (IAP) serve as the primary growth driver, contributing **79.28% ($56,488.39)** of total turnover, while In-App Advertising (Ad Revenue) delivered **20.72% ($14,765.86)**.
* **Volume & Acquisition Efficiency:** Generated **482,269 non-organic installs** at a blended Cost Per Install (CPI) of **~$0.043**, demonstrating efficient acquisition cost metrics.
* **Campaign Performance Variance:** While top-tier campaigns demonstrated ROAS metrics exceeding **300%**, several localized campaign configurations operated below the 100% break-even threshold, indicating specific regional budget drains.

---

## 💡 Strategic Recommendations

1. **Budget Reallocation:** Scale ad budgets on upper-quartile campaigns exhibiting $\text{ROAS} > 200\%$ while pausing or restructuring campaigns operating below the $100\%$ break-even benchmark.
2. **IAP Funnel Optimization:** Since In-App Purchases generate ~80% of revenue, align targeted live-ops events and premium purchase bundles with cohorts acquired via top-performing media sources.
3. **Geo-Targeting Refinement:** Adjust bidding caps and localization strategies in underperforming country segments where CPI exceeds the projected cohort monetization yield.

---

## 🗂 Project Structure & Deliverables

```text
mobile-app-marketing-analytics-tableau/
├── LICENSE
├── README.md
├── dashboards/
│   └── Marketing Performance & Revenue Overview.twb # Tableau Workbook file
├── sql/
│   └── company_marketing_mart.sql                 # BigQuery ETL extraction & mart generation script
├── data/
│   └── company_marketing_mart.csv                 # Cleaned & aggregated dataset
└── images/
    └── Marketing Performance & Revenue Overview.png # High-resolution dashboard view
```

📬 Contact
Author: Oleksandr Hordashevskyi

LinkedIn: www.linkedin.com/in/oleksandr-hordashevskyi

Email: o.hordashevskyi@gmail.com
