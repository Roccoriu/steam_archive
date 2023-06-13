import typer

from sqlalchemy import text

from config.db import get_db_session

from .commands.init import init_cli

db_commands = typer.Typer()

db_commands.add_typer(init_cli, name="init")


@db_commands.command()
def seed() -> None:
    print("seed the db with some data from the data folder")


@db_commands.command()
def test() -> None:
    session = get_db_session()

    res = session.execute(text("SELECT current_user")).scalars().all()

    print(session.execute(text("select * from hw_survey")).scalars().all())
    print(res)
