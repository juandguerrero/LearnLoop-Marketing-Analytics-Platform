from datetime import datetime, timedelta

from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator


PROJECT_ROOT = (
    "/mnt/c/Users/juang/OneDrive/Documentos/Portfolio/"
    "LearnLoop"
)

DBT_PROJECT_DIR = f"{PROJECT_ROOT}/learnloop_dbt"
SNOWFLAKE_LOAD_SCRIPT = (
    f"{PROJECT_ROOT}/snowflake/load_s3_to_snowflake.py"
)


default_args = {
    "owner": "juan",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}


with DAG(
    dag_id="learnloop_pipeline",
    description="LearnLoop Marketing Analytics orchestration pipeline",
    start_date=datetime(2026, 8, 1),
    schedule=None,
    catchup=False,
    default_args=default_args,
    tags=["learnloop", "marketing", "analytics"],
) as dag:

    # 1. Validate raw JSON files and upload them to AWS S3
    run_ingestion = BashOperator(
        task_id="run_ingestion",
        bash_command=f"""
            cd "{PROJECT_ROOT}" &&
            python -m ingestion.run_pipeline
        """,
    )

    # 2. Load raw JSON files from AWS S3 into Snowflake RAW tables
    load_s3_to_snowflake = BashOperator(
        task_id="load_s3_to_snowflake",
        bash_command=f"""
            cd "{PROJECT_ROOT}" &&
            python "{SNOWFLAKE_LOAD_SCRIPT}"
        """,
    )

    # 3. Run dbt transformations, tests, and models
    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=f"""
            cd "{DBT_PROJECT_DIR}" &&
            dbt build
        """,
    )

    # 4. Generate dbt documentation
    generate_dbt_docs = BashOperator(
        task_id="generate_dbt_docs",
        bash_command=f"""
            cd "{DBT_PROJECT_DIR}" &&
            dbt docs generate
        """,
    )

    (
        run_ingestion
        >> load_s3_to_snowflake
        >> dbt_build
        >> generate_dbt_docs
    )
