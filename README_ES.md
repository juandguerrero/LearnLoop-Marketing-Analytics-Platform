# LearnLoop — Plataforma de Analítica de Marketing

**Analítica de Marketing End-to-End | SQL · Tableau · Snowflake · dbt · Python · Airflow · AWS S3**

## Descripción del Proyecto

**LearnLoop** es una empresa SaaS EdTech simulada basada en suscripciones que ofrece cursos en línea y capacitación corporativa.

Sus datos de marketing, sitio web, CRM, suscripciones e ingresos se encuentran distribuidos entre diferentes sistemas, lo que dificulta entender qué campañas realmente generan clientes e ingresos.

Construí una **plataforma de analítica de marketing end-to-end** que conecta todo el recorrido del cliente:

**Inversión Publicitaria → Sesiones → Leads → MQLs → SQLs → Clientes → Suscripciones → Ingresos**

La solución utiliza **Python, AWS S3, Snowflake, dbt, SQL, Airflow y Tableau** para centralizar los datos, calcular KPIs de negocio y crear dashboards orientados a la toma de decisiones.

> **Objetivo:** ayudar a LearnLoop a identificar dónde la inversión en marketing está generando valor y dónde se está desperdiciando presupuesto.

---

## Principales Hallazgos

- **$1.11M de inversión publicitaria generaron $373.5K en ingresos atribuidos → ROAS de 0.34x**
- **CAC = $116.08 por cliente**
- **740,283 sesiones → 93,276 leads → 9,592 clientes**
- **Conversión de Lead a Cliente ≈ 10.3%**
- **Solo ~1.3% de las sesiones del sitio web se convirtieron en clientes**
- **Se generaron 9,592 suscripciones y 16,628 inscripciones a cursos**

### Conclusión Principal

La mayor oportunidad no consiste simplemente en generar más tráfico.

LearnLoop debería mejorar la **eficiencia de las campañas y la conversión del funnel**, para posteriormente reasignar mayor presupuesto hacia las campañas que generan un mejor **ROAS, menor CAC y mayor valor del cliente**.

---

## Recomendaciones

1. **Reasignar presupuesto hacia campañas con mayor ROAS**
   - Reducir la inversión en campañas con bajo retorno.
   - Aumentar la inversión en campañas con mayor ROAS y valor del cliente.

2. **Establecer objetivos de ROAS y CAC a nivel de campaña**
   - Clasificar las campañas como:
     - **Escalar**
     - **Optimizar**
     - **Reducir**
     - **Pausar**

3. **Mejorar la conversión del funnel antes de invertir en más tráfico**
   - Optimizar landing pages, formularios de leads, pruebas gratuitas, lead nurturing y seguimiento comercial.

4. **Evaluar el CAC junto con el CLV**
   - Una campaña con un CAC más alto puede seguir siendo rentable si genera clientes con un mayor valor de vida.

5. **Optimizar para clientes e ingresos, no solamente para clics**
   - El rendimiento de marketing debe evaluarse a lo largo de todo el recorrido:

**Inversión → Leads → Clientes → Suscripciones → Ingresos → CLV**

---

## Preguntas de Negocio y Respuestas

| Pregunta de Negocio | Respuesta / KPI |
| --- | --- |
| ¿Cuánto se invirtió en publicidad? | **$1.11M** |
| ¿Cuántos ingresos atribuidos se generaron? | **$373.5K** |
| ¿Cuál fue el ROAS general? | **0.34x** |
| ¿Cuál fue el CAC? | **$116.08** |
| ¿Cuántas sesiones web se generaron? | **740,283** |
| ¿Cuántos leads se generaron? | **93,276** |
| ¿Cuántos clientes se adquirieron? | **9,592** |
| ¿Cuál fue la conversión de Lead a Cliente? | **~10.3%** |
| ¿Cuál fue la conversión de Sesión a Cliente? | **~1.3%** |
| ¿Cuántas suscripciones se generaron? | **9,592** |
| ¿Cuántas inscripciones a cursos se generaron? | **16,628** |

