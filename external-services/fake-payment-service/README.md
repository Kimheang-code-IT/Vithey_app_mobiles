# Fake Payment Gateway (FastAPI)

> ## ⚠️ FAKE PAYMENT GATEWAY
> ## DEVELOPMENT / DEMO / UAT ONLY
> ## NO REAL MONEY
> ## NOT FOR PRODUCTION PAYMENT PROCESSING

A small FastAPI service that **simulates an external payment provider** for the
Vithey `finance-service`. It exists so the platform can be built, demoed, and
tested end‑to‑end without touching a real bank.

It never collects or stores card numbers, CVVs, PINs, OTPs, bank usernames, or
bank passwords. "Payment methods" are labels only: `DEMO_CARD`, `DEMO_BANK`,
`DEMO_WALLET`.

---

## Purpose

* Provide a deterministic, offline stand‑in for a real payment provider.
* Let `finance-service` exercise success, decline, pending, and timeout flows.
* Keep Flutter completely decoupled from the payment provider.
* Support integration testing and UAT without real money or credentials.

## Architecture

```text
Flutter
  -> API Gateway (Spring Cloud Gateway :8080)
    -> finance-service (Spring Boot :8086)   # owns invoices, amounts, auth, persistence
      -> fake-payment-service (FastAPI :8090) # simulates the provider
    <- finance-service (updates local transaction / invoice status)
  <- Flutter
```

Key rules:

* Flutter **never** calls this service directly.
* `finance-service` remains authoritative for invoice ownership, amount,
  business validation, transaction persistence, status, and authorization.
* This service only simulates the provider response.

## Installation

```bash
cd fake-payment-service
python -m venv .venv
# Windows: .venv\Scripts\activate    |    macOS/Linux: source .venv/bin/activate
pip install -r requirements-dev.txt
```

## Environment variables

Copy `.env.example` to `.env` and adjust. Nothing here is a secret; the service
must never hold production credentials.

| Variable | Default | Purpose |
| --- | --- | --- |
| `FAKE_PAYMENT_API_KEY` | `change-me` | Expected value of the `X-Demo-API-Key` header. **Change in shared environments.** |
| `FAKE_PAYMENT_SUPPORTED_CURRENCIES` | `USD,KHR` | Accepted ISO currency codes. |
| `FAKE_PAYMENT_CURRENCY_DECIMALS` | `USD:2,KHR:2` | Decimal precision used to normalize amounts. |
| `FAKE_PAYMENT_TIMEOUT_DELAY_SECONDS` | `0.01` | Delay before the deterministic `TIMEOUT` scenario fails. Kept tiny for tests. |
| `FAKE_PAYMENT_PROCESSING_SECONDS` | `0` | If `> 0`, a `PROCESSING` payment auto‑completes to `SUCCESS` after N seconds (`0` = never). |
| `FAKE_PAYMENT_LOG_LEVEL` | `INFO` | Python log level. |

## Running locally

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8090
# or: python -m uvicorn app.main:app --port 8090
```

* API docs: <http://localhost:8090/docs>
* OpenAPI JSON: <http://localhost:8090/openapi.json>
* Health (no auth): <http://localhost:8090/health>

## Docker

```bash
docker build -t vithey-fake-payment-service:local .
docker run --rm -p 8110:8090 -e FAKE_PAYMENT_API_KEY=change-me vithey-fake-payment-service:local
```

In the Vithey stack it is added to `backend/docker-compose.yml` (dev/demo):

* container listens on **8090** (same as the Dockerfile)
* host port is **8110** (`8110:8090`) to avoid clashing with `map-service`, which
  already uses host `8090`.

## Endpoints

Base path for payments is `/api/v1`.

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| `GET` | `/health` | none | Liveness probe. Returns `{"status":"UP","service":"fake-payment-service"}`. |
| `POST` | `/api/v1/payments` | `X-Demo-API-Key` | Create a simulated payment. Optional `Idempotency-Key` header. |
| `GET` | `/api/v1/payments/{payment_id}` | `X-Demo-API-Key` | Fetch a simulated payment (important for `PROCESSING`). |

### Create payment

```http
POST /api/v1/payments
X-Demo-API-Key: change-me
Idempotency-Key: 8f2c...   (optional)
Content-Type: application/json

