package com.vithey.chat.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

public record PresenceResponse(
    UUID userId,
    String status,
    OffsetDateTime lastSeenAt
) {
}