El **ROAS, CAC, ingresos y valor del cliente por campaña**, junto con **MRR, ARR, CLV, rendimiento del funnel y engagement de los cursos**, son analizados en los dashboards de Tableau.

---

# Dashboards en Tableau

## 1. Rendimiento de Campañas

Este dashboard analiza la eficiencia de la inversión publicitaria y permite comparar el desempeño de las campañas en términos de gasto, ingresos, ROAS y adquisición de clientes.

### KPIs y análisis

- Inversión publicitaria
- Ingresos atribuidos
- ROAS
- CAC
- Ingresos por campaña
- ROAS por campaña
- Inversión vs. ingresos
- Rendimiento a lo largo del tiempo

![Dashboard de Rendimiento de Campañas](docs/dashboards/campaign_performance.jpg)

---

## 2. Funnel de Marketing

Este dashboard analiza el recorrido completo de los usuarios desde la visita al sitio web hasta la adquisición como clientes.

### Funnel

**Sesiones → Leads → MQLs → SQLs → Clientes**

### KPIs y análisis

- Sesiones
- Leads
- MQLs
- SQLs
- Clientes
- Tasas de conversión
- Abandono entre etapas
- Conversión de Lead a Cliente
- Conversión de Sesión a Cliente
- Tendencias de conversión

![Dashboard del Funnel de Marketing](docs/dashboards/marketing_funnel.jpg)

---

## 3. Suscripciones y Valor del Cliente

Este dashboard conecta la adquisición de clientes con el valor económico generado posteriormente por las suscripciones.

### KPIs y análisis

- Suscripciones
- Suscripciones activas
- MRR
- ARR
- CLV
- MRR por plan
- Clientes por campaña
- Valor del cliente por campaña
- Ingresos generados por clientes

![Dashboard de Suscripciones y Valor del Cliente](docs/dashboards/subscription_&_customer_value.jpg)

---

## 4. Rendimiento de Cursos

Este dashboard analiza cómo los clientes interactúan con los cursos después de adquirir una suscripción.

### KPIs y análisis

- Inscripciones
- Finalizaciones
- Tasa de finalización
- Inscripciones por curso
- Rendimiento por categoría
- Rendimiento de cursos a lo largo del tiempo

![Dashboard de Rendimiento de Cursos](docs/dashboards/course_performance.jpg)

---

# Arquitectura de Datos

```text
Google Ads ──────┐
Meta Ads ────────┤
GA4 ─────────────┤
HubSpot ─────────┼────► Python ETL
Stripe ──────────┤           │
Datos de Cursos ─┘           ▼
                           AWS S3
                          Raw JSON
                             │
                             ▼
                          Snowflake
                             │
                             ▼
                             dbt
                             │
                Staging → Intermediate → Marts
                             │
                             ▼
                       Analítica / KPIs
                             │
                             ▼
                          Tableau
                             │
                             ▼
                    Decisiones de Negocio
```

**Apache Airflow** orquesta y monitorea el pipeline desde la ingesta de datos hasta las transformaciones y pruebas de calidad de datos.

### Flujo del Pipeline

```text
Fuentes de Datos
      │
      ▼
Python ETL
      │
      ▼
AWS S3
      │
      ▼
Snowflake
      │
      ▼
dbt
      │
      ├── Staging
      │
      ├── Intermediate
      │
      ├── Marts
      │
      └── Analytics
      │
      ▼
Tableau
      │
      ▼
Insights de Negocio
```

---

# Modelo de Datos

El modelo analítico utiliza una arquitectura dimensional con tablas de hechos y dimensiones para facilitar el análisis en Tableau.

## Dimensiones

`dim_date`

`dim_customer`

`dim_campaign`

`dim_channel`

`dim_course`

`dim_subscription_plan`

`dim_device`

## Tablas de Hechos

`fact_marketing_spend`

`fact_website_sessions`

`fact_leads`

`fact_subscriptions`

`fact_revenue`

`fact_course_enrollments`

## Modelos Analíticos

Los modelos analíticos agregan y preparan la información necesaria para los dashboards y KPIs.

`kpi_campaign_performance`

`kpi_funnel_performance`

`kpi_subscription_performance`

`kpi_customer_value`

