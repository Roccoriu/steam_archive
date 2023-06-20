import re
import json

from pprint import pprint
from pydantic import BaseModel, Field

import typer

from config.env import BASE_DIR

seed_cli = typer.Typer()

field_values = [
    "OS Version",
    "Windows Version",
    "date_code",
    "Video Card Description",
    "System RAM",
    "RAM",
    "Processor Count",
    "Physical CPUs",
]

cleaned_data: list[dict] = []


def get_os(os_version: list[str]) -> str:
    if "Mint" in os_version:
        return f"{os_version[0]} {os_version[1]}"

    if "NAME=" in os_version[0]:
        return os_version[0].split("=")[1].strip('"')

    return os_version[0].strip('"')


def get_numerical_string(vals: list[str]) -> str:
    return next(
        (
            s
            for s in vals
            if (s and s[0].isdigit() or s == "XP" or s == "Vista")
            and s != "64"
            and s != "32"
        ),
        "N/A",
    )


def clean_os_version(
    os_version: list[str],
    percentage: float,
) -> dict[str, str | float]:
    cleaned: dict[str, str | float] = {}

    cleaned["os"] = get_os(os_version)
    cleaned["version"] = get_numerical_string(os_version)
    cleaned["architecture"] = "64" if "64" in os_version else "32"
    cleaned["percentage"] = percentage

    return cleaned


def clean_windows_version(
    windows_version: str,
    percentage: float,
) -> dict[str, str | float]:
    pattern = (
        r"(\bXP|\b98|\b95|\b2000|\b2003|\bMe|\b7|\bVista)\s?(SP \d|\(Build \d+\))?"
    )
    cleaned: dict[str, str | float] = {}

    cleaned["os"] = "Windows"
    cleaned["version"] = (
        os.group() if (os := re.search(pattern, windows_version)) else "N/A"
    )
    cleaned["architecture"] = "64" if "64" in windows_version else "32"
    cleaned["percentage"] = percentage

    return cleaned


@seed_cli.command()
def data(input_file: str = f"{BASE_DIR}/data/survey_data_combined.json") -> None:
    with open(input_file, "r") as f:
        data_file = json.load(f)

    for i in data_file:
        data = {}

        if os := i.get("OS Version"):
            data["os"] = map(
                lambda x, y: clean_os_version(x.split(" "), y),
                os.keys(),
                os.values(),
            )

        if os := i.get("Windows Version"):
            data["os"] = map(
                lambda x, y: clean_windows_version(x, y),
                os.keys(),
                os.values(),
            )

        # print(data.get("os"))
