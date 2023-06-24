import sys
import json
from typing import Any, Iterable

from loguru import logger

from sqlalchemy import Result, text
from sqlalchemy.orm import Session
from sqlalchemy.exc import OperationalError


def exec_sql(
    db: Session,
    stmt: str,
    params: dict = {},
) -> Result[Any] | None:
    try:
        res = db.execute(text(stmt.strip()), params)
        logger.debug(f"Executed SQL statement:\n{stmt}")
        db.commit()

        return res

    except OperationalError as e:
        db.rollback()
        logger.error(f"Error executing SQL statement:\n{e}")

        sys.exit(1)


def convert_to_pg_array(items: Iterable):
    return [json.dumps(item) for item in items]
