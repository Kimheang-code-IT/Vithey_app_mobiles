# Module: Finance

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/finance/`, `vithey_app/lib/data/repositories/finance_repository.dart`, `vithey_app/lib/data/repositories/student_verification_repository.dart`, `vithey_app/lib/data/services/finance_service.dart`

## Purpose

Student fees/payments dashboard, payment UI (mock), invoice preview/download, and student verification gate. Backed by `finance-service`; payment alerts via `notification-service` routing. Finance access requires the `STUDENT` role. [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Finance dashboard | `/finance` | `lib/modules/finance/finance_screen.dart` |
| Payment (mock) | `/finance/pay` | `lib/modules/finance/payment/payment_screen.dart` |
| Student verification | `/student-verification` | `lib/modules/finance/verification/student_verification_screen.dart` |
| Verification status | `/verification-status` | `lib/modules/finance/verification/verification_status_screen.dart` |

[VERIFIED] `lib/routes/app_pages.dart`.

## Main widgets

- `finance_app_bar.dart`, `finance_balance_card.dart`, `finance_total_paycheck.dart`, `finance_status_colors.dart`, `payment_receipts_section.dart`, `payment_receipt_tile.dart`, `invoice_preview_sheet.dart`.
- Verification: `student_id_upload_box.dart`, `submitted_document_card.dart`, `verification_timeline.dart`, `verification_status_card.dart`, `verification_next_steps_card.dart`, `verification_app_bar.dart`.
- Payment: `payment/acleda_mobile_launcher.dart` (external app launch).

[VERIFIED]

## Controller / state

- `FinanceController` (`finance_controller.dart`): `dashboard`, `isLoading`, `isRefreshing`, `hasError`, `showAll`, `currentTab`, search state (`isSearchActive`, `searchQuery`, controller/focus). Commands: `_guardAndLoad`, `loadFinanceHome`, `refreshFinance`, `openPaymentDetail`, `payNow`, `downloadInvoice`, `onTabSelected`.
- `PaymentController` (`payment/payment_controller.dart`): `PaymentFlowStatus {collecting, processing, success}`; `confirmPayment()` is a **mock 2-second delay**, no gateway call; `backToFinance`.
- `StudentVerificationController` (`verification/student_verification_screen.dart`): student id/email/password controllers, document picker, `isSubmitting`, `errorMessage`, `submit`.
- `VerificationStatusController` (`verification/verification_status_screen.dart`).

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `FinanceRepository` | `lib/data/repositories/finance_repository.dart` | `getFinanceDashboard`, `getPaymentInvoice`, `getFees`, `downloadInvoice` |
| `FinanceService` | `lib/data/services/finance_service.dart` | `GET /payments`, `GET /fees` |
| `StudentVerificationRepository` | `lib/data/repositories/student_verification_repository.dart` | `/students/verify`, `GET /auth/me`, token refresh after verify |
| `StudentVerificationService` | `lib/data/services/student_verification_service.dart` | `/students/verify` |

[VERIFIED] `lib/core/constants/api_endpoints.dart`.

## User flow

1. Finance entry passes through verification gating (`FinanceNavigation.openFinanceEntry` and `FinanceController._guardAndLoad`): not submitted → verification form; pending/rejected → status screen; verified → dashboard. [VERIFIED]
2. Dashboard loads payments, computes total due / next due / paycheck client-side (`finance_repository.dart:16-44`).
3. Tapping a payment opens the invoice preview sheet; download re-fetches the invoice (mock: delay only).
4. `payNow` opens the next due payment's invoice. "Pay" pathways launch the external ACLEDA mobile app via `AcledaMobileLauncher` (deep link → intent → store fallback).
5. Verification submits student id + university email (+ optional document) and routes to `/verification-status`.

[VERIFIED]

## Loading / error / empty states

- `isLoading` → `LoadingWidget`; `hasError` → error + retry.
- `isRefreshing` for pull-to-refresh.
- Empty payments → summary shows `Paid` / no outstanding payment.
- Verification status has pending/verified/rejected states with a timeline.

[VERIFIED]

## Permissions

None directly. External app launch uses `url_launcher`; Android manifest declares a `<queries>` entry for `com.domain.acledabankqr` and the `ACLEDAmobile` scheme. [VERIFIED] `android/app/src/main/AndroidManifest.xml:2-12`, `ios/Runner/Info.plist:50-53`.

## Known limitations / stubs

- **Payment is a mock UI**: `PaymentController.confirmPayment` waits 2 seconds and succeeds; no payment gateway is called in-app. [VERIFIED]
- **ACLEDA integration is an app deep-link only** (`ACLEDAmobile://` and Play Store/App Store fallbacks), not an SDK integration. [VERIFIED]
- **Student verification is mock-first**: pending always resolves to verified in mock mode (`resolveMockPendingOutcome`). [VERIFIED]
- `FinanceService.fetchFees` live requires `STUDENT` role on the backend (`@PreAuthorize` in finance-service). [VERIFIED] `EVIDENCE-BASIS §5`.
- Password field on the verification form is collected but not sent to the API. [VERIFIED]
- `FinanceController.onTabSelected` maps tab 3 to the chat route and tab 4 to profile via the main shell — this is the finance screen's own bottom bar, not a persistent shell. [VERIFIED]

## TBDs

- [TBD] Real ACLEDA payment/QR settlement integration. TBD — Requires confirmation.
- [TBD] Fee catalog usage; `getFees` exists but the UI does not appear to filter by fee type. TBD — Requires confirmation.
- [TBD] Verification document upload to `file-service` in live mode. TBD — Requires confirmation.
