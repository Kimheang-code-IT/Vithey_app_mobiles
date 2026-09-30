package com.vithey.chat.repository;

import com.vithey.chat.entity.Conversation;
import com.vithey.chat.entity.ConversationStatus;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ConversationRepository extends JpaRepository<Conversation, UUID> {

  @Query("""
      SELECT c FROM Conversation c
      JOIN ConversationParticipant p ON p.id.conversationId = c.id
      WHERE p.id.userId = :userId
      ORDER BY c.updatedAt DESC
      """)
  Page<Conversation> findByParticipantUserId(@Param("userId") UUID userId, Pageable pageable);

  @Query("""
      SELECT c FROM Conversation c
      JOIN ConversationParticipant p1 ON p1.id.conversationId = c.id AND p1.id.userId = :userA
      JOIN ConversationParticipant p2 ON p2.id.conversationId = c.id AND p2.id.userId = :userB
      WHERE c.status IN :statuses
      """)
  Optional<Conversation> findBetweenUsers(
      @Param("userA") UUID userA,
      @Param("userB") UUID userB,
      @Param("statuses") List<ConversationStatus> statuses
  );

  @Query("""
      SELECT c FROM Conversation c
      JOIN ConversationParticipant p ON p.id.conversationId = c.id
      WHERE p.id.userId = :userId
        AND p.role = com.vithey.chat.entity.ParticipantRole.RECIPIENT
        AND c.status = com.vithey.chat.entity.ConversationStatus.PENDING
      ORDER BY c.updatedAt DESC
      """)
  List<Conversation> findPendingRequestsForRecipient(@Param("userId") UUID userId);
}
