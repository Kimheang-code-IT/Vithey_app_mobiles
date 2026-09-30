package com.vithey.chat.dto.request;

import com.vithey.chat.entity.MessageType;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ChatSendPayload(
    @NotNull UUID conversationId,
    String text,
    String clientMessageId,
    UUID replyToMessageId,
    MessageType messageType,
    UUID fileId
) {

  public SendMessageRequest toSendMessageRequest() {
    return new SendMessageRequest(text, clientMessageId, replyToMessageId, messageType, fileId);
  }
}
