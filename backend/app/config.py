from functools import lru_cache
from zoneinfo import ZoneInfo

from pydantic_settings import BaseSettings, SettingsConfigDict

# Toutes les dates/heures métier sont exprimées à l'heure du Cameroun.
CAMEROON_TZ = ZoneInfo("Africa/Douala")


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    database_url: str = "postgresql+psycopg://voyagecm:voyagecm@localhost:5432/voyagecm"
    jwt_secret: str = "dev-secret-a-changer-absolument-en-production"
    jwt_expire_minutes: int = 480
    admin_username: str = "admin"
    admin_password: str = "admin123"
    seed_agency_password: str = "agency123"
    cors_origins: str = "*"

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
