import typer

from sqlalchemy import text

from config.db import get_db_session

from .commands import init_cli, seed_cli

db_commands = typer.Typer()

db_commands.add_typer(init_cli, name="init")
db_commands.add_typer(seed_cli, name="seed")


@db_commands.command()
def test() -> None:
    session = get_db_session()

    res = session.execute(text("SELECT current_user")).scalars().all()

    print(session.execute(text("select * from hw_survey")).scalars().all())
    print(res)
