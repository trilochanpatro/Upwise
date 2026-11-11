from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_DIR = Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    supabase_url: str = "https://your-project.supabase.co"
    supabase_anon_key: str = "your-supabase-anon-key"
    database_url: str = "sqlite+aiosqlite:///./upwise_local.db"
    openai_api_key: str = ""
    openai_model: str = "gpt-4.1-mini"
    debug: bool = True

    model_config = SettingsConfigDict(
        env_file=(str(BACKEND_DIR / ".env"), ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
