package com.vithey.chat.repository;

import com.vithey.chat.entity.Message;
import com.vithey.chat.entity.MessageStatus;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MessageRepository extends JpaRepository<Message, UUID> {

  Page<Message> findByConversationIdAndDeletedAtIsNullOrderByCreatedAtDesc(
      UUID conversationId,
      Pageable pageable
  );

  Optional<Message> findFirstByConversationIdAndDeletedAtIsNullOrderByCreatedAtDesc(UUID conversationId);

  Optional<Message> findByConversationIdAndSenderIdAndClientMessageId(
      UUID conversationId,
      UUID senderId,
      String clientMessageId
  );

  long countByConversationIdAndSenderIdNotAndStatusNotAndDeletedAtIsNull(
      UUID conversationId,
      UUID senderId,
      MessageStatus status
  );
}
