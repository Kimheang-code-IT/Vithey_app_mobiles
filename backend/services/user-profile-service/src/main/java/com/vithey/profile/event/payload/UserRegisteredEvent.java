package com.vithey.profile.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record UserRegisteredEvent(
    UUID userId,
    String email,
    String fullName,
    String role,
    OffsetDateTime occurredAt
) {
}
