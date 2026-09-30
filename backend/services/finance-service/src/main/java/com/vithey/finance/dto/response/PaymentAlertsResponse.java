package com.vithey.finance.dto.response;

import com.vithey.finance.entity.CurrencyCode;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record PaymentAlertsResponse(
    List<PaymentAlertItem> alerts
) {

  public record PaymentAlertItem(
      UUID paymentId,
      String feeName,
      LocalDate dueDate,
      long daysRemaining,
      BigDecimal amount,
      CurrencyCode currency
  ) {
  }
}
