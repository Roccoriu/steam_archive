#!/usr/bin/env python3
import typer

from db.cli import db_commands

cli = typer.Typer()

cli.add_typer(db_commands, name="db")


@cli.command()
def eval() -> None:
    print("TODO: evaluate and make nice graphs for the data")


if __name__ == "__main__":
    cli()
