package com.vithey.notification.event.payload;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ChatMessageSentEvent(
    UUID messageId,
    UUID conversationId,
    UUID senderId,
    UUID recipientId,
    String text,
    String status,
    OffsetDateTime createdAt
) {
}
