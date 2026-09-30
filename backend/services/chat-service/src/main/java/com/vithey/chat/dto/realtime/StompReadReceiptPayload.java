package com.vithey.chat.dto.realtime;

import java.time.OffsetDateTime;
import java.util.UUID;

public record StompReadReceiptPayload(
    String type,
    UUID conversationId,
    UUID messageId,
    UUID readerId,
    OffsetDateTime readAt
) {

  public static final String FRAME_TYPE = "READ_RECEIPT";

  public static StompReadReceiptPayload from(
      UUID conversationId,
      UUID messageId,
      UUID readerId,
      OffsetDateTime readAt
  ) {
    return new StompReadReceiptPayload(FRAME_TYPE, conversationId, messageId, readerId, readAt);
  }
}
