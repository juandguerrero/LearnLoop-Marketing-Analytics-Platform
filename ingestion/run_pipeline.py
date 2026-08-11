import sys
from pathlib import Path

from ingestion.config import (
    RAW_DATA_DIR,
    S3_BUCKET_NAME,
    validate_configuration,
)
from ingestion.logger import get_logger
from ingestion.s3_uploader import (
    add_ingestion_metadata,
    upload_json_to_s3,
)
from ingestion.validator import (
    JSONValidationError,
    read_and_validate_json,
)


logger = get_logger("learnloop_ingestion")


SOURCE_SYSTEMS = (
    "ga4",
    "google_ads",
    "hubspot",
    "learnloop",
    "meta_ads",
    "stripe",
)


def discover_json_files(
    source_system: str,
) -> list[Path]:
    """
    Return all JSON files found inside a source-system folder.

    Example:
        synthetic_data/raw/ga4/sessions_part_0001.json
        synthetic_data/raw/ga4/sessions_part_0002.json
    """
    source_directory = RAW_DATA_DIR / source_system

    if not source_directory.exists():
        raise FileNotFoundError(
            f"Source directory does not exist: {source_directory}"
        )

    if not source_directory.is_dir():
        raise NotADirectoryError(
            f"Source path is not a directory: {source_directory}"
        )

    json_files = sorted(
        filepath
        for filepath in source_directory.glob("*.json")
        if filepath.is_file()
    )

    return json_files


def process_file(
    source_system: str,
    filepath: Path,
) -> int:
    """
    Validate one JSON file, add ingestion metadata,
    upload it to S3, and return its record count.
    """
    logger.info("Validating file: %s", filepath)

    payload = read_and_validate_json(filepath)

    payload = add_ingestion_metadata(
        payload=payload,
        source_system=source_system,
        source_file=filepath.name,
    )

    s3_key = upload_json_to_s3(
        payload=payload,
        source_system=source_system,
        source_file=filepath,
    )

    record_count = len(payload["data"])

    logger.info(
        "Uploaded %s records to s3://%s/%s",
        record_count,
        S3_BUCKET_NAME,
        s3_key,
    )

    return record_count


def run_pipeline() -> None:
    validate_configuration()

    total_files = 0
    successful_files = 0
    failed_files = 0
    total_records = 0

    logger.info("Starting LearnLoop ingestion pipeline")
    logger.info("Raw data directory: %s", RAW_DATA_DIR)

    for source_system in SOURCE_SYSTEMS:
        logger.info(
            "Discovering JSON files for source system: %s",
            source_system,
        )

        try:
            json_files = discover_json_files(source_system)

        except (
            FileNotFoundError,
            NotADirectoryError,
            PermissionError,
        ) as error:
            failed_files += 1

            logger.exception(
                "Failed to discover files for %s: %s",
                source_system,
                error,
            )

            continue

        if not json_files:
            logger.warning(
                "No JSON files found for source system: %s",
                source_system,
            )
            continue

        logger.info(
            "Discovered %s JSON file(s) for %s",
            len(json_files),
            source_system,
        )

        for filepath in json_files:
            total_files += 1

            try:
                record_count = process_file(
                    source_system=source_system,
                    filepath=filepath,
                )

                successful_files += 1
                total_records += record_count

            except (
                JSONValidationError,
                FileNotFoundError,
                PermissionError,
                ValueError,
                RuntimeError,
            ) as error:
                failed_files += 1

                logger.exception(
                    "Failed to process %s: %s",
                    filepath,
                    error,
                )

            except Exception as error:
                failed_files += 1

                logger.exception(
                    "Unexpected error processing %s: %s",
                    filepath,
                    error,
                )

    logger.info(
        (
            "Pipeline completed | total_files=%s | "
            "successful_files=%s | failed_files=%s | "
            "total_records=%s"
        ),
        total_files,
        successful_files,
        failed_files,
        total_records,
    )

    if total_files == 0:
        raise RuntimeError(
            "No JSON files were found in any configured source directory."
        )

    if failed_files > 0:
        raise RuntimeError(
            f"Ingestion pipeline finished with "
            f"{failed_files} failed file(s)."
        )


if __name__ == "__main__":
    try:
        run_pipeline()

    except Exception as error:
        logger.exception("Pipeline failed: %s", error)
        sys.exit(1)

    sys.exit(0)