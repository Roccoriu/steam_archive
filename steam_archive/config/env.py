from pathlib import Path
from pydantic import BaseSettings, validator


BASE_DIR = Path(__file__).resolve().parent.parent.parent


class Config(BaseSettings):
    class Config:
        env_file = f"{BASE_DIR}/.env"
        env_file_encoding = "utf-8"

    LOG_LEVEL: str = "DEBUG"

    DB_CONNECTION_STRING: str

    DEFAULT_ROUTINE_FILES = [
        "get_jsonb_value.sql",
        "upsert_cpu_count.sql",
        "upsert_gpu_config.sql",
        "upsert_hw_survey.sql",
        "upsert_os_version.sql",
        "upsert_ram_config.sql",
    ]

    DEFAULT_VIEW_FILES = []

    @validator("DEFAULT_ROUTINE_FILES")
    def validate_default_route_files(cls, v) -> str:
        return ",".join(v)

    @validator("DEFAULT_VIEW_FILES")
    def validate_default_views_files(cls, v) -> str:
        return ",".join(v)


config = Config()  # type: ignore
