package com.vithey.auth.event.payload;

import com.vithey.auth.entity.Role;
import java.time.OffsetDateTime;
import java.util.UUID;

public record UserRegisteredEvent(
    UUID userId,
    String email,
    String fullName,
    Role role,
    OffsetDateTime occurredAt
) {
}
