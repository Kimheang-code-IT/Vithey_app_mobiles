package com.vithey.auth.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record StudentVerifiedEvent(
    UUID userId,
    String studentId,
    OffsetDateTime occurredAt
) {
}
