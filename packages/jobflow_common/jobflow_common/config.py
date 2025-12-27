from pydantic_settings import BaseSettings


class CommonSettings(BaseSettings):

    API_BASE_URL: str = "http://localhost:8000"
    ENVIRONMENT: str = "development"
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"


settings = CommonSettings()