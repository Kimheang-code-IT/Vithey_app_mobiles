package com.vithey.chat.service;

import com.vithey.chat.dto.realtime.StompMessagePayload;
import com.vithey.chat.dto.realtime.StompPresencePayload;
import com.vithey.chat.dto.realtime.StompReadReceiptPayload;
import com.vithey.chat.dto.realtime.StompTypingPayload;
import com.vithey.chat.dto.response.MessageResponse;
import com.vithey.chat.entity.MessageType;
import com.vithey.chat.entity.MessageStatus;
import java.util.UUID;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class RealtimeMessageService {

  private final SimpMessagingTemplate messagingTemplate;

  public RealtimeMessageService(SimpMessagingTemplate messagingTemplate) {
    this.messagingTemplate = messagingTemplate;
  }

  public void deliverMessage(UUID userId, MessageResponse message) {
    StompMessagePayload payload = StompMessagePayload.from(
        message.conversationId(),
        message.messageId(),
        message.senderId(),
        message.text(),
        message.messageType() == null ? MessageType.TEXT : message.messageType(),
        message.fileId(),
        message.status() == null ? MessageStatus.DELIVERED : message.status(),
        message.createdAt()
    );
    messagingTemplate.convertAndSendToUser(userId.toString(), "/queue/messages", payload);
  }

  public void deliverReadReceipt(UUID userId, StompReadReceiptPayload payload) {
    messagingTemplate.convertAndSendToUser(userId.toString(), "/queue/messages", payload);
  }

  public void deliverTyping(UUID userId, StompTypingPayload payload) {
    messagingTemplate.convertAndSendToUser(userId.toString(), "/queue/messages", payload);
  }

  public void deliverPresence(UUID userId, StompPresencePayload payload) {
    messagingTemplate.convertAndSendToUser(userId.toString(), "/queue/presence", payload);
  }
}
