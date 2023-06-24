import subprocess
from typing_extensions import Annotated

import typer
from loguru import logger

from sqlalchemy import text

from config import env
from config.db import get_db_session

from .commands import init_cli, data_cli

cli = typer.Typer()

cli.add_typer(
    init_cli,
    name="init",
    help="Command group for initializing the database schema, routines, and views",
)
cli.add_typer(
    data_cli,
    name="data",
    help="Command group for seeding and dumping the database",
)


@cli.command()
def create(
    host: Annotated[str, typer.Option(..., "--host", "-H")],
    dbname: Annotated[str, typer.Option(..., "--dbname", "-d")],
    ssh_username: Annotated[str, typer.Option(..., "--ssh-username", "-S")],
    sql_file: Annotated[
        str,
        typer.Option(..., "--sql-file", "-f"),
    ] = f"{env.BASE_DIR}/sql/user.sql",
    username: Annotated[
        str,
        typer.Option(..., "--db-user", "-u"),
    ] = "postgres",
) -> None:
    """
    Create a database with the given name
    cand run the given sql file to create the schema.\n
    Make sure you set the 'PG_PASSWORD' and 'SSH_PASSWORD' environment variables.
    This is done to avoid having to pass the passwords as command line arguments.\n
    Additionally ensure that you have setup ssh keys for the remote host.
    This will NOT work if you have to enter a password for the remote host.
    """
    script_args = [
        f"{env.BASE_DIR}/scripts/create_db.sh",
        "-h",
        host,
        "-p",
        env.config.PG_PASSWORD,
        "-d",
        dbname,
        "-s",
        ssh_username,
        "-P",
        env.config.SSH_PASSWORD,
        "-f",
        sql_file,
        "-u",
        username,
    ]

    logger.info(f"executing script: create_db.sh on {host}@{username}")

    process = subprocess.Popen(
        script_args,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    _, error = process.communicate()

    if error:
        typer.echo(f"Error: {error}")

    logger.info("Successfully created database steam_archive")


@cli.command()
def test() -> None:
    """Test the database connection"""
    session = get_db_session()

    print(session.execute(text("SELECT current_user")).scalars().first())
