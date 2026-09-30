"""Storage abstraction for the fake gateway.

The first demo implementation is process-local (in memory). Data is lost when
the service restarts. The interface exists so a persistent store can replace it
later without touching the service logic.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from typing import Protocol

from app.models.responses import PaymentStatus


@dataclass
class PaymentRecord:
    payment_id: str
    provider_reference: str
    merchant_reference: str
    amount: Decimal
    currency: str
    status: PaymentStatus
    payment_method: str
    scenario: str
    created_at: datetime
    completed_at: datetime | None = None
    failure_code: str | None = None
    failure_message: str | None = None


@dataclass
class IdempotencyRecord:
    fingerprint: str
    payment_id: str | None
    timed_out: bool = False


class PaymentRepository(Protocol):
    def save_payment(self, record: PaymentRecord) -> None: ...

    def get_payment(self, payment_id: str) -> PaymentRecord | None: ...

    def save_idempotency(self, key: str, record: IdempotencyRecord) -> None: ...

    def get_idempotency(self, key: str) -> IdempotencyRecord | None: ...


class InMemoryPaymentRepository:
    """In-memory demo store. Data is lost when the service restarts."""

    def __init__(self) -> None:
        self._payments: dict[str, PaymentRecord] = {}
        self._idempotency: dict[str, IdempotencyRecord] = {}

    def save_payment(self, record: PaymentRecord) -> None:
        self._payments[record.payment_id] = record

    def get_payment(self, payment_id: str) -> PaymentRecord | None:
        return self._payments.get(payment_id)

    def save_idempotency(self, key: str, record: IdempotencyRecord) -> None:
        self._idempotency[key] = record

    def get_idempotency(self, key: str) -> IdempotencyRecord | None:
        return self._idempotency.get(key)

    def reset(self) -> None:
        self._payments.clear()
        self._idempotency.clear()


repository = InMemoryPaymentRepository()
