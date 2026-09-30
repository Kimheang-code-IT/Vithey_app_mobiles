package com.vithey.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record StudentVerifyRequest(
    @NotBlank @Size(max = 64) String studentId,
    @Email @NotBlank String universityEmail
) {
}
