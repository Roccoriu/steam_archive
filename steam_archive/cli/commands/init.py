from loguru import logger
import typer

import util
from config.env import BASE_DIR
from config.db import get_db_session
from config.env import config

init_cli = typer.Typer()


@init_cli.command()
def schema(file: str = f"{BASE_DIR}/sql/schema.sql") -> None:
    session = get_db_session()

    with open(file, "r") as f:
        stmts = f.read().split(";")

    for stmt in stmts:
        util.exec_sql(session, stmt)

    logger.info(f"Successfully executed {len(stmts)} statements from {file}")


@init_cli.command()
def routines(
    base_path: str = f"{BASE_DIR}/sql/routines",
    names: str = str(config.DEFAULT_ROUTINE_FILES),
) -> None:
    session = get_db_session()

    file_names = names.split(",")

    for file_name in file_names:
        with open(f"{base_path}/{file_name}", "r") as f:
            stmt = f.read()

        util.exec_sql(session, stmt)
    logger.info(f"Successfully c {len(file_names)} functions located in {base_path}")


@init_cli.command()
def views(
    base_path: str = f"{BASE_DIR}/sql/views",
    names: str = str(config.DEFAULT_VIEW_FILES),
) -> None:
    session = get_db_session()

    pass


@init_cli.command()
def all() -> None:
    schema()
    routines()
    views()
