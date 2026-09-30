package com.vithey.career.dto.response;

import java.util.UUID;

public record ProfileResponse(
    UUID userId,
    String fullName
) {
}
