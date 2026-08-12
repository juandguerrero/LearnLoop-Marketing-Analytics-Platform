# LearnLoop Marketing Analytics Platform

### End-to-End Marketing Analytics | SQL · Tableau · Snowflake · dbt · Python · Airflow · AWS S3

LearnLoop is an end-to-end **Marketing Analytics Platform** built around a simulated subscription-based EdTech SaaS company.

The project solves a common business problem: **marketing, website, CRM, subscription, and revenue data are distributed across multiple systems, making it difficult to understand which marketing activities actually drive customers and revenue.**

The platform integrates these sources into a centralized analytics environment and transforms the data into business-ready KPIs and Tableau dashboards for analyzing **campaign profitability, customer acquisition, funnel conversion, recurring revenue, customer value, and course performance**.

---

## 🎯 Business Problem

LearnLoop's customer journey generates data across multiple platforms:

- **Google Ads & Meta Ads** → advertising spend and campaign performance
- **Google Analytics 4** → website traffic and user behavior
- **HubSpot** → leads and customer acquisition
- **Stripe** → subscriptions, payments, and revenue
- **Course Enrollment Data** → enrollments and course completions

Individually, these systems provide only part of the picture.

For example, advertising platforms can show **clicks, impressions, and spend**, but they cannot independently explain whether those campaigns ultimately produced valuable customers, subscriptions, or recurring revenue.

The central analytics problem was:

> **How can LearnLoop connect marketing spend to customer acquisition and revenue so decision-makers can identify what is working, where potential customers are dropping out of the funnel, and where marketing resources should be allocated?**

To solve this, I built a centralized analytics platform connecting the customer journey from:

**Marketing Spend → Website Sessions → Leads → MQLs → SQLs → Customers → Subscriptions → Revenue → Course Engagement**

---

## 📊 Business Questions

The project was designed to answer practical marketing and SaaS business questions:

1. Which campaigns generate the highest **ROAS and revenue**?
2. What is the **Customer Acquisition Cost (CAC)**?
3. Which campaigns and channels acquire customers most efficiently?
4. Where are potential customers dropping out of the **marketing funnel**?
5. How many leads become **MQLs, SQLs, and customers**?
6. How are **MRR and ARR** changing over time?
7. Which subscription plans generate the most recurring revenue?
8. What is the average **Customer Lifetime Value (CLV)**?
9. Which marketing campaigns acquire the highest-value customers?
10. Which courses generate the most enrollments?
11. Which courses and categories have the strongest completion performance?

---

## 📈 Tableau Dashboards

The final analytical layer consists of **four Tableau dashboards**, each designed around a specific business decision area.

### 1. Campaign Performance

**Business purpose:** Evaluate marketing efficiency and determine which campaigns deserve additional or reduced investment.

Key metrics and analyses:

- Total Ad Spend
- Total Revenue
- ROAS
- CAC
- Revenue by Campaign
- ROAS by Campaign
- Spend vs. Revenue
- Performance Over Time

This dashboard connects advertising investment with downstream revenue and customer acquisition instead of evaluating campaigns only through clicks and impressions.

---

### 2. Marketing Funnel

**Business purpose:** Understand how effectively website traffic and leads progress toward becoming customers.

The dashboard tracks the acquisition journey:

**Sessions → Leads → MQLs → SQLs → Customers**

Key metrics and analyses:

- Total Sessions
- Total Leads
- Total MQLs
- Total SQLs
- Total Customers
- Funnel Conversion Rates
- Funnel Drop-Off
- Conversion Trends Over Time

This allows the business to identify where potential customers are being lost and which stages provide the greatest opportunities for conversion improvement.

---

### 3. Subscription & Customer Value

**Business purpose:** Measure recurring-revenue performance and understand the long-term value of acquired customers.

Key metrics and analyses:

- Total Subscriptions
- Active Subscriptions
- MRR
- ARR
- Average Customer Lifetime Value
- MRR Over Time
- MRR by Subscription Plan
- Subscriptions by Plan
- Customer Value by Campaign

This dashboard extends the analysis beyond customer acquisition by measuring **what happens after a customer converts**.

It allows marketing acquisition performance to be compared with downstream subscription and customer value.

---

### 4. Course Performance

**Business purpose:** Understand whether acquired customers are engaging with LearnLoop's educational products.

Key metrics and analyses:

- Total Enrollments
- Total Completions
- Incomplete Enrollments
- Completion Rate
- Enrollments by Course
- Enrollments by Category
- Completion Rate by Course
- Enrollments Over Time

This provides a product-performance perspective by connecting customer acquisition with actual engagement in LearnLoop's courses.

---

## 🏗️ Data Architecture

The project follows an end-to-end analytics architecture:

