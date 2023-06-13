from pathlib import Path
from pydantic import BaseSettings


BASE_DIR = Path(__file__).resolve().parent.parent.parent


class Config(BaseSettings):
    class Config:
        env_file = f"{BASE_DIR}/.env"
        env_file_encoding = "utf-8"

    DB_CONNECTION_STRING: str


config = Config()  # type: ignore