{
  "merchant_reference": "INV-2026-00001",
  "amount": "25.00",
  "currency": "USD",
  "payment_method": "DEMO_CARD",
  "scenario": "SUCCESS"
}
```

Response (`201` for a new payment, `200` for an idempotent replay):

```json
{
  "payment_id": "pay_6c1f...",
  "provider_reference": "demo_9d2a...",
  "merchant_reference": "INV-2026-00001",
  "amount": "25.00",
  "currency": "USD",
  "status": "SUCCESS",
  "failure_code": null,
  "failure_message": null,
  "created_at": "2026-09-30T08:15:00.123456Z",
  "completed_at": "2026-09-30T08:15:00.123456Z"
}
```

## Payment methods

`DEMO_CARD`, `DEMO_BANK`, `DEMO_WALLET`. Anything else returns
`400 INVALID_PAYMENT_METHOD`.

## Demo scenarios

| Scenario | Result |
| --- | --- |
| `SUCCESS` | `status: SUCCESS`, `completed_at` set. |
| `DECLINED` | `status: FAILED`, `failure_code: PAYMENT_DECLINED`, `failure_message: "Demo payment was declined."` |
| `PROCESSING` | `status: PROCESSING`, `completed_at: null`. Re‑`GET` to observe status. |
| `TIMEOUT` | Deterministic simulated timeout → HTTP `504`, `error.code: PROVIDER_TIMEOUT`. Waits `FAKE_PAYMENT_TIMEOUT_DELAY_SECONDS` (tiny by default). |

## Payment status values

`PENDING` · `PROCESSING` · `SUCCESS` · `FAILED` · `CANCELLED`

## Idempotency

Send `Idempotency-Key: <unique-request-id>`:

* Same key + same payment data → returns the original result (no new payment).
* Same key + different payment data → `409 IDEMPOTENCY_CONFLICT`.
* A replayed `TIMEOUT` returns `504` again.

This lets `finance-service` retry safely.

## Authentication

Every `/api/v1/**` route requires:

```http
X-Demo-API-Key: <FAKE_PAYMENT_API_KEY>
```

* Missing / wrong key → `401 UNAUTHORIZED`.
* `/health` stays unauthenticated.
* The key is compared in constant time and is never logged.

## Error format

```json
{
  "error": {
    "code": "INVALID_PAYMENT_METHOD",
    "message": "Unsupported demo payment method."
  }
}
```

| HTTP | Codes |
| --- | --- |
| `400` | `VALIDATION_ERROR`, `INVALID_AMOUNT`, `INVALID_CURRENCY`, `INVALID_PAYMENT_METHOD`, `INVALID_SCENARIO` |
| `401` | `UNAUTHORIZED` |
| `404` | `PAYMENT_NOT_FOUND` |
| `409` | `IDEMPOTENCY_CONFLICT` |
| `504` | `PROVIDER_TIMEOUT` |
| `500` | `INTERNAL_ERROR` (no stack traces exposed) |

## Money handling

Amounts use Python `Decimal` end‑to‑end; binary floating point is never used.
Amounts are normalized to the currency precision from
`FAKE_PAYMENT_CURRENCY_DECIMALS` (rounded half‑up) and returned as strings.

## Logging

Each payment logs payment id, merchant reference, scenario, status, and
timestamp. The service never logs API keys, `Authorization` headers, JWTs, or
other credentials.

## Testing

```bash
python -m pytest -q
```

Tests use FastAPI `TestClient` and the in‑memory store only — no external
services. They cover health, all four scenarios, decimal handling, validation,
authentication, lookup, and idempotency (including conflict). See
`tests/test_payments.py`.

## Limitations

* **In-memory only.** "In-memory demo payment data is lost when the service
  restarts." There is no database here; `finance-service` persists its own
  transaction records.
* No real money movement, no real card/bank integration.
* No webhooks; `PROCESSING` is polled via `GET`. It only auto‑completes when
  `FAKE_PAYMENT_PROCESSING_SECONDS > 0`.
* Single process only — in‑memory state is not shared across replicas.
* Not a security boundary: it is a demo double, kept simple by design.
