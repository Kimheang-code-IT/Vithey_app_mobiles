package com.vithey.finance.payment;

/** Provider-side payment status (mirrors the demo provider contract). */
public enum ProviderPaymentStatus {
  PENDING,
  PROCESSING,
  SUCCESS,
  FAILED,
  CANCELLED
}
