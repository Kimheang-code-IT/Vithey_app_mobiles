"""Payment endpoints (base path ``/api/v1``)."""

from __future__ import annotations

import secrets

from fastapi import APIRouter, Depends, Header, Response

from app.core.config import get_settings
from app.core.errors import UnauthorizedError
from app.models.requests import CreatePaymentRequest
from app.models.responses import PaymentResponse
from app.services.fake_payment_service import FakePaymentService

router = APIRouter(prefix="/api/v1", tags=["payments"])


def require_api_key(
    x_demo_api_key: str | None = Header(default=None, alias="X-Demo-API-Key"),
) -> None:
    """Simple service-to-service credential check (not user authentication)."""
    expected = get_settings().api_key
    if not x_demo_api_key or not secrets.compare_digest(x_demo_api_key, expected):
        raise UnauthorizedError()


@router.post(
    "/payments",
    response_model=PaymentResponse,
    status_code=201,
    summary="Create a simulated payment",
)
def create_payment(
    request: CreatePaymentRequest,
    response: Response,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    _: None = Depends(require_api_key),
) -> PaymentResponse:
    payment, created = FakePaymentService().create_payment(request, idempotency_key)
    response.status_code = 201 if created else 200
    return payment


@router.get(
    "/payments/{payment_id}",
    response_model=PaymentResponse,
    summary="Get a simulated payment",
)
def get_payment(
    payment_id: str,
    _: None = Depends(require_api_key),
) -> PaymentResponse:
    return FakePaymentService().get_payment(payment_id)
