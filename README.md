# LearnLoop Marketing Analytics Platform

**End-to-End Marketing Analytics | SQL · Tableau · Snowflake · dbt · Python · Airflow · AWS S3**

## Project Overview

**LearnLoop** is a simulated subscription-based EdTech SaaS company that sells online courses and corporate training.

Its marketing, website, CRM, subscription, and revenue data are stored across separate systems, making it difficult to understand which campaigns actually generate customers and revenue.

I built an **end-to-end marketing analytics platform** that connects:

**Ad Spend → Sessions → Leads → MQLs → SQLs → Customers → Subscriptions → Revenue**

The solution uses **Python, AWS S3, Snowflake, dbt, SQL, Airflow, and Tableau** to centralize the data, calculate business KPIs, and deliver decision-focused dashboards.

> **Goal:** help LearnLoop understand where marketing money is generating value and where budget is being wasted.

---

## Key Findings

- **$1.11M ad spend generated $373.5K in attributed revenue → 0.34x ROAS**
- **CAC = $116.08 per customer**
- **740,283 sessions → 93,276 leads → 9,592 customers**
- **Lead-to-Customer conversion ≈ 10.3%**
- **Only ~1.3% of website sessions became customers**
- **9,592 subscriptions and 16,628 course enrollments were generated**

### Main takeaway

The biggest opportunity is not simply generating more traffic.

LearnLoop should improve **campaign efficiency and funnel conversion**, then shift more budget toward campaigns that generate stronger **ROAS, lower CAC, and higher customer value**.

---

## Recommendations

1. **Reallocate budget toward higher-ROAS campaigns**
   - Reduce spend on campaigns with weak revenue return.
   - Increase investment in campaigns with stronger ROAS and customer value.

2. **Set campaign-level ROAS and CAC targets**
   - Classify campaigns as:
   - **Scale**
   - **Optimize**
   - **Reduce**
   - **Pause**

3. **Improve funnel conversion before buying more traffic**
   - Optimize landing pages, lead forms, free trials, lead nurturing, and sales follow-up.

4. **Evaluate CAC together with CLV**
   - A campaign with higher CAC can still be valuable if it produces customers with higher lifetime value.

5. **Optimize for customers and revenue, not clicks**
   - Marketing performance should be measured across the full journey:

**Spend → Leads → Customers → Subscriptions → Revenue → CLV**

---

# Business Questions & Answers

## 1. Which campaigns generate the strongest marketing return?

Overall campaign performance produced:

- **Ad Spend:** ~$1.11M
- **Attributed Revenue:** ~$373.5K
- **Overall ROAS:** ~**0.34x**

This indicates that marketing efficiency is currently weak at the portfolio level.

**Business decision:** compare campaigns individually and move budget toward those with stronger ROAS and customer value.

---

## 2. What is the Customer Acquisition Cost?

LearnLoop acquired:

**9,592 customers**

from approximately:

**$1.11M in advertising spend**

Therefore:

**CAC ≈ $116.08**

**Business decision:** monitor CAC by campaign and compare it with CLV.

---

## 3. Where is the biggest funnel drop-off?

The customer journey includes:

| Funnel Stage | Volume |
|---|---:|
| Website Sessions | **740,283** |
| Leads | **93,276** |
| Customers | **9,592** |

This means:

- Session-to-Lead Conversion ≈ **12.6%**
- Lead-to-Customer Conversion ≈ **10.3%**
- Session-to-Customer Conversion ≈ **1.3%**

The Tableau funnel also tracks the intermediate **MQL and SQL stages**.

**Business decision:** improving funnel conversion can increase customers without requiring the same proportional increase in marketing spend.

---

## 4. What is the Lead-to-Customer Conversion Rate?

\[
\text{Lead-to-Customer Conversion}
=
\frac{9,592}{93,276}
\approx 10.3\%
\]

Approximately **1 in every 10 leads becomes a customer**.

