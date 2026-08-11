import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from uuid import uuid4

import boto3

from ingestion.config import (
    AWS_ACCESS_KEY_ID,
    AWS_REGION,
    AWS_SECRET_ACCESS_KEY,
    S3_BUCKET_NAME,
)


def create_s3_client():
    return boto3.client(
        "s3",
        region_name=AWS_REGION,
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )


def add_ingestion_metadata(
    payload: dict[str, Any],
    source_system: str,
    source_file: str,
) -> dict[str, Any]:
    ingestion_timestamp = datetime.now(
        timezone.utc
    ).isoformat()

    batch_id = str(uuid4())

    payload["metadata"] = {
        "source_system": source_system,
        "source_file": source_file,
        "batch_id": batch_id,
        "ingestion_timestamp": ingestion_timestamp,
    }

    return payload


def build_s3_key(
    source_system: str,
    filename: str,
) -> str:
    now = datetime.now(timezone.utc)

    return (
        f"raw/{source_system}/"
        f"year={now.year}/"
        f"month={now.month:02d}/"
        f"day={now.day:02d}/"
        f"{filename}"
    )


def upload_json_to_s3(
    payload: dict[str, Any],
    source_system: str,
    source_file: Path,
) -> str:
    s3_client = create_s3_client()

    s3_key = build_s3_key(
        source_system=source_system,
        filename=source_file.name,
    )

    json_body = json.dumps(
        payload,
        indent=2,
        default=str,
    ).encode("utf-8")

    s3_client.put_object(
        Bucket=S3_BUCKET_NAME,
        Key=s3_key,
        Body=json_body,
        ContentType="application/json",
    )

    return s3_key