package com.vithey.finance.dto.response;

import java.util.UUID;

public record FeeCategoryResponse(
    UUID categoryId,
    String name,
    String description
) {
}
