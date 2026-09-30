# Finance Guide

> Status: **Partial** — finance data is read-only; **ACLEDA Mobile payment is NOT integrated** · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/finance/**`, `vithey_app/lib/data/repositories/finance_repository.dart`, `api_docs.md` §8, `../06-api/08-finance-api.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

> **Read this first.** Vithey's finance feature is a **tuition-fee viewer**: it lists fees and
> payments for verified students. The "Pay with ACLEDA" button opens the official ACLEDA Mobile app
> via a deep link, and the in-app payment screen is a **preview flow that processes no real
> payment** [VERIFIED: `payment_controller.dart` comment, `payment_screen.dart` banner]. There is no
> server endpoint that creates or settles a payment [VERIFIED: `../06-api/08-finance-api.md` §5].

## 1. Access is gated on student verification

Finance is only usable by a **verified student** (`STUDENT` role). The Home app-bar wallet icon
routes you as follows [VERIFIED: `student_verification_repository.dart` `FinanceNavigation`]:

| Verification status | Destination |
| --- | --- |
| Not submitted | `/student-verification` |
| Pending / Rejected | `/verification-status` |
| Verified | `/finance` |

Server-side, every finance endpoint is `@PreAuthorize("hasRole('STUDENT')")` and returns **`403`**
for non-students [VERIFIED: `../06-api/08-finance-api.md`].

### Student verification

`POST /students/verify` with `{ "student_id", "university_email" }` grants the `STUDENT` role
[VERIFIED: `api_docs.md` §3]. The screen is `/student-verification`; results are shown at
`/verification-status`.

## 2. Finance dashboard

`/finance` shows [VERIFIED: `lib/modules/finance/finance_screen.dart`, `finance_controller.dart`]:

- A **balance card** with a **Pay now** action (opens the next due payment's invoice).
- **Total paycheck** summary.
- **Payment receipts** list with search and a show-all toggle.
- Pull-to-refresh.

Payments are loaded from the finance dashboard; transactions support a text filter by fee name.

## 3. Payments & invoices

| Screen | Route | Contents |
| --- | --- | --- |
| Dashboard | `/finance` | Balance, due alerts, receipts |
| Invoice preview | bottom sheet | Fee name, reference, total, **Pay with ACLEDA** / another bank |
| Payment flow | `/finance/pay` | Preview collect → processing → success |

[VERIFIED: `lib/modules/finance/`, `lib/routes/app_pages.dart`]

Finance API (STUDENT only) [VERIFIED: `../06-api/08-finance-api.md`]:

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/payments?page=&limit=` | My payments |
| `GET` | `/payments/{payment_id}` | One payment (own only) |
| `GET` | `/payments/alerts` | Upcoming/overdue alerts |
| `GET` | `/fees` | Fee catalogue |
| `GET` | `/fees/categories` | Fee categories |

Payment fields: `payment_id`, `fee_name`, `amount`, `currency` (`KHR`/`USD`), `status`
(`UNPAID`/`PAID`/`OVERDUE`), `due_date`, `paid_at`.

## 4. ACLEDA Mobile payment — Stub / deep link only

What actually happens when you tap **Pay with ACLEDA**
[VERIFIED: `lib/modules/finance/payment/acleda_mobile_launcher.dart`, `payment_controller.dart`]:

1. The app attempts to open the official ACLEDA Mobile app via the `ACLEDAmobile://` scheme
   (Android package `com.domain.acledabankqr`), falling back to the Play Store / App Store listing.
   If the app cannot be opened, a "Could not open ACLEDA mobile" message appears.
2. Separately, the in-app payment screen shows a static KHQR placeholder and the note
   *"This is a preview flow — no real payment is processed yet."*
3. **Confirm** runs a fixed 2-second delay and shows a **"Payment Submitted"** success screen. No
   gateway call is made and no invoice status changes.

There is **no ACLEDA payment API, no QR generation, and no reconciliation** in the codebase
[VERIFIED: `../06-api/08-finance-api.md` §5; `_meta/EVIDENCE-BASIS.md` §9]. Verify-alert scheduling
(`VITHEY_FINANCE_ALERT_CRON`) is the only automated finance behaviour [VERIFIED: `../06-api/08-finance-api.md`].

## 5. What is not available

- Payment initiation / settlement: **Not integrated** — the API is read-only.
- "Pay with another bank" shows hard-coded demo transfer details (Bank Name, Account Number,
  Reference); it is illustrative only [VERIFIED: `payment_screen.dart` `_BankTransferPanel`].
- Invoice download in the demo downloads a mock/available document; treat it as best-effort
  [INFERRED from `finance_controller.dart` `downloadInvoice` — requires business confirmation].

## 6. Related

- [03-profile-guide.md](03-profile-guide.md) · [10-FAQ.md](10-FAQ.md) · [01-user-manual.md](01-user-manual.md)
- [../06-api/08-finance-api.md](../06-api/08-finance-api.md)
- Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
