package com.vithey.finance.event.payload;

import com.vithey.finance.entity.CurrencyCode;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record PaymentDueEvent(
    UUID paymentId,
    UUID userId,
    UUID feeId,
    BigDecimal amount,
    CurrencyCode currency,
    LocalDate dueDate
) {
}
