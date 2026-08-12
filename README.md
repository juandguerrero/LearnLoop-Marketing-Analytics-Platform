# LearnLoop Marketing Analytics Platform

**End-to-End Marketing Analytics | SQL · Tableau · Snowflake · dbt · Python · Airflow · AWS S3**

## Project Overview

**LearnLoop** is a simulated subscription-based EdTech SaaS company that sells online courses and corporate training through monthly subscription plans.

The company acquires customers through digital marketing, but its **advertising, website, CRM, subscription, and revenue data are distributed across separate systems**. This makes it difficult to determine which campaigns actually generate customers and revenue, how much customers cost to acquire, and where prospects drop out of the marketing funnel.

I built an **end-to-end marketing analytics platform** that centralizes these data sources and connects the customer journey from:

**Marketing Spend → Website Sessions → Leads → MQLs → SQLs → Customers → Subscriptions → Revenue**

The solution uses **Python, AWS S3, Snowflake, dbt, SQL, Airflow, and Tableau** to transform fragmented source data into validated analytical models and four decision-focused dashboards.

### Business Outcome

The platform allows LearnLoop to move beyond clicks and impressions and answer the more important question:

> **Which marketing activities acquire customers efficiently and generate the strongest business value?**

---

## Business Questions

The analysis focuses on four areas:

### Marketing Performance
- Which campaigns generate the most revenue?
- Which campaigns have the highest **ROAS**?
- What is the **Customer Acquisition Cost (CAC)**?
- How do advertising spend and revenue compare over time?

### Customer Acquisition
- How many visitors become leads, MQLs, SQLs, and customers?
- Where are the largest **funnel drop-offs**?
- How effectively are prospects converting through the funnel?

### Subscription & Customer Value
- What are the current **MRR and ARR**?
- Which subscription plans generate the most recurring revenue?
- What is the average **Customer Lifetime Value (CLV)**?
- Which campaigns acquire the highest-value customers?

### Course Performance
- Which courses generate the most enrollments?
- Which categories attract the most students?
- Which courses have the highest completion rates?
- How are enrollments changing over time?

---

# Tableau Dashboards

The final analytical solution contains **four Tableau dashboards**.

## 1. Campaign Performance

**Goal:** Identify which campaigns generate the strongest financial performance and support better marketing-budget allocation.

**KPIs**
- Total Ad Spend
- Total Revenue
- ROAS
- CAC

**Analysis**
- Revenue by Campaign
- ROAS by Campaign
- Spend vs. Revenue
- Performance Over Time

This dashboard connects advertising spend with downstream revenue and customer acquisition rather than evaluating campaigns only through clicks and impressions.

---

## 2. Marketing Funnel

**Goal:** Identify where potential customers are being lost during the acquisition process.

**Funnel**

**Sessions → Leads → MQLs → SQLs → Customers**

**KPIs**
- Total Sessions
- Total Leads
- Total MQLs
- Total SQLs
- Total Customers

**Analysis**
- Funnel Progression
- Stage-to-Stage Conversion
- Funnel Drop-Off
- Conversion Trends Over Time

This dashboard helps identify which stages represent the largest opportunities for improving customer conversion.

---

## 3. Subscription & Customer Value

**Goal:** Understand recurring revenue and determine the value of acquired customers.

**KPIs**
- Total Subscriptions
- Active Subscriptions
- MRR
- ARR
- Average Customer Lifetime Value

**Analysis**
- MRR Over Time
- MRR by Subscription Plan
- Subscriptions by Plan
- Customer Value by Campaign

This extends the analysis beyond customer acquisition by evaluating the **quality and value of customers acquired by marketing campaigns**.

---

## 4. Course Performance

**Goal:** Understand how customers engage with LearnLoop's educational products after acquisition.

**KPIs**
- Total Enrollments
- Total Completions
- Incomplete Enrollments
- Completion Rate

**Analysis**
- Enrollments by Course
- Enrollments by Category
- Completion Rate by Course
- Enrollments Over Time

This provides a product-engagement perspective by showing whether acquired customers actually use and complete LearnLoop's courses.

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

**Apache Airflow** orchestrates the workflow from data ingestion through dbt transformations and data-quality testing.

