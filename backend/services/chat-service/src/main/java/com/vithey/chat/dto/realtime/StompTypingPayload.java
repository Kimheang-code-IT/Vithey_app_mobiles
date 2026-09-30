package com.vithey.chat.dto.realtime;

import java.util.UUID;

public record StompTypingPayload(
    String type,
    UUID conversationId,
    UUID userId,
    boolean isTyping
) {

  public static final String FRAME_TYPE = "TYPING";

  public static StompTypingPayload from(UUID conversationId, UUID userId, boolean isTyping) {
    return new StompTypingPayload(FRAME_TYPE, conversationId, userId, isTyping);
  }
}
