package com.vithey.chat.dto.request;

import jakarta.validation.constraints.NotBlank;

public record ReportUserRequest(
    @NotBlank String reason
) {
}
