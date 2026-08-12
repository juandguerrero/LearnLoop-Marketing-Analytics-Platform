# Plataforma de Analítica de Marketing LearnLoop

**Analítica de Marketing End-to-End | SQL · Tableau · Snowflake · dbt · Python · Airflow · AWS S3**

## Descripción General del Proyecto

**LearnLoop** es una empresa SaaS EdTech simulada basada en suscripciones que vende cursos en línea y capacitación corporativa.

Sus datos de marketing, sitio web, CRM, suscripciones e ingresos están almacenados en sistemas separados, lo que dificulta comprender qué campañas realmente generan clientes e ingresos.

Construí una **plataforma de analítica de marketing end-to-end** que conecta:

**Inversión Publicitaria → Sesiones → Leads → MQLs → SQLs → Clientes → Suscripciones → Ingresos**

La solución utiliza **Python, AWS S3, Snowflake, dbt, SQL, Airflow y Tableau** para centralizar los datos, calcular KPIs de negocio y entregar dashboards orientados a la toma de decisiones.

> **Objetivo:** ayudar a LearnLoop a comprender dónde la inversión en marketing está generando valor y dónde se está desperdiciando presupuesto.

---

## Hallazgos Clave

- **$1.11M de inversión publicitaria generaron $373.5K en ingresos atribuidos → 0.34x ROAS**
- **CAC = $116.08 por cliente**
- **740,283 sesiones → 93,276 leads → 9,592 clientes**
- **Conversión de Lead a Cliente ≈ 10.3%**
- **Solo ~1.3% de las sesiones del sitio web se convirtieron en clientes**
- **Se generaron 9,592 suscripciones y 16,628 inscripciones a cursos**

### Conclusión Principal

La mayor oportunidad no consiste simplemente en generar más tráfico.

LearnLoop debería mejorar la **eficiencia de las campañas y la conversión del funnel**, y luego destinar más presupuesto hacia las campañas que generen un mejor **ROAS, menor CAC y mayor valor del cliente**.

---

## Recomendaciones

1. **Reasignar presupuesto hacia campañas con mayor ROAS**

   - Reducir la inversión en campañas con un retorno de ingresos débil.
   - Aumentar la inversión en campañas con mayor ROAS y valor del cliente.

2. **Establecer objetivos de ROAS y CAC a nivel de campaña**

   - Clasificar las campañas como:
     - **Escalar**
     - **Optimizar**
     - **Reducir**
     - **Pausar**

3. **Mejorar la conversión del funnel antes de comprar más tráfico**

   - Optimizar landing pages, formularios de leads, pruebas gratuitas, nutrición de leads y seguimiento de ventas.

4. **Evaluar el CAC junto con el CLV**

   - Una campaña con un CAC más alto puede seguir siendo valiosa si genera clientes con un mayor valor de vida.

5. **Optimizar para clientes e ingresos, no para clics**

   - El desempeño de marketing debería medirse a lo largo de todo el recorrido:

**Inversión → Leads → Clientes → Suscripciones → Ingresos → CLV**

---

## Preguntas y Respuestas de Negocio

| Pregunta de Negocio | Respuesta / KPI |
| ------------------------------------------- | ------------ |
| ¿Cuánto se invirtió en publicidad? | **$1.11M** |
| ¿Cuántos ingresos atribuidos se generaron? | **$373.5K** |
| ¿Cuál fue el ROAS general? | **0.34x** |
| ¿Cuál fue el CAC? | **$116.08** |
| ¿Cuántas sesiones del sitio web se generaron? | **740,283** |
| ¿Cuántos leads se generaron? | **93,276** |
| ¿Cuántos clientes se adquirieron? | **9,592** |
| ¿Cuál fue la conversión de Lead a Cliente? | **~10.3%** |
| ¿Cuál fue la conversión de Sesión a Cliente? | **~1.3%** |
| ¿Cuántas suscripciones se generaron? | **9,592** |
| ¿Cuántas inscripciones a cursos se generaron? | **16,628** |

