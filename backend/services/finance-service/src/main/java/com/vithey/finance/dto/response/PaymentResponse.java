package com.vithey.finance.dto.response;

import com.vithey.finance.entity.CurrencyCode;
import com.vithey.finance.entity.PaymentStatus;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record PaymentResponse(
    UUID paymentId,
    String feeName,
    BigDecimal amount,
    CurrencyCode currency,
    PaymentStatus status,
    LocalDate dueDate,
    OffsetDateTime paidAt
) {
}