---

# Data Pipeline

### 1. Python — Data Ingestion

Python scripts handle data extraction, validation, logging, and movement of source data.

### 2. AWS S3 — Raw Storage

Raw JSON data is stored in AWS S3, providing a centralized raw-data layer.

### 3. Snowflake — Data Warehouse

Source data is loaded into Snowflake, centralizing marketing, website, CRM, subscription, revenue, and course data.

### 4. dbt — Transformation & Modeling

dbt transforms the data through:

```text
Raw → Staging → Intermediate → Marts → Analytics
```

### 5. SQL — Business Logic

SQL transformations calculate and prepare business metrics such as:

- ROAS
- CAC
- Funnel Conversion
- MRR
- ARR
- CLV
- Course Completion Rate

### 6. Tableau — Business Intelligence

Tableau consumes the prepared analytical models and presents the results through interactive dashboards.

### 7. Airflow — Orchestration

Apache Airflow coordinates and monitors the pipeline workflow.

---

# Data Warehouse

The Snowflake warehouse uses a **dimensional model** designed for analytical querying.

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

Together, these models connect:

**Marketing Activity → Website Behavior → Leads → Customers → Subscriptions → Revenue → Course Engagement**

---

# dbt Analytics Layer

Business-ready KPI models provide prepared datasets for Tableau:

- `kpi_campaign_performance`
- `kpi_funnel_performance`
- `kpi_subscription_performance`
- `kpi_customer_value`
- `kpi_course_performance`

Keeping business logic in the data layer creates reusable metric definitions and avoids duplicating complex calculations across Tableau worksheets.

---

# Key KPIs

| KPI | Business Purpose |
|---|---|
| **ROAS** | Revenue generated for each dollar of advertising spend |
| **CAC** | Average marketing cost required to acquire a customer |
| **CTR** | Percentage of advertising impressions resulting in clicks |
| **CPC** | Average advertising cost per click |
| **MQLs** | Leads meeting marketing qualification criteria |
| **SQLs** | Qualified leads ready for sales engagement |
| **Conversion Rate** | Effectiveness of moving prospects through the funnel |
| **MRR** | Monthly recurring subscription revenue |
| **ARR** | Annualized recurring subscription revenue |
| **CLV** | Estimated value generated by a customer |
| **Completion Rate** | Percentage of course enrollments completed |

---

# Data Quality

Automated **dbt tests** validate analytical data before it reaches the reporting layer.

Tests include:

- `not_null`
- `unique`
- Relationship tests
- Referential integrity
- Accepted values
- Business-critical field validation

---

# Technology Stack

| Area | Technologies |
|---|---|
| **Data Analysis** | SQL |
| **Business Intelligence** | Tableau |
| **Data Warehouse** | Snowflake |
| **Transformation** | dbt |
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

**Data Analysis:** SQL · KPI Development · Funnel Analysis · Customer Analysis · Revenue Analysis · Trend Analysis

**Marketing Analytics:** Campaign Performance · ROAS · CAC · CTR · CPC · Marketing Attribution · Conversion Analysis

**SaaS Analytics:** MRR · ARR · CLV · Subscription Analytics · Customer Acquisition

**Business Intelligence:** Tableau · Dashboard Design · Data Visualization · Executive Reporting

**Data Modeling:** Snowflake · dbt · Dimensional Modeling · Star Schema · Fact & Dimension Tables

**Data Engineering:** Python · REST APIs · AWS S3 · ETL · Apache Airflow · Data Validation · Logging

---

# Project Outcome

LearnLoop transforms fragmented marketing and customer data into a **single analytical view of customer acquisition and value**.

Instead of stopping at:

> **Which campaign generated the most clicks?**

the company can evaluate:

> **Which campaigns acquire customers efficiently and generate the strongest revenue and customer value?**

The project demonstrates the complete analytical process:

**Business Problem → Data Integration → SQL & Data Modeling → KPIs → Tableau Dashboards → Business Decisions**

---

## Author

**Juan David Guerrero**  
**Data Analyst**

SQL · Tableau · Python · Snowflake · dbt · Marketing Analytics

*Portfolio project designed to demonstrate how a business problem can be translated into an end-to-end analytical solution.*
