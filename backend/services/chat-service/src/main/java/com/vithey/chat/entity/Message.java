package com.vithey.chat.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "messages")
@Getter
@Setter
public class Message {

  @Id
  private UUID id;

  @Column(name = "conversation_id", nullable = false)
  private UUID conversationId;

  @Column(name = "sender_id", nullable = false)
  private UUID senderId;

  @Column(columnDefinition = "TEXT")
  private String text;

  @Enumerated(EnumType.STRING)
  @Column(name = "message_type", nullable = false, length = 16)
  private MessageType messageType = MessageType.TEXT;

  @Column(name = "file_id")
  private UUID fileId;

  @Column(name = "reply_to_message_id")
  private UUID replyToMessageId;

  @Column(name = "client_message_id", length = 64)
  private String clientMessageId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 32)
  private MessageStatus status;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;
}
