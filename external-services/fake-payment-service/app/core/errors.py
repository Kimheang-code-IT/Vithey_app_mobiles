"""Domain errors for the fake payment gateway.

Each error carries a stable ``code`` and an HTTP status so the API layer can
return a consistent ``{"error": {"code", "message"}}`` body.
"""

from __future__ import annotations

from http import HTTPStatus


class ProviderError(Exception):
    """Base class for all fake-provider errors."""

    status_code: int = HTTPStatus.BAD_REQUEST
    code: str = "PROVIDER_ERROR"
    default_message: str = "Payment provider error."

    def __init__(self, message: str | None = None, code: str | None = None) -> None:
        self.message = message or self.default_message
        if code:
            self.code = code
        super().__init__(self.message)


class InvalidPaymentMethodError(ProviderError):
    code = "INVALID_PAYMENT_METHOD"
    default_message = "Unsupported demo payment method."


class InvalidScenarioError(ProviderError):
    code = "INVALID_SCENARIO"
    default_message = "Unsupported demo scenario."


class InvalidCurrencyError(ProviderError):
    code = "INVALID_CURRENCY"
    default_message = "Unsupported currency."


class InvalidAmountError(ProviderError):
    code = "INVALID_AMOUNT"
    default_message = "Amount must be greater than zero."


class UnauthorizedError(ProviderError):
    status_code = HTTPStatus.UNAUTHORIZED
    code = "UNAUTHORIZED"
    default_message = "Missing or invalid service credentials."


class PaymentNotFoundError(ProviderError):
    status_code = HTTPStatus.NOT_FOUND
    code = "PAYMENT_NOT_FOUND"
    default_message = "Payment not found."


class IdempotencyConflictError(ProviderError):
    status_code = HTTPStatus.CONFLICT
    code = "IDEMPOTENCY_CONFLICT"
    default_message = "Idempotency key reused with different payment data."


class ProviderTimeoutError(ProviderError):
    status_code = HTTPStatus.GATEWAY_TIMEOUT
    code = "PROVIDER_TIMEOUT"
    default_message = "Demo provider timed out."
