import os

from dotenv import load_dotenv

load_dotenv()


def _env_str(name: str, default: str) -> str:
    return os.getenv(name, default)


def _env_int(name: str, default: int) -> int:
    raw = os.getenv(name)
    if raw is None or raw.strip() == "":
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def _env_float(name: str, default: float) -> float:
    raw = os.getenv(name)
    if raw is None or raw.strip() == "":
        return default
    try:
        return float(raw)
    except ValueError:
        return default


def _env_bool(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None or raw.strip() == "":
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


class Config:
    """Central configuration. Every knob is env-driven so deployments can be
    tuned without code changes."""

    # --- DeepSeek / LLM -----------------------------------------------------
    DEEPSEEK_API_KEY = _env_str("DEEPSEEK_API_KEY", "")
    DEEPSEEK_BASE_URL = _env_str("DEEPSEEK_BASE_URL", "https://openrouter.ai/api/v1")
    DEEPSEEK_MODEL = _env_str("DEEPSEEK_MODEL", "z-ai/glm-5.3-flash")
    TEMPERATURE = _env_float("TEMPERATURE", 0.2)
    MAX_TOKENS = _env_int("MAX_TOKENS", 3000)
    TIMEOUT_SECONDS = _env_int("TIMEOUT_SECONDS", 30)

    # --- Reliability ---------------------------------------------------------
    MAX_RETRIES = _env_int("MAX_RETRIES", 2)
    RETRY_BACKOFF_SECONDS = _env_float("RETRY_BACKOFF_SECONDS", 1.0)

    # --- Rate limiting (library-level, protects cost) ------------------------
    RATE_LIMIT_ENABLED = _env_bool("RATE_LIMIT_ENABLED", True)
    RATE_LIMIT_MAX_CALLS = _env_int("RATE_LIMIT_MAX_CALLS", 120)
    RATE_LIMIT_WINDOW_SECONDS = _env_int("RATE_LIMIT_WINDOW_SECONDS", 60)

    # --- Input guards ----------------------------------------------------------
    MAX_POSTS_PER_BUILD = _env_int("MAX_POSTS_PER_BUILD", 100)
    MAX_CONTENT_CHARS = _env_int("MAX_CONTENT_CHARS", 6000)

    # --- Cache ------------------------------------------------------------------
    CACHE_ENABLED = _env_bool("CACHE_ENABLED", True)
    CACHE_MAX_SIZE = _env_int("CACHE_MAX_SIZE", 512)

    # --- CV standards -------------------------------------------------------------
    ALLOWED_LANGUAGES = {"en", "km"}

    # --- Logging ---------------------------------------------------------------
    LOG_LEVEL = _env_str("LOG_LEVEL", "INFO").upper()

    # --- HTTP API (optional FastAPI wrapper) --------------------------------------
    API_RATE_LIMIT_PER_MINUTE = _env_int("API_RATE_LIMIT_PER_MINUTE", 30)
    API_MAX_BODY_BYTES = _env_int("API_MAX_BODY_BYTES", 512 * 1024)
    API_CORS_ORIGINS = [
        origin.strip()
        for origin in _env_str(
            "API_CORS_ORIGINS", "http://localhost:3000,http://localhost:8080"
        ).split(",")
        if origin.strip()
    ]

    # --- Flutter /api/v1/ai/** (gateway-facing) ------------------------------------
    VITHEY_JWT_SECRET = _env_str(
        "VITHEY_JWT_SECRET",
        "change-me-to-a-strong-256-bit-secret-for-local-dev",
    )
    DATABASE_URL = _env_str("DATABASE_URL", "")
    USER_PROFILE_BASE_URL = _env_str(
        "USER_PROFILE_BASE_URL", "http://user-profile-service:8082"
    )
    CONTENT_BASE_URL = _env_str("CONTENT_BASE_URL", "http://content-service:8084")
    AI_CHAT_MODE = _env_str("AI_CHAT_MODE", "stub").strip().lower()
    AI_CV_MAX_POSTS = _env_int("AI_CV_MAX_POSTS", 20)

    VERSION = "0.2.0"
