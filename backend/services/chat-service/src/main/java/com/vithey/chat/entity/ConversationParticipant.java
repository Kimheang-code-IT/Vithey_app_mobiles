package com.vithey.chat.entity;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "conversation_participants")
@Getter
@Setter
public class ConversationParticipant {

  @EmbeddedId
  private ConversationParticipantId id;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 32)
  private ParticipantRole role;

  @Column(name = "joined_at", nullable = false)
  private OffsetDateTime joinedAt;
}
