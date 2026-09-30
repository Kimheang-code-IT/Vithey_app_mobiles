# Finance API (finance-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/finance-service/src/main/java/com/vithey/finance/controller/*.java`, `security/CurrentUserProvider.java`, `dto/**`

Base paths: `/api/v1/fees` (`FeeController`), `/api/v1/payments` (`PaymentController`). Service port
`8086`. **Both controllers are annotated `@PreAuthorize("hasRole('STUDENT')")`** and also call
`requireStudent()`; a non-verified-student JWT receives `403`. [VERIFIED: `FeeController.java:18`,
`PaymentController.java:20`, `CurrentUserProvider.java:12-18`]

## 1. Endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| GET | `/api/v1/fees` | JWT | STUDENT | Fee catalogue | — | `FeeResponse[]` | 401, 403 |
| GET | `/api/v1/fees/categories` | JWT | STUDENT | Fee categories | — | `FeeCategoryResponse[]` | 401, 403 |
| GET | `/api/v1/payments` | JWT | STUDENT | My payments (paginated) | `?page=&limit=` | `PaymentResponse[]` + meta | 401, 403 |
| GET | `/api/v1/payments/alerts` | JWT | STUDENT | Upcoming/overdue alerts | — | `PaymentAlertsResponse` | 401, 403 |
| GET | `/api/v1/payments/{paymentId}` | JWT | STUDENT | Single payment (own only) | path | `PaymentResponse` | 401, 403, 404 |

## 2. Schemas

`FeeResponse` = `fee_id, category_id, category_name, name, amount, currency`.
`FeeCategoryResponse` = `category_id, name, description`.
`PaymentResponse` = `payment_id, fee_name, amount, currency, status, due_date, paid_at`.
`PaymentAlertsResponse` = `{ alerts: [ { payment_id, fee_name, due_date, days_remaining, amount,
currency } ] }`.

**Status enum:** `UNPAID | PAID | OVERDUE` (DB also allows `PENDING`, `CANCELLED` — defect #4).
**Currency:** `KHR | USD`. Alert window is `VITHEY_FINANCE_ALERT_DUE_DAYS` (default 7);
alert cron `VITHEY_FINANCE_ALERT_CRON` (default `0 0 8 * * *`).

## 3. Examples

### GET `/api/v1/payments` → 200

```json
{
  "data": [
    {
      "payment_id": "33333333-3333-3333-3333-333333333301",
      "fee_name": "Tuition Semester 1",
      "amount": 1500000.00,
      "currency": "KHR",
      "status": "UNPAID",
      "due_date": "2026-10-15",
      "paid_at": null
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 1, "total_pages": 1 }
}
```

### GET `/api/v1/payments/alerts` → 200

```json
{
  "data": {
    "alerts": [
      {
        "payment_id": "33333333-3333-3333-3333-333333333301",
        "fee_name": "Tuition Semester 1",
        "due_date": "2026-10-15",
        "days_remaining": 15,
        "amount": 1500000.00,
        "currency": "KHR"
      }
    ]
  }
}
```

### Prerequisite

`POST /api/v1/students/verify` must succeed first (role becomes `STUDENT`) or every finance call
returns `403`.

## 4. Data touched

`finance_db`: `student_finance_accounts`, `fee_categories`, `fees`, `payments`. Seed data: 2
categories, 3 fees. See
[`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §6.

## 5. TBD

- Payment initiation (the current API is read-only; no create/update payment endpoint exists):
  `TBD — Requires confirmation.`
- ACLEDA payment integration: no endpoint or client found in this service — `TBD — Requires
  confirmation.`
- How `student_finance_accounts` is populated (no controller creates it): `TBD — Requires
  confirmation.`
