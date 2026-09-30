package com.vithey.notification.event.payload;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record PaymentDueEvent(
    UUID paymentId,
    UUID userId,
    UUID feeId,
    BigDecimal amount,
    String currency,
    LocalDate dueDate
) {
}
