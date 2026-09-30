package com.vithey.auth.dto.response;

import com.vithey.auth.entity.Role;
import java.util.UUID;

public record UserAuthResponse(
    UUID userId,
    String email,
    String phone,
    String fullName,
    Role role,
    boolean isStudentVerified,
    boolean isEmailVerified
) {
}
