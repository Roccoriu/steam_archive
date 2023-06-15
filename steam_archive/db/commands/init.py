from sqlalchemy import text
import typer

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
        session.execute(text(stmt.strip()))
        session.commit()


@init_cli.command()
def routines(
    base_path: str = f"{BASE_DIR}/sql/routines",
    file_names: str = config.DEFAULT_ROUTINE_FILES,
) -> None:
    session = get_db_session()

    file_names = file_names.split(",")

    for file_name in file_names:
        with open(f"{base_path}/{file_name}", "r") as f:
            stmt = f.read()

        session.execute(text(stmt.strip()))
        session.commit()


@init_cli.command()
def views(
    base_path: str = f"{BASE_DIR}/sql/views",
    file_names: str = config.DEFAULT_VIEW_FILES,
) -> None:
    session = get_db_session()

    pass


@init_cli.command()
def all() -> None:
    schema()
    routines()
    views()