**Business decision:** improve lead quality, nurturing, qualification, and conversion.

---

## 5. How should LearnLoop evaluate campaign quality?

Campaigns should not be evaluated only using:

**Impressions → Clicks**

They should be evaluated across:

**Spend → Leads → Customers → Revenue → ROAS → CLV**

This distinguishes campaigns that generate activity from campaigns that create real business value.

---

## 6. What role does Customer Lifetime Value play?

CLV provides a longer-term view of customer quality.

Two campaigns may acquire the same number of customers but produce very different business value.

**Business decision:** compare:

**CLV / CAC**

and prioritize campaigns that produce stronger long-term customer economics.

---

## 7. How is subscription performance measured?

The subscription dashboard analyzes:

- Total Subscriptions
- Active Subscriptions
- MRR
- ARR
- MRR Over Time
- MRR by Subscription Plan
- Customer Value

The project generated:

**9,592 subscriptions**

**Business decision:** evaluate whether customer acquisition is translating into sustainable recurring revenue.

---

## 8. Which courses are performing best?

The Course Performance dashboard analyzes:

- Enrollments by Course
- Enrollments by Category
- Completion Rate by Course
- Enrollments Over Time

The project generated:

**16,628 course enrollments**

**Business decision:** identify the courses and categories that attract and engage customers most effectively.

---

# Tableau Dashboards

The final analytical solution contains **four Tableau dashboards**.

## 1. Campaign Performance

**Purpose:** evaluate marketing efficiency and support budget allocation.

### KPIs

- Total Ad Spend
- Total Revenue
- ROAS
- CAC

### Analysis

- Revenue by Campaign
- ROAS by Campaign
- Spend vs. Revenue
- Performance Over Time

**Decision supported:** where should marketing budget be increased, reduced, or optimized?

---

## 2. Marketing Funnel

**Purpose:** identify where prospects are lost during acquisition.

### Funnel

**Sessions → Leads → MQLs → SQLs → Customers**

### Analysis

- Funnel Progression
- Stage Conversion
- Funnel Drop-Off
- Conversion Trends

**Decision supported:** which funnel stages should be optimized?

---

## 3. Subscription & Customer Value

**Purpose:** understand recurring revenue and customer value.

### KPIs

- Total Subscriptions
- Active Subscriptions
- MRR
- ARR
- Average CLV

### Analysis

- MRR Over Time
- MRR by Subscription Plan
- Subscriptions by Plan
- Customer Value by Campaign

**Decision supported:** which acquisition sources and subscription plans generate the strongest long-term value?

---

## 4. Course Performance

**Purpose:** understand product engagement after customer acquisition.

### KPIs

- Total Enrollments
- Total Completions
- Incomplete Enrollments
- Completion Rate

### Analysis

- Enrollments by Course
- Enrollments by Category
- Completion Rate by Course
- Enrollments Over Time

**Decision supported:** which courses attract and retain the most engagement?

---

# Data Architecture

```text
Google Ads ──────┐
Meta Ads ────────┤
GA4 ─────────────┤
HubSpot ─────────┼────► Python ETL
Stripe ──────────┤           │
Course Data ─────┘           ▼
                           AWS S3
                          Raw JSON
                             │
                             ▼
                          Snowflake
                          Raw Layer
                             │
                             ▼
                             dbt
                             │
                ┌────────────┼────────────┐
                ▼            ▼            ▼
             Staging    Intermediate     Marts
                                           │
                                           ▼
                                  Analytics / KPIs
                                           │
                                           ▼
                                        Tableau
                                           │
                                           ▼
                                  Business Decisions
```

**Apache Airflow** orchestrates the workflow from ingestion through transformation and data-quality testing.

---

# ETL & Analytics Pipeline

