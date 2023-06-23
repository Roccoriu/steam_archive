import sys
import json
from typing import Any

from loguru import logger

from sqlalchemy import Result, text
from sqlalchemy.orm import Session
from sqlalchemy.exc import OperationalError


def exec_sql(db: Session, stmt: str, params: dict = {}) -> Result[Any] | None:
    try:
        res = db.execute(text(stmt.strip()), params)
        logger.debug(f"Executed SQL statement:\n{stmt}")
        db.commit()

        return res

    except OperationalError as e:
        db.rollback()
        logger.error(f"Error executing SQL statement:\n{e}")

        sys.exit(1)


def convert_to_pg_array(items: Any):
    # py_list is a list of Python dicts representing JSON objects
    # convert each dict to a JSON string
    json_str_list = [json.dumps(item) for item in items]
    # convert the list of JSON strings to a string representing a PostgreSQL array
    return json_str_list
