import os
import snowflake.connector


LOADS = {
    "GA4_SESSIONS": "ga4/",
    "GOOGLE_ADS_CAMPAIGN_PERFORMANCE": "google_ads/",
    "HUBSPOT_CONTACTS": "hubspot/",
    "META_ADS_CAMPAIGN_PERFORMANCE": "meta_ads/",
    "STRIPE_PAYMENTS": "stripe/payments/",
    "STRIPE_SUBSCRIPTIONS": "stripe/subscriptions/",
    "LEARNLOOP_COURSE_ENROLLMENTS": "learnloop/",
}


def get_connection():
    return snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
        database="LEARNLOOP_ANALYTICS",
        schema="RAW",
    )


def load_table(cursor, table_name, path):
    sql = f"""
    COPY INTO {table_name}
    (
        RAW_DATA,
        SOURCE_FILE,
        LOADED_AT
    )
    FROM (
        SELECT
            $1,
            METADATA$FILENAME,
            CURRENT_TIMESTAMP()
        FROM @LEARNLOOP_S3_STAGE/{path}
    )
    FILE_FORMAT = (FORMAT_NAME = JSON_FORMAT)
    ON_ERROR = 'ABORT_STATEMENT';
    """

    cursor.execute(sql)


def main():
    conn = get_connection()

    try:
        cursor = conn.cursor()

        for table_name, s3_path in LOADS.items():
            print(f"Loading {s3_path} into {table_name}")
            load_table(cursor, table_name, s3_path)

    finally:
        conn.close()


if __name__ == "__main__":
    main()
