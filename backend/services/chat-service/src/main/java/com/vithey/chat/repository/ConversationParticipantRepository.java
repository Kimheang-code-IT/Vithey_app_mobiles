package com.vithey.chat.repository;

import com.vithey.chat.entity.ConversationParticipant;
import com.vithey.chat.entity.ConversationParticipantId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ConversationParticipantRepository extends JpaRepository<ConversationParticipant, ConversationParticipantId> {

  List<ConversationParticipant> findByIdConversationId(UUID conversationId);

  Optional<ConversationParticipant> findByIdConversationIdAndIdUserId(UUID conversationId, UUID userId);

  @Query("""
      SELECT DISTINCT partner.id.userId
      FROM ConversationParticipant partner
      WHERE partner.id.conversationId IN (
          SELECT mine.id.conversationId FROM ConversationParticipant mine WHERE mine.id.userId = :userId
      )
      AND partner.id.userId <> :userId
      """)
  List<UUID> findPartnerUserIds(@Param("userId") UUID userId);
}
