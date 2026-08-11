from datetime import datetime, timedelta

from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator


PROJECT_ROOT = (
    "/mnt/c/Users/juang/OneDrive/Documentos/Portfolio/"
    "LearnLoop"
)

DBT_PROJECT_DIR = f"{PROJECT_ROOT}/learnloop_dbt"


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

    run_ingestion = BashOperator(
        task_id="run_ingestion",
        bash_command=f"""
            cd "{PROJECT_ROOT}" &&
            python -m ingestion.run_pipeline
        """,
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=f"""
            cd "{DBT_PROJECT_DIR}" &&
            dbt build
        """,
    )

    generate_dbt_docs = BashOperator(
        task_id="generate_dbt_docs",
        bash_command=f"""
            cd "{DBT_PROJECT_DIR}" &&
            dbt docs generate
        """,
    )

    run_ingestion >> dbt_build >> generate_dbt_docs