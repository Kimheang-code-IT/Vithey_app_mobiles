package com.vithey.finance.dto.response;

import com.vithey.finance.entity.CurrencyCode;
import java.math.BigDecimal;
import java.util.UUID;

public record FeeResponse(
    UUID feeId,
    UUID categoryId,
    String categoryName,
    String name,
    BigDecimal amount,
    CurrencyCode currency
) {
}
