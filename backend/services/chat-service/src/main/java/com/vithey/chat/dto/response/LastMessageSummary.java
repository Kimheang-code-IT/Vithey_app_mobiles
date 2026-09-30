package com.vithey.chat.dto.response;

import java.time.OffsetDateTime;
import java.util.UUID;

public record LastMessageSummary(
    String text,
    OffsetDateTime createdAt,
    UUID senderId
) {
}
