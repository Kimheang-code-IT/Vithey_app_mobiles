package com.vithey.chat.dto.request;

import com.vithey.chat.entity.MessageType;
import java.util.UUID;

public record SendMessageRequest(
    String text,
    String clientMessageId,
    UUID replyToMessageId,
    MessageType messageType,
    UUID fileId
) {

  public MessageType resolvedMessageType() {
    return messageType == null ? MessageType.TEXT : messageType;
  }
}
