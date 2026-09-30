package com.vithey.auth.dto.request;

import com.vithey.auth.entity.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
    @Email @NotBlank String email,
    @NotBlank @Size(max = 32) String phone,
    @NotBlank @Size(min = 8, max = 72) String password,
    @NotBlank @Size(max = 160) String fullName,
    @NotNull Role role
) {
}
