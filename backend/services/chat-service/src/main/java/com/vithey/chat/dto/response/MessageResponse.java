package com.vithey.chat.dto.response;

import com.vithey.chat.entity.MessageType;
import com.vithey.chat.entity.MessageStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record MessageResponse(
    UUID messageId,
    UUID conversationId,
    UUID senderId,
    String text,
    MessageType messageType,
    UUID fileId,
    String fileUrl,
    UUID replyToMessageId,
    MessageStatus status,
    OffsetDateTime createdAt
) {
}
