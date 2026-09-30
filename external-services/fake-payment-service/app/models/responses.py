"""Response models."""

from __future__ import annotations

from enum import Enum

from pydantic import BaseModel


class PaymentStatus(str, Enum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"


class HealthResponse(BaseModel):
    status: str
    service: str


class PaymentResponse(BaseModel):
    payment_id: str
    provider_reference: str
    merchant_reference: str
    amount: str
    currency: str
    status: PaymentStatus
    failure_code: str | None = None
    failure_message: str | None = None
    created_at: str
    completed_at: str | None = None


class ErrorDetail(BaseModel):
    code: str
    message: str


class ErrorResponse(BaseModel):
    error: ErrorDetail
