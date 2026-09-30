package com.vithey.career.dto.request;

import com.vithey.career.entity.ApplicationStatus;
import jakarta.validation.constraints.NotNull;

public record UpdateApplicationStatusRequest(
    @NotNull ApplicationStatus status,
    String reviewerNote
) {
}
