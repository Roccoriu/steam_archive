from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from .env import config


engine = create_engine(config.DB_CONNECTION_STRING, echo=False)


def get_db_session() -> Session:
    with Session(engine) as session:
        return session
