package com.vithey.finance.payment;

/** Provider-agnostic charge result. */
public record ProviderChargeResult(
    String providerPaymentId,
    String providerReference,
    ProviderPaymentStatus status,
    String failureCode,
    String failureMessage
) {

  public boolean isSuccess() {
    return status == ProviderPaymentStatus.SUCCESS;
  }
}
