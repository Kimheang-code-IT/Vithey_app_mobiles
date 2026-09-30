package com.vithey.finance.payment;

import java.math.BigDecimal;

/** Provider-agnostic charge request. */
public record ProviderChargeRequest(
    String merchantReference,
    BigDecimal amount,
    String currency,
    String paymentMethod,
    String scenario,
    String idempotencyKey
) {
}
