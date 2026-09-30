"""Runtime configuration for the fake payment gateway.

Values are read from the environment on every access so tests can override them
without re-importing the app. No secret is hardcoded: the API key defaults to
the literal placeholder ``change-me`` which must be replaced in any shared
environment.
"""

from __future__ import annotations

import os
from dataclasses import dataclass

PLACEHOLDER_API_KEY = "change-me"


def _env(name: str, default: str) -> str:
    value = os.getenv(name)
    if value is None or value.strip() == "":
        return default
    return value.strip()


def _env_float(name: str, default: float) -> float:
    raw = os.getenv(name)
    if raw is None or raw.strip() == "":
        return default
    try:
        return float(raw)
    except ValueError:
        return default


def _parse_currencies(raw: str) -> tuple[str, ...]:
    parsed = tuple(part.strip().upper() for part in raw.split(",") if part.strip())
    return parsed or ("USD",)


def _parse_decimals(raw: str) -> dict[str, int]:
    decimals: dict[str, int] = {}
    for part in raw.split(","):
        if ":" not in part:
            continue
        currency, _, value = part.partition(":")
        currency = currency.strip().upper()
        try:
            decimals[currency] = max(0, int(value.strip()))
        except ValueError:
            continue
    return decimals


@dataclass(frozen=True)
class Settings:
    api_key: str
    supported_currencies: tuple[str, ...]
    currency_decimals: dict[str, int]
    timeout_delay_seconds: float
    processing_seconds: float
    log_level: str

    @property
    def uses_placeholder_api_key(self) -> bool:
        return self.api_key == PLACEHOLDER_API_KEY

    def decimals_for(self, currency: str) -> int:
        return self.currency_decimals.get(currency.upper(), 2)

    @classmethod
    def from_env(cls) -> "Settings":
        return cls(
            api_key=_env("FAKE_PAYMENT_API_KEY", PLACEHOLDER_API_KEY),
            supported_currencies=_parse_currencies(
                _env("FAKE_PAYMENT_SUPPORTED_CURRENCIES", "USD,KHR")
            ),
            currency_decimals=_parse_decimals(
                _env("FAKE_PAYMENT_CURRENCY_DECIMALS", "USD:2,KHR:2")
            ),
            timeout_delay_seconds=_env_float("FAKE_PAYMENT_TIMEOUT_DELAY_SECONDS", 0.01),
            processing_seconds=_env_float("FAKE_PAYMENT_PROCESSING_SECONDS", 0.0),
            log_level=_env("FAKE_PAYMENT_LOG_LEVEL", "INFO").upper(),
        )


def get_settings() -> Settings:
    return Settings.from_env()
