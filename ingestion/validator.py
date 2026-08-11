import json
from pathlib import Path
from typing import Any


class JSONValidationError(Exception):
    """Raised when a source JSON file is invalid."""


def read_and_validate_json(filepath: Path) -> dict[str, Any]:
    if not filepath.exists():
        raise JSONValidationError(
            f"File does not exist: {filepath}"
        )

    if filepath.stat().st_size == 0:
        raise JSONValidationError(
            f"File is empty: {filepath}"
        )

    try:
        with filepath.open("r", encoding="utf-8") as file:
            payload = json.load(file)

    except json.JSONDecodeError as error:
        raise JSONValidationError(
            f"Invalid JSON in {filepath}: {error}"
        ) from error

    if not isinstance(payload, dict):
        raise JSONValidationError(
            f"Expected a JSON object in {filepath}"
        )

    if "data" not in payload:
        raise JSONValidationError(
            f"Missing 'data' property in {filepath}"
        )

    if not isinstance(payload["data"], list):
        raise JSONValidationError(
            f"'data' must be a list in {filepath}"
        )

    if len(payload["data"]) == 0:
        raise JSONValidationError(
            f"No records found in {filepath}"
        )

    return payload