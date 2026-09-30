package com.vithey.chat.dto.response;

import com.vithey.chat.entity.ConversationStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record ConversationResponse(
    UUID conversationId,
    ConversationStatus status,
    ParticipantSummaryResponse participant,
    LastMessageSummary lastMessage,
    long unreadCount,
    boolean isOnline,
    OffsetDateTime updatedAt
) {
}
