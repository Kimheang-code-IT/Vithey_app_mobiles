"""FastAPI application for the Vithey fake payment gateway.

FAKE PAYMENT GATEWAY - DEVELOPMENT / DEMO / UAT ONLY.
NO REAL MONEY. NOT FOR PRODUCTION PAYMENT PROCESSING.
"""

from __future__ import annotations

import logging

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from app.api.payments import router as payments_router
from app.core.config import get_settings
from app.core.errors import ProviderError
from app.models.responses import ErrorDetail, ErrorResponse, HealthResponse

SERVICE_NAME = "fake-payment-service"

_settings = get_settings()
logging.basicConfig(
    level=getattr(logging, _settings.log_level, logging.INFO),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(SERVICE_NAME)

if _settings.uses_placeholder_api_key:
    logger.warning(
        "FAKE_PAYMENT_API_KEY is the default placeholder; set a real demo key "
        "before running in a shared environment."
    )

app = FastAPI(
    title="Vithey Fake Payment Gateway",
    version="0.1.0",
    description=(
        "DEMO ONLY. Simulates an external payment provider for the Vithey "
        "finance-service. No real money and no real credentials are processed."
    ),
)

_VALIDATION_CODE_BY_FIELD = {
    "payment_method": "INVALID_PAYMENT_METHOD",
    "scenario": "INVALID_SCENARIO",
    "currency": "INVALID_CURRENCY",
    "amount": "INVALID_AMOUNT",
}


def _error_response(status_code: int, code: str, message: str) -> JSONResponse:
    payload = ErrorResponse(error=ErrorDetail(code=code, message=message))
    return JSONResponse(status_code=status_code, content=payload.model_dump())


@app.exception_handler(ProviderError)
async def handle_provider_error(_: Request, exc: ProviderError) -> JSONResponse:
    return _error_response(int(exc.status_code), exc.code, exc.message)


@app.exception_handler(RequestValidationError)
async def handle_validation_error(_: Request, exc: RequestValidationError) -> JSONResponse:
    code = "VALIDATION_ERROR"
    errors = exc.errors()
    if errors:
        loc = [str(part) for part in errors[0].get("loc", [])]
        field = loc[-1] if loc else ""
        code = _VALIDATION_CODE_BY_FIELD.get(field, "VALIDATION_ERROR")
    return _error_response(400, code, "Request validation failed.")


@app.exception_handler(Exception)
async def handle_unexpected(_: Request, exc: Exception) -> JSONResponse:
    logger.exception("unexpected internal error")
    return _error_response(500, "INTERNAL_ERROR", "Unexpected server error.")


@app.get("/health", response_model=HealthResponse, tags=["health"])
def health() -> HealthResponse:
    return HealthResponse(status="UP", service=SERVICE_NAME)


app.include_router(payments_router)
