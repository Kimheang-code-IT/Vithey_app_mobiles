package com.vithey.chat.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.UUID;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

@Embeddable
@Getter
@Setter
@EqualsAndHashCode
public class ConversationParticipantId implements Serializable {

  @Column(name = "conversation_id")
  private UUID conversationId;

  @Column(name = "user_id")
  private UUID userId;
}
