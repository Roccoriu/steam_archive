import typer
from loguru import logger

import util
from config.env import BASE_DIR
from config.db import get_db_session
from config.env import config

init_cli = typer.Typer()


@init_cli.command()
def schema(
    schema_file: str = f"{BASE_DIR}/sql/schema.sql",
    view_file: str = f"{BASE_DIR}/sql/views.sql",
) -> None:
    """Create the schema for the database using the given sql file"""
    session = get_db_session()

    with open(schema_file, "r") as f:
        stmts = f.read().split(";")

    with open(view_file, "r") as f:
        stmts += f.read().split(";")

    for stmt in stmts:
        util.exec_sql(session, stmt)

    logger.info(f"Successfully executed {len(stmts)} statements from {schema_file}")


@init_cli.command()
def routines(
    base_path: str = f"{BASE_DIR}/sql/routines",
    names: str = str(config.DEFAULT_ROUTINE_FILES),
) -> None:
    """Create the routines/functions for the database using the given sql files"""
    session = get_db_session()

    file_names = names.split(",")

    for file_name in file_names:
        with open(f"{base_path}/{file_name}", "r") as f:
            stmt = f.read()

        util.exec_sql(session, stmt)
    logger.info(f"Successfully c {len(file_names)} functions located in {base_path}")


@init_cli.command()
def all() -> None:
    schema()
    routines()