El **ROAS, CAC, ingresos y valor del cliente** a nivel de campaña, junto con **MRR, ARR, CLV, desempeño del funnel y participación en cursos**, son analizados en los dashboards de Tableau.

---

## Dashboards de Tableau

### 1. Desempeño de Campañas

**Inversión Publicitaria · Ingresos · ROAS · CAC · Ingresos por Campaña · ROAS por Campaña · Inversión vs. Ingresos · Desempeño a lo Largo del Tiempo**

![Dashboard de Desempeño de Campañas](docs/dashboards/campaign_performance.jpg)

### 2. Funnel de Marketing

**Sesiones → Leads → MQLs → SQLs → Clientes · Tasas de Conversión · Abandono del Funnel · Tendencias de Conversión**

![Dashboard del Funnel de Marketing](docs/dashboards/marketing_funnel.jpg)

### 3. Suscripciones y Valor del Cliente

**Suscripciones · Suscripciones Activas · MRR · ARR · CLV · MRR por Plan · Valor del Cliente por Campaña**

![Dashboard de Suscripciones y Valor del Cliente](docs/dashboards/subscription_customer_value.jpg)

### 4. Desempeño de Cursos

**Inscripciones · Finalizaciones · Tasa de Finalización · Inscripciones por Curso · Categoría · Desempeño a lo Largo del Tiempo**

![Dashboard de Desempeño de Cursos](docs/dashboards/course_performance.jpg)

---

## Arquitectura de Datos

```text
Google Ads ──────┐
Meta Ads ────────┤
GA4 ─────────────┤
HubSpot ─────────┼────► ETL con Python
Stripe ──────────┤           │
Datos de Cursos ─┘           ▼
                           AWS S3
                          JSON Raw
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

**Apache Airflow** orquesta y monitorea el pipeline desde la ingesta de datos hasta la transformación y las pruebas de calidad de datos.

---

## Modelo de Datos

### Dimensiones

`dim_date` · `dim_customer` · `dim_campaign` · `dim_channel` · `dim_course` · `dim_subscription_plan` · `dim_device`

### Tablas de Hechos

`fact_marketing_spend` · `fact_website_sessions` · `fact_leads` · `fact_subscriptions` · `fact_revenue` · `fact_course_enrollments`

### Modelos Analíticos

`kpi_campaign_performance` · `kpi_funnel_performance` · `kpi_subscription_performance` · `kpi_customer_value` · `kpi_course_performance`

---

## Calidad de Datos

Las **pruebas automatizadas de dbt** validan:

- Valores nulos
- Claves únicas
- Integridad referencial
- Relaciones entre modelos
- Valores aceptados

---

## Stack Tecnológico

| Área | Tecnologías |
| ------------------- | ----------------- |
| **Análisis & BI** | SQL, Tableau |
| **Data Warehouse** | Snowflake |
| **Transformación** | dbt |
| **Ingesta** | Python, REST APIs |
| **Almacenamiento en la Nube** | AWS S3 |
| **Orquestación** | Apache Airflow |
| **Control de Versiones** | Git, GitHub |

---

## Estructura del Repositorio

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
│       └── subscription_customer_value.jpg
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
├── learnloop_tableau_dashboards.twb
└── requirements.txt
```

---

## Habilidades Demostradas

**SQL · Tableau · Analítica de Marketing · Análisis de Funnel · ROAS · CAC · CLV · MRR · ARR · Snowflake · dbt · Python · AWS S3 · Airflow · Modelado Dimensional · Calidad de Datos**

---

## Resultado del Proyecto

LearnLoop transforma datos fragmentados de marketing, clientes e ingresos en una **vista analítica unificada del recorrido del cliente**.

> **¿Qué inversiones de marketing adquieren clientes de manera eficiente y generan el mayor valor para el negocio?**

**Problema de Negocio → Integración de Datos → Análisis SQL → KPIs → Insights → Recomendaciones → Dashboards de Tableau**

---

## Autor

**Juan David Guerrero**  
**Analista de Datos**

SQL · Tableau · Python · Snowflake · dbt · Analítica de Marketing
