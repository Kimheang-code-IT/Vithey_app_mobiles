package com.vithey.auth.dto.response;

import com.vithey.auth.entity.Role;
import com.vithey.auth.entity.StudentVerificationStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record StudentVerificationResponse(
    UUID userId,
    String studentId,
    String universityEmail,
    Role role,
    boolean isStudentVerified,
    StudentVerificationStatus status,
    OffsetDateTime verifiedAt
) {
}
