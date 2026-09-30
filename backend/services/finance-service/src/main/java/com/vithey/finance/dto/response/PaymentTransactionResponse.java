package com.vithey.finance.dto.response;

import com.vithey.finance.entity.CurrencyCode;
import com.vithey.finance.entity.PaymentTransactionStatus;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record PaymentTransactionResponse(
    UUID transactionId,
    UUID paymentId,
    String merchantReference,
    BigDecimal amount,
    CurrencyCode currency,
    String providerName,
    String providerPaymentId,
    String providerReference,
    PaymentTransactionStatus status,
    String failureCode,
    String failureMessage,
    OffsetDateTime createdAt,
    OffsetDateTime completedAt
) {
}
