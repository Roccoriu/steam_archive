import json
from datetime import datetime

import typer

import util
from config.db import get_db_session
from config.env import BASE_DIR


seed_cli = typer.Typer()


@seed_cli.command()
def data(input_file: str = f"{BASE_DIR}/data/survey_data_combined.json") -> None:
    with open(input_file, "r") as f:
        data_file = json.load(f)

    db = get_db_session()

    for i in data_file:
        data = {}

        survey_date = datetime.strptime(i.get("date_code", "200001"), "%Y%m")

        data["date"] = datetime.strftime(survey_date, "%Y-%m-%d")

        if vga := i.get("Video Card Description"):
            data["vga"] = map(util.clean_vga, vga.keys(), vga.values())

        if os := i.get("OS Version"):
            data["os"] = map(util.clean_os_version, os.keys(), os.values())

        if os := i.get("Windows Version"):
            data["os"] = map(util.clean_windows_version, os.keys(), os.values())

        if ram := i.get("RAM"):
            data["ram"] = map(util.clean_ram, ram.keys(), ram.values())

        if ram := i.get("System RAM"):
            data["ram"] = map(util.clean_ram, ram.keys(), ram.values())

        if cores := i.get("Processor Count"):
            data["cores"] = map(util.clean_cores, cores.keys(), cores.values())

        if cores := i.get("Physical CPUs"):
            data["cores"] = map(util.clean_cores, cores.keys(), cores.values())

        if data.get("vga") and data.get("os") and data.get("ram") and data.get("cores"):
            util.exec_sql(
                db,
                """
                select steam.upsert_hw_survey(
                    :date,
                    :ram_configs,
                    :os_versions,
                    :cpu_counts,
                    :gpu_configs
                )
                """,
                {
                    "date": data["date"],
                    "ram_configs": util.convert_to_pg_array(data["ram"]),
                    "os_versions": util.convert_to_pg_array(data["os"]),
                    "cpu_counts": util.convert_to_pg_array(data["cores"]),
                    "gpu_configs": util.convert_to_pg_array(data["vga"]),
                },
            )
