package com.vithey.notification.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ChatRequestReceivedEvent(
    UUID conversationId,
    UUID requesterId,
    UUID recipientId,
    String initialMessage,
    OffsetDateTime createdAt
) {
}
