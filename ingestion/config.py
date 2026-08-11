from pathlib import Path
import os

from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")


RAW_DATA_DIR = BASE_DIR / "synthetic_data" / "raw"
LOG_DIR = BASE_DIR / "logs"

AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME")


def validate_configuration() -> None:
    required_variables = {
        "AWS_ACCESS_KEY_ID": AWS_ACCESS_KEY_ID,
        "AWS_SECRET_ACCESS_KEY": AWS_SECRET_ACCESS_KEY,
        "S3_BUCKET_NAME": S3_BUCKET_NAME,
    }

    missing_variables = [
        variable_name
        for variable_name, value in required_variables.items()
        if not value
    ]

    if missing_variables:
        missing = ", ".join(missing_variables)

        raise ValueError(
            f"Missing required environment variables: {missing}"
        )