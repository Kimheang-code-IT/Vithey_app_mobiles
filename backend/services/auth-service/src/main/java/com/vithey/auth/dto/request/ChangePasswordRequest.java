package com.vithey.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Change password for the authenticated user.
 * JSON fields are snake_case via the global Jackson config:
 * {@code current_password}, {@code new_password}.
 */
public record ChangePasswordRequest(
    @NotBlank String currentPassword,
    @NotBlank @Size(min = 8, max = 72) String newPassword
) {
}
