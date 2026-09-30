package com.vithey.profile.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ProfileUpdatedEvent(
    UUID userId,
    OffsetDateTime updatedAt
) {
}