```text
Google Ads ──────┐
Meta Ads ────────┤
GA4 ─────────────┤
HubSpot ─────────┼──► Python ETL
Stripe ──────────┤         │
Course Data ─────┘         ▼
                         AWS S3
                        Raw JSON
                           │
                           ▼
                        Snowflake
                        Raw Layer
                           │
                           ▼
                           dbt
                ┌──────────┼──────────┐
                ▼          ▼          ▼
             Staging  Intermediate   Marts
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

**Apache Airflow** orchestrates the workflow from data ingestion through transformation and data-quality validation.

---

## 🔄 ETL & Analytics Pipeline

The complete workflow follows these steps:

1. Extract source data using **Python**.
2. Validate and prepare incoming data.
3. Store raw JSON data in **AWS S3**.
4. Load raw datasets into **Snowflake**.
5. Clean and standardize data using **dbt staging models**.
6. Combine data sources using **dbt intermediate models**.
7. Build dimensional **fact and dimension tables**.
8. Execute automated **dbt data-quality tests**.
9. Calculate business KPIs using **SQL/dbt analytics models**.
10. Orchestrate the workflow with **Apache Airflow**.
11. Visualize business performance in **Tableau**.

---

## 🗄️ Data Warehouse

The Snowflake warehouse uses dimensional modeling to organize marketing, customer, subscription, revenue, and course data for analysis.

### Dimensions

- `dim_date`
- `dim_customer`
- `dim_campaign`
- `dim_channel`
- `dim_course`
- `dim_subscription_plan`
- `dim_device`

### Fact Tables

- `fact_marketing_spend`
- `fact_website_sessions`
- `fact_leads`
- `fact_subscriptions`
- `fact_revenue`
- `fact_course_enrollments`

The dimensional model connects marketing activity with website behavior, leads, customers, subscriptions, course engagement, and revenue.

---

## 🔧 dbt Transformation Layers

### Staging

Raw source data is cleaned, standardized, renamed, and validated before downstream use.

Staging models include data from:

- Google Ads
- Meta Ads
- Google Analytics 4
- HubSpot
- Stripe Payments
- Stripe Subscriptions
- Course Enrollments

### Intermediate

Intermediate models combine multiple sources and implement reusable business logic.

Examples include:

- `int_marketing_performance`
- `int_marketing_attribution`
- `int_customer_acquisition`
- `int_customer_revenue`
- `int_subscription_metrics`

### Marts

Business entities are organized into reusable **fact and dimension tables** optimized for analytics.

### Analytics / KPI Layer

Business-ready analytical models prepare the metrics consumed by Tableau:

- `kpi_campaign_performance`
- `kpi_funnel_performance`
- `kpi_subscription_performance`
- `kpi_customer_value`
- `kpi_course_performance`

This architecture keeps important business logic in the data layer rather than duplicating calculations across Tableau worksheets.

---

## 📐 Key Business KPIs

| KPI | Business Purpose |
|---|---|
| **ROAS** | Measures revenue generated for each dollar of advertising spend |
| **CAC** | Measures the average marketing cost required to acquire a customer |
| **CTR** | Measures how effectively advertising generates clicks |
| **CPC** | Measures average advertising cost per click |
| **MQLs** | Tracks leads that meet marketing qualification criteria |
| **SQLs** | Tracks qualified leads ready for sales engagement |
| **Conversion Rate** | Measures progression through the acquisition funnel |
| **MRR** | Measures monthly recurring subscription revenue |
| **ARR** | Measures annualized recurring subscription revenue |
| **CLV** | Estimates the value generated by a customer |
| **Completion Rate** | Measures the percentage of course enrollments completed |

---

## ✅ Data Quality

Automated **dbt tests** validate analytical reliability throughout the transformation pipeline.

Tests include:

- `not_null` validation
- Unique identifier validation
- Referential integrity between facts and dimensions
- Accepted categorical values
- Source relationships
- Business-critical field validation

Testing is integrated into the transformation workflow so analytical models are validated before being consumed by Tableau.

---

## 🛠️ Technology Stack

| Area | Technologies |
|---|---|
| **Data Analysis** | SQL, Tableau |
| **Data Transformation** | dbt |
| **Data Warehouse** | Snowflake |
| **Data Ingestion** | Python, REST APIs |
| **Cloud Storage** | AWS S3 |
| **Orchestration** | Apache Airflow |
| **Data Modeling** | Dimensional Modeling / Star Schema |
| **Version Control** | Git, GitHub |

---

## 📁 Repository Structure

```text
LearnLoop/
│
├── airflow/
│   └── dags/
│       └── learnloop_pipeline_dag.py
│
├── ingestion/
│   ├── __init__.py
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
│   ├── tests/
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

## 💡 Skills Demonstrated

### Data Analysis

`SQL` · `KPI Development` · `Marketing Analytics` · `Funnel Analysis` · `Customer Analysis` · `Revenue Analysis` · `Trend Analysis`

### Business Intelligence

`Tableau` · `Dashboard Design` · `Data Visualization` · `Executive Reporting` · `Business Metrics`

### Marketing & SaaS Analytics

`ROAS` · `CAC` · `CTR` · `CPC` · `MQL` · `SQL` · `Conversion Rate` · `MRR` · `ARR` · `CLV` · `Subscription Analytics`

### Data Modeling & Analytics Engineering

`Snowflake` · `dbt` · `Dimensional Modeling` · `Star Schema` · `Fact Tables` · `Dimension Tables` · `Data Quality Testing`

### Data Engineering

`Python` · `REST APIs` · `AWS S3` · `ETL Pipelines` · `Apache Airflow` · `Logging` · `Pipeline Orchestration`

---

## 🎯 Project Outcome

The final platform creates a **single analytical view of the customer acquisition lifecycle**.

Instead of analyzing advertising, website activity, CRM leads, subscriptions, and revenue independently, LearnLoop connects these datasets so marketing performance can be evaluated based on downstream business outcomes.

This changes the analysis from questions such as:

> **Which campaign generated the most clicks?**

to more decision-oriented questions such as:

> **Which campaigns acquire customers efficiently and generate the strongest customer and recurring-revenue outcomes?**

The project demonstrates the ability to translate a business problem into:

**Business Questions → Data Requirements → ETL → Data Modeling → SQL Analysis → KPIs → Tableau Dashboards → Business Decisions**

---

## 👤 Author

**Juan David Guerrero**

Data Analyst | SQL · Tableau · Python · Snowflake · dbt

This project was developed as part of my data analytics portfolio to demonstrate practical skills in solving business problems using data.