`kpi_course_performance`

---

# Transformaciones con dbt

La capa de transformación está organizada utilizando tres niveles principales.

```text
Raw Data
   │
   ▼
Staging
   │
   ▼
Intermediate
   │
   ▼
Marts
   │
   ▼
Analytics / KPIs
```

### Staging

Estandarización inicial de los datos provenientes de cada fuente.

Ejemplos:

```text
stg_google_ads
stg_meta_ads
stg_ga4_sessions
stg_hubspot_contacts
stg_stripe_payments
stg_stripe_subscriptions
stg_course_enrollments
```

### Intermediate

Transformaciones de negocio y combinación de fuentes.

Ejemplos:

```text
int_marketing_performance
int_customer_revenue
int_subscription_metrics
```

### Marts

Modelo dimensional utilizado para análisis.

```text
Dimensions
Facts
```

### Analytics

Modelos finales diseñados para responder preguntas de negocio y alimentar Tableau.

```text
kpi_campaign_performance
kpi_funnel_performance
kpi_subscription_performance
kpi_customer_value
kpi_course_performance
```

---

# Calidad de Datos

Las pruebas automatizadas de **dbt** validan la calidad y consistencia de los datos.

Las principales validaciones incluyen:

- Valores nulos
- Claves únicas
- Integridad referencial
- Relaciones entre modelos
- Valores aceptados

Estas pruebas permiten detectar problemas antes de que los datos lleguen a los dashboards.

---

# Stack Tecnológico

| Área | Tecnologías |
| --- | --- |
| **Análisis y BI** | SQL, Tableau |
| **Data Warehouse** | Snowflake |
| **Transformación** | dbt |
| **Ingesta** | Python, REST APIs |
| **Almacenamiento Cloud** | AWS S3 |
| **Orquestación** | Apache Airflow |
| **Control de Versiones** | Git, GitHub |

---

# Estructura del Repositorio

```text
LearnLoop/
│
├── airflow/
│   └── dags/
│       └── learnloop_pipeline_dag.py
│
├── docs/
│   └── dashboards/
│       ├── campaign_performance.jpg
│       ├── course_performance.jpg
│       ├── marketing_funnel.jpg
│       └── subscription_&_customer_value.jpg
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
│   ├── analyses/
│   ├── macros/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   ├── marts/
│   │   └── analytics/
│   ├── seeds/
│   ├── snapshots/
│   ├── tests/
│   ├── .gitignore
│   ├── README.md
│   └── dbt_project.yml
│
├── synthetic_data/
│   └── generate_data.py
│
├── .gitignore
├── README.md
├── README_ES.md
├── dashboards_2.twb
└── requirements.txt
```

---

# Habilidades Demostradas

### Analítica

**SQL · Tableau · Marketing Analytics · Funnel Analysis**

### KPIs de Marketing

**ROAS · CAC · CLV · Conversion Rate**

### Métricas SaaS

**MRR · ARR · Suscripciones · Customer Value**

### Data Engineering

**Python · REST APIs · AWS S3 · Snowflake · dbt · Apache Airflow**

### Modelado de Datos

**Star Schema · Fact Tables · Dimension Tables · Dimensional Modeling**

### Data Quality

**dbt Tests · Referential Integrity · Null Validation · Unique Keys · Accepted Values**

### Desarrollo

**Git · GitHub · Version Control**

---

# Resultado del Proyecto

LearnLoop transforma datos fragmentados provenientes de publicidad, comportamiento web, CRM, suscripciones e ingresos en una **visión analítica unificada del recorrido del cliente**.

La plataforma permite responder la pregunta principal del negocio:

> **¿Qué inversiones de marketing adquieren clientes de manera eficiente y generan el mayor valor para el negocio?**

El proyecto demuestra un flujo completo de analítica:

**Problema de Negocio → Ingesta de Datos → Data Warehouse → Transformación → Modelado → SQL → KPIs → Insights → Recomendaciones → Tableau Dashboards**

---

# Autor

**Juan David Guerrero**

**Data Analyst**

SQL · Tableau · Python · Snowflake · dbt · Marketing Analytics
