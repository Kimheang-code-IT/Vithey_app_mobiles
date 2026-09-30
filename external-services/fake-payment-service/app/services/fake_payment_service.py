"""Deterministic fake payment logic.

Scenarios:
* SUCCESS     -> status SUCCESS
* DECLINED    -> status FAILED (failure_code PAYMENT_DECLINED)
* PROCESSING  -> status PROCESSING (optionally completes after a delay)
* TIMEOUT     -> raises ProviderTimeoutError (HTTP 504)

Money is handled with ``decimal.Decimal`` only; binary floating point is never
used for amounts.
"""

from __future__ import annotations

import hashlib
import logging
import secrets
import time
from datetime import datetime, timezone
from decimal import ROUND_HALF_UP, Decimal

from app.core.config import Settings, get_settings
from app.core.errors import (
    IdempotencyConflictError,
    PaymentNotFoundError,
    ProviderTimeoutError,
)
from app.models.requests import CreatePaymentRequest, PaymentScenario
from app.models.responses import PaymentResponse, PaymentStatus
from app.services.repository import (
    IdempotencyRecord,
    PaymentRecord,
    PaymentRepository,
    repository,
)

logger = logging.getLogger("fake_payment")

_DECLINED_CODE = "PAYMENT_DECLINED"
_DECLINED_MESSAGE = "Demo payment was declined."


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


def _iso(value: datetime | None) -> str | None:
    if value is None:
        return None
    return value.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def _new_id(prefix: str) -> str:
    return f"{prefix}_{secrets.token_hex(10)}"


class FakePaymentService:
    def __init__(
        self,
        repo: PaymentRepository | None = None,
        settings: Settings | None = None,
    ) -> None:
        self._repo = repo if repo is not None else repository
        self._settings = settings

    @property
    def settings(self) -> Settings:
        return self._settings if self._settings is not None else get_settings()

    def create_payment(
        self,
        request: CreatePaymentRequest,
        idempotency_key: str | None = None,
    ) -> tuple[PaymentResponse, bool]:
        """Return ``(payment, created)``; ``created`` is False on idempotent replay."""
        settings = self.settings
        amount = self._normalize_amount(request.amount, request.currency, settings)
        fingerprint = self._fingerprint(request, amount)

        if idempotency_key:
            existing = self._repo.get_idempotency(idempotency_key)
            if existing is not None:
                if existing.fingerprint != fingerprint:
                    raise IdempotencyConflictError()
                if existing.timed_out:
                    raise ProviderTimeoutError()
                stored = (
                    self._repo.get_payment(existing.payment_id)
                    if existing.payment_id
                    else None
                )
                if stored is None:
                    raise ProviderTimeoutError()
                logger.info(
                    "idempotent replay payment_id=%s merchant_reference=%s",
                    stored.payment_id,
                    stored.merchant_reference,
                )
                return self._to_response(stored), False

        if request.scenario == PaymentScenario.TIMEOUT:
            time.sleep(max(settings.timeout_delay_seconds, 0.0))
            if idempotency_key:
                self._repo.save_idempotency(
                    idempotency_key,
                    IdempotencyRecord(fingerprint, payment_id=None, timed_out=True),
                )
            logger.info(
                "provider timeout merchant_reference=%s scenario=TIMEOUT",
                request.merchant_reference,
            )
            raise ProviderTimeoutError()

        now = _utc_now()
        record = self._build_record(request, amount, now)
        self._repo.save_payment(record)
        if idempotency_key:
            self._repo.save_idempotency(
                idempotency_key, IdempotencyRecord(fingerprint, record.payment_id)
            )

        logger.info(
            "payment created payment_id=%s merchant_reference=%s scenario=%s status=%s at=%s",
            record.payment_id,
            record.merchant_reference,
            record.scenario,
            record.status.value,
            _iso(now),
        )
        return self._to_response(record), True

    def get_payment(self, payment_id: str) -> PaymentResponse:
        record = self._repo.get_payment(payment_id)
        if record is None:
            raise PaymentNotFoundError()
        self._maybe_complete(record)
        return self._to_response(record)

    def _build_record(
        self, request: CreatePaymentRequest, amount: Decimal, now: datetime
    ) -> PaymentRecord:
        status = PaymentStatus.PROCESSING
        completed_at: datetime | None = None
        failure_code: str | None = None
        failure_message: str | None = None

        if request.scenario == PaymentScenario.SUCCESS:
            status = PaymentStatus.SUCCESS
            completed_at = now
        elif request.scenario == PaymentScenario.DECLINED:
            status = PaymentStatus.FAILED
            failure_code = _DECLINED_CODE
            failure_message = _DECLINED_MESSAGE
            completed_at = now

        return PaymentRecord(
            payment_id=_new_id("pay"),
            provider_reference=_new_id("demo"),
            merchant_reference=request.merchant_reference,
            amount=amount,
            currency=request.currency,
            status=status,
            payment_method=request.payment_method.value,
            scenario=request.scenario.value,
            created_at=now,
            completed_at=completed_at,
            failure_code=failure_code,
            failure_message=failure_message,
        )

    def _maybe_complete(self, record: PaymentRecord) -> None:
        """Optionally finish a PROCESSING payment after a configured delay."""
        settings = self.settings
        if record.status != PaymentStatus.PROCESSING:
            return
        if settings.processing_seconds <= 0:
            return
        elapsed = (_utc_now() - record.created_at).total_seconds()
        if elapsed < settings.processing_seconds:
            return
        record.status = PaymentStatus.SUCCESS
        record.completed_at = _utc_now()
        self._repo.save_payment(record)
        logger.info("processing payment completed payment_id=%s", record.payment_id)

    @staticmethod
    def _normalize_amount(amount: Decimal, currency: str, settings: Settings) -> Decimal:
        decimals = settings.decimals_for(currency)
        quantum = Decimal(1).scaleb(-decimals)
        return amount.quantize(quantum, rounding=ROUND_HALF_UP)

    @staticmethod
    def _fingerprint(request: CreatePaymentRequest, amount: Decimal) -> str:
        raw = "|".join(
            [
                request.merchant_reference,
                format(amount, "f"),
                request.currency,
                request.payment_method.value,
                request.scenario.value,
            ]
        )
        return hashlib.sha256(raw.encode("utf-8")).hexdigest()

    @staticmethod
    def _to_response(record: PaymentRecord) -> PaymentResponse:
        return PaymentResponse(
            payment_id=record.payment_id,
            provider_reference=record.provider_reference,
            merchant_reference=record.merchant_reference,
            amount=format(record.amount, "f"),
            currency=record.currency,
            status=record.status,
            failure_code=record.failure_code,
            failure_message=record.failure_message,
            created_at=_iso(record.created_at) or "",
            completed_at=_iso(record.completed_at),
        )
