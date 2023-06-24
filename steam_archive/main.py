#!/usr/bin/env python3
import sys

import typer

from loguru import logger

from cli import cli as main
from config.env import config

logger.remove()
logger.add(sys.stderr, level=config.LOG_LEVEL.upper())

cli = typer.Typer()

cli.add_typer(main, name="db")


@cli.command()
def eval() -> None:
    print("TODO: evaluate and make nice graphs for the data")


if __name__ == "__main__":
    cli()
