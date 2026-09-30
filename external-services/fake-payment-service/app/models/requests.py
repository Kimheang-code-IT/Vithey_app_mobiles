"""Request models (Pydantic v2).

Only demo fields are accepted. ``extra="forbid"`` rejects anything resembling
real card/bank credentials (card_number, cvv, pin, otp, ...).
"""

from __future__ import annotations

from decimal import Decimal
from enum import Enum

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.core.config import get_settings


class PaymentMethod(str, Enum):
    DEMO_CARD = "DEMO_CARD"
    DEMO_BANK = "DEMO_BANK"
    DEMO_WALLET = "DEMO_WALLET"


class PaymentScenario(str, Enum):
    SUCCESS = "SUCCESS"
    DECLINED = "DECLINED"
    PROCESSING = "PROCESSING"
    TIMEOUT = "TIMEOUT"


class CreatePaymentRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    merchant_reference: str = Field(min_length=1, max_length=120)
    amount: Decimal
    currency: str = Field(min_length=3, max_length=3)
    payment_method: PaymentMethod
    scenario: PaymentScenario = PaymentScenario.SUCCESS

    @field_validator("amount")
    @classmethod
    def _amount_positive(cls, value: Decimal) -> Decimal:
        if value <= 0:
            raise ValueError("amount must be greater than zero")
        return value

    @field_validator("currency")
    @classmethod
    def _currency_supported(cls, value: str) -> str:
        normalized = value.strip().upper()
        if normalized not in get_settings().supported_currencies:
            raise ValueError(f"currency '{normalized}' is not supported")
        return normalized
