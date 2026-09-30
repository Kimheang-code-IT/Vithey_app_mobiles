# Feature: Payment - Fake payment provider integration

- Issue: #27
- Component: Payment
- Status: Done
- Branch: `feature/payment-fake-provider`

## Objective

Exercise a realistic payment flow without real money.

## What exists

PaymentProcessingService + PaymentTransaction (V4); fake-payment-service (FastAPI).

## Endpoints / components

POST /payments

## Evidence

PaymentProcessingServiceTest; provider pytest (19)

## Limitations

DEV/DEMO/UAT only.
