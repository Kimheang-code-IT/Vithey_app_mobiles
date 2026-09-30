package com.vithey.chat.dto.realtime;

import com.vithey.chat.entity.MessageType;
import com.vithey.chat.entity.MessageStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record StompMessagePayload(
    String type,
    UUID conversationId,
    UUID messageId,
    UUID senderId,
    String text,
    MessageType messageType,
    UUID fileId,
    MessageStatus status,
    OffsetDateTime createdAt
) {

  public static final String FRAME_TYPE = "MESSAGE";

  public static StompMessagePayload from(
      UUID conversationId,
      UUID messageId,
      UUID senderId,
      String text,
      MessageType messageType,
      UUID fileId,
      MessageStatus status,
      OffsetDateTime createdAt
  ) {
    return new StompMessagePayload(
        FRAME_TYPE,
        conversationId,
        messageId,
        senderId,
        text,
        messageType,
        fileId,
        status,
        createdAt
    );
  }
}
