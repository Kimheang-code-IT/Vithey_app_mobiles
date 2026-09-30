package com.vithey.chat.service;

import com.vithey.chat.dto.request.BatchReadRequest;
import com.vithey.chat.dto.request.SendMessageRequest;
import com.vithey.chat.dto.response.FileMetadataResponse;
import com.vithey.chat.dto.response.MessageResponse;
import com.vithey.chat.dto.realtime.StompReadReceiptPayload;
import com.vithey.chat.entity.Conversation;
import com.vithey.chat.entity.Message;
import com.vithey.chat.entity.MessageStatus;
import com.vithey.chat.entity.MessageType;
import com.vithey.chat.event.payload.ChatMessageSentEvent;
import com.vithey.chat.event.publisher.ChatEventPublisher;
import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import com.vithey.chat.mapper.ChatMapper;
import com.vithey.chat.repository.ConversationRepository;
import com.vithey.chat.repository.MessageRepository;
import com.vithey.chat.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class MessageService {

  private static final int MAX_LIMIT = 50;

  private final MessageRepository messageRepository;
  private final ConversationRepository conversationRepository;
  private final ConversationAccessService accessService;
  private final ChatMapper chatMapper;
  private final ChatEventPublisher chatEventPublisher;
  private final RealtimeMessageService realtimeMessageService;
  private final MessageCacheService messageCacheService;
  private final ChatFileValidationService chatFileValidationService;

  public MessageService(
      MessageRepository messageRepository,
      ConversationRepository conversationRepository,
      ConversationAccessService accessService,
      ChatMapper chatMapper,
      ChatEventPublisher chatEventPublisher,
      RealtimeMessageService realtimeMessageService,
      MessageCacheService messageCacheService,
      ChatFileValidationService chatFileValidationService
  ) {
    this.messageRepository = messageRepository;
    this.conversationRepository = conversationRepository;
    this.accessService = accessService;
    this.chatMapper = chatMapper;
    this.chatEventPublisher = chatEventPublisher;
    this.realtimeMessageService = realtimeMessageService;
    this.messageCacheService = messageCacheService;
    this.chatFileValidationService = chatFileValidationService;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<MessageResponse>> listMessages(
      UUID conversationId,
      UUID userId,
      int page,
      int limit
  ) {
    accessService.requireParticipantConversation(conversationId, userId);

    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Message> messages = messageRepository.findByConversationIdAndDeletedAtIsNullOrderByCreatedAtDesc(
        conversationId,
        pageable
    );
    List<MessageResponse> content = messages.getContent().stream()
        .map(chatMapper::toMessageResponse)
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, messages.getTotalElements(), messages.getTotalPages())
    );
  }

  @Transactional
  public MessageResponse sendMessage(UUID conversationId, UUID senderId, SendMessageRequest request) {
    if (StringUtils.hasText(request.clientMessageId())) {
      return messageRepository
          .findByConversationIdAndSenderIdAndClientMessageId(conversationId, senderId, request.clientMessageId())
          .map(chatMapper::toMessageResponse)
          .orElseGet(() -> createMessage(conversationId, senderId, request));
    }
    return createMessage(conversationId, senderId, request);
  }

  @Transactional
  public MessageResponse markRead(UUID messageId, UUID userId) {
    Message message = messageRepository.findById(messageId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    return markReadInternal(message, userId);
  }

  @Transactional
  public List<MessageResponse> markReadBatch(UUID conversationId, UUID userId, BatchReadRequest request) {
    accessService.requireParticipantConversation(conversationId, userId);
    List<MessageResponse> updated = new ArrayList<>();
    for (UUID messageId : request.messageIds()) {
      Message message = messageRepository.findById(messageId)
          .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
      if (!message.getConversationId().equals(conversationId)) {
        throw new ApiException(ErrorCode.FORBIDDEN, "Message does not belong to conversation");
      }
      updated.add(markReadInternal(message, userId));
    }
    return updated;
  }

  private MessageResponse createMessage(UUID conversationId, UUID senderId, SendMessageRequest request) {
    accessService.requireActiveMessaging(conversationId, senderId);
    UUID recipientId = accessService.findOtherParticipantId(conversationId, senderId);
    MessageType messageType = request.resolvedMessageType();

    validateMessageContent(request, messageType);
    if (request.replyToMessageId() != null) {
      Message replyTarget = messageRepository.findById(request.replyToMessageId())
          .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Reply target not found"));
      if (!replyTarget.getConversationId().equals(conversationId)) {
        throw new ApiException(ErrorCode.VALIDATION_ERROR, "Reply target must be in the same conversation");
      }
    }

    String fileUrl = null;
    UUID fileId = null;
    if (messageType != MessageType.TEXT) {
      FileMetadataResponse metadata = chatFileValidationService.requireOwnedChatFile(
          request.fileId(),
          senderId,
          messageType
      );
      fileId = metadata.fileId();
      fileUrl = metadata.url();
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Message message = new Message();
    message.setId(UUID.randomUUID());
    message.setConversationId(conversationId);
    message.setSenderId(senderId);
    message.setText(request.text());
    message.setMessageType(messageType);
    message.setFileId(fileId);
    message.setReplyToMessageId(request.replyToMessageId());
    message.setClientMessageId(request.clientMessageId());
    message.setStatus(MessageStatus.SENT);
    message.setCreatedAt(now);
    Message saved = messageRepository.save(message);

    Conversation conversation = conversationRepository.findById(conversationId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    conversation.setUpdatedAt(now);
    conversationRepository.save(conversation);

    MessageResponse response = chatMapper.toMessageResponse(saved, fileUrl);
    messageCacheService.appendMessageId(conversationId, saved.getId());

    MessageResponse delivered = new MessageResponse(
        response.messageId(),
        response.conversationId(),
        response.senderId(),
        response.text(),
        response.messageType(),
        response.fileId(),
        response.fileUrl(),
        response.replyToMessageId(),
        MessageStatus.DELIVERED,
        response.createdAt()
    );
    realtimeMessageService.deliverMessage(recipientId, delivered);
    saved.setStatus(MessageStatus.DELIVERED);
    messageRepository.save(saved);

    chatEventPublisher.publishMessageSent(new ChatMessageSentEvent(
        saved.getId(),
        saved.getConversationId(),
        saved.getSenderId(),
        recipientId,
        previewText(saved),
        saved.getMessageType(),
        saved.getStatus(),
        saved.getCreatedAt()
    ));
    return response;
  }

  private MessageResponse markReadInternal(Message message, UUID userId) {
    accessService.requireParticipantConversation(message.getConversationId(), userId);
    if (message.getSenderId().equals(userId)) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Sender cannot mark their own message as read");
    }
    if (message.getStatus() == MessageStatus.READ) {
      return chatMapper.toMessageResponse(message);
    }

    message.setStatus(MessageStatus.READ);
    Message saved = messageRepository.save(message);
    OffsetDateTime readAt = OffsetDateTime.now(ZoneOffset.UTC);

    realtimeMessageService.deliverReadReceipt(
        message.getSenderId(),
        StompReadReceiptPayload.from(
            message.getConversationId(),
            message.getId(),
            userId,
            readAt
        )
    );
    return chatMapper.toMessageResponse(saved);
  }

  private void validateMessageContent(SendMessageRequest request, MessageType messageType) {
    if (messageType == MessageType.TEXT && !StringUtils.hasText(request.text())) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "text is required for TEXT messages");
    }
    if (messageType != MessageType.TEXT && request.fileId() == null) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "file_id is required for media messages");
    }
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
