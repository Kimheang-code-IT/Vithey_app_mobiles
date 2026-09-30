package com.vithey.chat.service;

import com.vithey.chat.entity.Conversation;
import com.vithey.chat.entity.ConversationParticipant;
import com.vithey.chat.entity.ConversationStatus;
import com.vithey.chat.entity.ParticipantRole;
import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import com.vithey.chat.repository.BlockRepository;
import com.vithey.chat.repository.ConversationParticipantRepository;
import com.vithey.chat.repository.ConversationRepository;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ConversationAccessService {

  private final ConversationRepository conversationRepository;
  private final ConversationParticipantRepository participantRepository;
  private final BlockRepository blockRepository;

  public ConversationAccessService(
      ConversationRepository conversationRepository,
      ConversationParticipantRepository participantRepository,
      BlockRepository blockRepository
  ) {
    this.conversationRepository = conversationRepository;
    this.participantRepository = participantRepository;
    this.blockRepository = blockRepository;
  }

  @Transactional(readOnly = true)
  public Conversation requireParticipantConversation(UUID conversationId, UUID userId) {
    Conversation conversation = conversationRepository.findById(conversationId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    if (!participantRepository.findByIdConversationIdAndIdUserId(conversationId, userId).isPresent()) {
      throw new ApiException(ErrorCode.FORBIDDEN);
    }
    return conversation;
  }

  @Transactional(readOnly = true)
  public void requireActiveMessaging(UUID conversationId, UUID senderId) {
    Conversation conversation = requireParticipantConversation(conversationId, senderId);
    if (conversation.getStatus() != ConversationStatus.ACTIVE) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Conversation is not active");
    }
    UUID recipientId = findOtherParticipantId(conversationId, senderId);
    if (blockRepository.existsBlockBetween(senderId, recipientId)) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Messaging is blocked");
    }
  }

  @Transactional(readOnly = true)
  public UUID findOtherParticipantId(UUID conversationId, UUID userId) {
    return participantRepository.findByIdConversationId(conversationId).stream()
        .map(participant -> participant.getId().getUserId())
        .filter(id -> !id.equals(userId))
        .findFirst()
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
  }

  @Transactional(readOnly = true)
  public void assertNotBlocked(UUID userA, UUID userB) {
    if (blockRepository.existsBlockBetween(userA, userB)) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Messaging is blocked");
    }
  }

  @Transactional(readOnly = true)
  public ConversationParticipant requireRecipient(UUID conversationId, UUID userId) {
    ConversationParticipant participant = participantRepository
        .findByIdConversationIdAndIdUserId(conversationId, userId)
        .orElseThrow(() -> new ApiException(ErrorCode.FORBIDDEN));
    if (participant.getRole() != ParticipantRole.RECIPIENT) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Only the recipient can perform this action");
    }
    return participant;
  }
}