1. **Python** extracts and validates source data.
2. Raw JSON data is stored in **AWS S3**.
3. Data is loaded into **Snowflake**.
4. **dbt staging models** clean and standardize the data.
5. **Intermediate models** combine data across systems.
6. **Fact and dimension tables** organize the analytical warehouse.
7. **dbt tests** validate data quality.
8. **SQL analytics models** calculate business KPIs.
9. **Apache Airflow** orchestrates the workflow.
10. **Tableau** presents the final analysis.

---

# Data Warehouse

The Snowflake warehouse uses dimensional modeling.

## Dimensions

- `dim_date`
- `dim_customer`
- `dim_campaign`
- `dim_channel`
- `dim_course`
- `dim_subscription_plan`
- `dim_device`

## Fact Tables

- `fact_marketing_spend`
- `fact_website_sessions`
- `fact_leads`
- `fact_subscriptions`
- `fact_revenue`
- `fact_course_enrollments`

The model connects:

**Marketing Activity → Website Behavior → Leads → Customers → Subscriptions → Revenue → Course Engagement**

---

# dbt Analytics Layer

Business-ready models provide prepared datasets for Tableau:

- `kpi_campaign_performance`
- `kpi_funnel_performance`
- `kpi_subscription_performance`
- `kpi_customer_value`
- `kpi_course_performance`

This keeps important business logic in the data layer and avoids duplicating complex calculations across Tableau worksheets.

---

# Data Quality

Automated dbt tests validate:

- Null values
- Unique identifiers
- Referential integrity
- Model relationships
- Accepted categorical values
- Business-critical fields

---

# Technology Stack

| Area | Technologies |
|---|---|
| **Data Analysis** | SQL |
| **Business Intelligence** | Tableau |
| **Data Warehouse** | Snowflake |
| **Data Transformation** | dbt |
| **Data Modeling** | Dimensional Modeling / Star Schema |
| **Data Ingestion** | Python, REST APIs |
| **Cloud Storage** | AWS S3 |
| **Orchestration** | Apache Airflow |
| **Data Quality** | dbt Tests |
| **Version Control** | Git, GitHub |

---

# Repository Structure

```text
LearnLoop/
│
├── airflow/
│   └── dags/
│       └── learnloop_pipeline_dag.py
│
├── ingestion/
│   ├── config.py
│   ├── logger.py
│   ├── run_pipeline.py
│   ├── s3_uploader.py
│   └── validator.py
│
├── learnloop_dbt/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   ├── marts/
│   │   │   ├── dimensions/
│   │   │   └── facts/
│   │   └── analytics/
│   └── dbt_project.yml
│
├── synthetic_data/
│   └── generate_data.py
│
├── dashboards_2.twb
├── requirements.txt
└── README.md
```

---

# Skills Demonstrated

**Data Analysis:** SQL · Business Analysis · KPI Development · Funnel Analysis · Customer Analysis · Revenue Analysis

**Marketing Analytics:** ROAS · CAC · Campaign Performance · Conversion Analysis · Marketing Attribution

**SaaS Analytics:** MRR · ARR · CLV · Subscription Analytics

**Business Intelligence:** Tableau · Dashboard Design · Data Visualization · Executive Reporting

**Data Modeling:** Snowflake · dbt · Dimensional Modeling · Star Schema

**Data Engineering:** Python · REST APIs · AWS S3 · ETL · Apache Airflow · Data Validation

---

# Project Outcome

The project turns fragmented marketing and customer data into a **single view of customer acquisition and business value**.

Instead of asking:

> **Which campaign generated the most clicks?**

LearnLoop can ask:

> **Which marketing investments acquire customers efficiently and generate the strongest revenue and customer value?**

The project demonstrates:

**Business Problem → Data Integration → SQL Analysis → Insights → Recommendations → Tableau Dashboards → Business Decisions**

---

## Author

**Juan David Guerrero**  
**Data Analyst**

SQL · Tableau · Python · Snowflake · dbt · Marketing Analytics
