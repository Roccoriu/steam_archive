import typer

from sqlalchemy import text

from config.db import get_db_session
from config.env import BASE_DIR


db_commands = typer.Typer()


@db_commands.command()
def init(file: str = f"{BASE_DIR}/sql/schema.sql") -> None:
    session = get_db_session()

    with open(file, "r") as f:
        stmts = f.read().split(";")

    for stmt in stmts:
        session.execute(text(stmt.strip()))
        session.commit()


@db_commands.command()
def seed() -> None:
    print("seed the db with some data from the data folder")


@db_commands.command()
def test() -> None:
    session = get_db_session()

    res = session.execute(text("SELECT current_user")).scalars().all()

    print(session.execute(text("select * from hw_survey")).scalars().all())
    print(res)
