package com.vithey.chat.service;

import com.vithey.chat.dto.request.MessageRequestDto;
import com.vithey.chat.dto.response.ConversationResponse;
import com.vithey.chat.dto.response.LastMessageSummary;
import com.vithey.chat.dto.response.PresenceResponse;
import com.vithey.chat.entity.Block;
import com.vithey.chat.entity.BlockId;
import com.vithey.chat.entity.Conversation;
import com.vithey.chat.entity.ConversationParticipant;
import com.vithey.chat.entity.ConversationParticipantId;
import com.vithey.chat.entity.ConversationStatus;
import com.vithey.chat.entity.Message;
import com.vithey.chat.entity.MessageStatus;
import com.vithey.chat.entity.MessageType;
import com.vithey.chat.entity.ParticipantRole;
import com.vithey.chat.event.payload.ChatRequestReceivedEvent;
import com.vithey.chat.event.publisher.ChatEventPublisher;
import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import com.vithey.chat.repository.BlockRepository;
import com.vithey.chat.repository.ConversationParticipantRepository;
import com.vithey.chat.repository.ConversationRepository;
import com.vithey.chat.repository.MessageRepository;
import com.vithey.chat.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ConversationService {

  private static final int MAX_LIMIT = 50;

  private final ConversationRepository conversationRepository;
  private final ConversationParticipantRepository participantRepository;
  private final MessageRepository messageRepository;
  private final BlockRepository blockRepository;
  private final ConversationAccessService accessService;
  private final ParticipantProfileService participantProfileService;
  private final ChatEventPublisher chatEventPublisher;
  private final PresenceService presenceService;

  public ConversationService(
      ConversationRepository conversationRepository,
      ConversationParticipantRepository participantRepository,
      MessageRepository messageRepository,
      BlockRepository blockRepository,
      ConversationAccessService accessService,
      ParticipantProfileService participantProfileService,
      ChatEventPublisher chatEventPublisher,
      PresenceService presenceService
  ) {
    this.conversationRepository = conversationRepository;
    this.participantRepository = participantRepository;
    this.messageRepository = messageRepository;
    this.blockRepository = blockRepository;
    this.accessService = accessService;
    this.participantProfileService = participantProfileService;
    this.chatEventPublisher = chatEventPublisher;
    this.presenceService = presenceService;
  }

  public ApiResponseWrapper<List<ConversationResponse>> listConversations(UUID userId, int page, int limit) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Conversation> conversations = conversationRepository.findByParticipantUserId(userId, pageable);
    List<ConversationResponse> content = conversations.getContent().stream()
        .map(conversation -> toResponse(conversation, userId))
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, conversations.getTotalElements(), conversations.getTotalPages())
    );
  }

  @Transactional(readOnly = true)
  public List<ConversationResponse> listPendingRequests(UUID userId) {
    return conversationRepository.findPendingRequestsForRecipient(userId).stream()
        .map(conversation -> toResponse(conversation, userId))
        .toList();
  }

  @Transactional(readOnly = true)
  public PresenceResponse partnerPresence(UUID conversationId, UUID userId) {
    accessService.requireParticipantConversation(conversationId, userId);
    UUID partnerId = accessService.findOtherParticipantId(conversationId, userId);
    PresenceService.PresenceSnapshot snapshot = presenceService.snapshot(partnerId);
    return new PresenceResponse(
        partnerId,
        snapshot.status(),
        OffsetDateTime.now(ZoneOffset.UTC)
    );
  }

  @Transactional
  public ConversationResponse createRequest(UUID requesterId, MessageRequestDto request) {
    if (requesterId.equals(request.toUserId())) {
      throw new ApiException(ErrorCode.BUSINESS_RULE_VIOLATION, "You cannot message yourself");
    }
    accessService.assertNotBlocked(requesterId, request.toUserId());

    List<ConversationStatus> activeStatuses = List.of(
        ConversationStatus.PENDING,
        ConversationStatus.ACTIVE,
        ConversationStatus.BLOCKED
    );
    if (conversationRepository.findBetweenUsers(requesterId, request.toUserId(), activeStatuses).isPresent()) {
      throw new ApiException(ErrorCode.CONFLICT, "A conversation already exists with this user");
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Conversation conversation = new Conversation();
    conversation.setId(UUID.randomUUID());
    conversation.setStatus(ConversationStatus.PENDING);
    conversation.setCreatedAt(now);
    conversation.setUpdatedAt(now);
    conversationRepository.save(conversation);

    saveParticipant(conversation.getId(), requesterId, ParticipantRole.REQUESTER, now);
    saveParticipant(conversation.getId(), request.toUserId(), ParticipantRole.RECIPIENT, now);

    Message message = new Message();
    message.setId(UUID.randomUUID());
    message.setConversationId(conversation.getId());
    message.setSenderId(requesterId);
    message.setText(request.initialMessage());
    message.setMessageType(MessageType.TEXT);
    message.setStatus(MessageStatus.SENT);
    message.setCreatedAt(now);
    messageRepository.save(message);

    chatEventPublisher.publishRequestReceived(new ChatRequestReceivedEvent(
        conversation.getId(),
        requesterId,
        request.toUserId(),
        request.initialMessage(),
        now
    ));

    return toResponse(conversation, requesterId);
  }

  @Transactional
  public ConversationResponse acceptRequest(UUID conversationId, UUID userId) {
    accessService.requireRecipient(conversationId, userId);
    Conversation conversation = conversationRepository.findById(conversationId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    if (conversation.getStatus() != ConversationStatus.PENDING) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Only pending requests can be accepted");
    }
    conversation.setStatus(ConversationStatus.ACTIVE);
    conversation.setUpdatedAt(OffsetDateTime.now(ZoneOffset.UTC));
    return toResponse(conversationRepository.save(conversation), userId);
  }

  @Transactional
  public ConversationResponse declineRequest(UUID conversationId, UUID userId) {
    accessService.requireRecipient(conversationId, userId);
    Conversation conversation = conversationRepository.findById(conversationId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    if (conversation.getStatus() != ConversationStatus.PENDING) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Only pending requests can be declined");
    }
    conversation.setStatus(ConversationStatus.DECLINED);
    conversation.setUpdatedAt(OffsetDateTime.now(ZoneOffset.UTC));
    return toResponse(conversationRepository.save(conversation), userId);
  }

  @Transactional
  public ConversationResponse blockConversation(UUID conversationId, UUID userId) {
    accessService.requireParticipantConversation(conversationId, userId);
    Conversation conversation = conversationRepository.findById(conversationId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    UUID otherUserId = accessService.findOtherParticipantId(conversationId, userId);

    BlockId blockId = new BlockId();
    blockId.setBlockerId(userId);
    blockId.setBlockedId(otherUserId);
    if (!blockRepository.existsById(blockId)) {
      Block block = new Block();
      block.setId(blockId);
      block.setCreatedAt(OffsetDateTime.now(ZoneOffset.UTC));
      blockRepository.save(block);
    }

    conversation.setStatus(ConversationStatus.BLOCKED);
    conversation.setUpdatedAt(OffsetDateTime.now(ZoneOffset.UTC));
    return toResponse(conversationRepository.save(conversation), userId);
  }

  private void saveParticipant(UUID conversationId, UUID userId, ParticipantRole role, OffsetDateTime joinedAt) {
    ConversationParticipant participant = new ConversationParticipant();
    ConversationParticipantId id = new ConversationParticipantId();
    id.setConversationId(conversationId);
    id.setUserId(userId);
    participant.setId(id);
    participant.setRole(role);
    participant.setJoinedAt(joinedAt);
    participantRepository.save(participant);
  }

  private ConversationResponse toResponse(Conversation conversation, UUID viewerId) {
    UUID otherUserId = accessService.findOtherParticipantId(conversation.getId(), viewerId);
    Message lastMessage = messageRepository
        .findFirstByConversationIdAndDeletedAtIsNullOrderByCreatedAtDesc(conversation.getId())
        .orElse(null);

    LastMessageSummary lastMessageSummary = lastMessage == null ? null : new LastMessageSummary(
        previewText(lastMessage),
        lastMessage.getCreatedAt(),
        lastMessage.getSenderId()
    );

    long unreadCount = messageRepository.countByConversationIdAndSenderIdNotAndStatusNotAndDeletedAtIsNull(
        conversation.getId(),
        viewerId,
        MessageStatus.READ
    );

    return new ConversationResponse(
        conversation.getId(),
        conversation.getStatus(),
        participantProfileService.resolve(otherUserId),
        lastMessageSummary,
        unreadCount,
        presenceService.isOnline(otherUserId),
        conversation.getUpdatedAt()
    );
  }

  private String previewText(Message message) {
    if (message.getMessageType() == MessageType.IMAGE) {
      return "[Image]";
    }
    if (message.getMessageType() == MessageType.FILE) {
      return "[File]";
    }
    return message.getText();
  }
}
