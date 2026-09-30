package com.vithey.career.dto.response;

import java.util.UUID;

public record ApplicantSummaryResponse(
    UUID userId,
    String fullName
) {
}
