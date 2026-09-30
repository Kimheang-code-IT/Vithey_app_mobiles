"""Tests for the fake payment gateway. No external services are used."""

from __future__ import annotations

import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402
from app.services.repository import repository  # noqa: E402

API_KEY = "test-key"
HEADERS = {"X-Demo-API-Key": API_KEY}


def _body(**overrides):
    payload = {
        "merchant_reference": "INV-2026-00001",
        "amount": "25.00",
        "currency": "USD",
        "payment_method": "DEMO_CARD",
        "scenario": "SUCCESS",
    }
    payload.update(overrides)
    return payload


@pytest.fixture(autouse=True)
def _isolated(monkeypatch):
    monkeypatch.setenv("FAKE_PAYMENT_API_KEY", API_KEY)
    monkeypatch.setenv("FAKE_PAYMENT_SUPPORTED_CURRENCIES", "USD,KHR")
    monkeypatch.setenv("FAKE_PAYMENT_CURRENCY_DECIMALS", "USD:2,KHR:2")
    monkeypatch.setenv("FAKE_PAYMENT_TIMEOUT_DELAY_SECONDS", "0.001")
    monkeypatch.setenv("FAKE_PAYMENT_PROCESSING_SECONDS", "0")
    repository.reset()
    yield
    repository.reset()


@pytest.fixture()
def client():
    with TestClient(app) as test_client:
        yield test_client


def test_health_is_unauthenticated(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "UP", "service": "fake-payment-service"}


def test_success_payment(client):
    response = client.post("/api/v1/payments", json=_body(scenario="SUCCESS"), headers=HEADERS)
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "SUCCESS"
    assert data["amount"] == "25.00"
    assert data["currency"] == "USD"
    assert data["merchant_reference"] == "INV-2026-00001"
    assert data["payment_id"].startswith("pay_")
    assert data["provider_reference"].startswith("demo_")
    assert data["failure_code"] is None
    assert data["completed_at"] is not None


def test_declined_payment(client):
    response = client.post("/api/v1/payments", json=_body(scenario="DECLINED"), headers=HEADERS)
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "FAILED"
    assert data["failure_code"] == "PAYMENT_DECLINED"
    assert data["failure_message"] == "Demo payment was declined."
    assert data["completed_at"] is not None


def test_processing_payment(client):
    response = client.post("/api/v1/payments", json=_body(scenario="PROCESSING"), headers=HEADERS)
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "PROCESSING"
    assert data["completed_at"] is None


def test_timeout_scenario(client):
    response = client.post("/api/v1/payments", json=_body(scenario="TIMEOUT"), headers=HEADERS)
    assert response.status_code == 504
    assert response.json()["error"]["code"] == "PROVIDER_TIMEOUT"


def test_invalid_amount_zero(client):
    response = client.post("/api/v1/payments", json=_body(amount="0"), headers=HEADERS)
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "INVALID_AMOUNT"


def test_invalid_amount_negative(client):
    response = client.post("/api/v1/payments", json=_body(amount="-5.00"), headers=HEADERS)
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "INVALID_AMOUNT"


def test_invalid_currency(client):
    response = client.post("/api/v1/payments", json=_body(currency="EUR"), headers=HEADERS)
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "INVALID_CURRENCY"


def test_invalid_payment_method(client):
    response = client.post(
        "/api/v1/payments", json=_body(payment_method="REAL_CARD"), headers=HEADERS
    )
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "INVALID_PAYMENT_METHOD"


def test_invalid_scenario(client):
    response = client.post("/api/v1/payments", json=_body(scenario="MAYBE"), headers=HEADERS)
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "INVALID_SCENARIO"


def test_real_credential_fields_rejected(client):
    payload = _body()
    payload["card_number"] = "4111111111111111"
    response = client.post("/api/v1/payments", json=payload, headers=HEADERS)
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


def test_missing_api_key(client):
    response = client.post("/api/v1/payments", json=_body())
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "UNAUTHORIZED"


def test_invalid_api_key(client):
    response = client.post(
        "/api/v1/payments", json=_body(), headers={"X-Demo-API-Key": "wrong"}
    )
    assert response.status_code == 401


def test_get_existing_payment(client):
    created = client.post("/api/v1/payments", json=_body(), headers=HEADERS).json()
    response = client.get(f"/api/v1/payments/{created['payment_id']}", headers=HEADERS)
    assert response.status_code == 200
    assert response.json()["payment_id"] == created["payment_id"]


def test_get_unknown_payment(client):
    response = client.get("/api/v1/payments/pay_does_not_exist", headers=HEADERS)
    assert response.status_code == 404
    assert response.json()["error"]["code"] == "PAYMENT_NOT_FOUND"


def test_idempotent_duplicate_returns_same_payment(client):
    headers = {**HEADERS, "Idempotency-Key": "req-1"}
    first = client.post("/api/v1/payments", json=_body(), headers=headers)
    second = client.post("/api/v1/payments", json=_body(), headers=headers)
    assert first.status_code == 201
    assert second.status_code == 200
    assert first.json()["payment_id"] == second.json()["payment_id"]


def test_idempotency_conflict_on_different_body(client):
    headers = {**HEADERS, "Idempotency-Key": "req-2"}
    client.post("/api/v1/payments", json=_body(), headers=headers)
    conflicting = client.post(
        "/api/v1/payments", json=_body(amount="99.00"), headers=headers
    )
    assert conflicting.status_code == 409
    assert conflicting.json()["error"]["code"] == "IDEMPOTENCY_CONFLICT"


def test_decimal_normalization(client):
    response = client.post("/api/v1/payments", json=_body(amount="25.5"), headers=HEADERS)
    assert response.json()["amount"] == "25.50"


def test_khr_currency_supported(client):
    response = client.post(
        "/api/v1/payments",
        json=_body(amount="1500000", currency="KHR"),
        headers=HEADERS,
    )
    assert response.status_code == 201
    assert response.json()["currency"] == "KHR"
    assert response.json()["amount"] == "1500000.00"
